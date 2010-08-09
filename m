From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 09 Aug 2010 03:28:03 -0700 (PDT)
Message-ID: <20100809.032803.193698039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) TX timeout task in netxen driver must take RTNL lock.  From
   Amit Kumar Salecha.

2) Add missing packet length sanity changes to various packet
   scheduler modules that peek at packet contents, from
   Changli Gao.

3) Correct ICMP packet peeking in act_nat module, also from
   Changli Gao.

4) Locking and memory freeing fixes in isdn gigaset driver from
   Dan Carpenter.

5) When TCP hits a md5 option while parsing, it needs to validate
   a minimum length.  Fix from Dmitry Popov.

6) RX tasklet race fix in solos-pci driver from David Woodhouse.

7) sch_sfq oops fix from Jarek Poplawski.

8) Fix ixgbe build with FCOE disabled, from John Fastabend.

9) iwlwifi locking fixes from Johannes Berg.

10) Mimick memory barrier fixes made to e1000 in e100, e1000e,
    igb and ixgbe.  From Jeff Kircher.

11) Several ath9k bug fixes via Felix Fietkau.

12) Fix oops in rtl8180_beacon_work, from John W. Linville.

Please pull, thanks a lot!

The following changes since commit 3cfc2c42c1cbc8e238bb9c0612c0df4565e3a8b4:

  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/trivial (2010-08-04 15:31:02 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amit Kumar Salecha (1):
      netxen: protect tx timeout recovery by rtnl lock

Andy Lutomirski (1):
      iwlagn: Improve aggregation failure error messages

Changli Gao (6):
      act_nat: fix on the TX path
      sk_buff: introduce pskb_network_may_pull()
      cls_flow: add sanity check for the packet length
      cls_rsvp: add sanity check for the packet length
      sch_sfq: add sanity check for the packet length
      net: disable preemption before call smp_processor_id()

Christian Samsel (1):
      usbnet: remove noisy and hardly useful printk

Christoph Fritz (1):
      wireless: ipw2100: check result of kzalloc()

Dan Carpenter (3):
      isdn: fix information leak
      isdn: gigaset: add missing unlock
      isdn: gigaset: use after free

Dan Williams (3):
      libertas: get the right # of scanned BSSes
      libertas: fix association with some APs by using extended rates
      libertas: scan before assocation if no BSSID was given

David Howells (1):
      RxRPC: Fix a potential deadlock between the call resend_timer and state_lock

David Miller (1):
      Bluetooth: Use list_head for HCI blacklist head

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

David Woodhouse (1):
      solos-pci: Fix race condition in tasklet RX handling

Dmitry Popov (1):
      tcp: no md5sig option size check bug

Felix Fietkau (7):
      ath9k_hw: clean up and fix initial noise floor calibration
      ath9k_hw: fix periodic noise floor calibration on AR9003
      ath9k: fix a crash in the PA predistortion apply function
      ath9k_hw: fix analog shift register writes on AR9003
      ath9k: prevent calibration during off-channel activity
      ath9k_hw: clean up per-channel calibration data
      ath9k_hw: fix a noise floor calibration related race condition

Gustavo F. Padovan (2):
      Bluetooth: Remove __exit from rfcomm_cleanup_ttys()
      Bluetooth: Don't send RFC for Basic Mode if only it is supported

Jan Friedrich (1):
      ath9k: fix erased ieee80211_rx_status.mactime

Jarek Poplawski (2):
      net: Fix napi_gro_frags vs netpoll path
      pkt_sched: Fix sch_sfq vs tcf_bind_filter oops

Jeff Kirsher (3):
      e100/e1000*/igb*/ixgb*: Add missing read memory barrier
      igb.txt: Add igb documentation
      igbvf.txt: Add igbvf Documentation

Joe Perches (1):
      drivers/net/enic: Use %pUB to format a UUID

Johannes Berg (5):
      iwlwifi: fix possible recursive locking deadlock
      mac80211: fix scan locking wrt. hw scan
      iwlwifi: fix compile warning
      iwlwifi: fix TX tracer
      iwlwifi: fix locking assertions

John Fastabend (1):
      ixgbe: fix build error with FCOE_CONFIG without DCB_CONFIG

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-next-2.6
      rtl8180: avoid potential NULL deref in rtl8180_beacon_work

Juuso Oikarinen (1):
      mac80211: Fix compilation warning when CONFIG_INET is not set

Kulikov Vasiliy (5):
      net: wl12xx: do not use kfree'd memory
      rt2x00: do not use PCI resources before pci_enable_device()
      cxgb3: do not use PCI resources before pci_enable_device()
      cxgb4vf: do not use PCI resources before pci_enable_device()
      via-velocity: do not use PCI resources before pci_enable_device()

Larry Finger (1):
      p54pci: Add PCI ID for SMC2802W

Lorenzo Bianconi (1):
      ath9k: fix an issue in ath_atx_tid paused flag management

Luis R. Rodriguez (1):
      ath9k_hw: Fix regulatory CTL index usage for AR9003

Rusty Russell (1):
      virtio_net: implements ethtool_ops.get_drvinfo

Stefan Weil (1):
      davinci_emac: Fix use after free in davinci_emac_remove

Sujith (1):
      ath9k: Remove myself from the MAINTAINERS list

Ville Tervo (1):
      Bluetooth: Check result code of L2CAP information response

Wey-Yi Guy (2):
      iwlwifi: BA scd_flow not match condition detected
      iwlagn: fix typo in ucode_bt_stats_read debugfs

stephen hemminger (1):
      ppp: make channel_ops const

 Documentation/networking/igb.txt               |  132 ++++++++
 Documentation/networking/igbvf.txt             |   78 +++++
 MAINTAINERS                                    |    1 -
 drivers/atm/solos-pci.c                        |    7 +-
 drivers/char/pcmcia/ipwireless/network.c       |    2 +-
 drivers/isdn/gigaset/bas-gigaset.c             |    6 +-
 drivers/isdn/gigaset/capi.c                    |    1 +
 drivers/isdn/sc/ioctl.c                        |   10 +-
 drivers/net/cxgb3/cxgb3_main.c                 |   25 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c             |   31 +-
 drivers/net/davinci_emac.c                     |    2 +-
 drivers/net/e100.c                             |    2 +
 drivers/net/e1000/e1000_main.c                 |    3 +
 drivers/net/e1000e/netdev.c                    |    4 +
 drivers/net/enic/enic_main.c                   |   17 +-
 drivers/net/igb/igb_main.c                     |    2 +
 drivers/net/igbvf/netdev.c                     |    2 +
 drivers/net/ixgb/ixgb_main.c                   |    2 +
 drivers/net/ixgbe/ixgbe_main.c                 |   15 +-
 drivers/net/ixgbevf/ixgbevf_main.c             |    2 +
 drivers/net/netxen/netxen_nic_main.c           |   15 +-
 drivers/net/ppp_async.c                        |    6 +-
 drivers/net/ppp_synctty.c                      |    6 +-
 drivers/net/pppoe.c                            |    4 +-
 drivers/net/usb/usbnet.c                       |    1 -
 drivers/net/via-velocity.c                     |    4 +-
 drivers/net/virtio_net.c                       |   14 +
 drivers/net/wireless/ath/ath9k/ar9002_calib.c  |   43 ++-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c  |   18 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |  388 +++++++++++++++++++++++-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c  |   17 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |    6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h         |    3 +-
 drivers/net/wireless/ath/ath9k/calib.c         |  118 ++++----
 drivers/net/wireless/ath/ath9k/calib.h         |    8 +-
 drivers/net/wireless/ath/ath9k/htc.h           |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |   10 +-
 drivers/net/wireless/ath/ath9k/hw.c            |   25 +-
 drivers/net/wireless/ath/ath9k/hw.h            |   25 +-
 drivers/net/wireless/ath/ath9k/main.c          |  104 ++++---
 drivers/net/wireless/ath/ath9k/recv.c          |   10 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |   36 +--
 drivers/net/wireless/ipw2x00/ipw2100.c         |    4 +
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c      |   11 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c      |   11 +-
 drivers/net/wireless/iwlwifi/iwl-core.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c         |    6 +-
 drivers/net/wireless/libertas/cfg.c            |  214 ++++++++++---
 drivers/net/wireless/libertas/dev.h            |    5 +
 drivers/net/wireless/libertas/main.c           |    1 +
 drivers/net/wireless/p54/p54pci.c              |    2 +
 drivers/net/wireless/rt2x00/rt2x00pci.c        |   21 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |    2 +
 drivers/net/wireless/wl12xx/wl1271_spi.c       |    3 +-
 include/linux/ppp_channel.h                    |    2 +-
 include/linux/skbuff.h                         |    5 +
 include/net/bluetooth/hci_core.h               |    2 +-
 net/atm/pppoatm.c                              |    2 +-
 net/bluetooth/hci_core.c                       |    2 +-
 net/bluetooth/hci_sock.c                       |    8 +-
 net/bluetooth/hci_sysfs.c                      |    3 +-
 net/bluetooth/l2cap.c                          |   24 ++-
 net/bluetooth/rfcomm/tty.c                     |    2 +-
 net/core/dev.c                                 |    7 +-
 net/ipv4/tcp_input.c                           |    2 +-
 net/irda/irnet/irnet_ppp.c                     |    2 +-
 net/l2tp/l2tp_ppp.c                            |    5 +-
 net/mac80211/main.c                            |    2 +
 net/mac80211/scan.c                            |   14 -
 net/rxrpc/ar-ack.c                             |    3 +
 net/rxrpc/ar-call.c                            |    6 +-
 net/sched/act_nat.c                            |   23 +-
 net/sched/cls_flow.c                           |   96 ++++---
 net/sched/cls_rsvp.h                           |   12 +-
 net/sched/sch_sfq.c                            |   36 ++-
 80 files changed, 1311 insertions(+), 450 deletions(-)
 create mode 100644 Documentation/networking/igb.txt
 create mode 100644 Documentation/networking/igbvf.txt
