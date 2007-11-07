From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/2] qla3xxx: bugfix: Fix bad logical operation in link state machine.
Date: Wed,  7 Nov 2007 13:59:07 -0800
Message-ID: <11944727472117-git-send-email-ron.mercer@qlogic.com>
References: <20071107215608.GB7090@linux-7mw0.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:29948 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757477AbXKGV7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 16:59:10 -0500
In-Reply-To: <20071107215608.GB7090@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luckily, this wasn't reported or reproduced. The logical operation for
setting duplex had wrong grouping.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 4f0fd41..a579111 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1456,16 +1456,11 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 			   PHYAddr[qdev->mac_index]);
 	reg &= ~PHY_GIG_ALL_PARAMS;
 
-	if(portConfiguration &
-	   PORT_CONFIG_FULL_DUPLEX_ENABLED &
-	   PORT_CONFIG_1000MB_SPEED) {
-		reg |= PHY_GIG_ADV_1000F;
-	}
-
-	if(portConfiguration &
-	   PORT_CONFIG_HALF_DUPLEX_ENABLED &
-	   PORT_CONFIG_1000MB_SPEED) {
-		reg |= PHY_GIG_ADV_1000H;
+	if(portConfiguration & PORT_CONFIG_1000MB_SPEED) {
+		if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED) 
+			reg |= PHY_GIG_ADV_1000F;
+		else 
+			reg |= PHY_GIG_ADV_1000H;
 	}
 
 	ql_mii_write_reg_ex(qdev, PHY_GIG_CONTROL, reg,
-- 
1.5.0.rc4.16.g9e258

