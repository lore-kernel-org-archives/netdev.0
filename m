From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Avoid copying writable clones in tunnel drivers
Date: Fri, 06 Jul 2007 14:27:47 +0200
Message-ID: <468E3543.1060106@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040009080609060901090500"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56669 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759809AbXGFM2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 08:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040009080609060901090500
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------040009080609060901090500
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Avoid copying writable clones in tunnel drivers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f9dcf4c066b67c80d81ed2de40f62169f3bb5cf0
tree c7cf908b9b97a9d9476fa7a96372305ec1478078
parent 720d6ee708b60d1f1f61484af02c900134de0651
author Patrick McHardy <kaber@trash.net> Fri, 06 Jul 2007 14:25:50 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 06 Jul 2007 14:26:34 +0200

 net/ipv4/ip_gre.c     |    3 ++-
 net/ipv4/ipip.c       |    3 ++-
 net/ipv6/ip6_tunnel.c |    4 ++--
 net/ipv6/sit.c        |    3 ++-
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6328293..5c14ed6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -809,7 +809,8 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen;
 
-	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shared(skb)) {
+	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
+	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index ebd2f2d..3964372 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -595,7 +595,8 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	max_headroom = (LL_RESERVED_SPACE(tdev)+sizeof(struct iphdr));
 
-	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shared(skb)) {
+	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
+	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a0902fb..281aee4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -883,8 +883,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	 */
 	max_headroom += LL_RESERVED_SPACE(tdev);
 
-	if (skb_headroom(skb) < max_headroom ||
-	    skb_cloned(skb) || skb_shared(skb)) {
+	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
+	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb;
 
 		if (!(new_skb = skb_realloc_headroom(skb, max_headroom)))
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 1efa95a..eb20bb6 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -532,7 +532,8 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev)+sizeof(struct iphdr);
 
-	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shared(skb)) {
+	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
+	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);

--------------040009080609060901090500--
