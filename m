From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: nfnetlink_acct: fix incomplete dumping of objects
Date: Mon, 10 Jun 2013 18:07:37 +0200
Message-ID: <1370880461-4265-2-git-send-email-pablo@netfilter.org>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59092 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014Ab3FJQHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 12:07:53 -0400
In-Reply-To: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix broken incomplete object dumping if the list of objects does not
fit into one single netlink message.

Reported-by: Gabriel Lazar <Gabriel.Lazar@com.utcluj.ro>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index dc3fd5d..c7b6d46 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -149,9 +149,12 @@ nfnl_acct_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(cur, &nfnl_acct_list, head) {
-		if (last && cur != last)
-			continue;
+		if (last) {
+			if (cur != last)
+				continue;
 
+			last = NULL;
+		}
 		if (nfnl_acct_fill_info(skb, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq,
 				       NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
-- 
1.7.10.4
