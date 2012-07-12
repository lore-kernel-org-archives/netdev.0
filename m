From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 5/7] be2net: Fix cleanup path when EQ creation fails
Date: Thu, 12 Jul 2012 19:27:21 +0530
Message-ID: <8ba16330-f4cc-4bcf-9f7b-3771872b0d8d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49169 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933878Ab2GLOB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:01:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9e7dbd5..cf6ad1f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1734,9 +1734,10 @@ static void be_evt_queues_destroy(struct be_adapter *adapter)
 	int i;
 
 	for_all_evt_queues(adapter, eqo, i) {
-		be_eq_clean(eqo);
-		if (eqo->q.created)
+		if (eqo->q.created) {
+			be_eq_clean(eqo);
 			be_cmd_q_destroy(adapter, &eqo->q, QTYPE_EQ);
+		}
 		be_queue_free(adapter, &eqo->q);
 	}
 }
-- 
1.6.0.2
