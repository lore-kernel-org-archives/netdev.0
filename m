From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/03: netfilter fixes
Date: Fri, 19 Feb 2010 18:02:06 +0100 (MET)
Message-ID: <20100219170206.18096.12788.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62746 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050Ab0BSRCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 12:02:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are three netfilter fixes for net-next, fixing:

- the NAT issue reported by Stephen, which was caused by inverted logic
  in NF_HOOK_COND(), causing it to skip the POST_ROUTING hook invocation

- an assertion in ct_extend, caused by invalid ordering in ctnetlink
  when setting up new conntracks. Additionally it is invalid to
  attach helpers to existing conntracks, which is disabled by this
  patch.

- an skb leak in nf_queue when userspace returns NF_STOLEN as verdict

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 include/linux/netfilter.h            |    5 +++--
 net/netfilter/nf_conntrack_netlink.c |   22 +++++++++++-----------
 net/netfilter/nf_queue.c             |    2 +-
 3 files changed, 15 insertions(+), 14 deletions(-)

Eric Dumazet (1):
      netfilter: nf_queue: fix NF_STOLEN skb leak

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix creation of conntrack with helpers

Patrick McHardy (1):
      netfilter: restore POST_ROUTING hook in NF_HOOK_COND
