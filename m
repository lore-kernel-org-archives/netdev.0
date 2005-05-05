From: Patrick McHardy <kaber@trash.net>
Subject: [IPV4]: multipath_wrandom.c GPF fixes
Date: Thu, 05 May 2005 22:31:06 +0200
Message-ID: <427A828A.3080309@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000100020409060809050509"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000100020409060809050509
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

multipath_wrandom needs to use GFP_ATOMIC.


--------------000100020409060809050509
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV4]: multipath_wrandom.c GPF fixes

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cdb5c875d48676b20ecd95fef080891a68c32e9c
tree 46b576def0e0b0e4600193306cb830e66b5a57da
parent 3a614a8969f79ac4116f496beff879736dca83e2
author Patrick McHardy <kaber@trash.net> 1115277458 +0200
committer Patrick McHardy <kaber@trash.net> 1115277458 +0200

Index: net/ipv4/multipath_wrandom.c
===================================================================
--- a744d6c4cd2587f82796c0f6cb4d7f94744ef9f2/net/ipv4/multipath_wrandom.c  (mode:100644 sha1:10b23e1bece663bd8a9317f980b30ec0df7f0a11)
+++ 46b576def0e0b0e4600193306cb830e66b5a57da/net/ipv4/multipath_wrandom.c  (mode:100644 sha1:c3d2ca1a6781513bc7b2524aad96f61e7a4053a6)
@@ -172,7 +172,7 @@
 		    multipath_comparekeys(&rt->fl, flp)) {
 			struct multipath_candidate* mpc =
 				(struct multipath_candidate*)
-				kmalloc(size_mpc, GFP_KERNEL);
+				kmalloc(size_mpc, GFP_ATOMIC);
 
 			if (!mpc)
 				return;
@@ -244,7 +244,7 @@
 	if (!target_route) {
 		const size_t size_rt = sizeof(struct multipath_route);
 		target_route = (struct multipath_route *)
-			kmalloc(size_rt, GFP_KERNEL);
+			kmalloc(size_rt, GFP_ATOMIC);
 
 		target_route->gw = nh->nh_gw;
 		target_route->oif = nh->nh_oif;
@@ -265,7 +265,7 @@
 	if (!target_dest) {
 		const size_t size_dst = sizeof(struct multipath_dest);
 		target_dest = (struct multipath_dest*)
-			kmalloc(size_dst, GFP_KERNEL);
+			kmalloc(size_dst, GFP_ATOMIC);
 
 		target_dest->nh_info = nh;
 		target_dest->network = network;

--------------000100020409060809050509--
