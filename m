From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/04: netfilter fixes
Date: Mon, 29 Jun 2009 16:20:13 +0200 (MEST)
Message-ID: <20090629142007.5728.63458.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following are four netfilter fixes for 2.6.31:

- Jesper's rcu_barrier() patch to fix conntrack module unload races

- a patch to fix false positives in TCP conntrack unacknowledged data
  detection, resulting in very short timeout values

- a missing linux/types.h include in xt_osf.h

- a fix for a conntrack match regression introduced with the last revision:
  the state member in the configuration struct isn't able to hold all valid
  values. This unfortunately needs a new revision.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!


 include/linux/netfilter/xt_conntrack.h |   13 ++++++
 include/linux/netfilter/xt_osf.h       |    2 +
 include/net/netfilter/nf_conntrack.h   |    4 +-
 net/ipv4/netfilter/nf_nat_helper.c     |   17 +++++---
 net/netfilter/nf_conntrack_expect.c    |    4 +-
 net/netfilter/nf_conntrack_extend.c    |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c |    6 +-
 net/netfilter/xt_conntrack.c           |   66 +++++++++++++++++++++++++++++---
 8 files changed, 95 insertions(+), 19 deletions(-)

Jan Engelhardt (1):
      netfilter: xtables: conntrack match revision 2

Jaswinder Singh Rajput (1):
      netfilter: headers_check fix: linux/netfilter/xt_osf.h

Jesper Dangaard Brouer (1):
      nf_conntrack: Use rcu_barrier()

Patrick McHardy (1):
      netfilter: tcp conntrack: fix unacknowledged data detection with NAT
