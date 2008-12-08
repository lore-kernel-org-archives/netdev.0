From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] net: Kill directly reference of netdev->priv
Date: Mon, 8 Dec 2008 22:53:33 +0800
Message-ID: <20081208145333.GB6830@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:54240 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbYLHOxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 09:53:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace netdev->priv with netdev_priv() like
4bcd42679643dd3dfd6aaad9fcbcc74ac5c7e2e9

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 drivers/net/igb/igb_ethtool.c     |    4 ++--
 drivers/net/ixgbe/ixgbe_ethtool.c |    4 ++--
 net/atm/mpc.c                     |   10 +++++-----
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 89964fa..34382cf 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -101,8 +101,8 @@ static const struct igb_stats igb_gstrings_stats[] = {
 };
 
 #define IGB_QUEUE_STATS_LEN \
-	((((struct igb_adapter *)netdev->priv)->num_rx_queues + \
-	 ((struct igb_adapter *)netdev->priv)->num_tx_queues) * \
+	(((netdev_priv(netdev))->num_rx_queues + \
+	 (netdev_priv(netdev))->num_tx_queues) * \
 	(sizeof(struct igb_queue_stats) / sizeof(u64)))
 #define IGB_GLOBAL_STATS_LEN	\
 	sizeof(igb_gstrings_stats) / sizeof(struct igb_stats)
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 81a9c4b..74d4aeb 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -94,8 +94,8 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
-                ((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
-                 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
+                (((netdev_priv(netdev))->num_tx_queues + \
+                 (netdev_priv(netdev))->num_rx_queues) * \
                  (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
 #define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 11b16d1..236f416 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -785,7 +785,7 @@ static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 	}
 
 	if (mpc->dev) { /* check if the lec is LANE2 capable */
-		priv = (struct lec_priv *)mpc->dev->priv;
+		priv = netdev_priv(mpc->dev);
 		if (priv->lane_version < 2) {
 			dev_put(mpc->dev);
 			mpc->dev = NULL;
@@ -845,7 +845,7 @@ static void mpoad_close(struct atm_vcc *vcc)
 
 	mpc->mpoad_vcc = NULL;
 	if (mpc->dev) {
-		struct lec_priv *priv = (struct lec_priv *)mpc->dev->priv;
+		struct lec_priv *priv = netdev_priv(mpc->dev);
 		priv->lane2_ops->associate_indicator = NULL;
 		stop_mpc(mpc);
 		dev_put(mpc->dev);
@@ -976,7 +976,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 
 	switch (event) {
 	case NETDEV_REGISTER:       /* a new lec device was allocated */
-		priv = (struct lec_priv *)dev->priv;
+		priv = netdev_priv(dev);
 		if (priv->lane_version < 2)
 			break;
 		priv->lane2_ops->associate_indicator = lane2_assoc_ind;
@@ -1322,7 +1322,7 @@ static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg, struct mpoa_client *m
 	dprintk("\n");
 
 	if (mpc->dev) {
-		priv = (struct lec_priv *)mpc->dev->priv;
+		priv = netdev_priv(mpc->dev);
 		retval = priv->lane2_ops->associate_req(mpc->dev, mpc->dev->dev_addr, tlv, sizeof(tlv));
 		if (retval == 0)
 			printk("mpoa: (%s) MPOA device type TLV association failed\n", mpc->dev->name);
@@ -1472,7 +1472,7 @@ static void __exit atm_mpoa_cleanup(void)
 		tmp = mpc->next;
 		if (mpc->dev != NULL) {
 			stop_mpc(mpc);
-			priv = (struct lec_priv *)mpc->dev->priv;
+			priv = netdev_priv(mpc->dev);
 			if (priv->lane2_ops != NULL)
 				priv->lane2_ops->associate_indicator = NULL;
 		}
-- 
1.5.6.3

-- 
Jianjun Kong |Happy Hacking
Homepage: http://kongove.cn
Gtalk:kongjianjun@gmail.com
