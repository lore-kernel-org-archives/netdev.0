From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4 : Only pass app selector of 0 or 3 to firmware
Date: Fri, 17 Jul 2015 13:12:30 -0700
Message-ID: <1437163953-15447-2-git-send-email-anish@chelsio.com>
References: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26603 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753537AbbGQUMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:12:41 -0400
In-Reply-To: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This keeps app format passed to firmware the same irrespective
of DCBx version in use.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 6074680bc985..7f7c4ba0d4f4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -794,7 +794,9 @@ static int __cxgb4_getapp(struct net_device *dev, u8 app_idtype, u16 app_id,
  */
 static int cxgb4_getapp(struct net_device *dev, u8 app_idtype, u16 app_id)
 {
-	return __cxgb4_getapp(dev, app_idtype, app_id, 0);
+	/* Convert app_idtype to firmware format before querying */
+	return __cxgb4_getapp(dev, app_idtype == DCB_APP_IDTYPE_ETHTYPE ?
+			      app_idtype : 3, app_id, 0);
 }
 
 /* Write a new Application User Priority Map for the specified Application ID
@@ -1133,7 +1135,7 @@ static int cxgb4_getpeerapp_tbl(struct net_device *dev, struct dcb_app *table)
 		if (!pcmd.u.dcb.app_priority.protocolid)
 			break;
 
-		table[i].selector = pcmd.u.dcb.app_priority.sel_field;
+		table[i].selector = (pcmd.u.dcb.app_priority.sel_field + 1);
 		table[i].protocol =
 			be16_to_cpu(pcmd.u.dcb.app_priority.protocolid);
 		table[i].priority =
-- 
2.4.6
