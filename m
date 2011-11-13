From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 02/12] bnx2x: use rx_queue index for
 skb_record_rx_queue()
Date: Sun, 13 Nov 2011 16:34:22 +0200
Message-ID: <1321194872-8276-3-git-send-email-dmitry@broadcom.com>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1435 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035Ab1KMOem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 09:34:42 -0500
In-Reply-To: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 4 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index aec7212..e17a739 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -507,6 +507,7 @@ struct bnx2x_fastpath {
 	__le16			fp_hc_idx;
 
 	u8			index;		/* number in fp array */
+	u8			rx_queue;	/* index for skb_record */
 	u8			cl_id;		/* eth client id */
 	u8			cl_qzone_id;
 	u8			fw_sb_id;	/* status block number in FW */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 580b44e..1ace946 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -755,7 +755,7 @@ reuse_rx:
 			}
 		}
 
-		skb_record_rx_queue(skb, fp->index);
+		skb_record_rx_queue(skb, fp->rx_queue);
 
 		if (le16_to_cpu(cqe_fp->pars_flags.flags) &
 		    PARSING_FLAGS_VLAN)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 283d663..4a16757 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1318,6 +1318,7 @@ static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
 	struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);
 	unsigned long q_type = 0;
 
+	bnx2x_fcoe(bp, rx_queue) = BNX2X_NUM_ETH_QUEUES(bp);
 	bnx2x_fcoe(bp, cl_id) = bnx2x_cnic_eth_cl_id(bp,
 						     BNX2X_FCOE_ETH_CL_ID_IDX);
 	/** Current BNX2X_FCOE_ETH_CID deffinition implies not more than
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6f3a784..1d185f2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5247,7 +5247,7 @@ static void bnx2x_init_eth_fp(struct bnx2x *bp, int fp_idx)
 	u8 cos;
 	unsigned long q_type = 0;
 	u32 cids[BNX2X_MULTI_TX_COS] = { 0 };
-
+	fp->rx_queue = fp_idx;
 	fp->cid = fp_idx;
 	fp->cl_id = bnx2x_fp_cl_id(fp);
 	fp->fw_sb_id = bnx2x_fp_fw_sb_id(fp);
-- 
1.7.7.2
