From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 2/7] be2net: Fix FW download in Lancer
Date: Wed, 25 Apr 2012 17:16:18 +0530
Message-ID: <972efcec-b429-477b-a865-3218ce365eaa@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:29215 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758114Ab2DYLrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 07:47:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase time given by driver to adapter for completing FW download
to 30 seconds. Also return correct status when FW download times out.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 22be08c..3ba4aed 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1824,18 +1824,16 @@ int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	spin_unlock_bh(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->flash_compl,
-			msecs_to_jiffies(12000)))
+					 msecs_to_jiffies(30000)))
 		status = -1;
 	else
 		status = adapter->flash_status;
 
 	resp = embedded_payload(wrb);
-	if (!status) {
+	if (!status)
 		*data_written = le32_to_cpu(resp->actual_write_len);
-	} else {
+	else
 		*addn_status = resp->additional_status;
-		status = resp->status;
-	}
 
 	return status;
 
-- 
1.6.0.2
