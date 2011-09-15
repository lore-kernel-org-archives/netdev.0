From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 26/27] Initconst section fixes for net
Date: Thu, 15 Sep 2011 13:09:53 -0700
Message-ID: <1316117394-21666-27-git-send-email-andi@firstfloor.org>
References: <1316117394-21666-1-git-send-email-andi@firstfloor.org>
Cc: Andi Kleen <ak@linux.intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316117394-21666-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Cc: davem@davemloft.net
Cc: netdev@vger.kernel.org
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/net/net_namespace.h |    2 ++
 net/can/af_can.c            |    2 +-
 net/can/bcm.c               |    2 +-
 net/can/raw.c               |    2 +-
 net/decnet/dn_rules.c       |    2 +-
 net/ipv4/fib_rules.c        |    2 +-
 net/ipv4/ipmr.c             |    2 +-
 net/ipv6/addrlabel.c        |    2 +-
 net/ipv6/fib6_rules.c       |    2 +-
 net/ipv6/ip6mr.c            |    2 +-
 10 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3bb6fa0..0d7e8ac 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -240,10 +240,12 @@ static inline struct net *read_pnet(struct net * const *pnet)
 #define __net_init
 #define __net_exit
 #define __net_initdata
+#define __net_initconst
 #else
 #define __net_init	__init
 #define __net_exit	__exit_refok
 #define __net_initdata	__initdata
+#define __net_initconst	__initconst
 #endif
 
 struct pernet_operations {
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 8ce926d..22e94a3 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -64,7 +64,7 @@
 
 #include "af_can.h"
 
-static __initdata const char banner[] = KERN_INFO
+static __initconst const char banner[] = KERN_INFO
 	"can: controller area network core (" CAN_VERSION_STRING ")\n";
 
 MODULE_DESCRIPTION("Controller Area Network PF_CAN core");
diff --git a/net/can/bcm.c b/net/can/bcm.c
index d6c8ae5..0cacb79 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -79,7 +79,7 @@
 		     (CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG))
 
 #define CAN_BCM_VERSION CAN_VERSION
-static __initdata const char banner[] = KERN_INFO
+static __initconst const char banner[] = KERN_INFO
 	"can: broadcast manager protocol (rev " CAN_BCM_VERSION " t)\n";
 
 MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
diff --git a/net/can/raw.c b/net/can/raw.c
index dea99a6..89a1e4b 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -57,7 +57,7 @@
 #include <net/net_namespace.h>
 
 #define CAN_RAW_VERSION CAN_VERSION
-static __initdata const char banner[] =
+static __initconst const char banner[] =
 	KERN_INFO "can: raw protocol (rev " CAN_RAW_VERSION ")\n";
 
 MODULE_DESCRIPTION("PF_CAN raw protocol");
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index f0efb0c..4d3c275 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -219,7 +219,7 @@ static void dn_fib_rule_flush_cache(struct fib_rules_ops *ops)
 	dn_rt_cache_flush(-1);
 }
 
-static const struct fib_rules_ops __net_initdata dn_fib_rules_ops_template = {
+static const struct fib_rules_ops __net_initconst dn_fib_rules_ops_template = {
 	.family		= AF_DECnet,
 	.rule_size	= sizeof(struct dn_fib_rule),
 	.addr_size	= sizeof(u16),
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index a53bb1b..1362927 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -247,7 +247,7 @@ static void fib4_rule_flush_cache(struct fib_rules_ops *ops)
 	rt_cache_flush(ops->fro_net, -1);
 }
 
-static const struct fib_rules_ops __net_initdata fib4_rules_ops_template = {
+static const struct fib_rules_ops __net_initconst fib4_rules_ops_template = {
 	.family		= AF_INET,
 	.rule_size	= sizeof(struct fib4_rule),
 	.addr_size	= sizeof(u32),
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 58e8791..64f14be 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -218,7 +218,7 @@ static int ipmr_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	return 0;
 }
 
-static const struct fib_rules_ops __net_initdata ipmr_rules_ops_template = {
+static const struct fib_rules_ops __net_initconst ipmr_rules_ops_template = {
 	.family		= RTNL_FAMILY_IPMR,
 	.rule_size	= sizeof(struct ipmr_rule),
 	.addr_size	= sizeof(u32),
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 2d8ddba..df6e555 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -75,7 +75,7 @@ struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
 
 #define IPV6_ADDR_LABEL_DEFAULT	0xffffffffUL
 
-static const __net_initdata struct ip6addrlbl_init_table
+static const __net_initconst struct ip6addrlbl_init_table
 {
 	const struct in6_addr *prefix;
 	int prefixlen;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 34d244d..c33c00a 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -239,7 +239,7 @@ static size_t fib6_rule_nlmsg_payload(struct fib_rule *rule)
 	       + nla_total_size(16); /* src */
 }
 
-static const struct fib_rules_ops __net_initdata fib6_rules_ops_template = {
+static const struct fib_rules_ops __net_initconst fib6_rules_ops_template = {
 	.family			= AF_INET6,
 	.rule_size		= sizeof(struct fib6_rule),
 	.addr_size		= sizeof(struct in6_addr),
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 705c828..c37cb9e 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -205,7 +205,7 @@ static int ip6mr_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	return 0;
 }
 
-static const struct fib_rules_ops __net_initdata ip6mr_rules_ops_template = {
+static const struct fib_rules_ops __net_initconst ip6mr_rules_ops_template = {
 	.family		= RTNL_FAMILY_IP6MR,
 	.rule_size	= sizeof(struct ip6mr_rule),
 	.addr_size	= sizeof(struct in6_addr),
-- 
1.7.4.4
