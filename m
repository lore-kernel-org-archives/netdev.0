From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 01 Dec 2013 21:30:42 -0500 (EST)
Message-ID: <20131201.213042.706633058656354133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here is a pile of bug fixes that accumulated while I was in Europe.

1) In fixing kernel leaks to userspace during copying of socket
   addresses, we broke a case that used to work, namely the user
   providing a buffer larger than the in-kernel generic socket address
   structure.  This broke Ruby amongst other things.  Fix from Dan
   Carpenter.

2) Fix regression added by byte queue limit support in 8139cp driver,
   from Yang Yingliang.

3) The addition of MSG_SENDPAGE_NOTLAST buggered up a few sendpage
   implementations, they should just treat it the same as MSG_MORE.
   Fix from Richard Weinberger and Shawn Landden.

4) Handle icmpv4 errors received on ipv6 SIT tunnels correctly,
   from Oussama Ghorbel.  In particular we should send an ICMPv6
   unreachable in such situations.

5) Fix some regressions in the recent genetlink fixes, in particular
   get the pmcraid driver to use the new safer interfaces correctly.
   From Johannes Berg.

6) macvtap was converted to use a per-cpu set of statistics, but some
   code was still bumping tx_dropped elsewhere.  From Jason Wang.

7) Fix build failure of xen-netback due to missing include on some
   architectures, from Andy Whitecroft.

8) macvtap double counts received packets in statistics, fix from
   Vlad Yasevich.

9) Fix various cases of using *_STATS_BH() when *_STATS() is more
   appropriate.  From Eric Dumazet and Hannes Frederic Sowa.

10) Pktgen ipsec mode doesn't update the ipv4 header length and
    checksum properly after encapsulation.  Fix from Fan Du.

Please pull, thanks a lot!

The following changes since commit 9d8506cc2d7ea1f911c72c100193a3677f66=
68c3:

  gso: handle new frag_list of frags GRO packets (2013-11-21 14:11:50 -=
0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 833846e8fa0c51fb3e47bca8adfdd7b10643b737=
:

  net/mlx4_en: Remove selftest TX queues empty condition (2013-12-01 20=
:36:07 -0500)

----------------------------------------------------------------
Ajit Khaparde (3):
      be2net: Disabling and enabling interrupts in suspend and resume
      be2net: set coalesce-wm in CQ_CREATE_V2 cmd
      be2net: Avoid programming permenant MAC by BE3-R VFs

Akeem G Abodunrin (1):
      igb: Fixed Wake On LAN support

Andy Whitcroft (1):
      xen-netback: include definition of csum_ipv6_magic

Arvid Brodin (3):
      MAINTAINERS: Added net/hsr/ maintainer
      net/hsr: Very small fix of comment style.
      net/hsr: Support iproute print_opt ('ip -details ...')

Baker Zhang (1):
      net: remove outdated comment for ipv4 and ipv6 protocol handler

Chang Xiangzhong (1):
      net: sctp: find the correct highest_new_tsn in sack

Dan Carpenter (1):
      net: clamp ->msg_namelen instead of returning an error

David Chang (1):
      r8169: check ALDPS bit and disable it if enabled for the 8168g

David S. Miller (4):
      Merge branch 'fixes-for-3.13-20131127' of git://gitorious.org/lin=
ux-can/linux-can
      Revert "be2net: call napi_disable() for all event queues"
      Revert "net: smc91: fix crash regression on the versatile"
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net

Eric Dumazet (2):
      sch_tbf: handle too small burst
      inet: fix possible seqlock deadlocks

Eugenia Emantayev (1):
      net/mlx4_en: Remove selftest TX queues empty condition

Gao feng (2):
      tcp_memcg: remove useless var old_lim
      sit: use kfree_skb to replace dev_kfree_skb

Geert Uytterhoeven (1):
      genetlink: Fix uninitialized variable in genl_validate_assign_mc_=
groups()

Guenter Roeck (2):
      tg3: Convert to use hwmon_device_register_with_groups
      sfc: Convert to use hwmon_device_register_with_groups

Hannes Frederic Sowa (3):
      inet: fix addr_len/msg->msg_namelen assignment in recv_error and =
rxpmtu functions
      ipv6: fix leaking uninitialized port number of offender sockaddr
      ipv6: fix possible seqlock deadlock in ip6_finish_output2

Herbert Xu (2):
      gro: Only verify TCP checksums for candidates
      gro: Clean up tcpX_gro_receive checksum verification

Holger Bechtold (1):
      can: c_can: fix calculation of transmitted bytes on tx complete

Ivan Vecera (2):
      be2net: call napi_disable() for all event queues
      be2net: call napi_disable() for all event queues

Jason Wang (1):
      macvtap: fix tx_dropped counting error

Jiri Pirko (1):
      team: fix master carrier set when user linkup is enabled

Johannes Berg (1):
      genetlink/pmcraid: use proper genetlink multicast API

John Fastabend (2):
      ixgbe: ixgbe_fwd_ring_down needs to be static
      ixgbe: turn NETIF_F_HW_L2FW_DOFFLOAD off by default

Linus Walleij (2):
      net: smc91: fix crash regression on the versatile
      net: smc91: fix crash regression on the versatile

Marc Kleine-Budde (2):
      can: c_can: don't call pm_runtime_get_sync() from interrupt conte=
xt
      can: flexcan: use correct clock as base for bit rate calculation

Mark Rustad (1):
      ixgbe: Make ixgbe_identify_qsfp_module_generic static

Michael S. Tsirkin (2):
      virtio_net: fix error handling for mergeable buffers
      virtio_net: make all RX paths handle erors consistently

Nicolas Dichtel (1):
      diag: warn about missing first netlink attribute

Oliver Hartkopp (1):
      can: sja1000: fix {pre,post}_irq() handling and IRQ handler retur=
n value

Oussama Ghorbel (1):
      sit: generate icmpv6 error when receiving icmpv4 error

Shaohui Xie (1):
      phy: Add Vitesse 8514 phy ID

Shawn Landden (1):
      net: update consumers of MSG_MORE to recognize MSG_SENDPAGE_NOTLA=
ST

Thomas Huth (1):
      virtio_net: Fixed a trivial typo (fitler --> filter)

Veaceslav Falico (1):
      af_packet: block BH in prb_shutdown_retire_blk_timer()

Vlad Yasevich (1):
      macvtap: Do not double-count received packets

Vladimir Davydov (2):
      e1000: fix lockdep warning in e1000_reset_task
      e1000: fix possible reset_task running after adapter down

Xufeng Zhang (1):
      sctp: Restore 'resent' bit to avoid retransmitted chunks for RTT =
measurements

Yang Yingliang (1):
      net: 8139cp: fix a BUG_ON triggered by wrong bytes_compl

dingtianhong (1):
      bonding: disable arp and enable mii monitoring when bond change t=
o no uses arp mode

fan.du (1):
      {pktgen, xfrm} Update IPv4 header total len and checksum after tr=
anformation

fran=E7ois romieu (1):
      via-velocity: fix netif_receive_skb use in irq disabled section.

stephen hemminger (3):
      netem: missing break in ge loss generator
      netem: fix loss 4 state model
      netem: fix gemodel loss generator

yzhu1 (1):
      e1000: prevent oops when adapter is being closed and reset simult=
aneously

 MAINTAINERS                                      |   6 +++
 crypto/algif_hash.c                              |   3 ++
 crypto/algif_skcipher.c                          |   3 ++
 drivers/net/bonding/bond_main.c                  |   4 +-
 drivers/net/bonding/bond_options.c               |  13 ++++--
 drivers/net/bonding/bond_sysfs.c                 |   4 +-
 drivers/net/bonding/bonding.h                    |   7 ++++
 drivers/net/can/c_can/c_can.c                    |  22 +++++++---
 drivers/net/can/flexcan.c                        |   2 +-
 drivers/net/can/sja1000/sja1000.c                |  17 ++++----
 drivers/net/ethernet/broadcom/tg3.c              |  25 +++---------
 drivers/net/ethernet/emulex/benet/be.h           |   1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c      |   7 ++++
 drivers/net/ethernet/emulex/benet/be_main.c      |  16 ++++----
 drivers/net/ethernet/intel/e1000/e1000.h         |   7 +++-
 drivers/net/ethernet/intel/e1000/e1000_main.c    |  60 +++++++++++----=
------------
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   7 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   9 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h     |   1 -
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |   7 ----
 drivers/net/ethernet/realtek/8139cp.c            |   5 +--
 drivers/net/ethernet/realtek/r8169.c             |   5 +++
 drivers/net/ethernet/sfc/mcdi.h                  |   2 +
 drivers/net/ethernet/sfc/mcdi_mon.c              |  78 ++++++++++++++-=
--------------------
 drivers/net/ethernet/smsc/smc91x.h               |  22 ++--------
 drivers/net/ethernet/via/via-velocity.c          |  11 ++---
 drivers/net/macvtap.c                            |  12 +-----
 drivers/net/phy/vitesse.c                        |  15 +++++++
 drivers/net/team/team.c                          |   4 ++
 drivers/net/virtio_net.c                         | 136 +++++++++++++++=
+++++++++++++++++++++++++----------------------
 drivers/net/xen-netback/netback.c                |   1 +
 drivers/scsi/pmcraid.c                           |  20 ++++++---
 include/net/ip.h                                 |   2 +-
 include/net/ipv6.h                               |   6 ++-
 include/net/ping.h                               |   3 +-
 include/net/sctp/structs.h                       |   1 +
 include/uapi/linux/genetlink.h                   |   1 +
 include/uapi/linux/if_link.h                     |   4 +-
 include/uapi/linux/netlink_diag.h                |   1 +
 include/uapi/linux/packet_diag.h                 |   1 +
 include/uapi/linux/unix_diag.h                   |   1 +
 net/compat.c                                     |   2 +-
 net/core/pktgen.c                                |   7 ++++
 net/hsr/hsr_framereg.c                           |   3 +-
 net/hsr/hsr_netlink.c                            |  28 +++++++++++++
 net/ipv4/ip_sockglue.c                           |   3 +-
 net/ipv4/ping.c                                  |   7 ++--
 net/ipv4/protocol.c                              |   8 ----
 net/ipv4/raw.c                                   |   2 +-
 net/ipv4/tcp_ipv4.c                              |   2 +-
 net/ipv4/tcp_memcontrol.c                        |   2 -
 net/ipv4/tcp_offload.c                           |  31 +++++++-------
 net/ipv4/udp.c                                   |   7 +++-
 net/ipv6/datagram.c                              |   8 +++-
 net/ipv6/ip6_output.c                            |   4 +-
 net/ipv6/ping.c                                  |   3 +-
 net/ipv6/protocol.c                              |   4 --
 net/ipv6/raw.c                                   |   4 +-
 net/ipv6/sit.c                                   |  50 +++++++++++++++=
+++-----
 net/ipv6/tcpv6_offload.c                         |  32 +++++++--------
 net/ipv6/udp.c                                   |   4 +-
 net/l2tp/l2tp_ip6.c                              |   2 +-
 net/netlink/genetlink.c                          |  13 ++++--
 net/packet/af_packet.c                           |   4 +-
 net/sched/sch_netem.c                            |   7 ++--
 net/sched/sch_tbf.c                              |  32 +++++++++++----
 net/sctp/output.c                                |   3 +-
 net/sctp/outqueue.c                              |   6 ++-
 net/socket.c                                     |   2 +-
 70 files changed, 491 insertions(+), 344 deletions(-)
