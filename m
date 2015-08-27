From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next 1/2] netfilter: Define v6ops in !CONFIG_NETFILTER case.
Date: Thu, 27 Aug 2015 15:25:45 -0700
Message-ID: <1440714346-43304-2-git-send-email-joestringer@nicira.com>
References: <1440714346-43304-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pshelar@nicira.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440714346-43304-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_OPENVSWITCH is set, and CONFIG_NETFILTER is not set, the
openvswitch IPv6 fragmentation handling cannot refer to ipv6_ops because
it isn't defined. Add a dummy version to avoid #ifdefs in source files.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/linux/netfilter_ipv6.h | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 8b7d28f..7715746 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -9,15 +9,6 @@
 
 #include <uapi/linux/netfilter_ipv6.h>
 
-
-#ifdef CONFIG_NETFILTER
-int ip6_route_me_harder(struct sk_buff *skb);
-__sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
-			unsigned int dataoff, u_int8_t protocol);
-
-int ipv6_netfilter_init(void);
-void ipv6_netfilter_fini(void);
-
 /*
  * Hook functions for ipv6 to allow xt_* modules to be built-in even
  * if IPv6 is a module.
@@ -30,6 +21,14 @@ struct nf_ipv6_ops {
 			int (*output)(struct sock *, struct sk_buff *));
 };
 
+#ifdef CONFIG_NETFILTER
+int ip6_route_me_harder(struct sk_buff *skb);
+__sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
+			unsigned int dataoff, u_int8_t protocol);
+
+int ipv6_netfilter_init(void);
+void ipv6_netfilter_fini(void);
+
 extern const struct nf_ipv6_ops __rcu *nf_ipv6_ops;
 static inline const struct nf_ipv6_ops *nf_get_ipv6_ops(void)
 {
@@ -39,6 +38,7 @@ static inline const struct nf_ipv6_ops *nf_get_ipv6_ops(void)
 #else /* CONFIG_NETFILTER */
 static inline int ipv6_netfilter_init(void) { return 0; }
 static inline void ipv6_netfilter_fini(void) { return; }
+static inline const struct nf_ipv6_ops *nf_get_ipv6_ops(void) { return NULL; }
 #endif /* CONFIG_NETFILTER */
 
 #endif /*__LINUX_IP6_NETFILTER_H*/
-- 
2.1.4
