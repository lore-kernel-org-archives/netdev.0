From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Compat-wireless for 2.6.35 final - 802.11, Bluetooth, Ethernet
	backported
Date: Wed, 4 Aug 2010 14:50:38 -0700
Message-ID: <AANLkTikicFU2M=G9EoexmqvH5cGiD2ir7P=OQ+Mm2hAx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linus released 2.6.35 so we get our respective compat-wireless-2.6.35
released which backports the kernel's 802.11, Bluetooth and some
Ethernet drivers down to kernels >= 2.6.27. Goal is to always backport
all drivers down to the oldest supported 2.6. kenrel release listed on
kernel.org. Some drivers are backported to even further older kernels
(ath9k should go down to 2.6.23), to enable only one driver use the
./scripts/driver-select script.  You can get compat-wireless-2.6.35
from:

http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.35/compat-wireless-2.6.35-0.tar.bz2
sha1sum: a718b6377136560894e7919304d0cf7a5106815b

compat-wireless code metrics

    491756 - Total lines of upstream code being pulled
      1394 - backport code changes
      1163 - backport code additions
       231 - backport code deletions
      5737 - backport from compat module
      7131 - total lines of backport code
      1.45 - % of code consists of backport work

Base tree: linux-2.6-allstable.git
Base tree version: v2.6.35
compat-wireless release: compat-wireless-v2.6.35-0

Since we can have extra fixes within compat.git / compat-wireless.git
for stable releases in between stable kernel extra version updates I'm
started to rely on -release_number tag postfixes to the release tag.
So this release has the -0 release number, if we get a new fix/update
on this package before 2.6.35.1 we'll have compat-wireless-2.6.35-1,
and so on.

Changes that went into the Linux kernel for this release:

http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.35/ChangeLog-2.6.35-wireless

This comes from:

git log v2.6.34..HEAD \
        net/wireless/ \
        net/mac80211/ \
        net/rfkill/ \
        drivers/net/wireless/ \
        net/bluetooth/ \
        drivers/net/atl1c/ \
        drivers/net/atl1e/ \
        drivers/net/atlx/ \
        drivers/bluetooth/ \
        include/linux/nl80211.h \
        include/linux/rfkill.h \
        include/net/cfg80211.h \
        include/net/regulatory.h \
        include/net/cfg80211.h

For more information see:

http://wireless.kernel.org/en/users/Download/stable

compat-wireless makes use of the compat.git tree which provides a
generic Linux kernel compatibility module which besides providing
generic kernel helpers also backports the new rfkill, pm-qos and
firmware_class stuff. The updates from compat since the 2.6.34 kernel
release are:

Hauke Mehrtens (7):
      compat: backport eth_change_mtu and eth_validate_addr
      compat: move kparam_{block,unblock}_sysfs_write
      compat: move usb_{alloc,free}_coherent
      compat: update bitops.h and wireless.h
      compat: move kparam_{block,unblock}_sysfs_write
      compat: backport small functions and defines
      compat: use kernel pm_qos_params.h

Luis R. Rodriguez (11):
      compat: add new way to backport the usage of net_device_ops
      compat: add the rest of the missing netdev_attach_ops()
      compat: add the ndo_select_queue for netdev_attach_ops()
      compat: add compat_version read-only module parameter
      Modify the compat print
      Add the COMPAT_BASE_TREE and COMPAT_BASE_TREE_VERSION
      Add a COMPAT_PROJECT tag
      Fix the syntax for the defines passed for compat
      Remove the stupid SET_NETDEVOP
      compat: create the udev directories for compat_firmware file
      compat: backport USHRT_MAX, SHRT_MAX and SHRT_MIN

Rajkumar Manoharan (1):
      compat: Fix panic caused by NULL pointer derefence in rtnl_fill_ifinfo

compat-wireless changes since the compat-wireless-2.6.34 release are:

Bruno Randolf (1):
      compat-wireless: fix 07-change-default-rate-alg.patch

Hauke Mehrtens (23):
      compat-wireless: rename {free,alloc}_ieee80211 to {free,alloc}_libipw
      compat-wireless: fix building of iwmc3200wifi
      compat-wireless: remove some uneeded header files
      compat-wireless: update config symbols
      compat-wireless: add orinoco to compat-wireless
      compat-wireless: remove rename {free,alloc}_ieee80211 patch
      compat-wireless: refresh patch to apply again
      compat-wireless: Backport changes in pcmcia system
      compat-wireless: fix use of device_create
      compat-wireless: use wireless_handlers for wext functions.
      compat-wireless: backport convert multicast list to list_head.
      compat-wireless: Remove use of sdio quirks attribute
      compat-wireless: include net and trace includes form compat.
      compat-wireless: refresh patches
      compat-wireless: updates for orinoco
      compat-wireless: backport pm_qos_{add,remove,update}_request
      compat-wireless: make patches apply again
      Revert "compat-wireless: fix 07-change-default-rate-alg.patch"
      compat-wireless: Update Readme to reflect changes
      compat-wireless: update clean scripts
      compat-wireless: use /etc/init.d/ and not sudo service
      compat-wireless: run refresh only on last applied directory
      compat-wireless: fix build of ath5k for CONFIG_PM_SLEEP=n

Luis R. Rodriguez (77):
      ./scripts/admin-update.sh  refresh
      ./scripts/admin-update.sh refres
      admin-update refresh the patches
      driver-select: enable listing of ath9k_htc
      driver-select: fix selecting ath9k_htc
      admin-update refresh
      Fix patches/06-header-changes.patch
      Fix patches/13-trace.patch
      admin-update refresh
      admin-update refresh
      admin-update refresh
      Update USB makefile for new driver ipheth.o
      ./scripts/admin-update.sh refresh
      compat-wireless: make use of new netdev_attach_ops() for orinoco
      scripts/admin-update.sh refresh
      Make rndis_host use netdev_attach_ops()
      usbnet: use netdev_attach_ops()
      rndis_wlan: fix backport of netdev_attach_ops() usage
      rndis_wlan: use netdev_attach_ops()
      mac80211: use netdev_attach_ops()
      admin-update refresh
      b44: use netdev_attach_ops()
      ipw2100: use netdev_attach_ops()
      ipw2200: use netdev_attach_ops()
      libertas: use netdev_attach_ops()
      mac80211_hwsim: use netdevice_attach_ops()
      bnep, atl1e, atl1c: use netdev_attach_ops()
      atl1: use netdev_attach_ops()
      atl2: use netdev_attach_ops()
      ./scripts/admin-update.sh refresh
      ./scripts/admin-update.sh refresh
      Change admin-update.sh to use system version files
      Remove double line on admin-update.sh
      Split up the NOSTDINC_FLAGS into a few lines
      Use the defines to tag the compat module
      Fix dependency on on WEXT
      Fix the CREL compat-wireless release name on top level Makefile
      Fix gen-compat-autoconf.sh for new version name changes
      Fix scripts/driver-select due to new version changes
      Add the compat to the unload of the modules
      compat-wireless: add linux-next-pending, crap patch dirs and nagometer
      rm -rf drivers when running scripts/admin-update.sh
      compat-wireless: add a set of pending patches for linux-wireless
      compat-wireless: add the Kconfig for drivers
      compat-wireless: add some Atheros crap patches
      compat-wireless: run ./scripts/compat_firmware_install
      compat-wireless: remove some new files upon make clean
      compat-wireless: add the new versioning files to .gitignore
      Revert "compat-wireless: run ./scripts/compat_firmware_install"
      compat-wireless: remove pending patches as of next-20100525
      compat-wireless: ./scripts/admin-update.sh refresh
      compat-wireless: fix backport code calculation
      compat-wireless: only copy existing Kconfig files
      compat-wireless: ./scripts/admin-update.sh -p refresh
      compat-wireless: fix typo for used color for nagometer
      compat-wireless: add new set of pending patches for 2010-05-25
      compat-wireless: update the atheros crap patches
      compat-wireless: clarify usage of linux-next-cherry-pick for bleeding edge
      compat-wireless: remove two pending patches now upstream
      compat-wireless: add pending fix patch for ath9k
      compat-wireless: fixes offsets for
07-change-default-rate-alg.patch for 2.6.35-rc1
      ./scripts/admin-update.sh  refresh
      compat-wireless: fix hunks for crap/0002-ath9k-Add-pktlog-support.patch
      compat-wireless: accept extra arguments for scripts/gen-stable-release.sh
      Remove sucked in patch post 2.6.35-rc1
      compat-wireless: add -n -p -c support for gen-stable-release.sh
      compat-wireless: optimize branch selection on gen-stable-release.sh
      compat-wireless: update the usage() print for gen-stable-release.sh
      compat-wireless: fix target kernel expecations on gen-stable-release.sh
      compat-wireless: Drop all the linux-next-pending patches
      compat-wireless: remove the crap patches
      compat-wireless: refresh hunks for 2.6.35-rc2
      compat-wireless: refresh hunks for 2.6.35-rc2 as of June 11 2010
      compat-wireless: fix patch patches/25-multicast-list_head.patch
for BT bnet
      compat-wireless: ./scripts/admin-update.sh refresh
      compta-wireless: update unload script
      compat-wireless: refresh patches for 2.6.36-rc6
Paul Fertser (1):
      compat-wireless: driver-select: add b43 to the list

Pavel Roskin (9):
      compat-wireless: disable rt2800 if crc_ccitt is not available
      compat-wireless: disable wl1251 SPI and wl1271 if crc7 is not available
      compat-wireless: add support for ath9k_htc
      compat-wireless: update 22-multiqueue.patch for the current linux-next
      compat-wireless: remove patch part dealing with net/net_namespace.h
      compat-wireless: remove 13-trace.patch, it's handled in compat now
      compat-wireless: remove 25-device_create.patch, it's handled by compat
      compat-wireless: find the actual remote URL
      compat-wireless: fix fallbacks for unknown branch, remote or remote URL

Walter Goldens (2):
      compat-wireless, unload rt2800usb
      compat-wireless: rt2x00 added to driver-select

Thanks to the contributors!

  Luis
