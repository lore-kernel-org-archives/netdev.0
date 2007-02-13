From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 7/8]: Add some tx timeout debug messages.
Date: Tue, 13 Feb 2007 12:14:50 -0800
Message-ID: <1171397690.18944.31.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1823 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbXBMTbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:31:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add some tx timeout debug messages.

Print the most useful information during tx timeout to help debug.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a1aeba2..159570b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3735,13 +3735,23 @@ out:
 	tg3_full_unlock(tp);
 }
 
+static void tg3_dump_short_state(struct tg3 *tp)
+{
+	printk(KERN_ERR PFX "DEBUG: MAC_TX_STATUS[%08x] MAC_RX_STATUS[%08x]\n",
+	       tr32(MAC_TX_STATUS), tr32(MAC_RX_STATUS));
+	printk(KERN_ERR PFX "DEBUG: RDMAC_STATUS[%08x] WDMAC_STATUS[%08x]\n",
+	       tr32(RDMAC_STATUS), tr32(WDMAC_STATUS));
+}
+
 static void tg3_tx_timeout(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (netif_msg_tx_err(tp))
+	if (netif_msg_tx_err(tp)) {
 		printk(KERN_ERR PFX "%s: transmit timed out, resetting\n",
 		       dev->name);
+		tg3_dump_short_state(tp);
+	}
 
 	schedule_work(&tp->reset_task);
 }


