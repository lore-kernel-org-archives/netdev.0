From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: struct xfrm_tunnel in read_mostly section
Date: Mon, 30 Aug 2010 19:04:14 +0200
Message-ID: <1283187854.2723.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60295 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398Ab0H3RET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 13:04:19 -0400
Received: by wwb28 with SMTP id 28so7564573wwb.1
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 10:04:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tunnel4_handlers chain being scanned for each incoming packet,
make sure it doesnt share an often dirtied cache line.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipip.c         |    2 +-
 net/ipv4/tunnel4.c      |    4 ++--
 net/ipv4/xfrm4_tunnel.c |    4 ++--
 net/ipv6/sit.c          |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index ec03673..3c6f8f3 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -744,7 +744,7 @@ static void __net_init ipip_fb_tunnel_init(struct net_device *dev)
 	ipn->tunnels_wc[0]	= tunnel;
 }
 
-static struct xfrm_tunnel ipip_handler = {
+static struct xfrm_tunnel ipip_handler __read_mostly = {
 	.handler	=	ipip_rcv,
 	.err_handler	=	ipip_err,
 	.priority	=	1,
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 59186ca..942f02d 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -14,8 +14,8 @@
 #include <net/protocol.h>
 #include <net/xfrm.h>
 
-static struct xfrm_tunnel *tunnel4_handlers;
-static struct xfrm_tunnel *tunnel64_handlers;
+static struct xfrm_tunnel *tunnel4_handlers __read_mostly;
+static struct xfrm_tunnel *tunnel64_handlers __read_mostly;
 static DEFINE_MUTEX(tunnel4_mutex);
 
 static inline struct xfrm_tunnel **fam_handlers(unsigned short family)
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 41f5982..8280645 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -58,14 +58,14 @@ static int xfrm_tunnel_err(struct sk_buff *skb, u32 info)
 	return -ENOENT;
 }
 
-static struct xfrm_tunnel xfrm_tunnel_handler = {
+static struct xfrm_tunnel xfrm_tunnel_handler __read_mostly = {
 	.handler	=	xfrm_tunnel_rcv,
 	.err_handler	=	xfrm_tunnel_err,
 	.priority	=	2,
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static struct xfrm_tunnel xfrm64_tunnel_handler = {
+static struct xfrm_tunnel xfrm64_tunnel_handler __read_mostly = {
 	.handler	=	xfrm_tunnel_rcv,
 	.err_handler	=	xfrm_tunnel_err,
 	.priority	=	2,
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 4699cd3..86618eb 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1132,7 +1132,7 @@ static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	sitn->tunnels_wc[0]	= tunnel;
 }
 
-static struct xfrm_tunnel sit_handler = {
+static struct xfrm_tunnel sit_handler __read_mostly = {
 	.handler	=	ipip6_rcv,
 	.err_handler	=	ipip6_err,
 	.priority	=	1,


