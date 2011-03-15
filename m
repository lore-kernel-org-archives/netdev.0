From: kaber@trash.net
Subject: [PATCH 04/37] netfilter: nf_conntrack: fix sysctl memory leak
Date: Tue, 15 Mar 2011 20:43:44 +0100
Message-ID: <1300218257-26953-5-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49424 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758202Ab1COTo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:27 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Message in log because sysctl table was not empty at netns exit
 WARNING: at net/sysctl_net.c:84 sysctl_net_exit+0x2a/0x2c()

Instrumenting showed that the nf_conntrack_timestamp was the entry
that was being created but not cleared.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1909311..1181236 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1294,6 +1294,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 	nf_conntrack_ecache_fini(net);
+	nf_conntrack_tstamp_fini(net);
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
-- 
1.7.2.3

