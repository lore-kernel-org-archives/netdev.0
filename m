From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: struct xfrm6_tunnel in read_mostly
 section
Date: Mon, 30 Aug 2010 22:27:10 +0200
Message-ID: <1283200030.2405.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44601 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846Ab0H3U1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:27:15 -0400
Received: by wyb35 with SMTP id 35so7020205wyb.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 13:27:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tunnel6_handlers chain being scanned for each incoming packet,
make sure it doesnt share an often dirtied cache line.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ip6_tunnel.c   |    4 ++--
 net/ipv6/tunnel6.c      |    4 ++--
 net/ipv6/xfrm6_tunnel.c |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 0fd027f..29f99dd 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1372,13 +1372,13 @@ static void __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	ip6n->tnls_wc[0] = t;
 }
 
-static struct xfrm6_tunnel ip4ip6_handler = {
+static struct xfrm6_tunnel ip4ip6_handler __read_mostly = {
 	.handler	= ip4ip6_rcv,
 	.err_handler	= ip4ip6_err,
 	.priority	=	1,
 };
 
-static struct xfrm6_tunnel ip6ip6_handler = {
+static struct xfrm6_tunnel ip6ip6_handler __read_mostly = {
 	.handler	= ip6ip6_rcv,
 	.err_handler	= ip6ip6_err,
 	.priority	=	1,
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index fc3c86a..d203e6d 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -30,8 +30,8 @@
 #include <net/protocol.h>
 #include <net/xfrm.h>
 
-static struct xfrm6_tunnel *tunnel6_handlers;
-static struct xfrm6_tunnel *tunnel46_handlers;
+static struct xfrm6_tunnel *tunnel6_handlers __read_mostly;
+static struct xfrm6_tunnel *tunnel46_handlers __read_mostly;
 static DEFINE_MUTEX(tunnel6_mutex);
 
 int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family)
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 2ce3a82..ac7584b 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -317,13 +317,13 @@ static const struct xfrm_type xfrm6_tunnel_type = {
 	.output		= xfrm6_tunnel_output,
 };
 
-static struct xfrm6_tunnel xfrm6_tunnel_handler = {
+static struct xfrm6_tunnel xfrm6_tunnel_handler __read_mostly = {
 	.handler	= xfrm6_tunnel_rcv,
 	.err_handler	= xfrm6_tunnel_err,
 	.priority	= 2,
 };
 
-static struct xfrm6_tunnel xfrm46_tunnel_handler = {
+static struct xfrm6_tunnel xfrm46_tunnel_handler __read_mostly = {
 	.handler	= xfrm6_tunnel_rcv,
 	.err_handler	= xfrm6_tunnel_err,
 	.priority	= 2,


