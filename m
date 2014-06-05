From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: nfnetlink_acct: Fix memory leak
Date: Thu,  5 Jun 2014 17:08:21 +0200
Message-ID: <1401980906-25290-2-git-send-email-pablo@netfilter.org>
References: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39224 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632AbaFEPIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 11:08:36 -0400
In-Reply-To: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Poirier <mathieu.poirier@linaro.org>

Allocation of memory need only to happen once, that is
after the proper checks on the NFACCT_FLAGS have been
done.  Otherwise the code can return without freeing
already allocated memory.

Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 70e86bb..54af985 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -83,7 +83,6 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 		return -EBUSY;
 	}
 
-	nfacct = kzalloc(sizeof(struct nf_acct), GFP_KERNEL);
 	if (tb[NFACCT_FLAGS]) {
 		flags = ntohl(nla_get_be32(tb[NFACCT_FLAGS]));
 		if (flags & ~NFACCT_F_QUOTA)
-- 
1.7.10.4
