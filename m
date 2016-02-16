From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Tue, 16 Feb 2016 18:02:31 +0100
Message-ID: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contain a rather large batch for your net that
includes accumulated bugfixes, they are:

1) Run conntrack cleanup from workqueue process context to avoid hitting
   soft lockup via watchdog for large tables. This is required by the
   IPv6 masquerading extension. From Florian Westphal.

2) Use original skbuff from nfnetlink batch when calling netlink_ack()
   on error since this needs to access the skb->sk pointer.

3) Incremental fix on top of recent Sasha Levin's lock fix for conntrack
   resizing.

4) Fix several problems in nfnetlink batch message header sanitization
   and error handling, from Phil Turnbull.

5) Select NF_DUP_IPV6 based on CONFIG_IPV6, from Arnd Bergmann.

6) Fix wrong signess in return values on nf_tables counter expression,
   from Anton Protopopov.

Due to the NetDev 1.1 organization burden, I had no chance to pass up
this to you any sooner in this release cycle, sorry about that.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 53729eb174c1589f9185340ffe8c10b3f39f3ef3:

  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth (2016-01-30 15:32:42 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 5cc6ce9ff27565949a1001a2889a8dd9fd09e772:

  netfilter: nft_counter: fix erroneous return values (2016-02-08 13:05:02 +0100)

----------------------------------------------------------------
Anton Protopopov (1):
      netfilter: nft_counter: fix erroneous return values

Arnd Bergmann (1):
      netfilter: tee: select NF_DUP_IPV6 unconditionally

Florian Westphal (2):
      netfilter: conntrack: resched in nf_ct_iterate_cleanup
      netfilter: cttimeout: fix deadlock due to erroneous unlock/lock conversion

Pablo Neira Ayuso (1):
      netfilter: nfnetlink: use original skbuff when acking batches

Phil Turnbull (1):
      netfilter: nfnetlink: correctly validate length of batch messages

 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c | 74 +++++++++++++++++++++++++++--
 net/netfilter/Kconfig                       |  2 +-
 net/netfilter/nf_conntrack_core.c           |  5 ++
 net/netfilter/nfnetlink.c                   | 16 ++++---
 net/netfilter/nfnetlink_cttimeout.c         |  2 +-
 net/netfilter/nft_counter.c                 |  4 +-
 net/netfilter/xt_TEE.c                      |  4 +-
 7 files changed, 91 insertions(+), 16 deletions(-)
