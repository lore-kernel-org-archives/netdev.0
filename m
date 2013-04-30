From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 1/4] be2net: Fix firmware download for Lancer
Date: Tue, 30 Apr 2013 17:06:37 +0530
Message-ID: <4a2c36c4-7538-4b4b-936d-c013009cc7cc@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Kalesh AP <kalesh.purayil@emulex.com>,
	"Somnath Kotur" <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:44801 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760370Ab3D3Lhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 07:37:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

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
