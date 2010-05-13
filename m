From: kaber@trash.net
Subject: [PATCH 10/12] netfilter: change NF_ASSERT to WARN_ON
Date: Thu, 13 May 2010 18:16:23 +0200
Message-ID: <1273767385-18225-11-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>

Change netfilter asserts to standard WARN_ON. This has the
benefit of backtrace info and also causes netfilter errors
to show up on kerneloops.org.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arp_tables.c |    7 +------
 net/ipv4/netfilter/ip_tables.c  |    7 +------
 net/ipv6/netfilter/ip6_tables.c |    7 +------
 3 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 03352fc..65f2944 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -49,12 +49,7 @@ MODULE_DESCRIPTION("arptables core");
 #endif
 
 #ifdef CONFIG_NETFILTER_DEBUG
-#define ARP_NF_ASSERT(x)					\
-do {								\
-	if (!(x))						\
-		printk("ARP_NF_ASSERT: %s:%s:%u\n",		\
-		       __func__, __FILE__, __LINE__);	\
-} while(0)
+#define ARP_NF_ASSERT(x)	WARN_ON(!(x))
 #else
 #define ARP_NF_ASSERT(x)
 #endif
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 49b9e4f..ad702bc 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -51,12 +51,7 @@ MODULE_DESCRIPTION("IPv4 packet filter");
 #endif
 
 #ifdef CONFIG_NETFILTER_DEBUG
-#define IP_NF_ASSERT(x)						\
-do {								\
-	if (!(x))						\
-		printk("IP_NF_ASSERT: %s:%s:%u\n",		\
-		       __func__, __FILE__, __LINE__);	\
-} while(0)
+#define IP_NF_ASSERT(x)		WARN_ON(!(x))
 #else
 #define IP_NF_ASSERT(x)
 #endif
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 5678233..02a7db0 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -52,12 +52,7 @@ MODULE_DESCRIPTION("IPv6 packet filter");
 #endif
 
 #ifdef CONFIG_NETFILTER_DEBUG
-#define IP_NF_ASSERT(x)						\
-do {								\
-	if (!(x))						\
-		printk("IP_NF_ASSERT: %s:%s:%u\n",		\
-		       __func__, __FILE__, __LINE__);	\
-} while(0)
+#define IP_NF_ASSERT(x)	WARN_ON(!(x))
 #else
 #define IP_NF_ASSERT(x)
 #endif
-- 
1.7.0.4

