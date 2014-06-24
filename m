From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH] cxgb4: Fix endian bug introduced in 76bcb31efc0685574fb123f7aaa92f8a50c14fd9
Date: Mon, 23 Jun 2014 17:27:29 -0700
Message-ID: <1403569649-22649-2-git-send-email-anish@chelsio.com>
References: <1403569649-22649-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:41609
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752597AbaFXA1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 20:27:38 -0400
In-Reply-To: <1403569649-22649-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 39b4a85..a8b1073 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -488,12 +488,12 @@ static void cxgb4_setpfccfg(struct net_device *dev, int priority, u8 pfccfg)
 		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY);
 
 	pcmd.u.dcb.pfc.type = FW_PORT_DCB_TYPE_PFC;
-	pcmd.u.dcb.pfc.pfcen = cpu_to_be16(pi->dcb.pfcen);
+	pcmd.u.dcb.pfc.pfcen = pi->dcb.pfcen;
 
 	if (pfccfg)
-		pcmd.u.dcb.pfc.pfcen |= cpu_to_be16(1 << priority);
+		pcmd.u.dcb.pfc.pfcen |= (1 << priority);
 	else
-		pcmd.u.dcb.pfc.pfcen &= cpu_to_be16(~(1 << priority));
+		pcmd.u.dcb.pfc.pfcen &= (~(1 << priority));
 
 	err = t4_wr_mbox(adap, adap->mbox, &pcmd, sizeof(pcmd), &pcmd);
 	if (err != FW_PORT_DCB_CFG_SUCCESS) {
@@ -501,7 +501,7 @@ static void cxgb4_setpfccfg(struct net_device *dev, int priority, u8 pfccfg)
 		return;
 	}
 
-	pi->dcb.pfcen = be16_to_cpu(pcmd.u.dcb.pfc.pfcen);
+	pi->dcb.pfcen = pcmd.u.dcb.pfc.pfcen;
 }
 
 static u8 cxgb4_setall(struct net_device *dev)
-- 
2.0.0
