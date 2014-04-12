From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 12 Apr 2014 17:42:00 -0400 (EDT)
Message-ID: <20140412.174200.277517786111079219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Various fixes to the new Redpine Signals wireless driver, from
   Fariya Fatima.

2) L2TP PPP connect code takes PMTU from the wrong socket, fix from
   Dmitry Petukhov.

3) UFO and TSO packets differ in whether they include the protocol head=
er
   in gso_size, account for that in skb_gso_transport_seglen().  From
   Florian Westphal.

4) If VLAN untagging fails, we double free the SKB in the bridging
   output path.  From Toshiaki Makita.

5) Several call sites of sk->sk_data_ready() were referencing an SKB
   just added to the socket receive queue in order to calculate the
   second argument via skb->len.  This is dangerous because the
   moment the skb is added to the receive queue it can be consumed
   in another context and freed up.

   It turns out also that none of the sk->sk_data_ready()
   implementations even care about this second argument.

   So just kill it off and thus fix all these use-after-free bugs as a
   side effect.

6) Fix inverted test in tcp_v6_send_response(), from Lorenzo Colitti.

7) pktgen needs to do locking properly for LLTX devices, from Daniel
   Borkmann.

8) xen-netfront driver initializes TX array entries in RX loop :-)
   From Vincenzo Maffione.

9) After refactoring, some tunnel drivers allow a tunnel to be
   configured on top itself.  Fix from Nicolas Dichtel.

Please pull, thanks a lot!

The following changes since commit ce7613db2d8d4d5af2587ab5d7090055c456=
2201:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-0=
4-08 12:41:23 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to eda43ce03919f2b929a884fddbefa98cfb04fec9=
:

  Merge branch 'tunnels' (2014-04-12 17:03:20 -0400)

----------------------------------------------------------------

Balakumaran Kannan (1):
      net phylib: Remove unnecessary condition check in phy

Chun-Yeow Yeoh (1):
      ath9k_htc: set IEEE80211_TX_STAT_AMPDU for acked aggregated frame=
s

Daniel Borkmann (2):
      net: sctp: test if association is dead in sctp_wake_up_waiters
      pktgen: be friendly to LLTX devices

David S. Miller (6):
      Merge branch 'hyperv'
      net: Fix use after free by removing length arg from sk_data_ready=
 callbacks.
      Merge branch 'cpsw'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'tunnels'

Dmitry Petukhov (1):
      l2tp: take PMTU from tunnel UDP socket

Duan Jiong (1):
      net/apne: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO

=46ariya Fatima (6):
      rsi: Potential null pointer derefernce issue fixed.
      rsi: Fixed signedness bug reported by static code analyzer.
      rsi: Fixed issue relating to variable de-referenced before check =
'adapter'
      rsi: Fixed issue relating to return value.
      rsi: Fixed issue relating to index of q_num.
      rsi: Fixed issue relating to doing dma on stack error.

=46elix Fietkau (2):
      ath9k_hw: reduce ANI firstep range for older chips
      ath9k: fix a scheduling while atomic bug in CSA handling

=46lorian Westphal (1):
      net: core: don't account for udp header size when computing segle=
n

=46rancois Romieu (8):
      ixgbe: remove open-coded skb_cow_head
      ixgbevf: remove open-coded skb_cow_head
      e1000: remove open-coded skb_cow_head
      e1000e: remove open-coded skb_cow_head
      igb: remove open-coded skb_cow_head
      igbvf: remove open-coded skb_cow_head
      ixgb: remove open-coded skb_cow_head
      i40evf: remove open-coded skb_cow_head

Jakub Kicinski (2):
      e1000: remove debug messages with function names
      igb: fix last_rx_timestamp usage

Janusz Dziedzic (1):
      ath9k: Enable DFS only when ATH9K_DFS_CERTIFIED

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

KY Srinivasan (3):
      Drivers: net: hyperv: Allocate memory for all possible per-pecket=
 information
      Drivers: net: hyperv: Negotiate suitable ndis version for offload=
 support
      Drivers: net: hyperv: Address UDP checksum issues

Lorenzo Colitti (1):
      net: ipv6: Fix oif in TCP SYN+ACK route lookup.

Marc Zyngier (1):
      net: sun4i-emac: add promiscuous support

Mark Rustad (2):
      ixgbe: Add bit to mark service task initialization
      ixgbevf: Add bit to mark work queue initialization

Mitch A Williams (1):
      i40evf: program RSS LUT correctly

Mugunthan V N (3):
      drivers: net: cpsw: Add default vlan for dual emac case also
      drivers: net: cpsw: discard all packets received when interface i=
s down
      drivers: net: cpsw: enable interrupts after napi enable and clear=
ing previous interrupts

Nicolas Dichtel (2):
      gre: don't allow to add the same tunnel twice
      vti: don't allow to add the same tunnel twice

Paul Bolle (1):
      rtlwifi: btcoexist: remove undefined Kconfig macros

Rafa=A9=A9 Mi=A9=A9ecki (1):
      b43: Fix machine check error due to improper access of B43_MMIO_P=
SM_PHY_HDR

Thomas Richter (1):
      bonding: Remove debug_fs files when module init fails

Toshiaki Makita (1):
      bridge: Fix double free and memory leak around br_allowed_ingress

Vincenzo Maffione (1):
      drivers: net: xen-netfront: fix array initialization bug

hayeswang (1):
      r8152: check RTL8152_UNPLUG

 drivers/net/bonding/bond_main.c                               |   1 +
 drivers/net/ethernet/8390/apne.c                              |   4 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c                   |  30 ++=
+++++----
 drivers/net/ethernet/intel/e1000/e1000_hw.c                   | 124 --=
--------------------------------------------
 drivers/net/ethernet/intel/e1000/e1000_main.c                 |  11 ++=
--
 drivers/net/ethernet/intel/e1000e/netdev.c                    |  10 ++=
--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c                 |  10 ++=
--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c               |  20 ++=
++++--
 drivers/net/ethernet/intel/igb/igb.h                          |  16 +-=
----
 drivers/net/ethernet/intel/igb/igb_main.c                     |  13 ++=
---
 drivers/net/ethernet/intel/igb/igb_ptp.c                      |  14 ++=
+---
 drivers/net/ethernet/intel/igbvf/netdev.c                     |  16 ++=
+---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c                   |  10 ++=
--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h                      |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c                 |  28 ++=
++++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h                  |   1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c             |  20 ++=
+++---
 drivers/net/ethernet/ti/cpsw.c                                |  17 ++=
+----
 drivers/net/hyperv/hyperv_net.h                               |   1 +
 drivers/net/hyperv/netvsc.c                                   |   2 +-
 drivers/net/hyperv/netvsc_drv.c                               |  30 ++=
++++++++-
 drivers/net/hyperv/rndis_filter.c                             |  12 ++=
++-
 drivers/net/phy/phy.c                                         |   6 +-=
-
 drivers/net/usb/r8152.c                                       |  48 ++=
++++++++++++++++
 drivers/net/wireless/ath/ath9k/ar5008_phy.c                   |   4 +-
 drivers/net/wireless/ath/ath9k/beacon.c                       |   7 ++=
-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c                 |   5 +-
 drivers/net/wireless/ath/ath9k/init.c                         |   2 +
 drivers/net/wireless/b43/phy_n.c                              |  14 ++=
+---
 drivers/net/wireless/rsi/rsi_91x_core.c                       |   6 ++=
-
 drivers/net/wireless/rsi/rsi_91x_debugfs.c                    |  35 ++=
++++-------
 drivers/net/wireless/rsi/rsi_91x_mgmt.c                       |   8 +-=
-
 drivers/net/wireless/rsi/rsi_91x_sdio.c                       |   5 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c                   |   6 +-=
-
 drivers/net/wireless/rsi/rsi_91x_usb.c                        |  26 ++=
+++++---
 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c         |  10 --=
--
 drivers/net/xen-netfront.c                                    |   2 +-
 drivers/scsi/iscsi_tcp.c                                      |   2 +-
 drivers/scsi/iscsi_tcp.h                                      |   2 +-
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c |   4 +-
 drivers/target/iscsi/iscsi_target_core.h                      |   2 +-
 drivers/target/iscsi/iscsi_target_nego.c                      |   2 +-
 fs/dlm/lowcomms.c                                             |   2 +-
 fs/ncpfs/ncp_fs_sb.h                                          |   4 +-
 fs/ncpfs/sock.c                                               |   4 +-
 fs/ocfs2/cluster/tcp.c                                        |  15 ++=
+---
 fs/ocfs2/cluster/tcp_internal.h                               |   2 +-
 include/linux/sunrpc/svcsock.h                                |   2 +-
 include/net/sctp/sctp.h                                       |   2 +-
 include/net/sock.h                                            |   2 +-
 net/atm/clip.c                                                |   2 +-
 net/atm/lec.c                                                 |  10 ++=
--
 net/atm/mpc.c                                                 |   6 +-=
-
 net/atm/raw.c                                                 |   2 +-
 net/atm/signaling.c                                           |   2 +-
 net/ax25/ax25_in.c                                            |   2 +-
 net/bluetooth/l2cap_sock.c                                    |   6 +-=
-
 net/bluetooth/rfcomm/core.c                                   |   4 +-
 net/bluetooth/rfcomm/sock.c                                   |   4 +-
 net/bluetooth/sco.c                                           |   2 +-
 net/bridge/br_input.c                                         |   2 +-
 net/bridge/br_vlan.c                                          |   7 +-=
-
 net/caif/caif_socket.c                                        |   4 +-
 net/ceph/messenger.c                                          |   2 +-
 net/core/pktgen.c                                             |   8 ++=
-
 net/core/skbuff.c                                             |  16 ++=
+---
 net/core/sock.c                                               |   4 +-
 net/dccp/input.c                                              |   2 +-
 net/dccp/minisocks.c                                          |   2 +-
 net/decnet/dn_nsp_in.c                                        |   4 +-
 net/ipv4/ip_gre.c                                             |   2 +-
 net/ipv4/ip_vti.c                                             |   2 +-
 net/ipv4/tcp_input.c                                          |  10 ++=
--
 net/ipv4/tcp_ipv4.c                                           |   2 +-
 net/ipv4/tcp_minisocks.c                                      |   2 +-
 net/ipv6/tcp_ipv6.c                                           |   2 +-
 net/iucv/af_iucv.c                                            |   4 +-
 net/key/af_key.c                                              |   2 +-
 net/l2tp/l2tp_ppp.c                                           |   4 +-
 net/netlink/af_netlink.c                                      |   4 +-
 net/netrom/af_netrom.c                                        |   2 +-
 net/nfc/llcp_core.c                                           |   2 +-
 net/packet/af_packet.c                                        |   6 +-=
-
 net/phonet/pep-gprs.c                                         |   4 +-
 net/phonet/pep.c                                              |   8 ++=
-
 net/rds/tcp.h                                                 |   4 +-
 net/rds/tcp_listen.c                                          |   6 +-=
-
 net/rds/tcp_recv.c                                            |   8 +-=
-
 net/rose/af_rose.c                                            |   2 +-
 net/rxrpc/ar-input.c                                          |   6 +-=
-
 net/rxrpc/ar-internal.h                                       |   2 +-
 net/sctp/socket.c                                             |   8 ++=
-
 net/sctp/ulpqueue.c                                           |   4 +-
 net/sunrpc/svcsock.c                                          |  12 ++=
---
 net/sunrpc/xprtsock.c                                         |   8 +-=
-
 net/tipc/server.c                                             |   4 +-
 net/tipc/socket.c                                             |   6 +-=
-
 net/unix/af_unix.c                                            |   6 +-=
-
 net/vmw_vsock/vmci_transport_notify.c                         |   2 +-
 net/vmw_vsock/vmci_transport_notify_qstate.c                  |   4 +-
 net/x25/af_x25.c                                              |   2 +-
 net/x25/x25_in.c                                              |   2 +-
 102 files changed, 420 insertions(+), 433 deletions(-)
