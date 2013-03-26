From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 26 Mar 2013 15:31:30 -0400 (EDT)
Message-ID: <20130326.153130.1796091339459697935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab3CZTbj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 15:31:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Always increment IPV4 ID field in encapsulated GSO packets, even whe=
n DF
   is set.  Regression fix from Pravin B Shelar.

2) Fix per-net subsystem initialization in netfilter conntrack, otherwi=
se
   we may access dynamically allocated memory before it is actually
   allocated.  From Gao Feng.

3) Fix DMA buffer lengths in iwl3945 driver, from Stanislaw Gruszka.

4) Fix race between submission of sync vs. async commands in mwifiex
   driver, from Amitkumar Karwar.

5) Add missing cancel of command timer in mwifiex driver, from Bing
   Zhao.

6) Missing SKB free in rtlwifi USB driver, from Jussi Kivilinna.

7) Thermal layer tries to use a genetlink multicast string that is
   longer than the 16 character limit.  Fix it and add a BUG check
   to prevent this kind of thing from happening in the future.

   From Masatake YAMATO.

8) Fix many bugs in the handling of the teardown of L2TP connections,
   UDP encapsulation instances, and sockets.  From Tom Parkin.

9) Missing socket release in IRDA, from Kees Cook.

10) Fix fec driver modular build, from Fabio Estevam.

11) Erroneous use of kfree() instead of free_netdev() in lantiq_etop, f=
rom
    Wei Yongjun.

12) Fix bugs in handling of queue numbers and steering rules in mlx4 dr=
iver,
    from Moshe Lazer, Hadar Hen Zion, and Or Gerlitz.

13) Some FOO_DIAG_MAX constants were defined off by one, fix from Andre=
y Vagin.

14) TCP segmentation deferral is unintentionally done too strongly, bre=
aking
    ACK clocking.  Fix from Eric Dumazet.

15) net_enable_timestamp() can legitimately be invoked from software
    interrupts, and in a way that is safe, so remove the WARN_ON().
    Also from Eric Dumazet.

16) Fix use after free in VLANs, from Cong Wang.

17) Fix TCP slow start retransmit storms after SACK reneging, from
    Yuchung Cheng.

18) Unix socket release should mark a socket dead before NULL'ing
    out sock->sk, otherwise we can race.  Fix from Paul Moore.

19) IPV6 addrconf code can try to free static memory, from Hong Zhiguo.

20) Fix register mis-programming, NULL pointer derefs, and wrong PHC cl=
ock
    frequency in IGB driver.  From Lior LevyAlex Williamson, Jiri Benc,=
 and
    Jeff Kirsher.

21) skb->ip_summed logic in pch_gbe driver is reversed, breaking packet
    forwarding.  Fix from Veaceslav Falico.

22) Bonding driver leaks 'master' sysfs file on slave sysfs file creati=
on
    failure.  Fix also from Veaceslav Falico.

The following changes since commit 10b38669d64c757cfd927e3820292c580ed7=
0aae:

  Merge tag 'for-linus-v3.9-rc4' of git://oss.sgi.com/xfs/xfs (2013-03-=
19 15:17:40 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 330305cc4a6b0cb75c22fc01b8826f0ad755550f=
:

  ipv4: Fix ip-header identification for gso packets. (2013-03-26 13:50=
:05 -0400)

----------------------------------------------------------------
Alex Williamson (2):
      igb: Fix null pointer dereference
      igb: SR-IOV init reordering

Amitkumar Karwar (1):
      mwifiex: fix race when queuing commands

Andrey Vagin (1):
      net: fix *_DIAG_MAX constants

Bing Zhao (2):
      mwifiex: skip pending commands after function shutdown
      mwifiex: cancel cmd timer and free curr_cmd in shutdown process

Cong Wang (1):
      8021q: fix a potential use-after-free

Daniel Borkmann (1):
      flow_keys: include thoff into flow_keys for later usage

David S. Miller (5):
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge branch 'l2tp'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'mlx4'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net

Eric Dumazet (2):
      tcp: preserve ACK clocking in TSO
      net: remove a WARN_ON() in net_enable_timestamp()

=46abio Estevam (2):
      net: fec: Define indexes as 'unsigned int'
      fec: Fix the build as module

=46elix Fietkau (2):
      ath9k_hw: revert chainmask to user configuration after calibratio=
n
      ath9k: limit tx path hang check to normal data queues

=46lorian Westphal (1):
      netfilter: ip6t_NPT: restrict to mangle table

Gao feng (1):
      netfilter: nf_conntrack: register pernet subsystem before registe=
r L4 proto

Hadar Hen Zion (4):
      net/mlx4_core: Fix wrong order of flow steering resources removal
      net/mlx4_en: Remove ethtool flow steering rules before releasing =
QPs
      net/mlx4_core: Always use 64 bit resource ID when doing lookup
      net/mlx4_core: Disallow releasing VF QPs which have steering rule=
s

Hong Zhiguo (1):
      ipv6: fix bad free of addrconf_init_net

Hong zhi guo (1):
      bridge: fix crash when set mac address of br interface

Jiri Benc (1):
      igb: fix PHC stopping on max freq

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Julian Anastasov (3):
      ipvs: fix sctp chunk length order
      ipvs: add backup_only flag to avoid loops
      ipvs: remove extra rcu lock

Jussi Kivilinna (1):
      rtlwifi: usb: add missing freeing of skbuff

Kees Cook (1):
      net/irda: add missing error path release_sock call

Kumar Amit Mehta (1):
      bnx2x: fix assignment of signed expression to unsigned variable

Lior Levy (1):
      igb: fix i350 anti spoofing config

Lothar Wa=DFmann (1):
      net: ethernet: cpsw: fix erroneous condition in error check

Martin Fuzzey (1):
      ipconfig: Fix newline handling in log message.

Masatake YAMATO (2):
      genetlink: trigger BUG_ON if a group name is too long
      thermal: shorten too long mcast group name

Ming Lei (2):
      Bluetooth: Add support for Dell[QCA 0cf3:0036]
      Bluetooth: Add support for Dell[QCA 0cf3:817a]

Moshe Lazer (1):
      net/mlx4_core: Fix wrong mask applied on EQ numbers in the wrappe=
r

Pablo Neira Ayuso (1):
      netfilter: nfnetlink_queue: fix incorrect initialization of copy =
range field

Paul Bolle (1):
      netfilter: remove unused "config IP_NF_QUEUE"

Paul Moore (1):
      unix: fix a race condition in unix_release()

Pravin B Shelar (1):
      ipv4: Fix ip-header identification for gso packets.

Sergei Shtylyov (2):
      sh_eth: fix bitbang memory leak
      sh_eth: check TSU registers ioremap() error

Stanislaw Gruszka (1):
      iwl3945: fix length of dma buffers

Stephen Hemminger (1):
      igb: make sensor info static

Tom Parkin (12):
      udp: add encap_destroy callback
      l2tp: add udp encap socket destroy handler
      l2tp: export l2tp_tunnel_closeall
      l2tp: close sessions in ip socket destroy callback
      l2tp: close sessions before initiating tunnel delete
      l2tp: take a reference for kernel sockets in l2tp_tunnel_sock_loo=
kup
      l2tp: don't BUG_ON sk_socket being NULL
      l2tp: add session reorder queue purge function to core
      l2tp: purge session reorder queue on delete
      l2tp: push all ppp pseudowire shutdown through .release handler
      l2tp: avoid deadlock in l2tp stats update
      l2tp: unhash l2tp sessions on delete, not on free

Veaceslav Falico (2):
      pch_gbe: fix ip_summed checksum reporting on rx
      bonding: remove already created master sysfs link on failure

Vinicius Costa Gomes (1):
      Bluetooth: Fix not closing SCO sockets in the BT_CONNECT2 state

Wei Yongjun (2):
      lpc_eth: fix error return code in lpc_eth_drv_probe()
      lantiq_etop: use free_netdev(netdev) instead of kfree()

Yuchung Cheng (1):
      tcp: undo spurious timeout after SACK reneging

dingtianhong (1):
      af_unix: dont send SCM_CREDENTIAL when dest socket is NULL

xunleer (1):
      ixgbevf: don't release the soft entries

 Documentation/networking/ipvs-sysctl.txt              |   7 +++
 drivers/bluetooth/ath3k.c                             |   4 ++
 drivers/bluetooth/btusb.c                             |   2 +
 drivers/net/bonding/bond_sysfs.c                      |   5 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c       |  18 +++---
 drivers/net/ethernet/freescale/fec.c                  |   6 +-
 drivers/net/ethernet/freescale/fec_ptp.c              |   3 +
 drivers/net/ethernet/intel/igb/e1000_82575.c          |  33 +++++-----
 drivers/net/ethernet/intel/igb/igb_hwmon.c            |   2 +-
 drivers/net/ethernet/intel/igb/igb_main.c             |   4 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c              |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c     |  24 +++++--
 drivers/net/ethernet/lantiq_etop.c                    |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  22 +++----
 drivers/net/ethernet/mellanox/mlx4/eq.c               |   2 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  45 ++++++++++=
---
 drivers/net/ethernet/nxp/lpc_eth.c                    |   3 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c  |   4 +-
 drivers/net/ethernet/renesas/sh_eth.c                 |  10 +++
 drivers/net/ethernet/renesas/sh_eth.h                 |   1 +
 drivers/net/ethernet/ti/cpsw.c                        |   2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c         |   4 ++
 drivers/net/wireless/ath/ath9k/link.c                 |  26 ++++----
 drivers/net/wireless/iwlegacy/3945-mac.c              |  22 ++++---
 drivers/net/wireless/mwifiex/cmdevt.c                 |  22 +++++--
 drivers/net/wireless/mwifiex/init.c                   |   8 +++
 drivers/net/wireless/mwifiex/main.h                   |   4 +-
 drivers/net/wireless/mwifiex/scan.c                   |   8 +--
 drivers/net/wireless/mwifiex/sta_ioctl.c              |  10 +--
 drivers/net/wireless/rtlwifi/usb.c                    |   1 +
 include/linux/thermal.h                               |   2 +-
 include/linux/udp.h                                   |   1 +
 include/net/flow_keys.h                               |   1 +
 include/net/ip_vs.h                                   |  12 ++++
 include/net/ipip.h                                    |  16 ++---
 include/uapi/linux/packet_diag.h                      |   4 +-
 include/uapi/linux/unix_diag.h                        |   4 +-
 net/8021q/vlan.c                                      |  14 ++---
 net/bluetooth/sco.c                                   |   1 +
 net/bridge/br_fdb.c                                   |   2 +-
 net/core/dev.c                                        |   1 -
 net/core/flow_dissector.c                             |   2 +
 net/ipv4/af_inet.c                                    |   3 +-
 net/ipv4/ipconfig.c                                   |   3 +-
 net/ipv4/netfilter/Kconfig                            |  13 ----
 net/ipv4/tcp_input.c                                  |   7 +--
 net/ipv4/tcp_output.c                                 |   7 ++-
 net/ipv4/udp.c                                        |   7 +++
 net/ipv6/addrconf.c                                   |  26 +++-----
 net/ipv6/netfilter/ip6t_NPT.c                         |   2 +
 net/ipv6/udp.c                                        |   8 +++
 net/irda/af_irda.c                                    |   6 +-
 net/l2tp/l2tp_core.c                                  | 206 ++++++++++=
+++++++++++++++++++-------------------------------
 net/l2tp/l2tp_core.h                                  |  22 ++++---
 net/l2tp/l2tp_debugfs.c                               |  28 ++++-----
 net/l2tp/l2tp_ip.c                                    |   6 ++
 net/l2tp/l2tp_ip6.c                                   |   7 +++
 net/l2tp/l2tp_netlink.c                               |  72 +++++++++-=
-----------
 net/l2tp/l2tp_ppp.c                                   | 111 ++++++++++=
+---------------------
 net/netfilter/ipvs/ip_vs_core.c                       |  14 +++--
 net/netfilter/ipvs/ip_vs_ctl.c                        |   7 +++
 net/netfilter/ipvs/ip_vs_proto_sctp.c                 |  16 ++---
 net/netfilter/nf_conntrack_proto_dccp.c               |  12 ++--
 net/netfilter/nf_conntrack_proto_gre.c                |  12 ++--
 net/netfilter/nf_conntrack_proto_sctp.c               |  12 ++--
 net/netfilter/nf_conntrack_proto_udplite.c            |  12 ++--
 net/netfilter/nfnetlink_queue_core.c                  |   2 +-
 net/netlink/genetlink.c                               |   1 +
 net/unix/af_unix.c                                    |  11 ++--
 69 files changed, 540 insertions(+), 459 deletions(-)
