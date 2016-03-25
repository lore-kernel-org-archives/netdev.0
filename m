From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net-next v3.16]r8169:  Correct value from speed 10 on MII_BMCR
Date: Fri, 25 Mar 2016 15:01:06 +0200
Message-ID: <1458910866-21784-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-53-82.residential.rdsnet.ro ([5.14.53.82]:58578 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbcCYNBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 09:01:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch correct value on MII_BMCR register ald value 0
 have target on reserved register first 2 bytes from MII_BMCR
 speed 10 is flipped value on BMCR_SPEED100

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index a450656..77c5efb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1707,7 +1707,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		giga_ctrl = 0;
 
 		if (speed == SPEED_10)
-			bmcr = 0;
+			bmcr = ~BMCR_SPEED100;
 		else if (speed == SPEED_100)
 			bmcr = BMCR_SPEED100;
 		else
-- 
2.1.4
