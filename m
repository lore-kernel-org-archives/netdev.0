From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6.26 2008-03-13
Date: Thu, 13 Mar 2008 21:26:16 -0400
Message-ID: <20080314012616.GB31964@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Here is another round of updates for 2.6.26.  Only 38 this week -- we
must be slowing-down. :-)

Along with the usual batch of driver updates there is also the
removal of the old bcm43xx driver, the (now unused) ieee80211softmac
component, and the old "simple" rate control algorithm for mac80211.
Other than that, there is nothing particularly remarkable.  FWIW,
the rt2x00 patches in particular fixed a lot of Fedora bugzillas...

Let me know if there are problems!

Thanks,

John

P.S.  The rt2x00 patch I just sent you in the wireless-2.6 tree will
conflict with your net-2.6.26 tree, and the resolution is not obvious
when looking at the change markers alone.  I created a "merge-sample"
branch in the wireless-2.6.26 tree to serve as a reference to show
you how I resolved the conflict.  Hth!

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26/

---

The following changes since commit ba73d4c84a7344f1b5635c2b4e96796e8c13a126:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6.26

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.26.git master

Adam Baker (1):
      rt2x00:correct rx packet length for USB devices

Adrian Bunk (4):
      make b43_mac_{enable,suspend}() static
      the scheduled bcm43xx removal
      the scheduled ieee80211 softmac removal
      the scheduled rc80211-simple.c removal

Assaf Krauss (1):
      iwlwifi: Use eeprom form iwlcore

Harvey Harrison (1):
      b43: pull out helpers for writing noise table

Holger Schurig (1):
      libertas: implement SSID scanning for SIOCSIWSCAN

Ivo van Doorn (16):
      rt2x00: Align RX descriptor to 4 bytes
      rt2x00: Don't use uninitialized desc_len
      rt2x00: Use skbdesc fields for descriptor initialization
      rt2x00: Only disable beaconing just before beacon update
      rt2x00: Upgrade queue->lock to use irqsave
      rt2x00: Move firmware checksumming to driver
      rt2x00: Start bugging when rt2x00lib doesn't filter SW diversity
      rt2x00: Check IEEE80211_TXCTL_SEND_AFTER_DTIM flag
      rt2x00: Rename config_preamble() to config_erp()
      rt2x00: Make rt2x00leds_register return void
      rt2x00: Always enable TSF ticking
      rt2x00: Fix basic rate initialization
      rt2x00: Fix RX DMA ring initialization
      rt2x00: Fix rt2400pci signal
      rt2x00: Release rt2x00 2.1.4
      rt2x00: Only strip preamble bit in rt2400pci

Joe Perches (2):
      drivers/net/wireless/ath5k - convert == (true|false) to simple logical tests
      include/net/ieee80211.h - remove duplicate include

Jussi Kivilinna (2):
      rndis_wlan: cleanup, rename and reorder enums and structures
      rndis_wlan: cleanup, rename structure members

Luis Correia (1):
      rt2x00: Fix trivial log message

Mattias Nissler (3):
      rt2x00: Initialize TX control field in data entries
      rt2x00: Use the correct size when copying the control info in txdone
      rt2x00: Don't use unitialized rxdesc->size

Michael Buesch (1):
      ssb: Add SPROM/invariants support for PCMCIA devices

Reinette Chatre (2):
      iwlwifi: update copyright year
      iwlwifi: fix bug to show hidden APs during scan

Tomas Winkler (3):
      iwlwifi: Use sta_bcast_id variable instead of BROADCAST_ID constant
      iwlwifi: Fix endianity in debug print
      iwlwifi: change rate number to a constant

 Documentation/feature-removal-schedule.txt       |   27 -
 Documentation/laptops/acer-wmi.txt               |    2 +-
 Documentation/networking/bcm43xx.txt             |   89 -
 MAINTAINERS                                      |   15 -
 drivers/net/wireless/Kconfig                     |    1 -
 drivers/net/wireless/Makefile                    |    1 -
 drivers/net/wireless/ath5k/hw.c                  |   36 +-
 drivers/net/wireless/ath5k/phy.c                 |   10 +-
 drivers/net/wireless/b43/main.c                  |    4 +-
 drivers/net/wireless/b43/main.h                  |    3 -
 drivers/net/wireless/b43/wa.c                    |   45 +-
 drivers/net/wireless/bcm43xx/Kconfig             |   70 -
 drivers/net/wireless/bcm43xx/Makefile            |   12 -
 drivers/net/wireless/bcm43xx/bcm43xx.h           |  997 -----
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c   |  556 ---
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h   |  118 -
 drivers/net/wireless/bcm43xx/bcm43xx_dma.c       | 1263 -------
 drivers/net/wireless/bcm43xx/bcm43xx_dma.h       |  386 --
 drivers/net/wireless/bcm43xx/bcm43xx_ethtool.c   |   50 -
 drivers/net/wireless/bcm43xx/bcm43xx_ethtool.h   |    8 -
 drivers/net/wireless/bcm43xx/bcm43xx_ilt.c       |  352 --
 drivers/net/wireless/bcm43xx/bcm43xx_ilt.h       |   33 -
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c      |  307 --
 drivers/net/wireless/bcm43xx/bcm43xx_leds.h      |   62 -
 drivers/net/wireless/bcm43xx/bcm43xx_main.c      | 4281 ----------------------
 drivers/net/wireless/bcm43xx/bcm43xx_main.h      |  133 -
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c       | 2346 ------------
 drivers/net/wireless/bcm43xx/bcm43xx_phy.h       |   78 -
 drivers/net/wireless/bcm43xx/bcm43xx_pio.c       |  674 ----
 drivers/net/wireless/bcm43xx/bcm43xx_pio.h       |  163 -
 drivers/net/wireless/bcm43xx/bcm43xx_power.c     |  393 --
 drivers/net/wireless/bcm43xx/bcm43xx_power.h     |   56 -
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c     | 2170 -----------
 drivers/net/wireless/bcm43xx/bcm43xx_radio.h     |  115 -
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c     |  471 ---
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.h     |    9 -
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c        | 1035 ------
 drivers/net/wireless/bcm43xx/bcm43xx_wx.h        |   36 -
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c      |  565 ---
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.h      |  150 -
 drivers/net/wireless/iwlwifi/Makefile            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-io.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965-debug.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       |  314 +--
 drivers/net/wireless/iwlwifi/iwl-4965-io.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c          |   55 +-
 drivers/net/wireless/iwlwifi/iwl-4965.h          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-core.h          |   10 +
 drivers/net/wireless/iwlwifi/iwl-csr.h           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |   25 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c      |  112 +-
 drivers/net/wireless/libertas/assoc.c            |    4 +-
 drivers/net/wireless/libertas/debugfs.c          |  169 -
 drivers/net/wireless/libertas/dev.h              |    2 +
 drivers/net/wireless/libertas/scan.c             |  145 +-
 drivers/net/wireless/libertas/scan.h             |   69 +-
 drivers/net/wireless/libertas/wext.c             |    3 +
 drivers/net/wireless/rndis_wlan.c                |  451 ++--
 drivers/net/wireless/rt2x00/Kconfig              |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |   70 +-
 drivers/net/wireless/rt2x00/rt2400pci.h          |    6 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |   71 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |   97 +-
 drivers/net/wireless/rt2x00/rt2x00.h             |   27 +-
 drivers/net/wireless/rt2x00/rt2x00config.c       |   62 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c        |    5 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c          |   58 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c     |   34 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c         |    7 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h          |   25 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |   22 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c          |    1 +
 drivers/net/wireless/rt2x00/rt2x00queue.c        |   17 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h        |    3 +
 drivers/net/wireless/rt2x00/rt2x00usb.c          |   19 +-
 drivers/net/wireless/rt2x00/rt61pci.c            |  100 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |  126 +-
 drivers/ssb/Kconfig                              |    6 +
 drivers/ssb/Makefile                             |    1 +
 drivers/ssb/main.c                               |   23 +-
 drivers/ssb/pci.c                                |  113 +-
 drivers/ssb/pcmcia.c                             |  518 +++-
 drivers/ssb/sprom.c                              |  133 +
 drivers/ssb/ssb_private.h                        |   17 +
 include/linux/ssb/ssb.h                          |    4 +-
 include/net/ieee80211.h                          |    1 -
 include/net/ieee80211softmac.h                   |  373 --
 include/net/ieee80211softmac_wx.h                |   99 -
 net/ieee80211/Kconfig                            |    1 -
 net/ieee80211/Makefile                           |    1 -
 net/ieee80211/softmac/Kconfig                    |   12 -
 net/ieee80211/softmac/Makefile                   |    9 -
 net/ieee80211/softmac/ieee80211softmac_assoc.c   |  489 ---
 net/ieee80211/softmac/ieee80211softmac_auth.c    |  413 ---
 net/ieee80211/softmac/ieee80211softmac_event.c   |  189 -
 net/ieee80211/softmac/ieee80211softmac_io.c      |  488 ---
 net/ieee80211/softmac/ieee80211softmac_module.c  |  568 ---
 net/ieee80211/softmac/ieee80211softmac_priv.h    |  244 --
 net/ieee80211/softmac/ieee80211softmac_scan.c    |  254 --
 net/ieee80211/softmac/ieee80211softmac_wx.c      |  508 ---
 net/mac80211/Kconfig                             |   19 -
 net/mac80211/Makefile                            |    2 -
 net/mac80211/ieee80211.c                         |    9 +-
 net/mac80211/ieee80211_rate.h                    |   15 -
 net/mac80211/rc80211_simple.c                    |  394 --
 119 files changed, 1493 insertions(+), 22703 deletions(-)
 delete mode 100644 Documentation/networking/bcm43xx.txt
 delete mode 100644 drivers/net/wireless/bcm43xx/Kconfig
 delete mode 100644 drivers/net/wireless/bcm43xx/Makefile
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_dma.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_dma.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_ethtool.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_ethtool.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_ilt.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_ilt.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_leds.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_leds.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_main.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_main.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_phy.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_phy.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_pio.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_pio.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_power.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_power.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_radio.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_radio.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_wx.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_wx.h
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
 delete mode 100644 drivers/net/wireless/bcm43xx/bcm43xx_xmit.h
 create mode 100644 drivers/ssb/sprom.c
 delete mode 100644 include/net/ieee80211softmac.h
 delete mode 100644 include/net/ieee80211softmac_wx.h
 delete mode 100644 net/ieee80211/softmac/Kconfig
 delete mode 100644 net/ieee80211/softmac/Makefile
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_assoc.c
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_auth.c
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_event.c
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_io.c
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_module.c
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_priv.h
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_scan.c
 delete mode 100644 net/ieee80211/softmac/ieee80211softmac_wx.c
 delete mode 100644 net/mac80211/rc80211_simple.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26-2008-03-13.patch.bz2
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
