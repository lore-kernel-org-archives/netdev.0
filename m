From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Always reroute in tunnel mode
Date: Thu, 17 Feb 2005 07:22:23 +0100
Message-ID: <4214381F.5020507@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010806070907080302070104"
Cc: Maillist netdev <netdev@oss.sgi.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010806070907080302070104
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Please see Changeset comment for a description, patch is based on
your 2.6.12 tree.

Regards
Patrick


--------------010806070907080302070104
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/17 07:10:03+01:00 kaber@coreworks.de 
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
#   2005/02/17 07:09:55+01:00 kaber@coreworks.de +3 -1
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
#   2005/02/17 07:09:55+01:00 kaber@coreworks.de +3 -1
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
--- a/net/ipv4/xfrm4_policy.c	2005-02-17 07:16:40 +01:00
+++ b/net/ipv4/xfrm4_policy.c	2005-02-17 07:16:40 +01:00
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
--- a/net/ipv6/xfrm6_policy.c	2005-02-17 07:16:40 +01:00
+++ b/net/ipv6/xfrm6_policy.c	2005-02-17 07:16:40 +01:00
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

--------------010806070907080302070104--
