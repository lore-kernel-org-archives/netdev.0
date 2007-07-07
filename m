From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 5/9][BNX2]: Modify link up message.
Date: Fri, 06 Jul 2007 20:29:48 -0700
Message-ID: <1183778988.5182.22.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3919 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753871AbXGGCha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:37:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Modify link up message.

Modify the link up dmesg to report remote copper or Serdes link.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 514ad32..dc6dcf5 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -604,12 +604,21 @@ bnx2_report_fw_link(struct bnx2 *bp)
 	REG_WR_IND(bp, bp->shmem_base + BNX2_LINK_STATUS, fw_link_status);
 }
 
+static char *
+bnx2_xceiver_str(struct bnx2 *bp)
+{
+	return ((bp->phy_port == PORT_FIBRE) ? "SerDes" :
+		((bp->phy_flags & PHY_SERDES_FLAG) ? "Remote Copper" :
+		 "Copper"));
+}
+
 static void
 bnx2_report_link(struct bnx2 *bp)
 {
 	if (bp->link_up) {
 		netif_carrier_on(bp->dev);
-		printk(KERN_INFO PFX "%s NIC Link is Up, ", bp->dev->name);
+		printk(KERN_INFO PFX "%s NIC %s Link is Up, ", bp->dev->name,
+		       bnx2_xceiver_str(bp));
 
 		printk("%d Mbps ", bp->line_speed);
 
@@ -633,7 +642,8 @@ bnx2_report_link(struct bnx2 *bp)
 	}
 	else {
 		netif_carrier_off(bp->dev);
-		printk(KERN_ERR PFX "%s NIC Link is Down\n", bp->dev->name);
+		printk(KERN_ERR PFX "%s NIC %s Link is Down\n", bp->dev->name,
+		       bnx2_xceiver_str(bp));
 	}
 
 	bnx2_report_fw_link(bp);


