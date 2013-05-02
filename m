From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 1/3] be2net: Fix firmware download for Lancer
Date: Thu, 2 May 2013 19:06:34 +0530
Message-ID: <18c7d598-93d2-4770-b314-586dec18b9be@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:18888 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757877Ab3EBNhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 09:37:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increasing the timeout value of write_object command to 60 seconds as
30 second timeout was found to be not enough for the command to complete.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ce5af9b..488ee6e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2086,7 +2086,7 @@ int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	spin_unlock_bh(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->flash_compl,
-					 msecs_to_jiffies(30000)))
+					 msecs_to_jiffies(60000)))
 		status = -1;
 	else
 		status = adapter->flash_status;
-- 
1.6.0.2
