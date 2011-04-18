From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 3/5] be2net: fix be_mcc_compl_process to identify
 eth_get_stat command
Date: Mon, 18 Apr 2011 17:30:21 -0500
Message-ID: <20110418223021.GA9499@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:45953 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753161Ab1DRWan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 18:30:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eth_get_statistics and vlan_config command have same opcode.
Use opcode subsystem id to differentiate one from other.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 11b774a..a94e980 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -78,7 +78,8 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 	}
 
 	if (compl_status == MCC_STATUS_SUCCESS) {
-		if (compl->tag0 == OPCODE_ETH_GET_STATISTICS) {
+		if ((compl->tag0 == OPCODE_ETH_GET_STATISTICS) &&
+			(compl->tag1 == CMD_SUBSYSTEM_ETH)) {
 			struct be_cmd_resp_get_stats *resp =
 						adapter->stats_cmd.va;
 			be_dws_le_to_cpu(&resp->hw_stats,
@@ -1096,6 +1097,7 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
 		OPCODE_ETH_GET_STATISTICS, sizeof(*req));
+	wrb->tag1 = CMD_SUBSYSTEM_ETH;
 	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
 	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
 	sge->len = cpu_to_le32(nonemb_cmd->size);
-- 
1.7.1

