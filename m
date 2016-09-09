From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 6/8] net: sched: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:18 -0400
Message-ID: <1473425000-9782-7-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 net/sched/cls_flow.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 2c1ae549edbf..a379bae1d74e 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -29,7 +29,7 @@
 #include <net/route.h>
 #include <net/flow_dissector.h>
 
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
 #endif
 
@@ -125,14 +125,14 @@ static u32 flow_get_mark(const struct sk_buff *skb)
 
 static u32 flow_get_nfct(const struct sk_buff *skb)
 {
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	return addr_fold(skb->nfct);
 #else
 	return 0;
 #endif
 }
 
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #define CTTUPLE(skb, member)						\
 ({									\
 	enum ip_conntrack_info ctinfo;					\
-- 
2.7.4
