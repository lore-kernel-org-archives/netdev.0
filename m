From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-06-04
Date: Thu, 4 Jun 2009 11:20:11 -0400
Message-ID: <20090604152011.GC2839@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49007 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbZFDPad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 11:30:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Hopefully this is (almost?) the last wireless pull request for
non-bugfix patches intended for 2.6.31...

Included are the usual round of driver updates, mac80211 updates, etc.
Also included is the long-awaited and slightly controversial rfkill
rewrite.  The userland guys (i.e. Dan and Marcel) are happy with it,
and it can clean-up a lot of driver code for wireless.  Henrique has
some lingering concerns about some corner cases for platform drivers,
but I think they are relatively minor and will be resolved amicably
soon.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 047584ce94108012288554a5f84585d792cc7f8f:
  Haiying Wang (1):
        net/ucc_geth: Add SGMII support for UEC GETH driver

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (2):
      iwl3945: port allow skb allocation in tasklet patch
      iwl3945/iwlwifi: fix led bug when SW rfkill

Bing Zhao (1):
      libertas: improve function init/shutdown handling for SD8688

Bob Copeland (3):
      ath5k: remove conf->beacon_int usage
      nl80211: use GFP_ATOMIC for michael mic failure message
      ath5k: disable beacon interrupt when interface is down

Christian Lamparter (11):
      ar9170: fix beacon plcp settings
      ar9170: update hardware definitions
      ar9170: 40mhz fixes
      ar9170: introduce functions for MAC programming
      ar9170: use bitop macros for tx filter flags
      ar9170: kill duplicated HT feature flag
      ar9170: fix LED power state handling
      ar9170: fix lockdep warning on hibernate
      ar9170usb: more minor fixes
      ar9170: cancel led worker properly on exit
      ar9170: remove deprecated code

Cliff Cai (1):
      wireless: libertas: fix unaligned accesses

Dan Williams (5):
      libertas: simplify and clean up association/start/join setup
      libertas: restyle Marvell & IEEE TLV structure names
      libertas: convert CMD_802_11_AUTHENTICATE to a direct command
      libertas: convert CMD_802_11_ASSOCIATE to a direct command
      libertas: fix WPA adhoc network creation

Ivo van Doorn (2):
      rt2x00: Add new rt2800usb USB ID's
      rt2x00: Remove last usage of beacon_int from ieee80211_config

Jeff Hansen (3):
      ath9k: Reset SC_OP_TSF_RESET flag after stuck beacon
      ath9k: Combine legacy and 11n rc statistics
      ath9k: Add "debug" file to debugfs

Johannes Berg (18):
      mac80211: deprecate conf.beacon_int properly
      cfg80211: validate AID of stations being added
      nl80211: bounce scan request back to userspace
      cfg80211: use key size constants
      mac80211: fix transposed min/max CW values
      cfg80211: disallow interfering with stations on non-AP (part 2)
      net: introduce pre-up netdev notifier
      mac80211_hwsim: remove deprecated radio_enabled
      rfkill: rewrite
      rfkill: create useful userspace interface
      cfg80211: move txpower wext from mac80211
      rfkill: add function to query state
      cfg80211: add rfkill support
      iwm: port to new cfg80211 rfkill
      rfkill: always init poll delayed work
      rfkill: document /dev/rfkill
      cfg80211: fix Kconfig for users of cfg80211
      wimax: depend on rfkill properly

John W. Linville (1):
      ath5k: avoid leaking mutex in ath5k_config

Jouni Malinen (1):
      ath9k: Add sanity check for beacon_int in adhoc/mesh case

Luis R. Rodriguez (8):
      mac80211: handle -EALREADY on cfg80211 op assoc req
      ar9170: add support for 1-stage firmware
      ar9170: add AVM FRITZ devices
      cfg80211: fix for duplicate userspace replies
      ath: make regulatory parsing more verbose on debug
      cfg80211: make ieee80211_get_mesh_hdrlen() static
      mac80211: extend sta kdoc - explain when they are added
      mac80211: removed unused variable in ieee80211_tx()

Mohamed Abbas (1):
      iwlagn: delay ict interrupt.

Rami Rosen (1):
      iwlwifi: avoid build warning in iwl-core.

Randy Dunlap (1):
      iwmc3200wifi: fix printk format

Reinette Chatre (3):
      iwlwifi: fix merge error
      iwlwifi: fix otp access init
      iwlwifi: fix comment describing disable_11n

Samuel Ortiz (3):
      iwmc3200wifi: fix fragmentation threshold setting
      iwmc3200wifi: shrink calibration lmac name
      wireless/p54: prepare for FIRMWARE_NAME_MAX removal

Sebastian Andrzej Siewior (1):
      net/libertas: make SPI interface big endian aware

Tomas Winkler (1):
      iwlwifi: unify station management

Vasanthakumar Thiagarajan (1):
      ath9k: Fix write callback of 'debug' which configures debug mask

Wey-Yi Guy (1):
      iwlwifi: add value and range define for link quality command

 Documentation/feature-removal-schedule.txt   |    7 +
 Documentation/rfkill.txt                     |  603 ++-----------
 MAINTAINERS                                  |    6 +-
 arch/arm/mach-pxa/tosa-bt.c                  |   30 +-
 arch/arm/mach-pxa/tosa.c                     |    1 -
 drivers/net/usb/hso.c                        |   42 +-
 drivers/net/wireless/Kconfig                 |    2 +-
 drivers/net/wireless/ath/ar9170/ar9170.h     |   10 +-
 drivers/net/wireless/ath/ar9170/hw.h         |    5 +-
 drivers/net/wireless/ath/ar9170/led.c        |   17 +-
 drivers/net/wireless/ath/ar9170/mac.c        |   55 ++-
 drivers/net/wireless/ath/ar9170/main.c       |   98 +-
 drivers/net/wireless/ath/ar9170/phy.c        |    6 +-
 drivers/net/wireless/ath/ar9170/usb.c        |   69 +-
 drivers/net/wireless/ath/ar9170/usb.h        |    2 +
 drivers/net/wireless/ath/ath5k/base.c        |   24 +-
 drivers/net/wireless/ath/ath9k/ath9k.h       |    7 +-
 drivers/net/wireless/ath/ath9k/beacon.c      |    9 +
 drivers/net/wireless/ath/ath9k/debug.c       |  155 ++--
 drivers/net/wireless/ath/ath9k/debug.h       |   10 +-
 drivers/net/wireless/ath/ath9k/main.c        |  115 +--
 drivers/net/wireless/ath/ath9k/pci.c         |   15 -
 drivers/net/wireless/ath/regd.c              |   29 +-
 drivers/net/wireless/b43/Kconfig             |    2 +-
 drivers/net/wireless/b43/leds.c              |    2 +-
 drivers/net/wireless/b43/main.c              |    4 +-
 drivers/net/wireless/b43/phy_a.c             |    4 +-
 drivers/net/wireless/b43/phy_common.c        |   17 +-
 drivers/net/wireless/b43/phy_common.h        |    4 +-
 drivers/net/wireless/b43/phy_g.c             |    4 +-
 drivers/net/wireless/b43/phy_lp.c            |    2 +-
 drivers/net/wireless/b43/phy_n.c             |    2 +-
 drivers/net/wireless/b43/rfkill.c            |  123 +--
 drivers/net/wireless/b43/rfkill.h            |    5 +-
 drivers/net/wireless/b43legacy/Kconfig       |    2 +-
 drivers/net/wireless/b43legacy/leds.c        |    3 +-
 drivers/net/wireless/b43legacy/rfkill.c      |  123 +--
 drivers/net/wireless/b43legacy/rfkill.h      |    6 +-
 drivers/net/wireless/iwlwifi/Kconfig         |    5 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c  |    4 -
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c   |    9 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |   73 +--
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    6 -
 drivers/net/wireless/iwlwifi/iwl-4965.c      |    8 -
 drivers/net/wireless/iwlwifi/iwl-5000.c      |   16 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |   22 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |   17 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   14 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |   14 +-
 drivers/net/wireless/iwlwifi/iwl-core.h      |   12 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |    9 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |   12 +-
 drivers/net/wireless/iwlwifi/iwl-led.c       |    4 -
 drivers/net/wireless/iwlwifi/iwl-rfkill.c    |   69 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c       |   56 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h       |    7 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |  228 ++----
 drivers/net/wireless/iwmc3200wifi/Kconfig    |    3 +-
 drivers/net/wireless/iwmc3200wifi/Makefile   |    2 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |    2 +-
 drivers/net/wireless/iwmc3200wifi/fw.c       |    2 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h      |    4 -
 drivers/net/wireless/iwmc3200wifi/netdev.c   |   10 -
 drivers/net/wireless/iwmc3200wifi/rfkill.c   |   88 --
 drivers/net/wireless/iwmc3200wifi/sdio.c     |    2 +-
 drivers/net/wireless/libertas/11d.c          |   26 +-
 drivers/net/wireless/libertas/11d.h          |   29 +-
 drivers/net/wireless/libertas/assoc.c        |  758 ++++++++--------
 drivers/net/wireless/libertas/assoc.h        |   13 -
 drivers/net/wireless/libertas/cmd.c          |   16 +-
 drivers/net/wireless/libertas/cmdresp.c      |   17 +-
 drivers/net/wireless/libertas/debugfs.c      |    8 +-
 drivers/net/wireless/libertas/dev.h          |   10 +-
 drivers/net/wireless/libertas/hostcmd.h      |   41 +-
 drivers/net/wireless/libertas/if_sdio.c      |   76 +-
 drivers/net/wireless/libertas/if_spi.c       |   34 +-
 drivers/net/wireless/libertas/main.c         |   20 -
 drivers/net/wireless/libertas/scan.c         |   63 +-
 drivers/net/wireless/libertas/types.h        |  150 ++--
 drivers/net/wireless/mac80211_hwsim.c        |   27 +-
 drivers/net/wireless/p54/p54usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c      |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c      |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c      |    2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c      |   12 +
 drivers/net/wireless/rt2x00/rt2x00.h         |    5 +
 drivers/net/wireless/rt2x00/rt2x00config.c   |    3 +
 drivers/net/wireless/rt2x00/rt61pci.c        |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c        |    2 +-
 drivers/platform/x86/Kconfig                 |   14 +-
 drivers/platform/x86/acer-wmi.c              |   50 +-
 drivers/platform/x86/dell-laptop.c           |  101 +--
 drivers/platform/x86/eeepc-laptop.c          |   99 +--
 drivers/platform/x86/hp-wmi.c                |  103 ++--
 drivers/platform/x86/sony-laptop.c           |  191 ++---
 drivers/platform/x86/thinkpad_acpi.c         |  873 ++++++++++---------
 drivers/platform/x86/toshiba_acpi.c          |  159 +---
 include/asm-generic/errno.h                  |    2 +
 include/linux/Kbuild                         |    1 +
 include/linux/ieee80211.h                    |    1 +
 include/linux/notifier.h                     |    1 +
 include/linux/rfkill.h                       |  381 +++++++--
 include/net/cfg80211.h                       |   51 ++
 include/net/mac80211.h                       |   26 +-
 include/net/wimax.h                          |    8 +-
 net/core/dev.c                               |    7 +-
 net/mac80211/Kconfig                         |    5 +-
 net/mac80211/cfg.c                           |   65 ++-
 net/mac80211/driver-ops.h                    |    7 +
 net/mac80211/iface.c                         |    4 +-
 net/mac80211/main.c                          |   12 +-
 net/mac80211/sta_info.c                      |    9 +
 net/mac80211/tx.c                            |    2 -
 net/mac80211/util.c                          |   10 +-
 net/mac80211/wext.c                          |   80 +--
 net/rfkill/Kconfig                           |   21 +-
 net/rfkill/Makefile                          |    5 +-
 net/rfkill/core.c                            | 1228 ++++++++++++++++++++++++++
 net/rfkill/input.c                           |  342 +++++++
 net/rfkill/rfkill-input.c                    |  390 --------
 net/rfkill/rfkill.c                          |  855 ------------------
 net/rfkill/{rfkill-input.h => rfkill.h}      |   10 +-
 net/wimax/Kconfig                            |   15 +-
 net/wimax/op-rfkill.c                        |  123 +--
 net/wireless/Kconfig                         |    3 +-
 net/wireless/core.c                          |   97 ++-
 net/wireless/core.h                          |    7 +
 net/wireless/nl80211.c                       |   57 +-
 net/wireless/reg.c                           |    8 +-
 net/wireless/scan.c                          |    3 +-
 net/wireless/util.c                          |   13 +-
 net/wireless/wext-compat.c                   |   83 ++
 133 files changed, 4465 insertions(+), 4698 deletions(-)
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/rfkill.c
 create mode 100644 net/rfkill/core.c
 create mode 100644 net/rfkill/input.c
 delete mode 100644 net/rfkill/rfkill-input.c
 delete mode 100644 net/rfkill/rfkill.c
 rename net/rfkill/{rfkill-input.h => rfkill.h} (60%)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-06-04.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
