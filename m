From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-07-08
Date: Tue, 8 Jul 2008 14:51:46 -0400
Message-ID: <20080708185146.GA30833@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Yet another round of patches intended for 2.6.27.  Included a few random
fixes for stuff already in -next, several rt2x00 updates, some mac80211
cleanups from Harvey Harrison, and a patch series to add rtl8187b
support to the rtl8187 driver.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 9bb8582efb555521c7eec595ebd34e835ddc34b8:
  Patrick McHardy (1):
        vlan: TCI related type and naming cleanups

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Adel Gadllah (1):
      iwlwifi: remove input device and fix rfkill state

Daniel Drake (1):
      zd1211rw: beacon config error checking

Emmanuel Grumbach (1):
      mac80211: add support for iwconfig wlanX frag auto

Harvey Harrison (8):
      mac80211: move QOS control helpers into ieee80211.h
      mac80211: use symbolic defines in wpa.c
      mac80211: remove one user of ieee80211_get_hdr_info
      mac80211: remove ieee80211_get_hdr_info
      mac80211: remove trivial rx_data->fc users
      mac80211: wpa.c remove rx/tx_data ->fc users
      mac80211: pass scratch buffer directly, remove additional pointers
      mac80211: aes_ccm.c remove crypto wrapper and extra args

Helmut Schaa (1):
      iwlwifi: fix typo which caused iwl_get_tx_fail_reason to ever return an empty string

Henrique de Moraes Holschuh (2):
      rfkill: some minor kernel-doc changes for rfkill_toggle_radio
      rfkill: ignore errors from rfkill_toggle_radio in rfkill_add_switch

Hin-Tak Leung (6):
      rtl8187: updating rtl8187.h to support RTL8187B
      rtl8187: updating rtl818x.h to support RTL8187B
      rtl8187: updating rtl8187_rtl8225.c to support RTL8187B
      rtl8187: change rtl8187_dev.c to support RTL8187B (part 1)
      rtl8187: change rtl8187_dev.c to support RTL8187B (part 2)
      rtl8187: updating Kconfig to support RTL8187B

Ivo van Doorn (6):
      mac80211: Don't request encryption for probe response
      rt2x00: Remove input_polldev requirements for rfkill
      rt2x00: Decrease alignment headroom
      rt2x00: Use ieee80211_hw->workqueue again
      rt2x00: Report RX end time for rt2400pci
      rt2x00: Fix register comments

Julius Volz (1):
      net/wireless/nl80211.c: fix endless Netlink callback loop.

Larry Finger (2):
      b43legacy: Remove switch statement with 64-bit index
      rtl8187: Change detection of RTL8187B with USB ID of 8187

Pavel Roskin (1):
      hostap: don't compile prism2_suspend() for hostap_pci without CONFIG_PM

Rami Rosen (1):
      mac80211: remove MAC80211_DEBUG from net/mac80211/Kconfig.

Randy Dunlap (1):
      mac80211: fix lots of kernel-doc

Ron Rindjunsky (2):
      mac80211: add block ack request capability
      iwlwifi: request Tx of block ack request if necessary

Tomas Winkler (4):
      iwlwifi: fix error path of iwl_rfkill_init
      mac80211: remove useless tid assignment for management and control frames
      mac80211: fix warning: unused variable ifsta
      mac80211: call bss_info_change only once upon disassociation

 drivers/net/wireless/Kconfig                |   12 +-
 drivers/net/wireless/b43legacy/dma.c        |   66 +++-
 drivers/net/wireless/hostap/hostap_hw.c     |    4 +-
 drivers/net/wireless/iwlwifi/Kconfig        |    5 +
 drivers/net/wireless/iwlwifi/iwl-3945.h     |   11 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    6 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   13 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c   |   65 ++--
 drivers/net/wireless/iwlwifi/iwl-rfkill.h   |    3 -
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |  117 +++----
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    8 +-
 drivers/net/wireless/rt2x00/Kconfig         |    8 +-
 drivers/net/wireless/rt2x00/rt2400pci.c     |   23 ++
 drivers/net/wireless/rt2x00/rt2500pci.h     |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.h     |   40 ++-
 drivers/net/wireless/rt2x00/rt2x00.h        |    6 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |   20 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h     |   12 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c   |    7 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h   |    2 +
 drivers/net/wireless/rt2x00/rt2x00rfkill.c  |  107 ++----
 drivers/net/wireless/rtl8187.h              |  113 ++++++-
 drivers/net/wireless/rtl8187_dev.c          |  490 +++++++++++++++++++++++----
 drivers/net/wireless/rtl8187_rtl8225.c      |  229 ++++++++++++-
 drivers/net/wireless/rtl818x.h              |   36 ++-
 drivers/net/wireless/zd1211rw/zd_mac.c      |   62 +++-
 include/linux/ieee80211.h                   |    6 +
 include/net/mac80211.h                      |   43 ++-
 net/mac80211/Kconfig                        |    3 +-
 net/mac80211/aes_ccm.c                      |   51 ++--
 net/mac80211/aes_ccm.h                      |    4 +-
 net/mac80211/ieee80211_i.h                  |    3 +-
 net/mac80211/main.c                         |   33 ++-
 net/mac80211/michael.c                      |   20 +-
 net/mac80211/michael.h                      |    2 +-
 net/mac80211/mlme.c                         |   34 ++-
 net/mac80211/rx.c                           |  135 ++++----
 net/mac80211/sta_info.c                     |    1 +
 net/mac80211/sta_info.h                     |   81 ++++--
 net/mac80211/wext.c                         |    2 +
 net/mac80211/wme.c                          |    5 +-
 net/mac80211/wme.h                          |    8 -
 net/mac80211/wpa.c                          |  183 ++++------
 net/rfkill/rfkill.c                         |   22 +-
 net/wireless/nl80211.c                      |    6 +-
 49 files changed, 1449 insertions(+), 678 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-07-08.patch.bz2

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
