From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 26 Jul 2008 18:01:57 -0700 (PDT)
Message-ID: <20080726.180157.90619311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752579AbYG0BB6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2008 21:01:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several updates, including the krealloc() fix for the
nf_iterate() OOPS, and the inverted test in net/ipv4/route.c
found and fixed by Hugh Dickens.

This also has changes from Ilpo which get rid of our stupid local
"BUG_TRAP()" thing in the networking, and use the common WARN_ON()
instead.

Please pull, thanks a lot!

The following changes since commit 7d7e5a60c62e88cb8782760bb6c4d3bd1577=
a6c6:
  Herbert Xu (1):
        ipsec: ipcomp - Decompress into frags if necessary

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (4):
      netfilter: ebtables: use nf_register_hooks()
      selinux: use nf_register_hooks()
      netfilter: ip{,6}tables_security: fix future section mismatch
      netfilter: arptables in netns for real

David S. Miller (1):
      Revert "pkt_sched: sch_sfq: dump a real number of flows"

=46lorian Westphal (1):
      syncookies: Make sure ECN is disabled

Heiko Carstens (1):
      qeth: use dev->ml_priv instead of dev->priv

Hugh Dickins (1):
      netns: fix ip_rt_frag_needed rt_is_expired

Ilpo J=E4rvinen (3):
      drivers/net: convert BUG_TRAP to generic WARN_ON
      net: convert BUG_TRAP to generic WARN_ON
      net: drop unused BUG_TRAP()

Patrick McHardy (1):
      netfilter: nf_conntrack_extend: avoid unnecessary "ct->ext" deref=
erences

Pekka Enberg (1):
      netfilter: fix double-free and use-after free

 drivers/net/bnx2x_main.c                |   10 +++---
 drivers/s390/net/qeth_core_main.c       |   14 +++++-----
 drivers/s390/net/qeth_l2_main.c         |   26 +++++++++---------
 drivers/s390/net/qeth_l3_main.c         |   30 ++++++++++----------
 include/linux/rtnetlink.h               |    7 -----
 include/linux/slab.h                    |    1 +
 include/net/request_sock.h              |    5 ++-
 mm/util.c                               |   44 +++++++++++++++++++++++=
+-------
 net/appletalk/ddp.c                     |    4 +-
 net/bridge/netfilter/ebtable_filter.c   |   18 +++---------
 net/bridge/netfilter/ebtable_nat.c      |   18 +++---------
 net/core/datagram.c                     |    8 +++---
 net/core/dev.c                          |   10 +++---
 net/core/request_sock.c                 |    2 +-
 net/core/skbuff.c                       |   20 +++++++-------
 net/core/stream.c                       |    6 ++--
 net/core/user_dma.c                     |    5 +--
 net/dccp/dccp.h                         |    2 +-
 net/dccp/input.c                        |    2 +-
 net/dccp/ipv4.c                         |    2 +-
 net/dccp/ipv6.c                         |    2 +-
 net/dccp/proto.c                        |    4 +-
 net/dccp/timer.c                        |    2 +-
 net/ipv4/af_inet.c                      |   14 +++++-----
 net/ipv4/devinet.c                      |    6 ++--
 net/ipv4/inet_connection_sock.c         |   18 ++++++------
 net/ipv4/inet_fragment.c                |    4 +-
 net/ipv4/inet_hashtables.c              |    8 +++---
 net/ipv4/inet_timewait_sock.c           |    2 +-
 net/ipv4/ip_fragment.c                  |    4 +-
 net/ipv4/ip_output.c                    |    2 +-
 net/ipv4/netfilter/arptable_filter.c    |   39 +++++++++++++++++++++--=
----
 net/ipv4/netfilter/iptable_security.c   |    2 +-
 net/ipv4/route.c                        |    2 +-
 net/ipv4/syncookies.c                   |    1 +
 net/ipv4/tcp.c                          |   12 ++++----
 net/ipv4/tcp_input.c                    |   20 +++++++-------
 net/ipv4/tcp_ipv4.c                     |    2 +-
 net/ipv4/tcp_timer.c                    |    2 +-
 net/ipv6/addrconf.c                     |   11 +++++---
 net/ipv6/af_inet6.c                     |    2 +-
 net/ipv6/inet6_connection_sock.c        |    2 +-
 net/ipv6/inet6_hashtables.c             |    4 +-
 net/ipv6/ip6_fib.c                      |   31 +++++++++++----------
 net/ipv6/ip6_output.c                   |    2 +-
 net/ipv6/mip6.c                         |    8 +++---
 net/ipv6/netfilter/ip6table_security.c  |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 +-
 net/ipv6/reassembly.c                   |    4 +-
 net/ipv6/syncookies.c                   |    1 +
 net/ipv6/tcp_ipv6.c                     |    2 +-
 net/key/af_key.c                        |    4 +-
 net/netfilter/nf_conntrack_extend.c     |   10 +++---
 net/netlink/af_netlink.c                |    7 +++--
 net/packet/af_packet.c                  |    4 +-
 net/rxrpc/af_rxrpc.c                    |    6 ++--
 net/sched/act_api.c                     |    2 +-
 net/sched/act_police.c                  |    2 +-
 net/sched/cls_u32.c                     |   10 +++---
 net/sched/sch_cbq.c                     |    4 +-
 net/sched/sch_generic.c                 |    2 +-
 net/sched/sch_htb.c                     |   16 +++++-----
 net/sched/sch_sfq.c                     |    9 +-----
 net/sctp/associola.c                    |    2 +-
 net/unix/af_unix.c                      |    8 +++---
 net/xfrm/xfrm_algo.c                    |    4 +-
 net/xfrm/xfrm_ipcomp.c                  |    3 +-
 net/xfrm/xfrm_state.c                   |    2 +-
 security/selinux/hooks.c                |   27 +++++-------------
 69 files changed, 293 insertions(+), 282 deletions(-)
