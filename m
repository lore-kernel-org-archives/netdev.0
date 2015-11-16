From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipvlan: fix use after free of skb
Date: Mon, 16 Nov 2015 22:44:53 +0100
Message-ID: <fc05eb243454762cf3c2d1ebf2266215d61b23e2.1447704740.git.sd@queasysnail.net>
Cc: maheshb@google.com, Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465AbbKPVpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 16:45:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipvlan_handle_frame is a rx_handler, and when it returns a value other
than RX_HANDLER_CONSUMED (here, NET_RX_DROP aka RX_HANDLER_ANOTHER),
__netif_receive_skb_core expects that the skb still exists and will
process it further, but we just freed it.

Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ipvlan/ipvlan_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8edd6f2a4da6..db9fa220ddae 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -676,5 +676,5 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
 	WARN_ONCE(true, "ipvlan_handle_frame() called for mode = [%hx]\n",
 			  port->mode);
 	kfree_skb(skb);
-	return NET_RX_DROP;
+	return RX_HANDLER_CONSUMED;
 }
-- 
2.6.2
