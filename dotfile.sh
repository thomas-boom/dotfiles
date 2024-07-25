#!/bin/bash

#dotfile for configuring new macOS install

#variables
dockutil=/usr/local/bin/dockutil
loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

install_rosetta(){
    softwareupdate --install-rosetta --agree-to-license
}

install_brew(){
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

check_dockutil(){
# Check for dockUtil and install if not found
  # Get the URL of the latest PKG From the dockUtil GitHub repo
  dialogURL=$(curl --silent --fail "https://api.github.com/repos/kcrawford/dockutil/releases/latest" | awk -F '"' "/browser_download_url/ && /pkg\"/ { print \$4; exit }")
  # Expected Team ID of the downloaded PKG
  expectedDialogTeamID="Z5J8CJBUWC"

  # Check for dockUtil and install if not found
  if [ ! -e "/usr/local/bin/dockutil" ]; then
    echo "dockUtil not found. Installing..."
    # Create temporary working directory
    workDirectory=$( /usr/bin/basename "$0" )
    tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )
    # Download the installer package
    /usr/bin/curl --location --silent "$dialogURL" -o "$tempDirectory/dockUtil.pkg"
    # Verify the download
    teamID=$(/usr/sbin/spctl -a -vv -t install "$tempDirectory/dockUtil.pkg" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()')
    # Install the package if Team ID validates
    if [ "$expectedDialogTeamID" = "$teamID" ] || [ "$expectedDialogTeamID" = "" ]; then
      sudo /usr/sbin/installer -pkg "$tempDirectory/dockUtil.pkg" -target /
      echo "dockUtil installed. Proceeding.."
    fi
    # Remove the temporary working directory when done
    /bin/rm -Rf "$tempDirectory"
  else echo "dockUtil found. Proceeding..."
  fi
}

run_finder(){
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder NewWindowTarget PfHm
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
}
brew_check_brewfile(){
    brew bundle
}

remove_dock(){
    #remove all items from Dock
    $dockutil --remove all /Users/"$loggedInUser"
    killall Dock
}

build_dock(){
    $dockutil --add "/System/Applications/System Settings.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Adobe Indesign 2024/Adobe Indesign 2024.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Adobe Dreamweaver 2021/Adobe Dreamweaver 2021.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Adobe Photoshop 2024/Adobe Photoshop 2024.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Mail.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Microsoft Outlook.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Arc.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Music.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Launchpad.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Passwords.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Warp.app" --no-restart /Users/"$loggedInUser"
    $dockutil --add "/System/Applications/Zed.app" --no-restart /Users/"$loggedInUser"
}

set_menubar(){
    defaults write com.apple.menuextra.battery ShowPercent -string "YES"
    defaults write com.apple.menuextra.clock "DateFormat" "EEE MMM d h:mm:ss"
    defaults write com.apple.menuextra.clock.plist ShowDayOfMonth -bool true
    defaults write com.apple.systemuiserver menuExtras -array-add Volume.menu
    defaults write com.apple.networkConnect VPNShowTime -string "1"
}

#run functions
install_rosetta
install_brew
check_dockutil
run_finder
set_menubar
brew_check_brewfile
remove_dock
kbuild_dock
