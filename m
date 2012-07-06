From: pablo@netfilter.org
Subject: [PATCH 1/2] netfilter: ipset: timeout fixing bug broke SET target special timeout value
Date: Fri,  6 Jul 2012 13:39:38 +0200
Message-ID: <1341574779-3373-2-git-send-email-pablo@netfilter.org>
References: <1341574779-3373-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341574779-3373-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The patch "127f559 netfilter: ipset: fix timeout value overflow bug"
broke the SET target when no timeout was specified.

Reported-by: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/xt_set.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 035960e..b172cbc 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -16,6 +16,7 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_set.h>
+#include <linux/netfilter/ipset/ip_set_timeout.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -310,7 +311,8 @@ set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 		info->del_set.flags, 0, UINT_MAX);
 
 	/* Normalize to fit into jiffies */
-	if (add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
+	if (add_opt.timeout != IPSET_NO_TIMEOUT
+	    && add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
 		add_opt.timeout = UINT_MAX/MSEC_PER_SEC;
 	if (info->add_set.index != IPSET_INVALID_ID)
 		ip_set_add(info->add_set.index, skb, par, &add_opt);
-- 
1.7.10

