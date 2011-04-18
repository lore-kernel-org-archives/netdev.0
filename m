From: David Miller <davem@davemloft.net>
Subject: [PATCH 31/42] bnx2x: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:04 -0700 (PDT)
Message-ID: <20110417.173404.191406362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51078
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754081Ab1DRAei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3B77D24C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'rc' is set but unused in bnx2x_timer().

Similarly for 'hc_index_p' in bnx2x_init_sb(), and 'port' in
bnx2x_get_hwinfo().

Just kill them off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bnx2x/bnx2x_main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 696e84a..bfd7ac9 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -3904,10 +3904,9 @@ static void bnx2x_timer(unsigned long data)
 
 	if (poll) {
 		struct bnx2x_fastpath *fp = &bp->fp[0];
-		int rc;
 
 		bnx2x_tx_int(fp);
-		rc = bnx2x_rx_int(fp, 1000);
+		bnx2x_rx_int(fp, 1000);
 	}
 
 	if (!BP_NOMCP(bp)) {
@@ -4062,7 +4061,6 @@ static void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
 	struct hc_status_block_data_e2 sb_data_e2;
 	struct hc_status_block_data_e1x sb_data_e1x;
 	struct hc_status_block_sm  *hc_sm_p;
-	struct hc_index_data *hc_index_p;
 	int data_size;
 	u32 *sb_data_p;
 
@@ -4083,7 +4081,6 @@ static void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
 		sb_data_e2.common.host_sb_addr.hi = U64_HI(mapping);
 		sb_data_e2.common.host_sb_addr.lo = U64_LO(mapping);
 		hc_sm_p = sb_data_e2.common.state_machine;
-		hc_index_p = sb_data_e2.index_data;
 		sb_data_p = (u32 *)&sb_data_e2;
 		data_size = sizeof(struct hc_status_block_data_e2)/sizeof(u32);
 	} else {
@@ -4097,7 +4094,6 @@ static void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
 		sb_data_e1x.common.host_sb_addr.hi = U64_HI(mapping);
 		sb_data_e1x.common.host_sb_addr.lo = U64_LO(mapping);
 		hc_sm_p = sb_data_e1x.common.state_machine;
-		hc_index_p = sb_data_e1x.index_data;
 		sb_data_p = (u32 *)&sb_data_e1x;
 		data_size = sizeof(struct hc_status_block_data_e1x)/sizeof(u32);
 	}
@@ -8635,7 +8631,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 {
 	int /*abs*/func = BP_ABS_FUNC(bp);
-	int vn, port;
+	int vn;
 	u32 val = 0;
 	int rc = 0;
 
@@ -8670,7 +8666,6 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->mf_ov = 0;
 	bp->mf_mode = 0;
 	vn = BP_E1HVN(bp);
-	port = BP_PORT(bp);
 
 	if (!CHIP_IS_E1(bp) && !BP_NOMCP(bp)) {
 		DP(NETIF_MSG_PROBE,
-- 
1.7.4.3

