From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/3 XFRM]: Fix ICMP tempsel
Date: Sat, 05 Mar 2005 14:58:58 +0100
Message-ID: <4229BB22.50107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020409020007020805000402"
Cc: Maillist netdev <netdev@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020409020007020805000402
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

there was a lot of discussion going on last time I posted these
patches, these are the patches everyone agreed on. They are based
on your 2.6.12 tree.


--------------020409020007020805000402
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/05 01:57:26+01:00 kaber@coreworks.de 
#   [XFRM]: Fix ICMP tempsel
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/xfrm6_state.c
#   2005/03/05 01:57:18+01:00 kaber@coreworks.de +2 -2
#   [XFRM]: Fix ICMP tempsel
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/xfrm4_state.c
#   2005/03/05 01:57:18+01:00 kaber@coreworks.de +2 -2
#   [XFRM]: Fix ICMP tempsel
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
--- a/net/ipv4/xfrm4_state.c	2005-03-05 13:03:27 +01:00
+++ b/net/ipv4/xfrm4_state.c	2005-03-05 13:03:27 +01:00
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
--- a/net/ipv6/xfrm6_state.c	2005-03-05 13:03:27 +01:00
+++ b/net/ipv6/xfrm6_state.c	2005-03-05 13:03:27 +01:00
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

--------------020409020007020805000402--
