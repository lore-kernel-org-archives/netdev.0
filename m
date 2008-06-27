From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-06-27
Date: Fri, 27 Jun 2008 11:35:41 -0400
Message-ID: <20080627153541.GA16597@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another batch intended for 2.6.27.  It includes the RF Kill
rework that has been pending for a while now, some more cleanups from
Harvey Harrison, an rt2x00 update, and a smattering of bug fixes.  Also
included is a WEXT series that you should find familiar.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit e35c3269edba151e1c703d87068a28ce2cd65bb0:
  Eilon Greenstein (1):
        bnx2x: Update version

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Adrian Bunk (1):
      remove the strip driver

Assaf Krauss (2):
      mac80211: 11h Infrastructure - Parsing
      mac80211: 11h - Handling measurement request

Bob Copeland (1):
      ath5k: convert LED code to use mac80211 triggers

David S. Miller (12):
      wext: Remove inline from get_priv_size() and adjust_priv_size().
      wext: Make adjust_priv_size() take a "struct iw_point *".
      wext: Extract standard call iw_point handling into seperate function.
      wext: Extract private call iw_point handling into seperate functions.
      wext: Pull ioctl permission checking out into helper function.
      wext: Parameterize the standard/private handlers.
      wext: Pass iwreq pointer down into standard/private handlers.
      wext: Pull top-level ioctl dispatch logic into helper function.
      wext: Dispatch and handle compat ioctls entirely in net/wireless/wext.c
      wext: Remove compat handling from fs/compat_ioctl.c
      wext: Create IW_REQUEST_FLAG_COMPAT and set it as needed.
      wext: Emit event stream entries correctly when compat.

Emmanuel Grumbach (2):
      mac80211: don't return -EINVAL upon iwconfig wlan0 rts auto
      mac80211: update the authentication method

Fabien Crespel (1):
      rfkill: drop current_state from tasks in rfkill-input

Gertjan van Wingerde (4):
      rt2x00: Properly clean up beacon skbs.
      rt2x00: Convert rt2x00 to use generic DMA-mapping API
      rt2x00: Centralize allocation of RX skbs.
      rt2x00: Replace statically allocated DMA buffers with mapped skb's.

Harvey Harrison (9):
      ath5k: use frame control helpers
      zd1211rw: use frame control helpers
      b43: use frame control helpers
      b43legacy: use frame control helpers
      adm8211: remove unnecessary protected bit mask/check
      mac80211: wep.c use new frame control helpers
      mac80211: tx.c use new frame control helpers
      mac80211: rx.c use new frame control helpers
      mac80211: mlme.c use new frame control helpers

Henrique de Moraes Holschuh (14):
      rfkill: clarify meaning of rfkill states
      rfkill: fix minor typo in kernel doc
      rfkill: handle SW_RFKILL_ALL events
      rfkill: add parameter to disable radios by default
      rfkill: add read-write rfkill switch support
      rfkill: add the WWAN radio type
      rfkill: rework suspend and resume handlers
      rfkill: add notifier chains support
      rfkill: add type string helper
      rfkill: add uevent notifications
      rfkill: do not allow userspace to override ALL RADIOS OFF
      rfkill: document rw rfkill switches and clarify input subsystem interactions
      rfkill: rename the rfkill_state states and add block-locked state
      rfkill: improve documentation for kernel drivers

Ivo van Doorn (8):
      rt2x00: Use ieee80211 fc handlers
      rt2x00: Cleanup symbol exports
      rt2x00: Fix sparse warning on nested container_of()
      rt2x00: Increase queue size
      rt2x00: Release rt2x00 2.1.8
      rt2x00: Remove duplicate deinitialization
      rt2x00: kill URB for all TX queues during disable_radio()
      mac80211: Add RTNL warning for workqueue

Johannes Berg (6):
      mac80211: remove shared key todo
      mac80211: use separate spinlock for sta flags
      mac80211: add single function calling tx handlers
      mac80211: rename TKIP debugging Kconfig symbol
      mac80211: make workqueue freezable
      mac80211: fix tx fragmentation

John W. Linville (3):
      Merge master.kernel.org:/.../davem/wireless-2.6
      ath5k: remove now unused variable declared in ath5k_tx
      wireless: remove RFKILL_STATE_HARD_BLOCKED warnings

Luis R. Rodriguez (1):
      mac80211: Let drivers have access to TKIP key offets for TX and RX MIC

Michael Buesch (8):
      b43: Add debugfs files for MMIO register access
      b43: Add debugfs files for random SHM access
      b43: Add mask/set capability to debugfs MMIO interface
      b43: Remove "shm" and "ucode_regs" debugfs files
      ssb, b43, b43legacy, b44: Rewrite SSB DMA API
      b43: Add simple firmware watchdog
      b43: Add debugfs firmware debugging knob
      b43: Fix PIO skb clobber

Pavel Machek (1):
      wireless: Small cleanups

Randy Dunlap (1):
      iwlwifi: fix build for CONFIG_INPUT=n

Stephen Rothwell (1):
      wireless: fix fallout from device_create removal

Tomas Winkler (1):
      mac80211: add phy information to giwname

 Documentation/rfkill.txt                   |  547 +++++-
 MAINTAINERS                                |    4 -
 drivers/net/b44.c                          |  140 +-
 drivers/net/ps3_gelic_wireless.c           |   30 +-
 drivers/net/wireless/Kconfig               |   24 -
 drivers/net/wireless/Makefile              |    1 -
 drivers/net/wireless/adm8211.c             |    9 +-
 drivers/net/wireless/airo.c                |   84 +-
 drivers/net/wireless/ath5k/Kconfig         |    3 +
 drivers/net/wireless/ath5k/base.c          |  263 ++--
 drivers/net/wireless/ath5k/base.h          |   32 +-
 drivers/net/wireless/ath5k/hw.c            |    4 +-
 drivers/net/wireless/atmel.c               |   24 +-
 drivers/net/wireless/b43/b43.h             |    2 +
 drivers/net/wireless/b43/debugfs.c         |  359 ++++-
 drivers/net/wireless/b43/debugfs.h         |   23 +-
 drivers/net/wireless/b43/dma.c             |   65 +-
 drivers/net/wireless/b43/main.c            |   86 +-
 drivers/net/wireless/b43/main.h            |    4 +
 drivers/net/wireless/b43/pio.c             |    2 +-
 drivers/net/wireless/b43/rfkill.c          |    7 +-
 drivers/net/wireless/b43/xmit.c            |   17 +-
 drivers/net/wireless/b43legacy/dma.c       |   63 +-
 drivers/net/wireless/b43legacy/rfkill.c    |    8 +-
 drivers/net/wireless/b43legacy/xmit.c      |   16 +-
 drivers/net/wireless/hostap/hostap.h       |    3 +-
 drivers/net/wireless/hostap/hostap_ap.c    |   32 +-
 drivers/net/wireless/hostap/hostap_ioctl.c |   58 +-
 drivers/net/wireless/iwlwifi/Kconfig       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c  |   18 +-
 drivers/net/wireless/libertas/scan.c       |   36 +-
 drivers/net/wireless/mac80211_hwsim.c      |    7 +-
 drivers/net/wireless/orinoco.c             |   30 +-
 drivers/net/wireless/prism54/isl_ioctl.c   |   49 +-
 drivers/net/wireless/rndis_wlan.c          |   32 +-
 drivers/net/wireless/rt2x00/rt2400pci.c    |   17 +-
 drivers/net/wireless/rt2x00/rt2500pci.c    |   14 +-
 drivers/net/wireless/rt2x00/rt2500usb.c    |    4 +-
 drivers/net/wireless/rt2x00/rt2x00.h       |   59 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c    |  100 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h    |   51 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c    |  126 +--
 drivers/net/wireless/rt2x00/rt2x00pci.h    |   12 -
 drivers/net/wireless/rt2x00/rt2x00queue.c  |  141 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.h  |   35 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c |    7 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c    |  103 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h    |    6 +
 drivers/net/wireless/rt2x00/rt61pci.c      |   23 +-
 drivers/net/wireless/rt2x00/rt73usb.c      |    8 +-
 drivers/net/wireless/strip.c               | 2804 ----------------------------
 drivers/net/wireless/wl3501_cs.c           |   10 +-
 drivers/net/wireless/zd1201.c              |   21 +-
 drivers/net/wireless/zd1211rw/zd_mac.c     |   22 +-
 drivers/ssb/Kconfig                        |    2 +-
 drivers/ssb/main.c                         |   75 +-
 fs/compat_ioctl.c                          |  113 +--
 include/linux/ieee80211.h                  |   64 +-
 include/linux/nl80211.h                    |    5 +-
 include/linux/rfkill.h                     |   46 +-
 include/linux/ssb/ssb.h                    |  143 ++-
 include/linux/wireless.h                   |   28 +
 include/net/iw_handler.h                   |  151 +-
 include/net/mac80211.h                     |   14 +-
 include/net/wext.h                         |    7 +
 net/ieee80211/ieee80211_wx.c               |   48 +-
 net/mac80211/Kconfig                       |    2 +-
 net/mac80211/ieee80211_i.h                 |   14 +-
 net/mac80211/key.h                         |   37 +-
 net/mac80211/main.c                        |    2 +-
 net/mac80211/mlme.c                        |  207 ++-
 net/mac80211/rx.c                          |    7 +-
 net/mac80211/sta_info.c                    |    1 +
 net/mac80211/sta_info.h                    |   40 +-
 net/mac80211/tkip.c                        |   30 +-
 net/mac80211/tx.c                          |  204 +-
 net/mac80211/wep.c                         |   39 +-
 net/mac80211/wext.c                        |   50 +-
 net/mac80211/wpa.c                         |   20 +-
 net/rfkill/rfkill-input.c                  |   98 +-
 net/rfkill/rfkill-input.h                  |    1 +
 net/rfkill/rfkill.c                        |  304 +++-
 net/socket.c                               |   10 +
 net/wireless/wext.c                        |  582 ++++---
 84 files changed, 3384 insertions(+), 4607 deletions(-)
 delete mode 100644 drivers/net/wireless/strip.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-06-27.patch.bz2
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
