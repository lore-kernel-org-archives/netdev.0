From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER 10/10]: Add ipt_policy/ip6t_policy matches
Date: Sat,  7 Jan 2006 02:09:45 +0100 (MET)
Message-ID: <20060107010909.8712.95340.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Add ipt_policy/ip6t_policy matches

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 77b5a9142e3a53b375c6c21ec80fdbe890a8403c
tree e9da4deaa832b50dfa746ed1e3fa873972dcbc42
parent dcaa54019ab79d6db75572a239fdc0df0d8019be
author Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:30:29 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:30:29 +0100

 include/linux/netfilter_ipv4/ipt_policy.h  |   52 ++++++++
 include/linux/netfilter_ipv6/ip6t_policy.h |   52 ++++++++
 net/ipv4/netfilter/Kconfig                 |   10 ++
 net/ipv4/netfilter/Makefile                |    1 
 net/ipv4/netfilter/ipt_policy.c            |  170 +++++++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig                 |   10 ++
 net/ipv6/netfilter/Makefile                |    1 
 net/ipv6/netfilter/ip6t_policy.c           |  175 ++++++++++++++++++++++++++++
 8 files changed, 471 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ipt_policy.h b/include/linux/netfilter_ipv4/ipt_policy.h
new file mode 100644
index 0000000..7fd1bec
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_policy.h
@@ -0,0 +1,52 @@
+#ifndef _IPT_POLICY_H
+#define _IPT_POLICY_H
+
+#define IPT_POLICY_MAX_ELEM	4
+
+enum ipt_policy_flags
+{
+	IPT_POLICY_MATCH_IN	= 0x1,
+	IPT_POLICY_MATCH_OUT	= 0x2,
+	IPT_POLICY_MATCH_NONE	= 0x4,
+	IPT_POLICY_MATCH_STRICT	= 0x8,
+};
+
+enum ipt_policy_modes
+{
+	IPT_POLICY_MODE_TRANSPORT,
+	IPT_POLICY_MODE_TUNNEL
+};
+
+struct ipt_policy_spec
+{
+	u_int8_t	saddr:1,
+			daddr:1,
+			proto:1,
+			mode:1,
+			spi:1,
+			reqid:1;
+};
+
+struct ipt_policy_elem
+{
+	u_int32_t	saddr;
+	u_int32_t	smask;
+	u_int32_t	daddr;
+	u_int32_t	dmask;
+	u_int32_t	spi;
+	u_int32_t	reqid;
+	u_int8_t	proto;
+	u_int8_t	mode;
+
+	struct ipt_policy_spec	match;
+	struct ipt_policy_spec	invert;
+};
+
+struct ipt_policy_info
+{
+	struct ipt_policy_elem pol[IPT_POLICY_MAX_ELEM];
+	u_int16_t flags;
+	u_int16_t len;
+};
+
+#endif /* _IPT_POLICY_H */
diff --git a/include/linux/netfilter_ipv6/ip6t_policy.h b/include/linux/netfilter_ipv6/ip6t_policy.h
new file mode 100644
index 0000000..5a93afc
--- /dev/null
+++ b/include/linux/netfilter_ipv6/ip6t_policy.h
@@ -0,0 +1,52 @@
+#ifndef _IP6T_POLICY_H
+#define _IP6T_POLICY_H
+
+#define IP6T_POLICY_MAX_ELEM	4
+
+enum ip6t_policy_flags
+{
+	IP6T_POLICY_MATCH_IN		= 0x1,
+	IP6T_POLICY_MATCH_OUT		= 0x2,
+	IP6T_POLICY_MATCH_NONE		= 0x4,
+	IP6T_POLICY_MATCH_STRICT	= 0x8,
+};
+
+enum ip6t_policy_modes
+{
+	IP6T_POLICY_MODE_TRANSPORT,
+	IP6T_POLICY_MODE_TUNNEL
+};
+
+struct ip6t_policy_spec
+{
+	u_int8_t	saddr:1,
+			daddr:1,
+			proto:1,
+			mode:1,
+			spi:1,
+			reqid:1;
+};
+
+struct ip6t_policy_elem
+{
+	struct in6_addr	saddr;
+	struct in6_addr	smask;
+	struct in6_addr	daddr;
+	struct in6_addr	dmask;
+	u_int32_t	spi;
+	u_int32_t	reqid;
+	u_int8_t	proto;
+	u_int8_t	mode;
+
+	struct ip6t_policy_spec	match;
+	struct ip6t_policy_spec	invert;
+};
+
+struct ip6t_policy_info
+{
+	struct ip6t_policy_elem pol[IP6T_POLICY_MAX_ELEM];
+	u_int16_t flags;
+	u_int16_t len;
+};
+
+#endif /* _IP6T_POLICY_H */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 88a6065..a9893ec 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -487,6 +487,16 @@ config IP_NF_MATCH_STRING
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_MATCH_POLICY
+       tristate "IPsec policy match support"
+       depends on IP_NF_IPTABLES && XFRM
+       help
+         Policy matching allows you to match packets based on the
+         IPsec policy that was used during decapsulation/will
+         be used during encapsulation.
+
+         To compile it as a module, choose M here.  If unsure, say N.
+
 # `filter', generic and specific targets
 config IP_NF_FILTER
 	tristate "Packet filtering"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index d0a447e..549b01a 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -72,6 +72,7 @@ obj-$(CONFIG_IP_NF_MATCH_TCPMSS) += ipt_
 obj-$(CONFIG_IP_NF_MATCH_REALM) += ipt_realm.o
 obj-$(CONFIG_IP_NF_MATCH_ADDRTYPE) += ipt_addrtype.o
 obj-$(CONFIG_IP_NF_MATCH_PHYSDEV) += ipt_physdev.o
+obj-$(CONFIG_IP_NF_MATCH_POLICY) += ipt_policy.o
 obj-$(CONFIG_IP_NF_MATCH_COMMENT) += ipt_comment.o
 obj-$(CONFIG_IP_NF_MATCH_STRING) += ipt_string.o
 
diff --git a/net/ipv4/netfilter/ipt_policy.c b/net/ipv4/netfilter/ipt_policy.c
new file mode 100644
index 0000000..709debc
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_policy.c
@@ -0,0 +1,170 @@
+/* IP tables module for matching IPsec policy
+ *
+ * Copyright (c) 2004,2005 Patrick McHardy, <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <net/xfrm.h>
+
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_policy.h>
+
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("IPtables IPsec policy matching module");
+MODULE_LICENSE("GPL");
+
+
+static inline int
+match_xfrm_state(struct xfrm_state *x, const struct ipt_policy_elem *e)
+{
+#define MATCH(x,y)	(!e->match.x || ((e->x == (y)) ^ e->invert.x))
+
+	return MATCH(saddr, x->props.saddr.a4 & e->smask) &&
+	       MATCH(daddr, x->id.daddr.a4 & e->dmask) &&
+	       MATCH(proto, x->id.proto) &&
+	       MATCH(mode, x->props.mode) &&
+	       MATCH(spi, x->id.spi) &&
+	       MATCH(reqid, x->props.reqid);
+}
+
+static int
+match_policy_in(const struct sk_buff *skb, const struct ipt_policy_info *info)
+{
+	const struct ipt_policy_elem *e;
+	struct sec_path *sp = skb->sp;
+	int strict = info->flags & IPT_POLICY_MATCH_STRICT;
+	int i, pos;
+
+	if (sp == NULL)
+		return -1;
+	if (strict && info->len != sp->len)
+		return 0;
+
+	for (i = sp->len - 1; i >= 0; i--) {
+		pos = strict ? i - sp->len + 1 : 0;
+		if (pos >= info->len)
+			return 0;
+		e = &info->pol[pos];
+
+		if (match_xfrm_state(sp->x[i].xvec, e)) {
+			if (!strict)
+				return 1;
+		} else if (strict)
+			return 0;
+	}
+
+	return strict ? 1 : 0;
+}
+
+static int
+match_policy_out(const struct sk_buff *skb, const struct ipt_policy_info *info)
+{
+	const struct ipt_policy_elem *e;
+	struct dst_entry *dst = skb->dst;
+	int strict = info->flags & IPT_POLICY_MATCH_STRICT;
+	int i, pos;
+
+	if (dst->xfrm == NULL)
+		return -1;
+
+	for (i = 0; dst && dst->xfrm; dst = dst->child, i++) {
+		pos = strict ? i : 0;
+		if (pos >= info->len)
+			return 0;
+		e = &info->pol[pos];
+
+		if (match_xfrm_state(dst->xfrm, e)) {
+			if (!strict)
+				return 1;
+		} else if (strict)
+			return 0;
+	}
+
+	return strict ? 1 : 0;
+}
+
+static int match(const struct sk_buff *skb,
+                 const struct net_device *in,
+                 const struct net_device *out,
+                 const void *matchinfo, int offset, int *hotdrop)
+{
+	const struct ipt_policy_info *info = matchinfo;
+	int ret;
+
+	if (info->flags & IPT_POLICY_MATCH_IN)
+		ret = match_policy_in(skb, info);
+	else
+		ret = match_policy_out(skb, info);
+
+	if (ret < 0)
+		ret = info->flags & IPT_POLICY_MATCH_NONE ? 1 : 0;
+	else if (info->flags & IPT_POLICY_MATCH_NONE)
+		ret = 0;
+
+	return ret;
+}
+
+static int checkentry(const char *tablename, const struct ipt_ip *ip,
+                      void *matchinfo, unsigned int matchsize,
+                      unsigned int hook_mask)
+{
+	struct ipt_policy_info *info = matchinfo;
+
+	if (matchsize != IPT_ALIGN(sizeof(*info))) {
+		printk(KERN_ERR "ipt_policy: matchsize %u != %zu\n",
+		       matchsize, IPT_ALIGN(sizeof(*info)));
+		return 0;
+	}
+	if (!(info->flags & (IPT_POLICY_MATCH_IN|IPT_POLICY_MATCH_OUT))) {
+		printk(KERN_ERR "ipt_policy: neither incoming nor "
+		                "outgoing policy selected\n");
+		return 0;
+	}
+	if (hook_mask & (1 << NF_IP_PRE_ROUTING | 1 << NF_IP_LOCAL_IN)
+	    && info->flags & IPT_POLICY_MATCH_OUT) {
+		printk(KERN_ERR "ipt_policy: output policy not valid in "
+		                "PRE_ROUTING and INPUT\n");
+		return 0;
+	}
+	if (hook_mask & (1 << NF_IP_POST_ROUTING | 1 << NF_IP_LOCAL_OUT)
+	    && info->flags & IPT_POLICY_MATCH_IN) {
+		printk(KERN_ERR "ipt_policy: input policy not valid in "
+		                "POST_ROUTING and OUTPUT\n");
+		return 0;
+	}
+	if (info->len > IPT_POLICY_MAX_ELEM) {
+		printk(KERN_ERR "ipt_policy: too many policy elements\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct ipt_match policy_match = {
+	.name		= "policy",
+	.match		= match,
+	.checkentry 	= checkentry,
+	.me		= THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	return ipt_register_match(&policy_match);
+}
+
+static void __exit fini(void)
+{
+	ipt_unregister_match(&policy_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 04912f9..105dd69 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -179,6 +179,16 @@ config IP6_NF_MATCH_PHYSDEV
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_MATCH_POLICY
+	tristate "IPsec policy match support"
+	depends on IP6_NF_IPTABLES && XFRM
+	help
+	  Policy matching allows you to match packets based on the
+	  IPsec policy that was used during decapsulation/will
+	  be used during encapsulation.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 # The targets
 config IP6_NF_FILTER
 	tristate "Packet filtering"
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 9ab5b2c..c0c809b 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -13,6 +13,7 @@ obj-$(CONFIG_IP6_NF_MATCH_OPTS) += ip6t_
 obj-$(CONFIG_IP6_NF_MATCH_IPV6HEADER) += ip6t_ipv6header.o
 obj-$(CONFIG_IP6_NF_MATCH_FRAG) += ip6t_frag.o
 obj-$(CONFIG_IP6_NF_MATCH_AHESP) += ip6t_esp.o ip6t_ah.o
+obj-$(CONFIG_IP6_NF_MATCH_POLICY) += ip6t_policy.o
 obj-$(CONFIG_IP6_NF_MATCH_EUI64) += ip6t_eui64.o
 obj-$(CONFIG_IP6_NF_MATCH_MULTIPORT) += ip6t_multiport.o
 obj-$(CONFIG_IP6_NF_MATCH_OWNER) += ip6t_owner.o
diff --git a/net/ipv6/netfilter/ip6t_policy.c b/net/ipv6/netfilter/ip6t_policy.c
new file mode 100644
index 0000000..13fedad
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_policy.c
@@ -0,0 +1,175 @@
+/* IP tables module for matching IPsec policy
+ *
+ * Copyright (c) 2004,2005 Patrick McHardy, <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <net/xfrm.h>
+
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter_ipv6/ip6t_policy.h>
+
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("IPtables IPsec policy matching module");
+MODULE_LICENSE("GPL");
+
+
+static inline int
+match_xfrm_state(struct xfrm_state *x, const struct ip6t_policy_elem *e)
+{
+#define MATCH_ADDR(x,y,z)	(!e->match.x || \
+				 ((ip6_masked_addrcmp((z), &e->x, &e->y)) == 0) ^ e->invert.x)
+#define MATCH(x,y)		(!e->match.x || ((e->x == (y)) ^ e->invert.x))
+	
+	return MATCH_ADDR(saddr, smask, (struct in6_addr *)&x->props.saddr.a6) &&
+	       MATCH_ADDR(daddr, dmask, (struct in6_addr *)&x->id.daddr.a6) &&
+	       MATCH(proto, x->id.proto) &&
+	       MATCH(mode, x->props.mode) &&
+	       MATCH(spi, x->id.spi) &&
+	       MATCH(reqid, x->props.reqid);
+}
+
+static int
+match_policy_in(const struct sk_buff *skb, const struct ip6t_policy_info *info)
+{
+	const struct ip6t_policy_elem *e;
+	struct sec_path *sp = skb->sp;
+	int strict = info->flags & IP6T_POLICY_MATCH_STRICT;
+	int i, pos;
+
+	if (sp == NULL)
+		return -1;
+	if (strict && info->len != sp->len)
+		return 0;
+
+	for (i = sp->len - 1; i >= 0; i--) {
+		pos = strict ? i - sp->len + 1 : 0;
+		if (pos >= info->len)
+			return 0;
+		e = &info->pol[pos];
+
+		if (match_xfrm_state(sp->x[i].xvec, e)) {
+			if (!strict)
+				return 1;
+		} else if (strict)
+			return 0;
+	}
+
+	return strict ? 1 : 0;
+}
+
+static int
+match_policy_out(const struct sk_buff *skb, const struct ip6t_policy_info *info)
+{
+	const struct ip6t_policy_elem *e;
+	struct dst_entry *dst = skb->dst;
+	int strict = info->flags & IP6T_POLICY_MATCH_STRICT;
+	int i, pos;
+
+	if (dst->xfrm == NULL)
+		return -1;
+
+	for (i = 0; dst && dst->xfrm; dst = dst->child, i++) {
+		pos = strict ? i : 0;
+		if (pos >= info->len)
+			return 0;
+		e = &info->pol[pos];
+
+		if (match_xfrm_state(dst->xfrm, e)) {
+			if (!strict)
+				return 1;
+		} else if (strict)
+			return 0;
+	}
+
+	return strict ? 1 : 0;
+}
+
+static int match(const struct sk_buff *skb,
+                 const struct net_device *in,
+                 const struct net_device *out,
+                 const void *matchinfo,
+		 int offset,
+		 unsigned int protoff,
+		 int *hotdrop)
+{
+	const struct ip6t_policy_info *info = matchinfo;
+	int ret;
+
+	if (info->flags & IP6T_POLICY_MATCH_IN)
+		ret = match_policy_in(skb, info);
+	else
+		ret = match_policy_out(skb, info);
+
+	if (ret < 0)
+		ret = info->flags & IP6T_POLICY_MATCH_NONE ? 1 : 0;
+	else if (info->flags & IP6T_POLICY_MATCH_NONE)
+		ret = 0;
+
+	return ret;
+}
+
+static int checkentry(const char *tablename, const struct ip6t_ip6 *ip,
+                      void *matchinfo, unsigned int matchsize,
+                      unsigned int hook_mask)
+{
+	struct ip6t_policy_info *info = matchinfo;
+
+	if (matchsize != IP6T_ALIGN(sizeof(*info))) {
+		printk(KERN_ERR "ip6t_policy: matchsize %u != %zu\n",
+		       matchsize, IP6T_ALIGN(sizeof(*info)));
+		return 0;
+	}
+	if (!(info->flags & (IP6T_POLICY_MATCH_IN|IP6T_POLICY_MATCH_OUT))) {
+		printk(KERN_ERR "ip6t_policy: neither incoming nor "
+		                "outgoing policy selected\n");
+		return 0;
+	}
+	if (hook_mask & (1 << NF_IP6_PRE_ROUTING | 1 << NF_IP6_LOCAL_IN)
+	    && info->flags & IP6T_POLICY_MATCH_OUT) {
+		printk(KERN_ERR "ip6t_policy: output policy not valid in "
+		                "PRE_ROUTING and INPUT\n");
+		return 0;
+	}
+	if (hook_mask & (1 << NF_IP6_POST_ROUTING | 1 << NF_IP6_LOCAL_OUT)
+	    && info->flags & IP6T_POLICY_MATCH_IN) {
+		printk(KERN_ERR "ip6t_policy: input policy not valid in "
+		                "POST_ROUTING and OUTPUT\n");
+		return 0;
+	}
+	if (info->len > IP6T_POLICY_MAX_ELEM) {
+		printk(KERN_ERR "ip6t_policy: too many policy elements\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct ip6t_match policy_match = {
+	.name		= "policy",
+	.match		= match,
+	.checkentry 	= checkentry,
+	.me		= THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	return ip6t_register_match(&policy_match);
+}
+
+static void __exit fini(void)
+{
+	ip6t_unregister_match(&policy_match);
+}
+
+module_init(init);
+module_exit(fini);
