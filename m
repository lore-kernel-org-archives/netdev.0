From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/07: netfilter fixes
Date: Mon, 22 Jun 2009 14:53:49 +0200 (MEST)
Message-ID: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches fix a number of netfilter bugs:

- a conntrack race condition in death_by_timeout() when moving dying entries
  to the dying list. Fix from Eric Dumazet.

- a conntrack confirmation race condition that might lead to new conntrack
  entries becoming visible before they are fully set up.

- a conntrack lookup race condition that might lead to deleted conntrack
  entries being returned

- some sparse endianess fixes

- a fix for the nf_log proc handler, which is accessing userspace memory directly

- an incomplete initialization in the quota match, fix from Jan Engelhardt

- an incorrect comparison in the rateest match

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 net/netfilter/nf_conntrack_core.c |   25 ++++++++++++++++++++-----
 net/netfilter/nf_log.c            |   16 +++++++++++-----
 net/netfilter/xt_NFQUEUE.c        |    8 ++++----
 net/netfilter/xt_cluster.c        |    8 ++++----
 net/netfilter/xt_quota.c          |    1 +
 net/netfilter/xt_rateest.c        |    2 +-
 6 files changed, 41 insertions(+), 19 deletions(-)

Eric Dumazet (1):
      netfilter: nf_conntrack: death_by_timeout() fix

Jan Engelhardt (1):
      netfilter: xt_quota: fix incomplete initialization

Patrick McHardy (5):
      netfilter: nf_conntrack: fix confirmation race condition
      netfilter: nf_conntrack: fix conntrack lookup race
      netfilter: fix some sparse endianess warnings
      netfilter: nf_log: fix direct userspace memory access in proc handler
      netfilter: xt_rateest: fix comparison with self
