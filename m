From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: can: dev: remove unused code in can_restart
Date: Fri, 20 Oct 2017 22:36:52 -0500
Message-ID: <20171021033652.GA28755@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Value assigned to variable err is overwritten at line
562: err = priv->do_set_mode(dev, CAN_MODE_START); before
it can be used.

Also, notice that this code has been there since 2014.

Addresses-Coverity-ID: 1227031
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only.

 drivers/net/can/dev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 365a8cc..064d0f6 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -543,10 +543,9 @@ static void can_restart(struct net_device *dev)
 
 	/* send restart message upstream */
 	skb = alloc_can_err_skb(dev, &cf);
-	if (skb == NULL) {
-		err = -ENOMEM;
+	if (!skb)
 		goto restart;
-	}
+
 	cf->can_id |= CAN_ERR_RESTARTED;
 
 	netif_rx(skb);
-- 
2.7.4
