From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] ipv6: xfrm6_mode_tunnel: Fix warning
Date: Mon, 18 Feb 2013 11:15:30 -0300
Message-ID: <1361196930-25531-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pshelar@nicira.com>, <edumazet@google.com>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe006.messaging.microsoft.com ([216.32.180.189]:16251
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753042Ab3BRO7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 09:59:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following warning:

net/ipv6/xfrm6_mode_tunnel.c:72:2: warning: suggest parentheses around assignment used as truth value [-Wparentheses]

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 net/ipv6/xfrm6_mode_tunnel.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 93c41a8..9bf6a74 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -69,7 +69,8 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
 
-	if (err = skb_unclone(skb, GFP_ATOMIC))
+	err = skb_unclone(skb, GFP_ATOMIC);
+	if (err)
 		goto out;
 
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-- 
1.7.9.5
