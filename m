From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 28/44] [IPV6] MIP6: Add routing header type 2 transformation.
Date: Thu, 24 Aug 2006 00:02:29 +0900
Message-ID: <11563453674049-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:7049 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964940AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add routing header type 2 transformation for Mobile IPv6.
Based on MIPL2 kernel patch.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/mip6.h  |   31 +++++++++
 net/ipv6/Makefile   |    2 +
 net/ipv6/af_inet6.c |    9 +++
 net/ipv6/mip6.c     |  181 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 223 insertions(+), 0 deletions(-)

diff --git a/include/net/mip6.h b/include/net/mip6.h
new file mode 100644
index 0000000..644b8b6
--- /dev/null
+++ b/include/net/mip6.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (C)2003-2006 Helsinki University of Technology
+ * Copyright (C)2003-2006 USAGI/WIDE Project
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+/*
+ * Authors:
+ *	Noriaki TAKAMIYA @USAGI
+ *	Masahide NAKAMURA @USAGI
+ *	YOSHIFUJI Hideaki @USAGI
+ */
+#ifndef _NET_MIP6_H
+#define _NET_MIP6_H
+
+extern int mip6_init(void);
+extern void mip6_fini(void);
+
+#endif
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 87e912e..0213c66 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -14,6 +14,8 @@ ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xf
 	xfrm6_output.o
 ipv6-$(CONFIG_NETFILTER) += netfilter.o
 ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
+ipv6-$(CONFIG_IPV6_MIP6) += mip6.o
+
 ipv6-objs += $(ipv6-y)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2ff600c..5d57f57 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -59,6 +59,9 @@ #include <net/addrconf.h>
 #ifdef CONFIG_IPV6_TUNNEL
 #include <net/ip6_tunnel.h>
 #endif
+#ifdef CONFIG_IPV6_MIP6
+#include <net/mip6.h>
+#endif
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -857,6 +860,9 @@ #endif
 	ipv6_frag_init();
 	ipv6_nodata_init();
 	ipv6_destopt_init();
+#ifdef CONFIG_IPV6_MIP6
+	mip6_init();
+#endif
 
 	/* Init v6 transport protocols. */
 	udpv6_init();
@@ -920,6 +926,9 @@ #ifdef CONFIG_PROC_FS
  	tcp6_proc_exit();
  	raw6_proc_exit();
 #endif
+#ifdef CONFIG_IPV6_MIP6
+	mip6_fini();
+#endif
 	/* Cleanup code parts. */
 	sit_cleanup();
 	ip6_flowlabel_cleanup();
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
new file mode 100644
index 0000000..63e548b
--- /dev/null
+++ b/net/ipv6/mip6.c
@@ -0,0 +1,181 @@
+/*
+ * Copyright (C)2003-2006 Helsinki University of Technology
+ * Copyright (C)2003-2006 USAGI/WIDE Project
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+/*
+ * Authors:
+ *	Noriaki TAKAMIYA @USAGI
+ *	Masahide NAKAMURA @USAGI
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ipv6.h>
+#include <net/ipv6.h>
+#include <net/xfrm.h>
+#include <net/mip6.h>
+
+static xfrm_address_t *mip6_xfrm_addr(struct xfrm_state *x, xfrm_address_t *addr)
+{
+	return x->coaddr;
+}
+
+static int mip6_rthdr_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct rt2_hdr *rt2 = (struct rt2_hdr *)skb->data;
+
+	if (!ipv6_addr_equal(&rt2->addr, (struct in6_addr *)x->coaddr) &&
+	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
+		return -ENOENT;
+
+	return rt2->rt_hdr.nexthdr;
+}
+
+/* Routing Header type 2 is inserted.
+ * IP Header's dst address is replaced with Routing Header's Home Address.
+ */
+static int mip6_rthdr_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph;
+	struct rt2_hdr *rt2;
+	u8 nexthdr;
+
+	iph = (struct ipv6hdr *)skb->data;
+	iph->payload_len = htons(skb->len - sizeof(*iph));
+
+	nexthdr = *skb->nh.raw;
+	*skb->nh.raw = IPPROTO_ROUTING;
+
+	rt2 = (struct rt2_hdr *)skb->h.raw;
+	rt2->rt_hdr.nexthdr = nexthdr;
+	rt2->rt_hdr.hdrlen = (x->props.header_len >> 3) - 1;
+	rt2->rt_hdr.type = IPV6_SRCRT_TYPE_2;
+	rt2->rt_hdr.segments_left = 1;
+	memset(&rt2->reserved, 0, sizeof(rt2->reserved));
+
+	BUG_TRAP(rt2->rt_hdr.hdrlen == 2);
+
+	memcpy(&rt2->addr, &iph->daddr, sizeof(rt2->addr));
+	memcpy(&iph->daddr, x->coaddr, sizeof(iph->daddr));
+
+	return 0;
+}
+
+static int mip6_rthdr_offset(struct xfrm_state *x, struct sk_buff *skb,
+			     u8 **nexthdr)
+{
+	u16 offset = sizeof(struct ipv6hdr);
+	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.ipv6h + 1);
+	unsigned int packet_len = skb->tail - skb->nh.raw;
+	int found_rhdr = 0;
+
+	*nexthdr = &skb->nh.ipv6h->nexthdr;
+
+	while (offset + 1 <= packet_len) {
+
+		switch (**nexthdr) {
+		case NEXTHDR_HOP:
+			break;
+		case NEXTHDR_ROUTING:
+			if (offset + 3 <= packet_len) {
+				struct ipv6_rt_hdr *rt;
+				rt = (struct ipv6_rt_hdr *)(skb->nh.raw + offset);
+				if (rt->type != 0)
+					return offset;
+			}
+			found_rhdr = 1;
+			break;
+		case NEXTHDR_DEST:
+			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0)
+				return offset;
+
+			if (found_rhdr)
+				return offset;
+
+			break;
+		default:
+			return offset;
+		}
+
+		offset += ipv6_optlen(exthdr);
+		*nexthdr = &exthdr->nexthdr;
+		exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+	}
+
+	return offset;
+}
+
+static int mip6_rthdr_init_state(struct xfrm_state *x)
+{
+	if (x->id.spi) {
+		printk(KERN_INFO "%s: spi is not 0: %u\n", __FUNCTION__,
+		       x->id.spi);
+		return -EINVAL;
+	}
+	if (x->props.mode != XFRM_MODE_ROUTEOPTIMIZATION) {
+		printk(KERN_INFO "%s: state's mode is not %u: %u\n",
+		       __FUNCTION__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
+		return -EINVAL;
+	}
+
+	x->props.header_len = sizeof(struct rt2_hdr);
+
+	return 0;
+}
+
+/*
+ * Do nothing about destroying since it has no specific operation for routing
+ * header type 2 unlike IPsec protocols.
+ */
+static void mip6_rthdr_destroy(struct xfrm_state *x)
+{
+}
+
+static struct xfrm_type mip6_rthdr_type =
+{
+	.description	= "MIP6RT",
+	.owner		= THIS_MODULE,
+	.proto	     	= IPPROTO_ROUTING,
+	.flags		= XFRM_TYPE_NON_FRAGMENT,
+	.init_state	= mip6_rthdr_init_state,
+	.destructor	= mip6_rthdr_destroy,
+	.input		= mip6_rthdr_input,
+	.output		= mip6_rthdr_output,
+	.hdr_offset	= mip6_rthdr_offset,
+	.remote_addr	= mip6_xfrm_addr,
+};
+
+int __init mip6_init(void)
+{
+	printk(KERN_INFO "Mobile IPv6\n");
+
+	if (xfrm_register_type(&mip6_rthdr_type, AF_INET6) < 0) {
+		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __FUNCTION__);
+		goto mip6_rthdr_xfrm_fail;
+	}
+	return 0;
+
+ mip6_rthdr_xfrm_fail:
+	return -EAGAIN;
+}
+
+void __exit mip6_fini(void)
+{
+	if (xfrm_unregister_type(&mip6_rthdr_type, AF_INET6) < 0)
+		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __FUNCTION__);
+}
-- 
1.4.0

