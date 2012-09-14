From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 14 Sep 2012 14:48:31 -0400 (EDT)
Message-ID: <20120914.144831.523108873368428472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are the networking fixes that have accumulated over the past few
weeks, most notably:

1) Use after free and new device IDs in bluetooth from Andre Guedes,
   Yevgeniy Melnichuk, Gustavo Padovan, and Henrik Rydberg.

2) Fix crashes with short packet lengths and VLAN in pktgen, from
   Nishank Trivedi.

3) mISDN calls flush_work_sync() with locks held, fix from Karsten
   Keil.

4) Packet scheduler gred parameters are reported to userspace improperl=
y
   scaled, and WRED idling is not performed correctly.  All from
   David Ward.

5) Fix TCP socket refcount problem in ipv6, from Julian Anastasov.

6) ibmveth device has RX queue alignment requirements which are not
   being explicitly met resulting in sporadic failures, fix from
   Santiago Leon.

7) Netfilter needs to take care when interpreting sockets attached
   to socket buffers, they could be time-wait minisockets.  Fix
   from Eric Dumazet.

8) sock_edemux() has the same issue as netfilter did in #7 above,
   fix from Eric Dumazet.

9) Avoid infinite loops in CBQ scheduler with some configurations,
   from Eric Dumazet.

10) Deal with "Reflection scan: an Off-Path Attack on TCP", from
    Jozsef Kadlecsik.

11) SCTP overcharges socket for TX packets, fix from Thomas Graf.

12) CODEL packet scheduler should not reset it's state every
    time it builds a new flow, fix from Eric Dumazet.

13) Fix memory leak in nl80211, from Wei Yongjun.

14) NETROM doesn't check skb_copy_datagram_iovec() return values,
    from Alan Cox.

15) l2tp ethernet was using sizeof(ETH_HLEN) instead of plain
    ETH_HLEN, oops.  From Eric Dumazet.

16) Fix selection of ath9k chips on which PA linearization and
    AM2PM predistoration are used, from Felix Fietkau.

17) Flow steering settings in mlx4 driver need to be validated
    properly, from Hadar Hen Zion.

18) bnx2x doesn't show the correct link duplex setting, from
    Yaniv Rosner.

Please pull, thanks a lot.

The following changes since commit 5b716ac728bcc01b1f2a7ed6e43719660223=
7c27:

  Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6 (2012=
-09-02 11:30:10 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 6af773e786ad617b0264ebe06ba60675c01f3e51=
:

  pktgen: fix crash with vlan and packet size less than 46 (2012-09-13 =
17:10:00 -0400)

----------------------------------------------------------------
Alan Cox (1):
      netrom: copy_datagram_iovec can fail

Andre Guedes (1):
      Bluetooth: Fix use-after-free bug in SMP

Arend van Spriel (1):
      brcmfmac: fix use of dev_kfree_skb() in irq context

Aviad Yehezkel (2):
      net/mlx4_core: Looking for promiscuous entries on the correct por=
t
      net/mlx4_core: Fixing error flow in case of QUERY_FW failure

Beno=EEt Locher (1):
      can: mcp251x: avoid repeated frame bug

Bj=F8rn Mork (2):
      net: usbnet: fix softirq storm on suspend
      net: qmi_wwan: call subdriver with control intf only

Chema Gonzalez (1):
      net: small bug on rxhash calculation

Daniel Drake (1):
      libertas sdio: fix suspend when interface is down

David S. Miller (3):
      Merge branch 'fixes' of git://git.kernel.org/.../jesse/openvswitc=
h
      Merge branch 'fixes-for-3.6' of git://gitorious.org/linux-can/lin=
ux-can
      Merge branch 'master' of git://1984.lsi.us.es/nf

David Ward (4):
      net_sched: gred: correct comment about qavg calculation in RIO mo=
de
      net_sched: gred: eliminate redundant DP prio comparisons
      net_sched: gred: fix qave reporting via netlink
      net_sched: gred: actually perform idling in WRED mode

Dmitry Kravkov (2):
      bnx2x: Avoid sending multiple statistics queries
      bnx2x: fix registers dumped

Eliad Peller (1):
      mac80211: clear bssid on auth/assoc failure

Eric Dumazet (7):
      net: sock_edemux() should take care of timewait sockets
      fq_codel: dont reinit flow state
      l2tp: fix a lockdep splat
      l2tp: fix a typo in l2tp_eth_dev_recv()
      netfilter: take care of timewait sockets
      udp: increment UDP_MIB_INERRORS if copy failed
      net-sched: sch_cbq: avoid infinite loop

Eugenia Emantayev (1):
      net/mlx4_core: Return the error value in case of command initiali=
zation failure

=46elix Fietkau (6):
      ath9k_hw: do not enable the MIB interrupt in the interrupt mask r=
egister
      ath9k_hw: clear the AM2PM predistortion mask on AR933x
      ath9k_hw: calibrate PA input for PA predistortion
      ath9k_hw: disable PA linearization for AR9462
      ath9k: fix PA linearization calibration related crash
      ath9k_hw: enable PA linearization

=46lorian Fainelli (1):
      ixp4xx_hss: fix build failure due to missing linux/module.h inclu=
sion

Gertjan van Wingerde (3):
      rt2x00: Identify ASUS USB-N53 device.
      rt2x00: Fix word size of rt2500usb MAC_CSR19 register.
      rt2x00: Fix rfkill polling prior to interface start.

Gustavo Padovan (1):
      Bluetooth: Use USB_VENDOR_AND_INTERFACE() for Broadcom devices

Hadar Hen Zion (2):
      net/mlx4_core: Put Firmware flow steering structures in common he=
ader files
      net/mlx4_core: Add security check / enforcement for flow steering=
 rules set for VMs

Hante Meuleman (3):
      brcmfmac: dont use ZERO flag for usb IN
      brcmfmac: fix race condition for rx and tx data.
      brcmfmac: fix get rssi by clearing getvar struct.

Henrik Rydberg (1):
      Bluetooth: Add support for Apple vendor-specific devices

Jean Delvare (1):
      |PATCH] seeq: Add missing spinlock init

Jesse Gross (2):
      openvswitch: Relax set header validation.
      openvswitch: Fix FLOW_BUFSIZE definition.

Joe Perches (1):
      netfilter: log: Fix log-level processing

Joe Stringer (1):
      openvswitch: Fix typo

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jozsef Kadlecsik (2):
      netfilter: Mark SYN/ACK packets as invalid from original directio=
n
      netfilter: Validate the sequence number of dataless ACK packets a=
s well

Julian Anastasov (1):
      tcp: fix possible socket refcount problem for ipv6

Karsten Keil (1):
      mISDN: Fix wrong usage of flush_work_sync while holding locks

LEO Airwarosu Yoichi Shinoda (1):
      mac80211: Various small fixes for cfg.c: mpath_set_pinfo()

Lennart Sorensen (1):
      sierra_net: Endianess bug fix.

Marc Kleine-Budde (1):
      rt2x00: fix voltage setting for RT3572/RT3592

Mohammed Shafi Shajakhan (1):
      ath9k: Fix a crash in 2 WIRE btcoex chipsets

Nishank Trivedi (1):
      pktgen: fix crash with vlan and packet size less than 46

Pierre Sauter (1):
      net: qmi_wwan: fix Gobi device probing for un2430

Randy Dunlap (1):
      net: fix net/core/sock.c build error

Santiago Leon (1):
      ibmveth: Fix alignment of rx queue bug

Sergei Poselenov (1):
      rt2800usb: Added rx packet length validity check

Steffen Klassert (1):
      xfrm: Workaround incompatibility of ESN and async crypto

Stone Piao (1):
      mwifiex: fix skb length issue when send a command to firmware

Thomas Graf (1):
      sctp: Don't charge for data in sndbuf again when transmitting pac=
ket

Vinicius Costa Gomes (2):
      Bluetooth: Change signature of smp_conn_security()
      Bluetooth: Fix sending a HCI Authorization Request over LE links

Wei Yongjun (3):
      mISDN: fix possible memory leak in hfcmulti_init()
      nl80211: fix possible memory leak nl80211_connect()
      caif: move the dereference below the NULL test

Wu Fengguang (1):
      i825xx: fix paging fault on znet_probe()

Yaniv Rosner (3):
      bnx2x: prevent timeouts when using PFC
      bnx2x: display the correct duplex value
      bnx2x: correct advertisement of pause capabilities

Yevgeniy Melnichuk (1):
      Bluetooth: Add support for Sony Vaio T-Series

Yuval Mintz (2):
      bnx2x: fix stats copying logic
      bnx2x: Add missing afex code

 drivers/bluetooth/ath3k.c                             |   2 ++
 drivers/bluetooth/btusb.c                             |  12 +++++---
 drivers/isdn/hardware/mISDN/avmfritz.c                |   3 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c                |   2 ++
 drivers/isdn/hardware/mISDN/mISDNipac.c               |   3 +-
 drivers/isdn/hardware/mISDN/mISDNisar.c               |   3 +-
 drivers/isdn/hardware/mISDN/netjet.c                  |   3 +-
 drivers/isdn/hardware/mISDN/w6692.c                   |   3 +-
 drivers/isdn/mISDN/hwchannel.c                        |   9 +++---
 drivers/net/can/mcp251x.c                             |  11 ++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h       |  11 +++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h      |  25 +++++-----=
-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c   |   8 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c      |  18 ++++++----=
-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |  21 ++++++++++=
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c     |  15 ++++++---
 drivers/net/ethernet/i825xx/znet.c                    |  13 +++++---
 drivers/net/ethernet/ibm/ibmveth.c                    |  26 ++++++----=
------
 drivers/net/ethernet/mellanox/mlx4/main.c             |  16 +++++-----
 drivers/net/ethernet/mellanox/mlx4/mcg.c              | 106 +++++++++-=
-----------------------------------------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |  76 ++++++++++=
+++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 116 ++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/seeq/sgiseeq.c                   |   1 +
 drivers/net/usb/qmi_wwan.c                            |   9 +++---
 drivers/net/usb/sierra_net.c                          |   2 +-
 drivers/net/usb/usbnet.c                              |  16 +++++++---
 drivers/net/wan/ixp4xx_hss.c                          |   1 +
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c         | 105 ++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h           |   4 +++
 drivers/net/wireless/ath/ath9k/gpio.c                 |   3 +-
 drivers/net/wireless/ath/ath9k/hw.c                   |  11 +++----
 drivers/net/wireless/ath/ath9k/hw.h                   |   1 +
 drivers/net/wireless/ath/ath9k/link.c                 |  18 +++++-----=
-
 drivers/net/wireless/ath/ath9k/xmit.c                 |   3 ++
 drivers/net/wireless/brcm80211/brcmfmac/usb.c         |  30 +++++++++-=
--------
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  15 ++++-----
 drivers/net/wireless/libertas/if_sdio.c               |   5 +++
 drivers/net/wireless/mwifiex/cmdevt.c                 |  15 ++++++++-
 drivers/net/wireless/rt2x00/rt2400pci.c               |   9 ++++++
 drivers/net/wireless/rt2x00/rt2400pci.h               |   1 +
 drivers/net/wireless/rt2x00/rt2500pci.c               |   9 ++++++
 drivers/net/wireless/rt2x00/rt2500usb.c               |  11 ++++++-
 drivers/net/wireless/rt2x00/rt2500usb.h               |  17 +++++-----
 drivers/net/wireless/rt2x00/rt2800lib.c               |   1 +
 drivers/net/wireless/rt2x00/rt2800pci.c               |   9 ++++++
 drivers/net/wireless/rt2x00/rt2800usb.c               |  22 ++++++++++=
+--
 drivers/net/wireless/rt2x00/rt2x00dev.c               |   2 +-
 drivers/net/wireless/rt2x00/rt61pci.c                 |   9 ++++++
 drivers/net/wireless/rt2x00/rt61pci.h                 |   1 +
 drivers/net/wireless/rt2x00/rt73usb.c                 |   9 ++++++
 drivers/net/wireless/rt2x00/rt73usb.h                 |   3 ++
 include/linux/mISDNhw.h                               |   2 +-
 include/linux/mlx4/device.h                           |  13 ++++++++
 include/net/bluetooth/smp.h                           |   2 +-
 include/net/xfrm.h                                    |   3 ++
 net/bluetooth/hci_conn.c                              |   4 +++
 net/bluetooth/l2cap_core.c                            |  11 ++++---
 net/bluetooth/l2cap_sock.c                            |   2 +-
 net/bluetooth/smp.c                                   |  10 +++---
 net/bridge/netfilter/ebt_log.c                        |   2 +-
 net/caif/cfsrvl.c                                     |   5 +--
 net/core/dev.c                                        |  11 ++++---
 net/core/pktgen.c                                     |   2 +-
 net/core/sock.c                                       |   9 +++++-
 net/ipv4/udp.c                                        |   5 +++
 net/ipv6/tcp_ipv6.c                                   |   5 +--
 net/ipv6/udp.c                                        |  11 +++++++
 net/l2tp/l2tp_core.c                                  |   4 +++
 net/l2tp/l2tp_eth.c                                   |   2 +-
 net/mac80211/cfg.c                                    |   9 +++---
 net/mac80211/mlme.c                                   |   4 +++
 net/netfilter/nf_conntrack_proto_tcp.c                |  29 ++++++----=
--------
 net/netfilter/nfnetlink_log.c                         |  14 +++++----
 net/netfilter/xt_LOG.c                                |  37 ++++++++++=
+-----------
 net/netrom/af_netrom.c                                |   7 ++++-
 net/openvswitch/actions.c                             |   2 +-
 net/openvswitch/datapath.c                            |   6 ++--
 net/openvswitch/flow.h                                |   8 +++--
 net/sched/sch_cbq.c                                   |   5 +--
 net/sched/sch_fq_codel.c                              |   2 +-
 net/sched/sch_gred.c                                  |  38 ++++++++++=
+++----------
 net/sctp/output.c                                     |  21 ++++++++++=
++-
 net/wireless/nl80211.c                                |   4 ++-
 net/xfrm/xfrm_input.c                                 |   2 +-
 net/xfrm/xfrm_replay.c                                |  15 +++++++++
 85 files changed, 808 insertions(+), 342 deletions(-)
