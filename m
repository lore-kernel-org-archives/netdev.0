From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 20 Oct 2011 05:43:50 -0400 (EDT)
Message-ID: <20111020.054350.742736048265300053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I have two fixes still being worked on and under discussion.  One for
pktgen giving too large values to ndelay(), and one for RAW ipv4/ipv6
sockets crashing when used over IP_GRE tunnels.  Probably I can have
both fixes finalized in about a day.

1) When bridge is removed via netlink, we hang, fix from Stephen Hemmin=
ger.

2) USE_PHYLIB flag test reversed in tg3 due to regression, fix from Jir=
i Pirko.

3) IPVS netns down/up deadlock fix from Hans Schillstrom.

4) Leaks and missing SKB pull calls in pptp and l2tp, from Eric Dumazet=
=2E

5) Several buffer overruns and missing skb size checks in x25, fixes fr=
om
   Matthew Daley.

6) bond_handle_frame() races with taking a bond down, resulting in cras=
h,
   fix from Mitsuo Hayasaka.

7) R8169 WoL regression fix from Francois Romieu.  Energy Efficient Eth=
ernet
   setting for rtl8111evl r8169 chip from Hayes Wang.

8) Add SMSC LAN89218 device IDs, from Phil Edworthy.

9) Bluetooth forgets to propagate LSM attributes on child sockets, fix
   from Paul Moore.

10) Transparent proxy doesn't propagate flag to TIME_WAIT sockets, resu=
lting
    in resets.  Fix from KOVACS Krisztian.

Please pull, thanks a lot.

The following changes since commit 486cf46f3f9be5f2a966016c1a8fe01e32cd=
e09e:

  mm: fix race between mremap and removing migration entry (2011-10-19 =
23:42:58 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

David S. Miller (1):
      Merge branch 'nf' of git://1984.lsi.us.es/net

Eric Dumazet (3):
      l2tp: fix a potential skb leak in l2tp_xmit_skb()
      pptp: fix skb leak in pptp_xmit()
      pptp: pptp_rcv_core() misses pskb_may_pull() call

=46lorian Westphal (1):
      netfilter: nf_conntrack: fix event flooding in GRE protocol track=
er

Gao feng (1):
      netconsole: enable netconsole can make net_device refcnt incorren=
t

Gerrit Renker (1):
      udplite: fast-path computation of checksum coverage

Hans Schillstrom (1):
      IPVS netns shutdown/startup dead-lock

Jiri Pirko (1):
      tg3: negate USE_PHYLIB flag check

KOVACS Krisztian (1):
      tproxy: copy transparent flag when creating a time wait

Matthew Daley (3):
      x25: Validate incoming call user data lengths
      x25: Handle undersized/fragmented skbs
      x25: Prevent skb overreads when checking call user data

Mitsuo Hayasaka (1):
      bonding: use local function pointer of bond->recv_probe in bond_h=
andle_frame

Paul Moore (1):
      bluetooth: Properly clone LSM attributes to newly created child c=
onnections

Phil Edworthy (1):
      smsc911x: Add support for SMSC LAN89218

Thadeu Lima de Souza Cascardo (1):
      ehea: Change maintainer to me

Yan, Zheng (1):
      fib_rules: fix unresolved_rules counting

fran=E7ois romieu (1):
      r8169: fix driver shutdown WoL regression.

hayeswang (1):
      r8169: fix wrong eee setting for rlt8111evl

stephen hemminger (1):
      bridge: fix hang on removal of bridge via netlink

 MAINTAINERS                            |    2 +-
 drivers/net/bonding/bond_main.c        |    7 +-
 drivers/net/netconsole.c               |    5 +
 drivers/net/pptp.c                     |   22 ++++--
 drivers/net/r8169.c                    |   90 ++++++++++++++--------
 drivers/net/smsc911x.c                 |    2 +
 drivers/net/tg3.c                      |    2 +-
 include/net/ip_vs.h                    |    1 +
 include/net/udplite.h                  |   63 ++++++++--------
 net/bluetooth/l2cap_sock.c             |    4 +
 net/bluetooth/rfcomm/sock.c            |    3 +
 net/bluetooth/sco.c                    |    5 +-
 net/bridge/br_if.c                     |    9 +-
 net/bridge/br_netlink.c                |    1 +
 net/bridge/br_private.h                |    1 +
 net/core/fib_rules.c                   |    5 +-
 net/ipv4/tcp_minisocks.c               |    1 +
 net/l2tp/l2tp_core.c                   |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c         |  131 +++++++++++++++++++-----=
-------
 net/netfilter/ipvs/ip_vs_sync.c        |    6 ++
 net/netfilter/nf_conntrack_proto_gre.c |    4 +-
 net/x25/af_x25.c                       |   40 ++++++++--
 net/x25/x25_dev.c                      |    6 ++
 net/x25/x25_facilities.c               |   10 ++-
 net/x25/x25_in.c                       |   43 +++++++++-
 net/x25/x25_link.c                     |    3 +
 net/x25/x25_subr.c                     |   14 +++-
 security/security.c                    |    1 +
 28 files changed, 330 insertions(+), 155 deletions(-)
