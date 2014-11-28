From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH] cxgb4: Fill in supported link mode for SFP modules
Date: Fri, 28 Nov 2014 18:35:14 +0530
Message-ID: <1417179914-5806-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:44503
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750901AbaK1M7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 07:59:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 605eaab..279275d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2362,9 +2362,13 @@ static unsigned int from_fw_linkcaps(unsigned int type, unsigned int caps)
 		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full |
 		     SUPPORTED_10000baseKX4_Full;
 	else if (type == FW_PORT_TYPE_FIBER_XFI ||
-		 type == FW_PORT_TYPE_FIBER_XAUI || type == FW_PORT_TYPE_SFP)
+		 type == FW_PORT_TYPE_FIBER_XAUI || type == FW_PORT_TYPE_SFP) {
 		v |= SUPPORTED_FIBRE;
-	else if (type == FW_PORT_TYPE_BP40_BA)
+		if (caps & FW_PORT_CAP_SPEED_1G)
+			v |= SUPPORTED_1000baseT_Full;
+		if (caps & FW_PORT_CAP_SPEED_10G)
+			v |= SUPPORTED_10000baseT_Full;
+	} else if (type == FW_PORT_TYPE_BP40_BA)
 		v |= SUPPORTED_40000baseSR4_Full;
 
 	if (caps & FW_PORT_CAP_ANEG)
-- 
1.7.1
