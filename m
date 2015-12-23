From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/9] cxgb4: Update correct encoding of SGE Ingress DMA States for T6 adapter
Date: Wed, 23 Dec 2015 22:47:16 +0530
Message-ID: <1450891039-17196-7-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:2260 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933166AbbLWRQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:09 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 59 ++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 2f8c736..0132b64 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5702,6 +5702,39 @@ void t4_sge_decode_idma_state(struct adapter *adapter, int state)
 		"IDMA_FL_SEND_PADDING",
 		"IDMA_FL_SEND_COMPLETION_TO_IMSG",
 	};
+	static const char * const t6_decode[] = {
+		"IDMA_IDLE",
+		"IDMA_PUSH_MORE_CPL_FIFO",
+		"IDMA_PUSH_CPL_MSG_HEADER_TO_FIFO",
+		"IDMA_SGEFLRFLUSH_SEND_PCIEHDR",
+		"IDMA_PHYSADDR_SEND_PCIEHDR",
+		"IDMA_PHYSADDR_SEND_PAYLOAD_FIRST",
+		"IDMA_PHYSADDR_SEND_PAYLOAD",
+		"IDMA_FL_REQ_DATA_FL",
+		"IDMA_FL_DROP",
+		"IDMA_FL_DROP_SEND_INC",
+		"IDMA_FL_H_REQ_HEADER_FL",
+		"IDMA_FL_H_SEND_PCIEHDR",
+		"IDMA_FL_H_PUSH_CPL_FIFO",
+		"IDMA_FL_H_SEND_CPL",
+		"IDMA_FL_H_SEND_IP_HDR_FIRST",
+		"IDMA_FL_H_SEND_IP_HDR",
+		"IDMA_FL_H_REQ_NEXT_HEADER_FL",
+		"IDMA_FL_H_SEND_NEXT_PCIEHDR",
+		"IDMA_FL_H_SEND_IP_HDR_PADDING",
+		"IDMA_FL_D_SEND_PCIEHDR",
+		"IDMA_FL_D_SEND_CPL_AND_IP_HDR",
+		"IDMA_FL_D_REQ_NEXT_DATA_FL",
+		"IDMA_FL_SEND_PCIEHDR",
+		"IDMA_FL_PUSH_CPL_FIFO",
+		"IDMA_FL_SEND_CPL",
+		"IDMA_FL_SEND_PAYLOAD_FIRST",
+		"IDMA_FL_SEND_PAYLOAD",
+		"IDMA_FL_REQ_NEXT_DATA_FL",
+		"IDMA_FL_SEND_NEXT_PCIEHDR",
+		"IDMA_FL_SEND_PADDING",
+		"IDMA_FL_SEND_COMPLETION_TO_IMSG",
+	};
 	static const u32 sge_regs[] = {
 		SGE_DEBUG_DATA_LOW_INDEX_2_A,
 		SGE_DEBUG_DATA_LOW_INDEX_3_A,
@@ -5710,6 +5743,32 @@ void t4_sge_decode_idma_state(struct adapter *adapter, int state)
 	const char **sge_idma_decode;
 	int sge_idma_decode_nstates;
 	int i;
+	unsigned int chip_version = CHELSIO_CHIP_VERSION(adapter->params.chip);
+
+	/* Select the right set of decode strings to dump depending on the
+	 * adapter chip type.
+	 */
+	switch (chip_version) {
+	case CHELSIO_T4:
+		sge_idma_decode = (const char **)t4_decode;
+		sge_idma_decode_nstates = ARRAY_SIZE(t4_decode);
+		break;
+
+	case CHELSIO_T5:
+		sge_idma_decode = (const char **)t5_decode;
+		sge_idma_decode_nstates = ARRAY_SIZE(t5_decode);
+		break;
+
+	case CHELSIO_T6:
+		sge_idma_decode = (const char **)t6_decode;
+		sge_idma_decode_nstates = ARRAY_SIZE(t6_decode);
+		break;
+
+	default:
+		dev_err(adapter->pdev_dev,
+			"Unsupported chip version %d\n", chip_version);
+		return;
+	}
 
 	if (is_t4(adapter->params.chip)) {
 		sge_idma_decode = (const char **)t4_decode;
-- 
2.3.4
