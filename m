From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net-next v3.16]r8169:  Add support for half duplex on MDI
Date: Fri, 25 Mar 2016 16:29:52 +0200
Message-ID: <1458916193-32521-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-53-82.residential.rdsnet.ro ([5.14.53.82]:58588 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbcCYOaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 10:30:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch add support for half duplex on MDI chips.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 77c5efb..7f6fb1f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1713,8 +1713,13 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		else
 			goto out;
 
-		if (duplex == DUPLEX_FULL)
+		if (duplex == DUPLEX_FULL) {
 			bmcr |= BMCR_FULLDPLX;
+		} else if (duplex == DUPLEX_HALF) {
+				bmcr |= ~BMCR_FULLDPLX;
+		} else {
+			goto out;
+		 }
 	}
 
 	rtl_writephy(tp, MII_BMCR, bmcr);
-- 
2.1.4
