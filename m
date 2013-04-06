From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/51] netfilter: use IS_ENABLE to replace if defined in TRACE target
Date: Sat,  6 Apr 2013 14:17:33 +0200
Message-ID: <1365250670-14993-35-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/ip_output.c           |    3 +--
 net/ipv4/netfilter/ip_tables.c |    6 ++----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 5e12dca..147abf5 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -430,8 +430,7 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->tc_index = from->tc_index;
 #endif
 	nf_copy(to, from);
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 	to->nf_trace = from->nf_trace;
 #endif
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3efcf87..1b433aa 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -182,8 +182,7 @@ ipt_get_target_c(const struct ipt_entry *e)
 	return ipt_get_target((struct ipt_entry *)e);
 }
 
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 static const char *const hooknames[] = {
 	[NF_INET_PRE_ROUTING]		= "PREROUTING",
 	[NF_INET_LOCAL_IN]		= "INPUT",
@@ -361,8 +360,7 @@ ipt_do_table(struct sk_buff *skb,
 		t = ipt_get_target(e);
 		IP_NF_ASSERT(t->u.kernel.target);
 
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
 		if (unlikely(skb->nf_trace))
 			trace_packet(skb, hook, in, out,
-- 
1.7.10.4

