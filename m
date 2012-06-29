From: pablo@netfilter.org
Subject: [PATCH 5/5] netfilter: nfnetlink: fix missing rcu_read_unlock in nfnetlink_rcv_msg
Date: Fri, 29 Jun 2012 17:37:35 +0200
Message-ID: <1340984255-738-6-git-send-email-pablo@netfilter.org>
References: <1340984255-738-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38960 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756150Ab2F2Phu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 11:37:50 -0400
In-Reply-To: <1340984255-738-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>

Bug added in commit 6b75e3e8d664a9a (netfilter: nfnetlink: add RCU in
nfnetlink_rcv_msg())

Signed-off-by: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 3e797d1..791d56b 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -169,8 +169,10 @@ replay:
 
 		err = nla_parse(cda, ss->cb[cb_id].attr_count,
 				attr, attrlen, ss->cb[cb_id].policy);
-		if (err < 0)
+		if (err < 0) {
+			rcu_read_unlock();
 			return err;
+		}
 
 		if (nc->call_rcu) {
 			err = nc->call_rcu(net->nfnl, skb, nlh,
-- 
1.7.10
