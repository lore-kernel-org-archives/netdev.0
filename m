From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] fib_trie: call fib_table_flush_external under RTNL
Date: Tue, 10 Mar 2015 21:03:54 +0100
Message-ID: <1426017834-24209-1-git-send-email-sd@queasysnail.net>
References: <20150310183555.GB1743@kria>
Cc: netdev@vger.kernel.org, alexander.h.duyck@redhat.com,
	sfeldma@gmail.com, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:59365 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752899AbbCJUEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 16:04:21 -0400
In-Reply-To: <20150310183555.GB1743@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move rtnl_lock() before the call to fib4_rules_exit so that
fib_table_flush_external is called under RTNL.

Fixes: 104616e74e0b ("switchdev: don't support custom ip rules, for now")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv4/fib_frontend.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e067770235bf..ed94bc80eb78 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1126,11 +1126,12 @@ static void ip_fib_net_exit(struct net *net)
 {
 	unsigned int i;
 
+	rtnl_lock();
+
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	fib4_rules_exit(net);
 #endif
 
-	rtnl_lock();
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[i];
 		struct hlist_node *tmp;
-- 
2.3.2
