From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/03: nf_conntrack: fix crash when unloading helpers
Date: Thu, 16 Apr 2009 19:16:24 +0200 (MEST)
Message-ID: <20090416171623.11406.45891.sendpatchset@x2.localnet>
References: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61774 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757106AbZDPRQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 13:16:26 -0400
In-Reply-To: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 38fb0afcd8761f8858e27135ed89a65117e2019c
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Apr 15 12:45:08 2009 +0200

    netfilter: nf_conntrack: fix crash when unloading helpers
    
    Commit ea781f197d (netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and)
    get rid of call_rcu() was missing one conversion to the hlist_nulls
    functions, causing a crash when unloading conntrack helper modules.
    
    Reported-and-tested-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 30b8e90..0fa5a42 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -176,7 +176,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	}
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
+	hlist_nulls_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
 		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
