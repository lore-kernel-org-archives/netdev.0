From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] ipv4: xfrm4_mode_tunnel: Fix warning
Date: Mon, 18 Feb 2013 10:45:27 -0300
Message-ID: <1361195127-17889-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pshelar@nicira.com>, <edumazet@google.com>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:20744
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754774Ab3BRNpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 08:45:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following warning:

net/ipv4/xfrm4_mode_tunnel.c:145:2: warning: suggest parentheses around assignment used as truth value [-Wparentheses]

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 net/ipv4/xfrm4_mode_tunnel.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 1162ace..fe5189e 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -142,7 +142,8 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	for_each_input_rcu(rcv_notify_handlers, handler)
 		handler->handler(skb);
 
-	if (err = skb_unclone(skb, GFP_ATOMIC))
+	err = skb_unclone(skb, GFP_ATOMIC);
+	if (err)
 		goto out;
 
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-- 
1.7.9.5
