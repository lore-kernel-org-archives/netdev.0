From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/3 XFRM]: Always reroute in tunnel mode
Date: Sat, 05 Mar 2005 14:59:03 +0100
Message-ID: <4229BB27.30009@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080900080003050705020402"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080900080003050705020402
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080900080003050705020402
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/05 01:58:51+01:00 kaber@coreworks.de 
#   [XFRM]: Always reroute in tunnel mode
#   
#   Tunnel mode packets are rerouted if the tunnel destination
#   address is different from the original destination address,
#   otherwise the old route is used. This is inconsistent, the
#   old route might have been selected for a given output device
#   or using routing by tos/fwmark. Always choose a new route
#   in tunnel mode.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/xfrm6_policy.c
#   2005/03/05 01:58:41+01:00 kaber@coreworks.de +3 -1
#   [XFRM]: Always reroute in tunnel mode
#   
#   Tunnel mode packets are rerouted if the tunnel destination
#   address is different from the original destination address,
#   otherwise the old route is used. This is inconsistent, the
#   old route might have been selected for a given output device
#   or using routing by tos/fwmark. Always choose a new route
#   in tunnel mode.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/xfrm4_policy.c
#   2005/03/05 01:58:41+01:00 kaber@coreworks.de +3 -1
#   [XFRM]: Always reroute in tunnel mode
#   
#   Tunnel mode packets are rerouted if the tunnel destination
#   address is different from the original destination address,
#   otherwise the old route is used. This is inconsistent, the
#   old route might have been selected for a given output device
#   or using routing by tos/fwmark. Always choose a new route
#   in tunnel mode.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	2005-03-05 13:03:32 +01:00
+++ b/net/ipv4/xfrm4_policy.c	2005-03-05 13:03:32 +01:00
@@ -59,6 +59,7 @@
 	int err;
 	int header_len = 0;
 	int trailer_len = 0;
+	int tunnel = 0;
 
 	dst = dst_prev = NULL;
 
@@ -81,12 +82,13 @@
 		if (xfrm[i]->props.mode) {
 			remote = xfrm[i]->id.daddr.a4;
 			local  = xfrm[i]->props.saddr.a4;
+			tunnel = 1;
 		}
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 	}
 
-	if (remote != fl->fl4_dst) {
+	if (tunnel) {
 		struct flowi fl_tunnel = { .nl_u = { .ip4_u =
 						     { .daddr = remote,
 						       .saddr = local }
diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c	2005-03-05 13:03:32 +01:00
+++ b/net/ipv6/xfrm6_policy.c	2005-03-05 13:03:32 +01:00
@@ -76,6 +76,7 @@
 	int err = 0;
 	int header_len = 0;
 	int trailer_len = 0;
+	int tunnel = 0;
 
 	dst = dst_prev = NULL;
 
@@ -98,12 +99,13 @@
 		if (xfrm[i]->props.mode) {
 			remote = (struct in6_addr*)&xfrm[i]->id.daddr;
 			local  = (struct in6_addr*)&xfrm[i]->props.saddr;
+			tunnel = 1;
 		}
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 	}
 
-	if (!ipv6_addr_equal(remote, &fl->fl6_dst)) {
+	if (tunnel) {
 		struct flowi fl_tunnel;
 
 		memset(&fl_tunnel, 0, sizeof(fl_tunnel));

--------------080900080003050705020402--
