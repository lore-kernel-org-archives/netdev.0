From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: don't need to initialize instance_table
Date: Thu,  9 Dec 2010 18:10:21 +0800
Message-ID: <1291889421-10794-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since instance_table is a static array, and has been zeroed already, we
don't need to take CPU cycles to initialize it.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nfnetlink_queue.c |    3 ---
 1 file changed, 3 deletions(-)
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 68e67d1..9c80d6f 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -893,9 +893,6 @@ static int __init nfnetlink_queue_init(void)
 {
 	int i, status = -ENOMEM;
 
-	for (i = 0; i < INSTANCE_BUCKETS; i++)
-		INIT_HLIST_HEAD(&instance_table[i]);
-
 	netlink_register_notifier(&nfqnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfqnl_subsys);
 	if (status < 0) {
