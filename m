From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 3/6] be2net: variable name change
Date: Sun, 20 Feb 2011 15:41:39 -0600
Message-ID: <20110220214139.GA13659@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11624 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755152Ab1BTVmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:42:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change occurances of stats_ioctl_sent to stats_cmd_sent

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h      |    2 +-
 drivers/net/benet/be_cmds.c |    4 ++--
 drivers/net/benet/be_main.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 3a800e2..fb605e8 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -298,7 +298,7 @@ struct be_adapter {
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
 	bool ue_detected;
-	bool stats_ioctl_sent;
+	bool stats_cmd_sent;
 	int link_speed;
 	u8 port_type;
 	u8 transceiver;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 619ebc2..7120106 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -81,7 +81,7 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 			be_dws_le_to_cpu(&resp->hw_stats,
 						sizeof(resp->hw_stats));
 			netdev_stats_update(adapter);
-			adapter->stats_ioctl_sent = false;
+			adapter->stats_cmd_sent = false;
 		}
 	} else if ((compl_status != MCC_STATUS_NOT_SUPPORTED) &&
 		   (compl->tag0 != OPCODE_COMMON_NTWK_MAC_QUERY)) {
@@ -1075,7 +1075,7 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	sge->len = cpu_to_le32(nonemb_cmd->size);
 
 	be_mcc_notify(adapter);
-	adapter->stats_ioctl_sent = true;
+	adapter->stats_cmd_sent = true;
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index aad7ea3..b9e170d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1873,7 +1873,7 @@ static void be_worker(struct work_struct *work)
 		goto reschedule;
 	}
 
-	if (!adapter->stats_ioctl_sent)
+	if (!adapter->stats_cmd_sent)
 		be_cmd_get_stats(adapter, &adapter->stats_cmd);
 
 	be_tx_rate_update(adapter);
-- 
1.7.1

