From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-jgarzik' branch of wireless-2.6 (use this
	one)
Date: Tue, 8 Jan 2008 22:20:09 -0500
Message-ID: <20080109032009.GC3048@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3607 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbYAIDuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 22:50:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ 2nd try...more thoroughly checked... ]

Jeff,

Another round of patches intended for 2.6.25...the biggest factions are
rt2x00 and b43 updates, as well as some Viro-isms... :-)

Please let me know if there are any problems!

John

P.S.  Copying Dave in case he is handling these requests...FWIW, it
will definitely depend on the patches already in netdev-2.6#upstream...

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/up=
stream-jgarzik

---

The following changes since commit 65d0aa09c183ee45dc1786675209313fa75c=
f4ec:
  Jeff Garzik (1):
        wireless/iwl: fix namespace breakage

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it upstream-jgarzik

Al Viro (35):
      eliminate byteswapping in struct ieee80211_qos_parameters
      several missing cpu_to_le16() in ieee80211softmac_capabilities()
      ieee80211softmac_auth_resp() fix
      ieee80211: fix misannotations
      ieee80211: beacon->capability is little-endian
      airo: fix transmit_802_11_packet()
      airo: fix endianness bug in ->dBm handling
      airo: bug in airo_interrupt() handling on incoming 802.11
      airo endianness bug: cap_rid.extSoftCap
      airo: fix writerids() endianness
      hostap: fix endianness with txdesc->sw_support
      p54common annotations and fixes
      ipw2100 annotations and fixes
      ray_cs fixes
      ipw2200 fix: struct ieee80211_radiotap_header is little-endian
      ipw2200 fix: ->rt_chbitmask is le16
      ipw2200: ipw_tx_skb() endianness bug
      airo: trivial endianness annotations
      airo: sanitize handling of SSID_rid
      bap_read()/bap_write() work with fixed-endian buffers
      airo: sanitize BSSListRid handling
      airo: sanitize handling of WepKeyRid
      airo: sanitize handling of StatsRid
      airo: sanitize handling of CapabilityRid
      airo: sanitize APListRid handling
      airo: sanitize handling of StatusRid
      airo: last of endianness annotations
      hostap annotations
      hostap: don't mess with mixed-endian even for internal skb queues
      p54pci: endianness annotations and fixes
      bcm43xx annotations
      prism54 trivial annotations
      ipw2200 trivial annotations
      ipw2200: do not byteswap struct ipw_associate
      misc wireless annotations

Daniel Walker (1):
      prism54: remove questionable down_interruptible usage

Ivo van Doorn (12):
      rt2x00: Fix chipset debugfs file
      rt2x00: Always call ieee80211_stop_queue() when return NETDEV_TX_=
BUSY
      rt2x00: Only set the TBCN flag when the interface is configured t=
o send beacons.
      rt2x00: Store queue idx and entry idx in data_ring and data_entry
      rt2x00: Move start() and stop() handlers into rt2x00lib.c
      rt2x00: Put 802.11 data on 4 byte boundary
      rt2x00: Move packet filter flags
      rt2x00: Cleanup write_tx_desc() arguments
      rt2x00: Determine MY_BSS from descriptor
      rt2x00: Move init_txring and init_rxring into rt2x00lib
      rt2x00: Correctly initialize data and desc pointer
      rt2x00: Release rt2x00 2.0.14

John W. Linville (1):
      Revert "rtl8187: fix tx power reading"

Michael Buesch (10):
      ssb: Fix extraction of values from SPROM
      b43: Only select allowed TX and RX antennas
      b43: Fix chip access validation for new devices
      ssb: Fix PCMCIA lowlevel register access
      b43: Remove PIO support
      b43: Add definitions for MAC Control register
      b43-ssb-bridge: Add PCI ID for BCM43XG
      b43: Add NPHY kconfig option
      b43: Fix any N-PHY related WARN_ON() in the attach stage.
      zd1211rw: fix alignment for QOS and WDS frames

Miguel Bot=F3n (3):
      ssb: add 'ssb_pcihost_set_power_state' function
      b44: power down PHY when interface down
      iwlwifi: fix compilation warning in 'iwl-4965.c'

Zhu Yi (1):
      iwlwifi: fix typo in 'drivers/net/wireless/iwlwifi/Kconfig'

 drivers/net/b44.c                             |   28 +-
 drivers/net/wireless/adm8211.c                |    8 +-
 drivers/net/wireless/airo.c                   | 1233 ++++++++++++-----=
--------
 drivers/net/wireless/atmel.c                  |   30 +-
 drivers/net/wireless/b43/Kconfig              |   58 +-
 drivers/net/wireless/b43/Makefile             |    9 +-
 drivers/net/wireless/b43/b43.h                |   78 +-
 drivers/net/wireless/b43/debugfs.c            |    1 -
 drivers/net/wireless/b43/dma.c                |   19 +-
 drivers/net/wireless/b43/dma.h                |   50 -
 drivers/net/wireless/b43/main.c               |  357 +++-----
 drivers/net/wireless/b43/main.h               |    3 +
 drivers/net/wireless/b43/xmit.c               |   26 +-
 drivers/net/wireless/b43legacy/main.c         |    5 -
 drivers/net/wireless/b43legacy/phy.c          |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h        |    6 +-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |   40 +-
 drivers/net/wireless/bcm43xx/bcm43xx_pio.c    |    6 +-
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c   |    6 +-
 drivers/net/wireless/hostap/hostap_80211.h    |   34 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c |    2 +-
 drivers/net/wireless/hostap/hostap_ap.c       |   72 +-
 drivers/net/wireless/hostap/hostap_common.h   |   34 +-
 drivers/net/wireless/hostap/hostap_download.c |   22 +-
 drivers/net/wireless/hostap/hostap_hw.c       |   28 +-
 drivers/net/wireless/hostap/hostap_info.c     |    9 +-
 drivers/net/wireless/hostap/hostap_ioctl.c    |   66 +-
 drivers/net/wireless/hostap/hostap_main.c     |    6 +-
 drivers/net/wireless/hostap/hostap_pci.c      |   16 +-
 drivers/net/wireless/hostap/hostap_wlan.h     |  202 ++--
 drivers/net/wireless/ipw2100.c                |   10 +-
 drivers/net/wireless/ipw2200.c                |  175 ++--
 drivers/net/wireless/ipw2200.h                |  190 ++--
 drivers/net/wireless/iwlwifi/Kconfig          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |    4 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c   |    4 +-
 drivers/net/wireless/p54common.c              |    8 +-
 drivers/net/wireless/p54pci.c                 |   16 +-
 drivers/net/wireless/p54pci.h                 |    4 +-
 drivers/net/wireless/prism54/isl_38xx.h       |   10 +-
 drivers/net/wireless/prism54/isl_ioctl.c      |   12 +-
 drivers/net/wireless/prism54/islpci_eth.c     |    2 +-
 drivers/net/wireless/prism54/islpci_eth.h     |   38 +-
 drivers/net/wireless/prism54/islpci_mgt.h     |    2 +-
 drivers/net/wireless/ray_cs.c                 |   69 +-
 drivers/net/wireless/rt2x00/rt2400pci.c       |  102 +--
 drivers/net/wireless/rt2x00/rt2500pci.c       |   88 +--
 drivers/net/wireless/rt2x00/rt2500usb.c       |   36 +-
 drivers/net/wireless/rt2x00/rt2x00.h          |   32 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c     |   13 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c       |  142 +++-
 drivers/net/wireless/rt2x00/rt2x00lib.h       |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c       |   59 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c       |   28 +-
 drivers/net/wireless/rt2x00/rt2x00ring.h      |   13 +
 drivers/net/wireless/rt2x00/rt2x00usb.c       |   87 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h       |    5 +-
 drivers/net/wireless/rt2x00/rt61pci.c         |  114 +--
 drivers/net/wireless/rt2x00/rt73usb.c         |   35 +-
 drivers/net/wireless/rtl8187_rtl8225.c        |    8 +-
 drivers/net/wireless/wavelan_cs.p.h           |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c        |   17 +-
 drivers/ssb/b43_pci_bridge.c                  |    1 +
 drivers/ssb/pci.c                             |   76 ++-
 drivers/ssb/pcmcia.c                          |   71 +-
 include/linux/ssb/ssb.h                       |   29 +-
 include/linux/ssb/ssb_regs.h                  |   38 +-
 include/net/ieee80211.h                       |    6 +-
 net/ieee80211/ieee80211_crypt_tkip.c          |   22 +-
 net/ieee80211/ieee80211_rx.c                  |   47 +-
 net/ieee80211/ieee80211_tx.c                  |   14 +-
 net/ieee80211/softmac/ieee80211softmac_auth.c |    6 +-
 net/ieee80211/softmac/ieee80211softmac_io.c   |   10 +-
 74 files changed, 1972 insertions(+), 2139 deletions(-)

Omnibus patch attached as 'upstream-jgarzik.patch.bz2'.
--=20
John W. Linville
linville@tuxdriver.com
