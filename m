From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/5] be2net: increase FW update completion timeout
Date: Mon, 22 Aug 2011 16:43:32 +0530
Message-ID: <1314011613-4519-5-git-send-email-sathya.perla@emulex.com>
References: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:12581 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756841Ab1HVLOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 07:14:21 -0400
In-Reply-To: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flashing some of the PHYs can take longer thus increasing the total flash
update time to a max of 40s.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index bec039d..bebeee6 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1939,7 +1939,7 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	spin_unlock_bh(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->flash_compl,
-			msecs_to_jiffies(12000)))
+			msecs_to_jiffies(40000)))
 		status = -1;
 	else
 		status = adapter->flash_status;
-- 
1.7.4

