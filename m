From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] SAA9730: Handle multicast frames.
Date: Tue, 17 Jul 2007 13:46:00 +0900 (JST)
Message-ID: <20070717.134600.41689222.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48118 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbXGQEpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 00:45:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--
diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index 451486b..7dae4d4 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -940,15 +940,14 @@ static void lan_saa9730_set_multicast(struct net_device *dev)
 		       CAM_CONTROL_GROUP_ACC | CAM_CONTROL_BROAD_ACC,
 		       &lp->lan_saa9730_regs->CamCtl);
 	} else {
-		if (dev->flags & IFF_ALLMULTI) {
+		if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
 			/* accept all multicast packets */
-			writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
-			       CAM_CONTROL_BROAD_ACC,
-			       &lp->lan_saa9730_regs->CamCtl);
-		} else {
 			/*
 			 * Will handle the multicast stuff later. -carstenl
 			 */
+			writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
+			       CAM_CONTROL_BROAD_ACC,
+			       &lp->lan_saa9730_regs->CamCtl);
 		}
 	}
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
