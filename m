From: "David S. Miller" <davem@redhat.com>
Subject: Today's net-2.6.9 update
Date: Thu, 19 Aug 2004 07:50:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819075019.23ca9e4e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Just to include Herbert Xu's xfrm tunnel diffs.
If bored, try to see that all combinations of modular
vs. non-modular work for the new xfrm tunnel choices.

As usual:

	bk://kernel.bkbits.net/davem/net-2.6
	ftp://ftp.kernel.org/pub/linux/kernel/people/davem/net-2.6.9-3.diff.gz

Thanks.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/19 07:12:01-07:00 herbert@gondor.apana.org.au 
#   [IPSEC]: Use xfrm4_rcv in xfrm4_tunnel
#   
#   This is a trivial patch to use xfrm4_rcv in xfrm4_tunnel.  It doesn't
#   need the extra argument provided by xfrm4_rcv_encap.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/xfrm4_tunnel.c
#   2004/08/19 07:11:45-07:00 herbert@gondor.apana.org.au +1 -1
#   [IPSEC]: Use xfrm4_rcv in xfrm4_tunnel
#   
#   This is a trivial patch to use xfrm4_rcv in xfrm4_tunnel.  It doesn't
#   need the extra argument provided by xfrm4_rcv_encap.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
diff -Nru a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
--- a/net/ipv4/xfrm4_tunnel.c	2004-08-19 07:34:12 -07:00
+++ b/net/ipv4/xfrm4_tunnel.c	2004-08-19 07:34:12 -07:00
@@ -68,7 +68,7 @@
 	if (handler && handler->handler(skb) == 0)
 		return 0;
 
-	return xfrm4_rcv_encap(skb, 0);
+	return xfrm4_rcv(skb);
 }
 
 static void ipip_err(struct sk_buff *skb, u32 info)
# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/19 07:13:27-07:00 herbert@gondor.apana.org.au 
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/xfrm/xfrm_export.c
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +0 -2
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv6/xfrm6_tunnel.c
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +10 -5
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv6/xfrm6_policy.c
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +0 -2
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv6/Makefile
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +2 -1
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv6/Kconfig
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +13 -1
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/xfrm4_tunnel.c
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +5 -0
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/Makefile
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +2 -1
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/Kconfig
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +11 -1
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# include/net/xfrm.h
#   2004/08/19 07:13:10-07:00 herbert@gondor.apana.org.au +0 -2
#   [IPSEC]: Modularise xfrm_tunnel.
#   
#   This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
#   modules.
#   
#   This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
#   which are modules themselves.  It also means that distros can cut
#   down on there core kernel size when compiling with IPsec support.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2004-08-19 07:34:25 -07:00
+++ b/include/net/xfrm.h	2004-08-19 07:34:25 -07:00
@@ -792,8 +792,6 @@
 extern void xfrm4_state_fini(void);
 extern void xfrm6_state_init(void);
 extern void xfrm6_state_fini(void);
-extern void xfrm6_tunnel_init(void);
-extern void xfrm6_tunnel_fini(void);
 
 extern int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*), void *);
 extern struct xfrm_state *xfrm_state_alloc(void);
diff -Nru a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig	2004-08-19 07:34:25 -07:00
+++ b/net/ipv4/Kconfig	2004-08-19 07:34:25 -07:00
@@ -187,7 +187,7 @@
 config NET_IPIP
 	tristate "IP: tunneling"
 	depends on INET
-	select XFRM
+	select INET_TUNNEL
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
@@ -351,11 +351,21 @@
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
 	select XFRM
+	select INET_TUNNEL
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
 	  Support for IP Paylod Compression (RFC3173), typically needed
 	  for IPsec.
+	  
+	  If unsure, say Y.
+
+config INET_TUNNEL
+	tristate "IP: tunnel transformation"
+	select XFRM
+	---help---
+	  Support for generic IP tunnel transformation, which is required by
+	  the IP tunneling module as well as tunnel mode IPComp.
 	  
 	  If unsure, say Y.
 
diff -Nru a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2004-08-19 07:34:25 -07:00
+++ b/net/ipv4/Makefile	2004-08-19 07:34:25 -07:00
@@ -19,9 +19,10 @@
 obj-$(CONFIG_INET_AH) += ah4.o
 obj-$(CONFIG_INET_ESP) += esp4.o
 obj-$(CONFIG_INET_IPCOMP) += ipcomp.o
+obj-$(CONFIG_INET_TUNNEL) += xfrm4_tunnel.o 
 obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
-		      xfrm4_tunnel.o xfrm4_output.o
+		      xfrm4_output.o
diff -Nru a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
--- a/net/ipv4/xfrm4_tunnel.c	2004-08-19 07:34:25 -07:00
+++ b/net/ipv4/xfrm4_tunnel.c	2004-08-19 07:34:25 -07:00
@@ -4,6 +4,7 @@
  */
 
 #include <linux/skbuff.h>
+#include <linux/module.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -43,6 +44,8 @@
 	return ret;
 }
 
+EXPORT_SYMBOL(xfrm4_tunnel_register);
+
 int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler)
 {
 	int ret;
@@ -59,6 +62,8 @@
 
 	return ret;
 }
+
+EXPORT_SYMBOL(xfrm4_tunnel_deregister);
 
 static int ipip_rcv(struct sk_buff *skb)
 {
diff -Nru a/net/ipv6/Kconfig b/net/ipv6/Kconfig
--- a/net/ipv6/Kconfig	2004-08-19 07:34:25 -07:00
+++ b/net/ipv6/Kconfig	2004-08-19 07:34:25 -07:00
@@ -48,6 +48,7 @@
 	tristate "IPv6: IPComp transformation"
 	depends on IPV6
 	select XFRM
+	select INET6_TUNNEL
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
@@ -56,10 +57,21 @@
 
 	  If unsure, say Y.
 
+config INET6_TUNNEL
+	tristate "IPv6: tunnel transformation"
+	depends on IPV6
+	select XFRM
+	---help---
+	  Support for generic IPv6-in-IPv6 tunnel transformation, which is
+	  required by the IPv6-in-IPv6 tunneling module as well as tunnel mode
+	  IPComp.
+	  
+	  If unsure, say Y.
+
 config IPV6_TUNNEL
 	tristate "IPv6: IPv6-in-IPv6 tunnel"
 	depends on IPV6
-	select XFRM
+	select INET6_TUNNEL
 	---help---
 	  Support for IPv6-in-IPv6 tunnels described in RFC 2473.
 
diff -Nru a/net/ipv6/Makefile b/net/ipv6/Makefile
--- a/net/ipv6/Makefile	2004-08-19 07:34:25 -07:00
+++ b/net/ipv6/Makefile	2004-08-19 07:34:25 -07:00
@@ -11,12 +11,13 @@
 		ip6_flowlabel.o ipv6_syms.o
 
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
-	xfrm6_tunnel.o xfrm6_output.o
+	xfrm6_output.o
 ipv6-objs += $(ipv6-y)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
 obj-$(CONFIG_INET6_ESP) += esp6.o
 obj-$(CONFIG_INET6_IPCOMP) += ipcomp6.o
+obj-$(CONFIG_INET6_TUNNEL) += xfrm6_tunnel.o 
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c	2004-08-19 07:34:25 -07:00
+++ b/net/ipv6/xfrm6_policy.c	2004-08-19 07:34:25 -07:00
@@ -287,12 +287,10 @@
 {
 	xfrm6_policy_init();
 	xfrm6_state_init();
-	xfrm6_tunnel_init();
 }
 
 void __exit xfrm6_fini(void)
 {
-	xfrm6_tunnel_fini();
 	//xfrm6_input_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
diff -Nru a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
--- a/net/ipv6/xfrm6_tunnel.c	2004-08-19 07:34:25 -07:00
+++ b/net/ipv6/xfrm6_tunnel.c	2004-08-19 07:34:25 -07:00
@@ -501,31 +501,32 @@
 	.flags          = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-void __init xfrm6_tunnel_init(void)
+static int __init xfrm6_tunnel_init(void)
 {
 	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
 
 	if (xfrm_register_type(&xfrm6_tunnel_type, AF_INET6) < 0) {
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel init: can't add xfrm type\n");
-		return;
+		return -EAGAIN;
 	}
 	if (inet6_add_protocol(&xfrm6_tunnel_protocol, IPPROTO_IPV6) < 0) {
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel init(): can't add protocol\n");
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-		return;
+		return -EAGAIN;
 	}
 	if (xfrm6_tunnel_spi_init() < 0) {
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel init: failed to initialize spi\n");
 		inet6_del_protocol(&xfrm6_tunnel_protocol, IPPROTO_IPV6);
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-		return;
+		return -EAGAIN;
 	}
+	return 0;
 }
 
-void __exit xfrm6_tunnel_fini(void)
+static void __exit xfrm6_tunnel_fini(void)
 {
 	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
 
@@ -537,3 +538,7 @@
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel close: can't remove xfrm type\n");
 }
+
+module_init(xfrm6_tunnel_init);
+module_exit(xfrm6_tunnel_fini);
+MODULE_LICENSE("GPL");
diff -Nru a/net/xfrm/xfrm_export.c b/net/xfrm/xfrm_export.c
--- a/net/xfrm/xfrm_export.c	2004-08-19 07:34:25 -07:00
+++ b/net/xfrm/xfrm_export.c	2004-08-19 07:34:25 -07:00
@@ -33,8 +33,6 @@
 EXPORT_SYMBOL(xfrm_get_acqseq);
 EXPORT_SYMBOL(xfrm_parse_spi);
 EXPORT_SYMBOL(xfrm4_rcv);
-EXPORT_SYMBOL(xfrm4_tunnel_register);
-EXPORT_SYMBOL(xfrm4_tunnel_deregister);
 EXPORT_SYMBOL(xfrm_register_type);
 EXPORT_SYMBOL(xfrm_unregister_type);
 EXPORT_SYMBOL(xfrm_get_type);
