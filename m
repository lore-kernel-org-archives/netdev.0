From: Marek Vasut <marex@denx.de>
Subject: [PATCH] can: Use correct type in sizeof() in nla_put()
Date: Fri, 30 Oct 2015 13:48:19 +0100
Message-ID: <1446209299-6250-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sizeof() is invoked on an incorrect variable, likely due to some
copy-paste error, and this might result in memory corruption. Fix this.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: netdev@vger.kernel.org
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

NOTE: I only compile-tested this.

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index aede704..141c2a4 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -915,7 +915,7 @@ static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	     nla_put(skb, IFLA_CAN_BITTIMING_CONST,
 		     sizeof(*priv->bittiming_const), priv->bittiming_const)) ||
 
-	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock) ||
+	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(priv->clock), &priv->clock) ||
 	    nla_put_u32(skb, IFLA_CAN_STATE, state) ||
 	    nla_put(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm) ||
 	    nla_put_u32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms) ||
-- 
2.1.4

