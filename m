From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 12/12] be2net: fix alignment on line wrap
Date: Fri, 19 Sep 2014 15:47:02 +0530
Message-ID: <1411121822-25842-13-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52817 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624AbaISKOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:32 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch fixes alignment whereever it doesn't match the open parenthesis
alignment.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    9 +++++----
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    6 +++---
 drivers/net/ethernet/emulex/benet/be_main.c    |    6 +++---
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 58e7eff..fead5c6 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1034,7 +1034,8 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, int pmac_id, u32 dom)
 	req = embedded_payload(wrb);
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_PMAC_DEL, sizeof(*req), wrb, NULL);
+			       OPCODE_COMMON_NTWK_PMAC_DEL, sizeof(*req),
+			       wrb, NULL);
 
 	req->hdr.domain = dom;
 	req->if_id = cpu_to_le32(if_id);
@@ -1709,7 +1710,7 @@ int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 					      &get_fat_cmd.dma);
 	if (!get_fat_cmd.va) {
 		dev_err(&adapter->pdev->dev,
-		"Memory allocation failure while retrieving FAT data\n");
+			"Memory allocation failure while reading FAT data\n");
 		return -ENOMEM;
 	}
 
@@ -2471,7 +2472,7 @@ err_unlock:
 }
 
 int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
-			  u16 optype, int offset)
+			 u16 optype, int offset)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_read_flash_crc *req;
@@ -2645,7 +2646,7 @@ int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 
 		resp = cmd->va;
 		if ((memcmp(resp->rcv_buff, req->snd_buff, byte_cnt) != 0) ||
-				resp->snd_err) {
+		    resp->snd_err) {
 			status = -1;
 		}
 	}
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 240fb46..e42a791 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -277,7 +277,7 @@ static int lancer_cmd_read_file(struct be_adapter *adapter, u8 *file_name,
 
 	while ((total_read_len < buf_len) && !eof) {
 		chunk_size = min_t(u32, (buf_len - total_read_len),
-				LANCER_READ_FILE_CHUNK);
+				   LANCER_READ_FILE_CHUNK);
 		chunk_size = ALIGN(chunk_size, 4);
 		status = lancer_cmd_read_object(adapter, &read_cmd, chunk_size,
 						total_read_len, file_name,
@@ -1213,8 +1213,8 @@ static int be_set_rxfh(struct net_device *netdev, const u32 *indir,
 		hkey =  adapter->rss_info.rss_hkey;
 
 	rc = be_cmd_rss_config(adapter, rsstable,
-			adapter->rss_info.rss_flags,
-			RSS_INDIR_TABLE_LEN, hkey);
+			       adapter->rss_info.rss_flags,
+			       RSS_INDIR_TABLE_LEN, hkey);
 	if (rc) {
 		adapter->rss_info.rss_flags = RSS_ENABLE_NONE;
 		return -EIO;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 78f1de6..9a18e79 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -982,8 +982,8 @@ static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
 	 * skip HW tagging is not enabled by FW.
 	 */
 	if (unlikely(be_ipv6_tx_stall_chk(adapter, skb) &&
-	    (adapter->pvid || adapter->qnq_vid) &&
-	    !qnq_async_evt_rcvd(adapter)))
+		     (adapter->pvid || adapter->qnq_vid) &&
+		     !qnq_async_evt_rcvd(adapter)))
 		goto tx_drop;
 
 	/* Manual VLAN tag insertion to prevent:
@@ -4777,7 +4777,7 @@ static void be_worker(struct work_struct *work)
 	if (!adapter->stats_cmd_sent) {
 		if (lancer_chip(adapter))
 			lancer_cmd_get_pport_stats(adapter,
-						&adapter->stats_cmd);
+						   &adapter->stats_cmd);
 		else
 			be_cmd_get_stats(adapter, &adapter->stats_cmd);
 	}
-- 
1.7.1
