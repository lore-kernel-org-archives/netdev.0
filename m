From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/19] netfilter: nf_conntrack: remove net_ratelimit() for LOG_INVALID()
Date: Tue, 20 Aug 2013 12:54:34 +0200
Message-ID: <1376996091-3964-3-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Logging of invalid packets has to be explicitly enabled. Rate-limiting these
messages is inconsistent with other netfilter logging features and makes
debugging harder.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 914d8d9..b411d7b 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -148,17 +148,10 @@ extern int nf_ct_port_nlattr_tuple_size(void);
 extern const struct nla_policy nf_ct_port_nla_policy[];
 
 #ifdef CONFIG_SYSCTL
-#ifdef DEBUG_INVALID_PACKETS
 #define LOG_INVALID(net, proto)				\
 	((net)->ct.sysctl_log_invalid == (proto) ||	\
 	 (net)->ct.sysctl_log_invalid == IPPROTO_RAW)
 #else
-#define LOG_INVALID(net, proto)				\
-	(((net)->ct.sysctl_log_invalid == (proto) ||	\
-	  (net)->ct.sysctl_log_invalid == IPPROTO_RAW)	\
-	 && net_ratelimit())
-#endif
-#else
 static inline int LOG_INVALID(struct net *net, int proto) { return 0; }
 #endif /* CONFIG_SYSCTL */
 
-- 
1.7.10.4

