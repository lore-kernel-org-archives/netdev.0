From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] NET: xfrm, use correct rcu dereference helper
Date: Fri, 17 Aug 2012 15:38:36 +0200
Message-ID: <1345210716-24556-1-git-send-email-jslaby@suse.cz>
Cc: netdev@vger.kernel.org, jirislaby@gmail.com,
	linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	Priyanka Jain <Priyanka.Jain@freescale.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use rcu_dereference_bh while holding bh rcu lock. Otherwise we get:
===============================
[ INFO: suspicious RCU usage. ]
3.6.0-rc1-next-20120816+ #10 Not tainted
-------------------------------
net/xfrm/xfrm_policy.c:2504 suspicious rcu_dereference_check() usage!

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Priyanka Jain <Priyanka.Jain@freescale.com>
---
 net/xfrm/xfrm_policy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5ad4d2c..6405764 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2501,11 +2501,11 @@ static void __net_init xfrm_dst_ops_init(struct net *net)
 	struct xfrm_policy_afinfo *afinfo;
 
 	rcu_read_lock_bh();
-	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET]);
+	afinfo = rcu_dereference_bh(xfrm_policy_afinfo[AF_INET]);
 	if (afinfo)
 		net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
 #if IS_ENABLED(CONFIG_IPV6)
-	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
+	afinfo = rcu_dereference_bh(xfrm_policy_afinfo[AF_INET6]);
 	if (afinfo)
 		net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
 #endif
-- 
1.7.11.5
