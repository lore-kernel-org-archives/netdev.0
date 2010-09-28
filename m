From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 28 Sep 2010 00:22:59 -0700 (PDT)
Message-ID: <20100928.002259.70186559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) AF_ROSE digi count signedness fix

2) On 64-bit, send() with iov_len >=3D 4GB can fail on TCP.

3) qlcnic assumes NET_IP_ALIGN is 2, use the macro instead of assuming.
   From Eric Dumazet.

4) ip_gre needs to check both CONFIG_IPV6 and CONFIG_IPV6_MODULE,
   also from Eric.

5) qlcnic and netxen corrupt skb->truesize breaking socket level and
   system-wide net buffer memory accounting.  Also from Eric Dumazet.

6) IP fragmentation can corrupt skb->truesize resulting in corrupt
   socket memory accounting, and stuck sockets (since the memory
   charge goes negative).  From Eric Dumazet.

7) 3c59x WOL support added some regressions (assumes PCI, which not
   all 3c59x are, also tries to erroneously hit the card when in D3)
   Fix from Jan Beulich.

8) Memory leak in wext private ioctls, fix from Johannes Berg.

9) Fix ATM br2684 scheduling-while-atomic, was invoking atomic notifier
   chain unregister with locks held and irqs disabled, from Karl Hiramo=
to.

10) Fix drivers using kfree() on a netdev which is always wrong,=09
    need to always use free_netdev().  From Kulikov Vasiliy and
    Vasiliy Kulikov.

11) Fix broken resume, and forgetting to clear CMB and SBM in ring
    release, in atl1 driver.  From Luca Tettamanti.

12) Missing unregister_pernet_subsys call in ipv6, from Neil Horman.

13) "struct net" needs __KERNEL__ guard, from Ollie Wild.

14) Several de2104x tulip link handling fixes from Ondrej Zary.

15) net/9p virtio code string comparison is busted, fix from Sven Eckel=
mann.

16) IPSEC xfrm code uses wrong address family sometimes, from Thomas Eg=
erer.

17) Traversing a tunnel requires resetting the RX queue setting, since
    downstream device might have different number of queues.  From
    Tom Herbert.

18) Fix hopefully the last race in our lockless tcp_poll, from
    Tom Marshall.

19) ipv4 ipsec code erroneously include ECN bits in the TOS it uses,
    which will cause route failures since those bits have internal
    meaning in the ipv4 routing code.  From Ulrich Weber.

20) Both ipv4 and ipv6 routing code spew "Neighbour table overflow"
    making it impossible to tell which of the two the notification is
    about.  Fix the log messages to be prefixed with "ipv{4,6}:"
    From Ulrich Weber.

21) ip_route_newport() needs to handle tproxy just as
    ip_route_connect() does, also from Ulrich Weber.

22) smsc911x missing module alias, from Vincent Stehl=E9.

23) Don't force a reset during scan in iwlwif, from Wey-Yi Guy.

24) tcp_mark_head_lost() mismarks segmented packets when doing FACK,
    fix from Yuchung Cheng.

25) e1000e bug fixes from Bruce Alan:
    a) Handle bugs in Sx state.
    b) Device reset leaves LEDs and SMBUS address in wrong state
    c) 82566DC link failure
    d) jumbo frames erroneously generate CRC errors

26) Netfilter bug fixes via Patrick McHardy
    a) ipt_REJECT mis-routes when indev=3D=3Doutdev (Changli Gao)
    b) nf_ct_ext_create() can race (Eric Dumazet)
    c) fix dangerous blind test of ->nodefrag (Jiri Olsa)
    d) nf_nat_snmp incorrect csums (Patrick McHardy)
    e) sip_help_tcp() should default to NF_ACCEPT (Simon Horman)

27) vhost bug fixes from Michael S. Tsirkin
    a) vhost-net range checking fix
    b) log ctx signalling inadvertantly in dead code

Please pull, thanks a lot!

The following changes since commit 252a52aa4fa22a668f019e55b3aac3ff71ec=
1c29:

  Fix pktcdvd ioctl dev_minor range check (2010-09-27 16:29:06 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Bruce Allan (6):
      e1000e: 82577/8/9 issues with device in Sx
      e1000e: 82579 SMBus address and LEDs incorrect after device reset
      e1000e: 82566DC fails to get link
      e1000e: 82579 unaccounted missed packets
      e1000e: 82579 jumbo frame workaround causing CRC errors
      e1000e: 82579 do not gate auto config of PHY by hardware during n=
ominal use

Changli Gao (1):
      netfilter: fix ipt_REJECT TCP RST routing for indev =3D=3D outdev

David S. Miller (5):
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost
      rose: Fix signedness issues wrt. digi count.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost
      tcp: Fix >4GB writes on 64-bit.

Eric Dumazet (8):
      qlcnic: dont assume NET_IP_ALIGN is 2
      ip_gre: CONFIG_IPV6_MODULE support
      qlcnic: dont set skb->truesize
      netxen: dont set skb->truesize
      ip: fix truesize mismatch in ip fragmentation
      netfilter: tproxy: nf_tproxy_assign_sock() can handle tw sockets
      netfilter: fix a race in nf_ct_ext_create()
      net: fix a lockdep splat

Jan Beulich (1):
      3c59x: fix regression from patch "Add ethtool WOL support"

Jiri Olsa (1):
      netfilter: nf_conntrack_defrag: check socket type before touching=
 nodefrag flag

Johannes Berg (1):
      wext: fix potential private ioctl memory content leak

Karl Hiramoto (1):
      br2684: fix scheduling while atomic

Kulikov Vasiliy (3):
      ibm_newemac: use free_netdev(netdev) instead of kfree()
      rionet: use free_netdev(netdev) instead of kfree()
      sgiseeq: use free_netdev(netdev) instead of kfree()

Luca Tettamanti (2):
      atl1: fix resume
      atl1: zero out CMB and SBM in atl1_free_ring_resources

Michael S. Tsirkin (2):
      vhost-net: fix range checking in mrg bufs case
      vhost: fix log ctx signalling

Neil Horman (1):
      ipv6: add a missing unregister_pernet_subsys call

Ollie Wild (1):
      net: Move "struct net" declaration inside the __KERNEL__ macro gu=
ard

Ondrej Zary (4):
      de2104x: disable autonegotiation on broken hardware
      de2104x: fix power management
      de2104x: fix TP link detection
      de2104x: fix ethtool

Patrick McHardy (1):
      netfilter: nf_nat_snmp: fix checksum calculation (v4)

Simon Horman (1):
      netfilter: nf_ct_sip: default to NF_ACCEPT in sip_help_tcp()

Sven Eckelmann (1):
      net/9p: Mount only matching virtio channels

Thomas Egerer (1):
      xfrm: Allow different selector family in temporary state

Tom Herbert (1):
      net: reset skb queue mapping when rx'ing over tunnel

Tom Marshall (1):
      tcp: Fix race in tcp_poll

Ulrich Weber (3):
      xfrm4: strip ECN bits from tos field
      ipv6: add IPv6 to neighbour table overflow warning
      tproxy: check for transparent flag in ip_route_newports

Vasiliy Kulikov (1):
      s390: use free_netdev(netdev) instead of kfree()

Vincent Stehl=E9 (1):
      smsc911x: Add MODULE_ALIAS()

Wey-Yi Guy (1):
      iwlwifi: do not perferm force reset while doing scan

Yuchung Cheng (1):
      tcp: fix TSO FACK loss marking in tcp_mark_head_lost

 drivers/net/3c59x.c                     |   10 ++
 drivers/net/atlx/atl1.c                 |   11 ++-
 drivers/net/e1000e/hw.h                 |    1 +
 drivers/net/e1000e/ich8lan.c            |  197 +++++++++++++++++++++++=
++-----
 drivers/net/e1000e/netdev.c             |   29 +++--
 drivers/net/ibm_newemac/core.c          |    4 +-
 drivers/net/netxen/netxen_nic_init.c    |    3 -
 drivers/net/qlcnic/qlcnic_init.c        |    7 +-
 drivers/net/rionet.c                    |    2 +-
 drivers/net/sgiseeq.c                   |    2 +-
 drivers/net/smsc911x.c                  |    1 +
 drivers/net/tulip/de2104x.c             |   43 ++++++-
 drivers/net/wireless/iwlwifi/iwl-core.c |    5 +
 drivers/s390/net/ctcm_main.c            |    4 +-
 drivers/vhost/net.c                     |    2 +-
 drivers/vhost/vhost.c                   |    7 +-
 include/linux/netlink.h                 |    4 +-
 include/linux/socket.h                  |    2 +-
 include/net/addrconf.h                  |    1 +
 include/net/dst.h                       |    1 +
 include/net/route.h                     |    2 +
 include/net/xfrm.h                      |    4 +-
 net/9p/trans_virtio.c                   |    3 +-
 net/atm/br2684.c                        |   12 +--
 net/core/iovec.c                        |    5 +-
 net/core/sock.c                         |    8 +-
 net/ipv4/ip_gre.c                       |    8 +-
 net/ipv4/ip_output.c                    |   19 ++-
 net/ipv4/netfilter/ipt_REJECT.c         |    1 +
 net/ipv4/netfilter/nf_defrag_ipv4.c     |    4 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c  |    6 +-
 net/ipv4/route.c                        |    2 +-
 net/ipv4/tcp.c                          |    9 +-
 net/ipv4/tcp_input.c                    |    5 +-
 net/ipv4/xfrm4_policy.c                 |    2 +-
 net/ipv4/xfrm4_state.c                  |   33 +++--
 net/ipv6/addrconf.c                     |   11 ++-
 net/ipv6/addrlabel.c                    |    5 +
 net/ipv6/ip6_output.c                   |   18 ++-
 net/ipv6/route.c                        |    2 +-
 net/ipv6/xfrm6_state.c                  |   33 +++--
 net/netfilter/nf_conntrack_extend.c     |    4 +-
 net/netfilter/nf_conntrack_sip.c        |    2 +-
 net/netfilter/nf_tproxy_core.c          |    6 +-
 net/rds/tcp_connect.c                   |    4 +-
 net/rds/tcp_listen.c                    |    4 +-
 net/rds/tcp_recv.c                      |    4 +-
 net/rds/tcp_send.c                      |    4 +-
 net/rose/af_rose.c                      |    4 +-
 net/sunrpc/xprtsock.c                   |   28 ++--
 net/wireless/wext-priv.c                |    2 +-
 net/xfrm/xfrm_policy.c                  |    5 +-
 net/xfrm/xfrm_state.c                   |   45 ++++---
 53 files changed, 444 insertions(+), 196 deletions(-)
