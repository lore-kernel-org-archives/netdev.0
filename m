From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix ICMP tempsel
Date: Sat, 19 Feb 2005 12:43:43 +0100
Message-ID: <4217266F.6090700@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070100090607050204020104"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Maillist netdev <netdev@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070100090607050204020104
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
type and code should be stored in sport and dport, in struct flowi both
are contained in fl_ip_sport.



--------------070100090607050204020104
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/19 12:35:18+01:00 kaber@coreworks.de 
#   [XFRM]: Fix ICMP tempsel
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/xfrm6_state.c
#   2005/02/19 12:35:06+01:00 kaber@coreworks.de +2 -2
#   [XFRM]: Fix ICMP tempsel
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/xfrm4_state.c
#   2005/02/19 12:35:06+01:00 kaber@coreworks.de +2 -2
#   [XFRM]: Fix ICMP tempsel
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
--- a/net/ipv4/xfrm4_state.c	2005-02-19 12:36:31 +01:00
+++ b/net/ipv4/xfrm4_state.c	2005-02-19 12:36:31 +01:00
@@ -20,9 +20,9 @@
 {
 	x->sel.daddr.a4 = fl->fl4_dst;
 	x->sel.saddr.a4 = fl->fl4_src;
-	x->sel.dport = fl->fl_ip_dport;
+	x->sel.dport = xfrm_flowi_dport(fl);
 	x->sel.dport_mask = ~0;
-	x->sel.sport = fl->fl_ip_sport;
+	x->sel.sport = xfrm_flowi_sport(fl);
 	x->sel.sport_mask = ~0;
 	x->sel.prefixlen_d = 32;
 	x->sel.prefixlen_s = 32;
diff -Nru a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
--- a/net/ipv6/xfrm6_state.c	2005-02-19 12:36:31 +01:00
+++ b/net/ipv6/xfrm6_state.c	2005-02-19 12:36:31 +01:00
@@ -27,9 +27,9 @@
 	 * to current session. */
 	ipv6_addr_copy((struct in6_addr *)&x->sel.daddr, &fl->fl6_dst);
 	ipv6_addr_copy((struct in6_addr *)&x->sel.saddr, &fl->fl6_src);
-	x->sel.dport = fl->fl_ip_dport;
+	x->sel.dport = xfrm_flowi_dport(fl);
 	x->sel.dport_mask = ~0;
-	x->sel.sport = fl->fl_ip_sport;
+	x->sel.sport = xfrm_flowi_sport(fl);
 	x->sel.sport_mask = ~0;
 	x->sel.prefixlen_d = 128;
 	x->sel.prefixlen_s = 128;

--------------070100090607050204020104--
