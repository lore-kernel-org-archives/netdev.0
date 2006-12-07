From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/7][TG3]: Use netif_msg_*.
Date: Wed, 06 Dec 2006 23:47:11 -0800
Message-ID: <1165477631.8488.31.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2198 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031754AbWLGG5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:57:12 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Use netif_msg_*.

Use netif_msg_* to turn on or off some messages.

Based on Stephen Hemminger's initial patch.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5dfeb64..99fb4e4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1402,8 +1402,10 @@ static int tg3_set_power_state(struct tg
 static void tg3_link_report(struct tg3 *tp)
 {
 	if (!netif_carrier_ok(tp->dev)) {
-		printk(KERN_INFO PFX "%s: Link is down.\n", tp->dev->name);
-	} else {
+		if (netif_msg_link(tp))
+			printk(KERN_INFO PFX "%s: Link is down.\n",
+			       tp->dev->name);
+	} else if (netif_msg_link(tp)) {
 		printk(KERN_INFO PFX "%s: Link is up at %d Mbps, %s duplex.\n",
 		       tp->dev->name,
 		       (tp->link_config.active_speed == SPEED_1000 ?
@@ -3710,8 +3712,9 @@ static void tg3_tx_timeout(struct net_de
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	printk(KERN_ERR PFX "%s: transmit timed out, resetting\n",
-	       dev->name);
+	if (netif_msg_tx_err(tp))
+		printk(KERN_ERR PFX "%s: transmit timed out, resetting\n",
+		       dev->name);
 
 	schedule_work(&tp->reset_task);
 }
@@ -8665,7 +8668,9 @@ static int tg3_test_registers(struct tg3
 	return 0;
 
 out:
-	printk(KERN_ERR PFX "Register test failed at offset %x\n", offset);
+	if (netif_msg_hw(tp))
+		printk(KERN_ERR PFX "Register test failed at offset %x\n",
+		       offset);
 	tw32(offset, save_val);
 	return -EIO;
 }


