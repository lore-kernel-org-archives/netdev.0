From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 3/3] iproute2 and xfrm
Date: Thu, 15 Jul 2004 15:02:21 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715150221.537fee7d@localhost>
References: <20040703094632.GA14235@gondor.apana.org.au>
	<20040705160500.208591b5@localhost>
	<20040706140550.2d483dc8@dell_ss3.pdx.osdl.net>
	<20040707130950.0112edf6@localhost>
	<20040707140533.41c66c03@localhost>
	<20040707155602.4698121a@localhost>
	<20040707110315.GA26100@gondor.apana.org.au>
	<20040709125100.3edce4e9@localhost>
	<20040714174637.0ce79ae1@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040714174637.0ce79ae1@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch is for iproute2 and fixes minor output format.

Regards,


ChangeSet@1.57, 2004-07-12 20:01:23+09:00, nakam@linux-ipv6.org
  fix message for protocol.

diff -Nru a/ip/ipxfrm.c b/ip/ipxfrm.c
--- a/ip/ipxfrm.c	2004-07-14 16:35:49 +09:00
+++ b/ip/ipxfrm.c	2004-07-14 16:35:49 +09:00
@@ -91,6 +91,23 @@
 	return str;
 }
 
+const char *strxf_proto(__u8 proto)
+{
+	static char buf[32];
+	struct protoent *pp;
+	const char *p;
+
+	pp = getprotobynumber(proto);
+	if (pp)
+		p = pp->p_name;
+	else {
+		sprintf(buf, "%d", proto);
+		p = buf;
+	}
+
+	return p;
+}
+
 void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
 			__u8 mode, __u32 reqid, __u16 family, FILE *fp,
 			const char *prefix)
diff -Nru a/ip/xfrm.h b/ip/xfrm.h
--- a/ip/xfrm.h	2004-07-14 16:35:49 +09:00
+++ b/ip/xfrm.h	2004-07-14 16:35:49 +09:00
@@ -80,6 +80,7 @@
 
 const char *strxf_flags(__u8 flags);
 const char *strxf_share(__u8 share);
+const char *strxf_proto(__u8 proto);
 void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
 			__u8 mode, __u32 reqid, __u16 family, FILE *fp,
 			const char *prefix);
diff -Nru a/ip/xfrm_policy.c b/ip/xfrm_policy.c
--- a/ip/xfrm_policy.c	2004-07-14 16:35:49 +09:00
+++ b/ip/xfrm_policy.c	2004-07-14 16:35:49 +09:00
@@ -78,7 +78,12 @@
 	fprintf(stderr, "TMPL := ID [ mode MODE ] [ reqid REQID ] [ level LEVEL ]\n");
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
 
-	fprintf(stderr, "XFRM_PROTO := [ esp | ah | ipcomp ]\n");
+	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | ipcomp ]\n");
+	fprintf(stderr, "XFRM_PROTO := [ ");
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ESP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_AH));
+	fprintf(stderr, "%s", strxf_proto(IPPROTO_COMP));
+	fprintf(stderr, " ]\n");
 
  	fprintf(stderr, "MODE := [ transport | tunnel ](default=transport)\n");
  	//fprintf(stderr, "REQID - number(default=0)\n");
diff -Nru a/ip/xfrm_state.c b/ip/xfrm_state.c
--- a/ip/xfrm_state.c	2004-07-14 16:35:49 +09:00
+++ b/ip/xfrm_state.c	2004-07-14 16:35:49 +09:00
@@ -63,7 +63,13 @@
 	fprintf(stderr, "        [ FLAG_LIST ]\n");
 
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
-	fprintf(stderr, "XFRM_PROTO := [ esp | ah | ipcomp ]\n");
+	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | ipcomp ]\n");
+	fprintf(stderr, "XFRM_PROTO := [ ");
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ESP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_AH));
+	fprintf(stderr, "%s", strxf_proto(IPPROTO_COMP));
+	fprintf(stderr, " ]\n");
+
 	//fprintf(stderr, "SPI - security parameter index(default=0)\n");
 
  	fprintf(stderr, "MODE := [ transport | tunnel ](default=transport)\n");




-- 
Masahide NAKAMURA
