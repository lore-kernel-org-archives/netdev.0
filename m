From: nakam@linux-ipv6.org
Subject: [PATCH] [XFRM]: Add module alias for transformation type. (Re: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.)
Date: Fri, 25 May 2007 13:23:23 +0900
Message-ID: <1180067003902-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	jmorris@namei.org, kazunori@miyazawa.org, mk@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: netdev@axxeo.de, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:42734 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbXEYEX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 00:23:26 -0400
In-Reply-To: 20070524222026.F55B.NAKAM@linux-ipv6.org
References: 20070524222026.F55B.NAKAM@linux-ipv6.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ingo and all,

This is the third one of MIPv6 module patch. It can be applied
after two patches which are already sent to the list.
Could you review it?


It is clean-up for XFRM type modules and adds aliases with its
protocol:
 ESP, AH, IPCOMP, IPIP and IPv6 for IPsec
 ROUTING and DSTOPTS for MIPv6

It is almost the same thing as XFRM mode alias, but it is added
new defines XFRM_PROTO_XXX for preprocessing since some protocols
are defined as enum.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/net/xfrm.h      |   10 ++++++++++
 net/ipv4/ah4.c          |    1 +
 net/ipv4/esp4.c         |    1 +
 net/ipv4/ipcomp.c       |    1 +
 net/ipv4/xfrm4_tunnel.c |    1 +
 net/ipv6/ah6.c          |    1 +
 net/ipv6/esp6.c         |    1 +
 net/ipv6/ipcomp6.c      |    2 +-
 net/ipv6/mip6.c         |    2 ++
 net/ipv6/xfrm6_tunnel.c |    1 +
 10 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1e53520..c9f895f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -19,9 +19,19 @@
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 
+#define XFRM_PROTO_ESP		50
+#define XFRM_PROTO_AH		51
+#define XFRM_PROTO_COMP		108
+#define XFRM_PROTO_IPIP		4
+#define XFRM_PROTO_IPV6		41
+#define XFRM_PROTO_ROUTING	IPPROTO_ROUTING
+#define XFRM_PROTO_DSTOPTS	IPPROTO_DSTOPTS
+
 #define XFRM_ALIGN8(len)	(((len) + 7) & ~7)
 #define MODULE_ALIAS_XFRM_MODE(family, encap) \
 	MODULE_ALIAS("xfrm-mode-" __stringify(family) "-" __stringify(encap))
+#define MODULE_ALIAS_XFRM_TYPE(family, proto) \
+	MODULE_ALIAS("xfrm-type-" __stringify(family) "-" __stringify(proto))
 
 extern struct sock *xfrm_nl;
 extern u32 sysctl_xfrm_aevent_etime;
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 6da8ff5..7a23e59 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -339,3 +339,4 @@ static void __exit ah4_fini(void)
 module_init(ah4_init);
 module_exit(ah4_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_TYPE(AF_INET, XFRM_PROTO_AH);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 47c95e8..98767a4 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -481,3 +481,4 @@ static void __exit esp4_fini(void)
 module_init(esp4_init);
 module_exit(esp4_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_TYPE(AF_INET, XFRM_PROTO_ESP);
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index ab86137..e787044 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -485,3 +485,4 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("IP Payload Compression Protocol (IPComp) - RFC3173");
 MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
 
+MODULE_ALIAS_XFRM_TYPE(AF_INET, XFRM_PROTO_COMP);
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 5685103..9275c79 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -109,3 +109,4 @@ static void __exit ipip_fini(void)
 module_init(ipip_init);
 module_exit(ipip_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_TYPE(AF_INET, XFRM_PROTO_IPIP);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 7f764f9..5669430 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -554,3 +554,4 @@ module_init(ah6_init);
 module_exit(ah6_fini);
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_TYPE(AF_INET6, XFRM_PROTO_AH);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 7107bb7..2db31ce 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -421,3 +421,4 @@ module_init(esp6_init);
 module_exit(esp6_fini);
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_TYPE(AF_INET6, XFRM_PROTO_ESP);
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 1ee50b5..473f165 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -500,4 +500,4 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("IP Payload Compression Protocol (IPComp) for IPv6 - RFC3173");
 MODULE_AUTHOR("Mitsuru KANDA <mk@linux-ipv6.org>");
 
-
+MODULE_ALIAS_XFRM_TYPE(AF_INET6, XFRM_PROTO_COMP);
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 20c78ec..8a1399c 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -514,3 +514,5 @@ module_init(mip6_init);
 module_exit(mip6_fini);
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_TYPE(AF_INET6, XFRM_PROTO_DSTOPTS);
+MODULE_ALIAS_XFRM_TYPE(AF_INET6, XFRM_PROTO_ROUTING);
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 5502cc9..6f87dd5 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -379,3 +379,4 @@ static void __exit xfrm6_tunnel_fini(void)
 module_init(xfrm6_tunnel_init);
 module_exit(xfrm6_tunnel_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_TYPE(AF_INET6, XFRM_PROTO_IPV6);
-- 
1.4.4.2

