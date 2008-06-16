From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6 7/7] atm: [he] send idle cells instead of unassigned when in SDH mode
Date: Mon, 16 Jun 2008 13:28:00 -0400
Message-ID: <200806161728.m5GHS0G8003402@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45525 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513AbYFPR2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:28:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ecb4818bb519d7b428a74f1c4d6ef7f0f8086f52
Author: Chas Williams <chas@relax.cmf.nrl.navy.mil>
Date:   Sat Jun 14 17:41:32 2008 -0400

    atm: [he] send idle cells instead of unassigned when in SDH mode
    
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index cd58cd3..8cd71b0 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1496,6 +1496,7 @@ he_start(struct atm_dev *dev)
 		val = he_phy_get(he_dev->atm_dev, SUNI_TPOP_APM);
 		val = (val & ~SUNI_TPOP_APM_S) | (SUNI_TPOP_S_SDH << SUNI_TPOP_APM_S_SHIFT);
 		he_phy_put(he_dev->atm_dev, val, SUNI_TPOP_APM);
+		he_phy_put(he_dev->atm_dev, SUNI_TACP_IUCHP_CLP, SUNI_TACP_IUCHP);
 	}
 
 	/* 5.1.12 enable transmit and receive */
