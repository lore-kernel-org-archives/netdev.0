From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] cxgb4 : Fix bug in DCB app deletion
Date: Fri,  7 Nov 2014 15:41:21 -0800
Message-ID: <1415403681-4120-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:35611
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752279AbaKGXla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 18:41:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike CEE, IEEE has a bespoke app delete call and does not rely on priority
for app deletion

Fixes : 2376c879b80c ('cxgb4 : Improve handling of DCB negotiation or loss
 thereof')

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 6fe300e..b6fdb14 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -79,8 +79,9 @@ static void cxgb4_dcb_cleanup_apps(struct net_device *dev)
 		app.protocol = dcb->app_priority[i].protocolid;
 
 		if (dcb->dcb_version == FW_PORT_DCB_VER_IEEE) {
+			app.priority = dcb->app_priority[i].user_prio_map;
 			app.selector = dcb->app_priority[i].sel_field + 1;
-			err = dcb_ieee_setapp(dev, &app);
+			err = dcb_ieee_delapp(dev, &app);
 		} else {
 			app.selector = !!(dcb->app_priority[i].sel_field);
 			err = dcb_setapp(dev, &app);
-- 
2.1.3
