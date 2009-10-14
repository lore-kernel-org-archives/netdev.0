From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 7/8] bnx2x: Report the maximal available BW as link
 speed
Date: Wed, 14 Oct 2009 17:10:08 +0200
Message-ID: <1255533009.25030.42.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3086 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761884AbZJNPLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 11:11:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device is limited to the maximal BW allocation, so it should be displayed as
the link speed to notify the user.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 42cd957..ba131f4 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2163,11 +2163,23 @@ static void bnx2x_link_report(struct bnx2x *bp)
 	}
 
 	if (bp->link_vars.link_up) {
+		u16 line_speed;
+
 		if (bp->state == BNX2X_STATE_OPEN)
 			netif_carrier_on(bp->dev);
 		printk(KERN_INFO PFX "%s NIC Link is Up, ", bp->dev->name);
 
-		printk("%d Mbps ", bp->link_vars.line_speed);
+		line_speed = bp->link_vars.line_speed;
+		if (IS_E1HMF(bp)) {
+			u16 vn_max_rate;
+
+			vn_max_rate =
+				((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
+				 FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
+			if (vn_max_rate < line_speed)
+				line_speed = vn_max_rate;
+		}
+		printk("%d Mbps ", line_speed);
 
 		if (bp->link_vars.duplex == DUPLEX_FULL)
 			printk("full duplex");
-- 
1.5.4.3




