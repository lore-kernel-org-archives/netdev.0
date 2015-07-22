From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/10] netfilter: ctnetlink: put back references to master ct and expect objects
Date: Thu, 23 Jul 2015 01:00:43 +0200
Message-ID: <1437606052-5179-2-git-send-email-pablo@netfilter.org>
References: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54418 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbbGVWzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 18:55:17 -0400
In-Reply-To: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to put back the references to the master conntrack and the expectation
that we just created, otherwise we'll leak them.

Fixes: 0ef71ee1a5b9 ("netfilter: ctnetlink: refactor ctnetlink_create_expect")
Reported-by: Tim Wiess <Tim.Wiess@watchguard.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index d1c2394..6b8b0ab 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2995,11 +2995,6 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	}
 
 	err = nf_ct_expect_related_report(exp, portid, report);
-	if (err < 0)
-		goto err_exp;
-
-	return 0;
-err_exp:
 	nf_ct_expect_put(exp);
 err_ct:
 	nf_ct_put(ct);
-- 
1.7.10.4
