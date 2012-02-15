From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 07/11] bnx2x: allocate smaller Rx rings for 1G
 functions
Date: Wed, 15 Feb 2012 07:10:28 -0500
Message-ID: <1329307832-32454-8-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3823 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951Ab2BOFQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:26 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 7f6a1b1..5d15efc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3122,9 +3122,16 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	} else
 #endif
 	if (!bp->rx_ring_size) {
+		u32 cfg = SHMEM_RD(bp,
+			     dev_info.port_hw_config[BP_PORT(bp)].default_cfg);
 
 		rx_ring_size = MAX_RX_AVAIL/BNX2X_NUM_RX_QUEUES(bp);
 
+		/* Dercease ring size for 1G functions */
+		if ((cfg & PORT_HW_CFG_NET_SERDES_IF_MASK) ==
+		    PORT_HW_CFG_NET_SERDES_IF_SGMII)
+			rx_ring_size /= 10;
+
 		/* allocate at least number of buffers required by FW */
 		rx_ring_size = max_t(int, bp->disable_tpa ? MIN_RX_SIZE_NONTPA :
 				     MIN_RX_SIZE_TPA, rx_ring_size);
-- 
1.7.9.rc2
