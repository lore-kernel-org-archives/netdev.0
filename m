From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 00/08: netfilter -stable fixes
Date: Thu, 23 Jul 2009 16:15:24 +0200 (MEST)
Message-ID: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following are couple of netfilter fixes for -stable, fixing

- various races in nf_conntrack introduced by the conversion to use
  RCU for the conntrack hash and follow-up patch to use SLAB_DESTROY_BY_RCU
  for the conntrack slab

- direct userspace memory access in the nf_log /proc handler

- a missing initialization in the quota match, possibly causing malfunction
  on SMP

- an incorrect comparison in the rateest match

- unacknowledged data detection in TCP conntrack in combination with
  NAT helpers reducing the packet size

Please apply, thanks.


 Documentation/RCU/rculist_nulls.txt    |    7 +++++-
 include/net/netfilter/nf_conntrack.h   |    4 +-
 net/ipv4/netfilter/nf_nat_helper.c     |   17 +++++++++-----
 net/netfilter/nf_conntrack_core.c      |   36 ++++++++++++++++++++++++++-----
 net/netfilter/nf_conntrack_proto_tcp.c |    6 ++--
 net/netfilter/nf_log.c                 |   22 ++++++++++++-------
 net/netfilter/xt_quota.c               |    1 +
 net/netfilter/xt_rateest.c             |    2 +-
 8 files changed, 68 insertions(+), 27 deletions(-)

Patrick McHardy (8):
      netfilter: nf_log: fix sleeping function called from invalid context
      netfilter: nf_conntrack: fix confirmation race condition
      netfilter: nf_conntrack: fix conntrack lookup race
      netfilter: nf_log: fix direct userspace memory access in proc handler
      netfilter: xt_quota: fix incomplete initialization
      netfilter: xt_rateest: fix comparison with self
      netfilter: tcp conntrack: fix unacknowledged data detection with NAT
      netfilter: nf_conntrack: nf_conntrack_alloc() fixes
