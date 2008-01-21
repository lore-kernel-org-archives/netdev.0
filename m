From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-davem' branch of wireless-2.6 (2008-01-21)
Date: Mon, 21 Jan 2008 15:28:35 -0500
Message-ID: <20080121202835.GA3065@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

A slew of patches intended for 2.6.25...  Included are some big updates=
 to
b43, iwlwifi, libertas, and rt2x00.  Also included are some sizeable
mac80211 updates and a bunch of cleanup work from Al Viro, as well as a
smattering of other patches.

More notable are two new drivers: ath5k and rtl8180.  Both of these
drivers have seen a lot of development during this cycle, and both have
been serving commendably in Fedora 8 for some time.  I think we are bet=
ter
off with them in the upstream tree now.

Please let me know if there are problems!

Thanks,

John

P.S.  It looks like there are some minor conflicts that you will see in
the rt2x00 driver when rebasing on Linus' current tree.  Just FYI, but
feel free to ask if the fixes aren't obvious...thanks!

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/up=
stream-davem

---

The following changes since commit f2b4e6efaad1ad76acc66683edec8eca2623=
6eed:
  Jan Engelhardt (1):
        [IPV4]: Enable use of 240/4 address space.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it upstream-davem

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

Andrew Morton (2):
      drivers/net/wireless/iwlwifi/iwl-3945.c: fix printk warning
      drivers/net/wireless/rt2x00/rt2x00usb.c: fix uninitialized var wa=
rning

Ben M Cahill (1):
      iwlwifi: document scan command

Daniel Walker (1):
      prism54: remove questionable down_interruptible usage

Helge Deller (1):
      WAVELAN - compile-time check for struct sizes

Holger Schurig (5):
      libertas cs/sdio: fix 'NOHZ: local_softirq_pending 08' message
      libertas: move cardspecific data to driver
      libertas: always show firmware release
      libertas: don't blindly try mesh
      libertas: pepper main with debug statement

Ivo van Doorn (15):
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
      rt2x00: Data and desc pointer initialization
      rt2x00: Fix queue_idx initialization
      mac80211: Initialize vif pointer

Jiri Slaby (1):
      Net: add ath5k wireless driver

Johannes Berg (5):
      mac80211: dont use interface indices in drivers
      mac80211: move interface type to vif structure
      mac80211: add beacon configuration via cfg80211
      mac80211: implement cfg80211 station handling
      mac80211: add unified BSS configuration

John W. Linville (4):
      wireless: cleanup some merge errors
      Revert "rtl8187: fix tx power reading"
      b43: finish removal of pio support
      b43/nphy.c: include headers to avoid build breakage on some platf=
orms

Luis R. Rodriguez (1):
      ath5k: Fix frame duration oops

Michael Buesch (25):
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
      b43: Add N-PHY register definitions
      b43: Fix PHY register routing
      b43: Remove the PHY spinlock
      b43: Fix upload of beacon packets to the hardware
      b43: Fix template upload locking.
      b43: Put multicast frames on the mcast queue
      b43: Fix tim search buffer overrun
      b43: Add N-PHY related initvals firmware filenames.
      b43: Fix radio ID register reading
      b43: Add support for new firmware
      b43: Add Broadcom 2055 radio register definitions
      ssb: Add boardflags_hi field to the sprom data structure
      b43: Add NPHY radio init code
      b43: Add NPHY channel switch code
      b43: Add lots of N-PHY lookup tables

Michael Wu (2):
      Add rtl8180 wireless driver
      mac80211: Fix rate reporting regression

Miguel Bot=F3n (3):
      ssb: add 'ssb_pcihost_set_power_state' function
      b44: power down PHY when interface down
      iwlwifi: fix compilation warning in 'iwl-4965.c'

Pavel Roskin (1):
      hostap_cs: don't match revisions in presense of the MAC chip name

Reinette Chatre (2):
      iwlwifi: remove reference to non-existent documentation
      iwlwifi: style fixes to usage of << and >> operators

Ron Rindjunsky (3):
      iwlwifi: A-MPDU Rx flow enabled
      mac80211: A-MPDU Rx stop aggregation on proper dev
      mac80211: A-MPDU Rx remove stop_rx_ba_session warning print

Stefano Brivio (1):
      b43legacy: fix use-after-free rfkill bug

Tomas Winkler (6):
      iwl4965: Remove redundant code in iwl4965_tx_cmd
      iwlwifi: move iwl4965_get_dma_hi_address function to iwl-helpers.=
h
      iwlwifi: remove iwl4965_tx_cmd
      iwlwifi: move uCode helper functions to iwl-helpers.h
      iwlwifi: 4965 unify rate scale variable names for station data
      iwlwifi: 3954 renames iwl3945_rate_scale_priv to iwl3945_rs_sta

Zhu Yi (4):
      iwlwifi: fix typo in 'drivers/net/wireless/iwlwifi/Kconfig'
      iwlwifi: delay firmware loading from pci_probe to network interfa=
ce open
      iwlwifi: fix problem when rf_killswitch change during suspend/res=
ume
      iwlwifi: Update iwlwifi version stamp to 1.2.23

 Documentation/feature-removal-schedule.txt       |   11 +-
 MAINTAINERS                                      |   11 +
 drivers/net/b44.c                                |   28 +-
 drivers/net/wireless/Kconfig                     |   73 +
 drivers/net/wireless/Makefile                    |    5 +
 drivers/net/wireless/adm8211.c                   |   11 +-
 drivers/net/wireless/airo.c                      | 1233 +++----
 drivers/net/wireless/ath5k/Makefile              |    2 +
 drivers/net/wireless/ath5k/ath5k.h               | 1173 ++++++
 drivers/net/wireless/ath5k/base.c                | 2818 ++++++++++++++
 drivers/net/wireless/ath5k/base.h                |  178 +
 drivers/net/wireless/ath5k/debug.c               |  469 +++
 drivers/net/wireless/ath5k/debug.h               |  216 ++
 drivers/net/wireless/ath5k/hw.c                  | 4353 ++++++++++++++=
++++++++
 drivers/net/wireless/ath5k/hw.h                  |  588 +++
 drivers/net/wireless/ath5k/initvals.c            | 1347 +++++++
 drivers/net/wireless/ath5k/phy.c                 | 2071 ++++++++++
 drivers/net/wireless/ath5k/reg.h                 | 1987 ++++++++++
 drivers/net/wireless/ath5k/regdom.c              |  121 +
 drivers/net/wireless/ath5k/regdom.h              |  500 +++
 drivers/net/wireless/atmel.c                     |   30 +-
 drivers/net/wireless/b43/Kconfig                 |   58 +-
 drivers/net/wireless/b43/Makefile                |   11 +-
 drivers/net/wireless/b43/b43.h                   |  119 +-
 drivers/net/wireless/b43/debugfs.c               |    7 +-
 drivers/net/wireless/b43/dma.c                   |  123 +-
 drivers/net/wireless/b43/dma.h                   |   50 -
 drivers/net/wireless/b43/lo.c                    |   64 +-
 drivers/net/wireless/b43/main.c                  |  702 ++--
 drivers/net/wireless/b43/main.h                  |    3 +
 drivers/net/wireless/b43/nphy.c                  |  199 +
 drivers/net/wireless/b43/nphy.h                  |  926 +++++
 drivers/net/wireless/b43/phy.c                   |  342 ++-
 drivers/net/wireless/b43/phy.h                   |   79 +-
 drivers/net/wireless/b43/pio.c                   |  652 ----
 drivers/net/wireless/b43/pio.h                   |  153 -
 drivers/net/wireless/b43/tables_nphy.c           | 2476 ++++++++++++
 drivers/net/wireless/b43/tables_nphy.h           |  159 +
 drivers/net/wireless/b43/xmit.c                  |  196 +-
 drivers/net/wireless/b43/xmit.h                  |  200 +-
 drivers/net/wireless/b43legacy/b43legacy.h       |    5 +-
 drivers/net/wireless/b43legacy/main.c            |   18 +-
 drivers/net/wireless/b43legacy/phy.c             |    2 +-
 drivers/net/wireless/b43legacy/rfkill.c          |   11 +-
 drivers/net/wireless/b43legacy/xmit.c            |   26 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h           |    6 +-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c      |   40 +-
 drivers/net/wireless/bcm43xx/bcm43xx_pio.c       |    6 +-
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c      |    6 +-
 drivers/net/wireless/hostap/hostap_80211.h       |   34 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c    |    2 +-
 drivers/net/wireless/hostap/hostap_ap.c          |   72 +-
 drivers/net/wireless/hostap/hostap_common.h      |   34 +-
 drivers/net/wireless/hostap/hostap_cs.c          |   15 +-
 drivers/net/wireless/hostap/hostap_download.c    |   22 +-
 drivers/net/wireless/hostap/hostap_hw.c          |   28 +-
 drivers/net/wireless/hostap/hostap_info.c        |    9 +-
 drivers/net/wireless/hostap/hostap_ioctl.c       |   66 +-
 drivers/net/wireless/hostap/hostap_main.c        |    6 +-
 drivers/net/wireless/hostap/hostap_pci.c         |   16 +-
 drivers/net/wireless/hostap/hostap_wlan.h        |  202 +-
 drivers/net/wireless/ipw2100.c                   |   10 +-
 drivers/net/wireless/ipw2200.c                   |  175 +-
 drivers/net/wireless/ipw2200.h                   |  190 +-
 drivers/net/wireless/iwlwifi/Kconfig             |   24 +-
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h |  155 +-
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h    |   58 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h       |   46 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |  218 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h       |   26 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h |  187 +-
 drivers/net/wireless/iwlwifi/iwl-4965-debug.h    |   58 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       |   36 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c       |  616 ++--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h       |   28 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c          |  230 +-
 drivers/net/wireless/iwlwifi/iwl-4965.h          |   15 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h       |   23 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |  401 +--
 drivers/net/wireless/iwlwifi/iwl4965-base.c      |  459 ++--
 drivers/net/wireless/libertas/cmd.c              |   23 +-
 drivers/net/wireless/libertas/dev.h              |    3 +-
 drivers/net/wireless/libertas/hostcmd.h          |    4 +-
 drivers/net/wireless/libertas/if_usb.c           |    5 +-
 drivers/net/wireless/libertas/if_usb.h           |    1 +
 drivers/net/wireless/libertas/main.c             |  194 +-
 drivers/net/wireless/libertas/rx.c               |    5 +-
 drivers/net/wireless/libertas/wext.c             |   16 +-
 drivers/net/wireless/p54common.c                 |   11 +-
 drivers/net/wireless/p54pci.c                    |   16 +-
 drivers/net/wireless/p54pci.h                    |    4 +-
 drivers/net/wireless/prism54/isl_38xx.h          |   10 +-
 drivers/net/wireless/prism54/isl_ioctl.c         |   12 +-
 drivers/net/wireless/prism54/islpci_eth.c        |    2 +-
 drivers/net/wireless/prism54/islpci_eth.h        |   38 +-
 drivers/net/wireless/prism54/islpci_mgt.h        |    2 +-
 drivers/net/wireless/ray_cs.c                    |   69 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |  104 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |   90 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |   35 +-
 drivers/net/wireless/rt2x00/rt2x00.h             |   43 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c        |   13 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c          |  166 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |   80 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c          |   28 +-
 drivers/net/wireless/rt2x00/rt2x00ring.h         |   13 +
 drivers/net/wireless/rt2x00/rt2x00usb.c          |  108 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h          |    5 +-
 drivers/net/wireless/rt2x00/rt61pci.c            |  116 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |   40 +-
 drivers/net/wireless/rtl8180.h                   |  151 +
 drivers/net/wireless/rtl8180_dev.c               | 1051 ++++++
 drivers/net/wireless/rtl8180_grf5101.c           |  179 +
 drivers/net/wireless/rtl8180_grf5101.h           |   28 +
 drivers/net/wireless/rtl8180_max2820.c           |  150 +
 drivers/net/wireless/rtl8180_max2820.h           |   28 +
 drivers/net/wireless/rtl8180_rtl8225.c           |  779 ++++
 drivers/net/wireless/rtl8180_rtl8225.h           |   23 +
 drivers/net/wireless/rtl8180_sa2400.c            |  201 +
 drivers/net/wireless/rtl8180_sa2400.h            |   36 +
 drivers/net/wireless/rtl8187.h                   |    4 +-
 drivers/net/wireless/rtl8187_dev.c               |   68 +-
 drivers/net/wireless/rtl8187_rtl8225.c           |   60 +-
 drivers/net/wireless/rtl8187_rtl8225.h           |    9 +-
 drivers/net/wireless/rtl818x.h                   |   29 +-
 drivers/net/wireless/wavelan.c                   |   34 +-
 drivers/net/wireless/wavelan.p.h                 |    1 -
 drivers/net/wireless/wavelan_cs.c                |   33 +-
 drivers/net/wireless/wavelan_cs.p.h              |    3 +-
 drivers/net/wireless/zd1211rw/zd_mac.c           |   32 +-
 drivers/ssb/b43_pci_bridge.c                     |    1 +
 drivers/ssb/pci.c                                |   79 +-
 drivers/ssb/pcmcia.c                             |   71 +-
 include/linux/pci_ids.h                          |    3 +
 include/linux/ssb/ssb.h                          |   30 +-
 include/linux/ssb/ssb_regs.h                     |   38 +-
 include/net/ieee80211.h                          |    6 +-
 include/net/mac80211.h                           |  138 +-
 net/ieee80211/ieee80211_crypt_tkip.c             |   22 +-
 net/ieee80211/ieee80211_rx.c                     |   47 +-
 net/ieee80211/ieee80211_tx.c                     |   14 +-
 net/ieee80211/softmac/ieee80211softmac_auth.c    |    6 +-
 net/ieee80211/softmac/ieee80211softmac_io.c      |   10 +-
 net/mac80211/cfg.c                               |  350 ++-
 net/mac80211/debugfs_netdev.c                    |   33 +-
 net/mac80211/ieee80211.c                         |   94 +-
 net/mac80211/ieee80211_i.h                       |   42 +-
 net/mac80211/ieee80211_iface.c                   |   16 +-
 net/mac80211/ieee80211_ioctl.c                   |   65 +-
 net/mac80211/ieee80211_rate.c                    |   18 +-
 net/mac80211/ieee80211_sta.c                     |  121 +-
 net/mac80211/key.c                               |    6 +-
 net/mac80211/rc80211_pid_algo.c                  |   20 +-
 net/mac80211/rc80211_simple.c                    |   19 +-
 net/mac80211/rx.c                                |   38 +-
 net/mac80211/sta_info.c                          |   27 +-
 net/mac80211/tx.c                                |  136 +-
 net/mac80211/util.c                              |   59 +-
 161 files changed, 27651 insertions(+), 5360 deletions(-)
 create mode 100644 drivers/net/wireless/ath5k/Makefile
 create mode 100644 drivers/net/wireless/ath5k/ath5k.h
 create mode 100644 drivers/net/wireless/ath5k/base.c
 create mode 100644 drivers/net/wireless/ath5k/base.h
 create mode 100644 drivers/net/wireless/ath5k/debug.c
 create mode 100644 drivers/net/wireless/ath5k/debug.h
 create mode 100644 drivers/net/wireless/ath5k/hw.c
 create mode 100644 drivers/net/wireless/ath5k/hw.h
 create mode 100644 drivers/net/wireless/ath5k/initvals.c
 create mode 100644 drivers/net/wireless/ath5k/phy.c
 create mode 100644 drivers/net/wireless/ath5k/reg.h
 create mode 100644 drivers/net/wireless/ath5k/regdom.c
 create mode 100644 drivers/net/wireless/ath5k/regdom.h
 create mode 100644 drivers/net/wireless/b43/nphy.c
 create mode 100644 drivers/net/wireless/b43/nphy.h
 delete mode 100644 drivers/net/wireless/b43/pio.c
 delete mode 100644 drivers/net/wireless/b43/pio.h
 create mode 100644 drivers/net/wireless/b43/tables_nphy.c
 create mode 100644 drivers/net/wireless/b43/tables_nphy.h
 create mode 100644 drivers/net/wireless/rtl8180.h
 create mode 100644 drivers/net/wireless/rtl8180_dev.c
 create mode 100644 drivers/net/wireless/rtl8180_grf5101.c
 create mode 100644 drivers/net/wireless/rtl8180_grf5101.h
 create mode 100644 drivers/net/wireless/rtl8180_max2820.c
 create mode 100644 drivers/net/wireless/rtl8180_max2820.h
 create mode 100644 drivers/net/wireless/rtl8180_rtl8225.c
 create mode 100644 drivers/net/wireless/rtl8180_rtl8225.h
 create mode 100644 drivers/net/wireless/rtl8180_sa2400.c
 create mode 100644 drivers/net/wireless/rtl8180_sa2400.h

Omnibus patch available here:

	http://www.kernel.org:/pub/linux/kernel/people/linville/upstream-davem=
-2008-01-21.patch.bz2
--=20
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
