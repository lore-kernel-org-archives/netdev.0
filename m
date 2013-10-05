From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: dev: fix nlmsg size calculation in can_get_size()
Date: Sat,  5 Oct 2013 21:25:17 +0200
Message-ID: <1381001117-19624-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, kernel@pengutronix.de,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the calculation of the nlmsg size, by adding the missing
nla_total_size().

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
Hello,

this patch touches the rtnl_link_ops get_size() callback:

    static struct rtnl_link_ops can_link_ops __read_mostly = {
    ...
    	.get_size	= can_get_size,
    ...
    };

By looking at other nlmsg size calculation I think a nla_total_size() for all
contributers is needed. Am I correct?

regards,
Marc

 drivers/net/can/dev.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index f9cba41..1870c47 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -705,14 +705,14 @@ static size_t can_get_size(const struct net_device *dev)
 	size_t size;
 
 	size = nla_total_size(sizeof(u32));   /* IFLA_CAN_STATE */
-	size += sizeof(struct can_ctrlmode);  /* IFLA_CAN_CTRLMODE */
+	size += nla_total_size(sizeof(struct can_ctrlmode));  /* IFLA_CAN_CTRLMODE */
 	size += nla_total_size(sizeof(u32));  /* IFLA_CAN_RESTART_MS */
-	size += sizeof(struct can_bittiming); /* IFLA_CAN_BITTIMING */
-	size += sizeof(struct can_clock);     /* IFLA_CAN_CLOCK */
+	size += nla_total_size(sizeof(struct can_bittiming)); /* IFLA_CAN_BITTIMING */
+	size += nla_total_size(sizeof(struct can_clock));     /* IFLA_CAN_CLOCK */
 	if (priv->do_get_berr_counter)        /* IFLA_CAN_BERR_COUNTER */
-		size += sizeof(struct can_berr_counter);
+		size += nla_total_size(sizeof(struct can_berr_counter));
 	if (priv->bittiming_const)	      /* IFLA_CAN_BITTIMING_CONST */
-		size += sizeof(struct can_bittiming_const);
+		size += nla_total_size(sizeof(struct can_bittiming_const));
 
 	return size;
 }
-- 
1.8.4.rc3

