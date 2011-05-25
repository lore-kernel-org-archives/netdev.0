From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 25 May 2011 18:52:37 -0400 (EDT)
Message-ID: <20110525.185237.2170881036700315885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


That majority of the bits here are just a merge with John Linville's
queued up wireless stuff.  This has been in his tree for more than
a week and I was just waiting for him to get back from a conference
to send the pull request to me.

Other noteworthy bits:

1) Erroneous socket filters can log kernel messages without control,
   fix from Joe Perches.

2) Fix regression in the locking of interface dumping, from Eric Dumaze=
t.

3) Fix crash in bridging due to improperly initialized route object,
   also from Eric.

4) IP fragments give erroneous congestion notification signals in
   SFQ packet scheduler, also from Eric.

5) Rest of networking %pK conversions, from Dan Rosenberg via Andrew
   Morton.

6) When the RTNL mutex is held, synchonize_net() can use
   synchronize_rcu_expedited().  From Eric Dumazet.

7) Fix IGMP source filter clearing when users of the group still
   exist, from Veaceslav Falico.

8) __dst_destroy_metrics_generic() forgets to set "read-only" bit
   in the encoded pointer.  Fix from Eric Dumazet.

9) dev_disable_lro() needs to propagate to underlying physical device
   of a VLAN, from Neil Horman.

10) ASCONF memory leak in SCTP, fix from Wei Yongjun.

11) SFQ packet scheduler's ->peek() method returns different packets
    than ->dequeue() would, fix from Eric Dumazet.

12) Fix bonding deadlock in ALB mode, from Neil Horman.

Please pull, thanks a lot!

The following changes since commit 2a651c7f8d377cf88271374315cbb5fe82ea=
c784:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ericvh/v9fs (2011-05-25 09:21:56 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (1):
      airo: correct proc entry creation interfaces

Alexey Orishko (1):
      CDC NCM: release interfaces fix in unbind()

Breno Leitao (1):
      ehea: Fix multicast registration on semi-promiscuous mode

Christian Lamparter (2):
      p54usb: add zoom 4410 usbid
      carl9170: advertise interface combinations

Dan Rosenberg (1):
      net: convert %p usage to %pK

Daniel Halperin (1):
      iwlwifi: remove unused parameter from iwl_hcmd_queue_reclaim

David S. Miller (3):
      ipv6: Fix return of xfrm6_tunnel_rcv()
      bug.h: Fix build with CONFIG_PRINTK disabled.
      Merge branch 'for-davem' of ssh://master.kernel.org/.../linville/=
wireless-next-2.6

Dmitry Kravkov (2):
      bnx2x: fix inverted condition
      bnx2x: protect sequence increment with mutex

Eric Dumazet (8):
      net: ping: cleanups ping_v4_unhash()
      snap: remove one synchronize_net()
      sch_sfq: avoid giving spurious NET_XMIT_CN signals
      net: use synchronize_rcu_expedited()
      net: fix __dst_destroy_metrics_generic()
      bridge: initialize fake_rtable metrics
      sch_sfq: fix peek() implementation
      net: hold rtnl again in dump callbacks

=46elix Fietkau (3):
      ath9k: fix ad-hoc mode beacon selection
      ath9k: fix ad-hoc nexttbtt calculation
      ath9k: implement .tx_last_beacon()

=46lavio Leitner (1):
      bonding: documentation and code cleanup for resend_igmp

Ian Campbell (1):
      xen: netfront: hold RTNL when updating features.

Javier Cardona (2):
      mac80211: Deactivate mesh path timers when freeing nodes
      mac80211: Don't sleep when growing the mesh path

Joe Perches (2):
      bug.h: Add WARN_RATELIMIT
      net: filter: Use WARN_RATELIMIT

Johannes Berg (10):
      iwlagn: prepare for multi-TB commands
      iwlagn: clean up TXQ indirection
      iwlagn: remove unused pad argument
      iwlagn: support multiple TBs per command
      iwlagn: remove set but unused vars
      iwlagn: change default beacon interval
      mac80211: verify IBSS in interface combinations
      mac80211: add missing rcu_barrier
      mac80211: fix and simplify mesh locking
      mac80211: annotate and fix RCU in mesh code

John W. Linville (2):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge ssh://master.kernel.org/.../linville/wireless-next-2.6 into=
 for-davem

Jouni Malinen (1):
      cfg80211: Use consistent BSS matching between scan and sme

Larry Finger (1):
      rtlwifi: rtl8192c-common: rtl8192ce: Fix for HT40 regression

Luciano Coelho (1):
      nl80211: remove some stack variables in trigger_scan and start_sc=
hed_scan

Marc Yang (5):
      mwifiex: reduce CPU usage by tracking tx_pkts_queued
      mwifiex: reduce CPU usage by tracking highest_queued_prio
      mwifiex: check mwifiex_wmm_lists_empty() before dequeue
      mwifiex: CPU mips optimization with NO_PKT_PRIO_TID
      mwifiex: adjust high/low water marks for tx_pending queue

Meelis Roos (1):
      Add Fujitsu 1000base-SX PCI ID to tg3

Mike Frysinger (1):
      net/irda: convert bfin_sir to common Blackfin UART header

Mohammed Shafi Shajakhan (2):
      ath_hw: Fix bssid mask documentation
      ath9k: use PS wakeup before REG_READ

Neil Horman (3):
      net: move is_vlan_dev into public header file (v2)
      net: make dev_disable_lro use physical device if passed a vlan de=
v (v2)
      bonding: prevent deadlock on slave store with alb mode (v3)

Prarit Bhargava (1):
      isdn: netjet - blacklist Digium TDM400P

Rafa=A9=A9 Mi=A9=A9ecki (8):
      b43: rename b43_wldev's field with ssb_device to sdev
      bcma: add PCI ID of the card found in Thinkpad X120e
      b43: add helpers for block R/W ops
      b43: make b43_wireless_init less bus specific
      b43: dma: cache translation (routing bits)
      b43: add helper for finding GPIO device
      b43: separate ssb core reset
      b43: read PHY info only when needed (for PHY-A)

Rajkumar Manoharan (2):
      mac80211: abort scan_work immediately when the device goes down
      ath9k: Fix power save wrappers in debug ops

Randy Dunlap (2):
      wireless: fix cfg80211.h new kernel-doc warnings
      wireless: fix fatal kernel-doc error + warning in mac80211.h

Rhyland Klein (1):
      net: rfkill: add generic gpio rfkill driver

Sathya Perla (1):
      be2net: hash key for rss-config cmd not set

Stephen Hemminger (1):
      dst: catch uninitialized metrics

Sujith Manoharan (9):
      ath9k_htc: Fix mode selection
      ath9k_htc: Fix station flags
      ath9k_htc: Recalculate the BSSID mask on interface
      ath9k_htc: Fix RX filter calculation
      ath9k_htc: Fix BSSID calculation
      ath9k_htc: Fix max subframe handling
      ath9k_htc: Change credit limit for UB94/95
      ath9k_htc: Fix packet timeout
      ath9k: Drag the driver to the year 2011

Ulrich Hecht (1):
      via-velocity: don't annotate MAC registers as packed

Veaceslav Falico (1):
      igmp: call ip_mc_clear_src() only when we have no users of ip_mc_=
list

Wei Yongjun (1):
      sctp: fix memory leak of the ASCONF queue when free asoc

Wey-Yi Guy (8):
      iwlagn: more ucode error log info
      iwlagn: add testmode trace command
      iwlagn: add eeprom command to testmode
      iwlagn: add testmode set fixed rate command
      iwlagn: clear STATUS_HCMD_ACTIVE bit if fail enqueue
      iwlagn: alwasy send RXON with disassociate falge before associate
      iwlagn: remove unused old_assoc parameter
      iwlagn: dbg_fixed_rate only used when CONFIG_MAC80211_DEBUGFS ena=
bled

 Documentation/networking/bonding.txt               |   13 +-
 drivers/bcma/host_pci.c                            |    1 +
 drivers/isdn/hardware/mISDN/netjet.c               |    6 +
 drivers/net/benet/be_cmds.c                        |    3 +-
 drivers/net/bnx2x/bnx2x_cmn.c                      |    2 +-
 drivers/net/bnx2x/bnx2x_main.c                     |    3 +-
 drivers/net/bonding/bond_alb.c                     |    4 -
 drivers/net/bonding/bond_main.c                    |   28 +-
 drivers/net/bonding/bond_sysfs.c                   |   16 +-
 drivers/net/ehea/ehea_main.c                       |    2 +-
 drivers/net/irda/bfin_sir.c                        |   59 ++--
 drivers/net/irda/bfin_sir.h                        |   63 +----
 drivers/net/tg3.c                                  |    1 +
 drivers/net/usb/cdc_ncm.c                          |   73 ++---
 drivers/net/via-velocity.h                         |    2 +-
 drivers/net/wireless/airo.c                        |   33 +--
 drivers/net/wireless/ath/ath9k/ahb.c               |    2 +-
 drivers/net/wireless/ath/ath9k/ani.c               |    2 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    2 +-
 drivers/net/wireless/ath/ath9k/ar5008_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9001_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    2 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   16 +
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.h        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    5 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   48 ++-
 drivers/net/wireless/ath/ath9k/btcoex.c            |    2 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    2 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    2 +-
 drivers/net/wireless/ath/ath9k/calib.h             |    2 +-
 drivers/net/wireless/ath/ath9k/common.c            |    2 +-
 drivers/net/wireless/ath/ath9k/common.h            |    2 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   10 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    2 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    4 +-
 drivers/net/wireless/ath/ath9k/htc.h               |   25 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    9 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   79 +++--
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    6 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.h           |    2 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    2 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +-
 drivers/net/wireless/ath/ath9k/init.c              |    2 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   42 +++-
 drivers/net/wireless/ath/ath9k/pci.c               |    2 +-
 drivers/net/wireless/ath/ath9k/phy.h               |    2 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +-
 drivers/net/wireless/ath/ath9k/rc.h                |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.h               |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    2 +-
 drivers/net/wireless/ath/carl9170/carl9170.h       |    4 +
 drivers/net/wireless/ath/carl9170/fw.c             |   19 +-
 drivers/net/wireless/ath/carl9170/main.c           |   10 +-
 drivers/net/wireless/ath/hw.c                      |   10 +-
 drivers/net/wireless/b43/b43.h                     |   24 +-
 drivers/net/wireless/b43/dma.c                     |   37 +-
 drivers/net/wireless/b43/leds.c                    |    4 +-
 drivers/net/wireless/b43/lo.c                      |    4 +-
 drivers/net/wireless/b43/main.c                    |  194 ++++++-----
 drivers/net/wireless/b43/phy_a.c                   |   16 +-
 drivers/net/wireless/b43/phy_common.c              |    8 +-
 drivers/net/wireless/b43/phy_g.c                   |   48 ++--
 drivers/net/wireless/b43/phy_lp.c                  |   22 +-
 drivers/net/wireless/b43/phy_n.c                   |   24 +-
 drivers/net/wireless/b43/pio.c                     |   30 +-
 drivers/net/wireless/b43/rfkill.c                  |    6 +-
 drivers/net/wireless/b43/sdio.c                    |    4 +-
 drivers/net/wireless/b43/sysfs.c                   |    4 +-
 drivers/net/wireless/b43/tables_lpphy.c            |    4 +-
 drivers/net/wireless/b43/wa.c                      |    4 +-
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    4 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   86 +++--
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  250 +++---------=
--
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   13 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   10 -
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   66 +++--
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   58 +++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   12 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c         |  177 ++++++++++-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   34 ++
 drivers/net/wireless/iwlwifi/iwl-tx.c              |  364 ++++++++++++=
++------
 drivers/net/wireless/iwmc3200wifi/rx.c             |    4 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    4 +
 drivers/net/wireless/mwifiex/main.h                |    9 +-
 drivers/net/wireless/mwifiex/txrx.c                |    4 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   59 +++-
 drivers/net/wireless/p54/p54usb.c                  |    1 +
 drivers/net/wireless/rndis_wlan.c                  |    3 +-
 drivers/net/wireless/rtlwifi/ps.c                  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |   69 ++++
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    1 +
 drivers/net/xen-netfront.c                         |    2 +
 drivers/staging/ath6kl/os/linux/cfg80211.c         |    2 +-
 drivers/staging/brcm80211/brcmfmac/wl_cfg80211.c   |    4 +-
 drivers/staging/wlan-ng/cfg80211.c                 |    2 +-
 fs/proc/generic.c                                  |    1 +
 include/asm-generic/bug.h                          |   37 ++
 include/linux/if_vlan.h                            |    5 +
 include/linux/rfkill-gpio.h                        |   43 +++
 include/net/cfg80211.h                             |    8 +-
 include/net/dst.h                                  |    2 +
 net/802/psnap.c                                    |    1 -
 net/8021q/vlan.h                                   |    5 -
 net/atm/proc.c                                     |    4 +-
 net/bridge/br_netfilter.c                          |    6 +-
 net/can/bcm.c                                      |    6 +-
 net/core/dev.c                                     |   12 +-
 net/core/dst.c                                     |    2 +-
 net/core/fib_rules.c                               |    1 +
 net/core/filter.c                                  |    4 +-
 net/core/rtnetlink.c                               |    9 +-
 net/ipv4/igmp.c                                    |   10 +-
 net/ipv4/ping.c                                    |    3 -
 net/ipv4/raw.c                                     |    2 +-
 net/ipv4/tcp_ipv4.c                                |    6 +-
 net/ipv4/udp.c                                     |    2 +-
 net/ipv6/raw.c                                     |    2 +-
 net/ipv6/tcp_ipv6.c                                |    6 +-
 net/ipv6/udp.c                                     |    2 +-
 net/ipv6/xfrm6_tunnel.c                            |    2 +-
 net/key/af_key.c                                   |    2 +-
 net/mac80211/iface.c                               |    4 +-
 net/mac80211/main.c                                |   22 +-
 net/mac80211/mesh.h                                |    7 +-
 net/mac80211/mesh_pathtbl.c                        |  204 +++++++----
 net/mac80211/scan.c                                |    5 +
 net/netlink/af_netlink.c                           |    2 +-
 net/packet/af_packet.c                             |    2 +-
 net/phonet/socket.c                                |    2 +-
 net/rfkill/Kconfig                                 |    9 +
 net/rfkill/Makefile                                |    1 +
 net/rfkill/rfkill-gpio.c                           |  227 ++++++++++++
 net/sched/sch_sfq.c                                |   22 +-
 net/sctp/associola.c                               |   16 +
 net/sctp/proc.c                                    |    4 +-
 net/unix/af_unix.c                                 |    2 +-
 net/wireless/core.h                                |    5 +-
 net/wireless/nl80211.c                             |   12 +-
 net/wireless/sme.c                                 |   19 +-
 net/wireless/util.c                                |    2 +-
 187 files changed, 2050 insertions(+), 1204 deletions(-)
 create mode 100644 include/linux/rfkill-gpio.h
 create mode 100644 net/rfkill/rfkill-gpio.c
