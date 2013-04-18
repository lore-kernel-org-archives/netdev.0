From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/2] bnx2x: Fix status blocks configuration
Date: Thu, 18 Apr 2013 11:49:06 +0300
Message-ID: <1366274946-11625-3-git-send-email-yuvalmin@broadcom.com>
References: <1366274946-11625-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4274 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966746Ab3DRJwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 05:52:14 -0400
In-Reply-To: <1366274946-11625-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

This fixes 2 issues regarding bnx2x's status blocks:

   1. ethtool -c caused corruption of status blocks in FW RAM.

   2. when using multi-CoS, the configuration of the timeout values of
      status blocks is incorrect, harming the coalescing of interrupts
      for such CoSs.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9e99d38..0cd508a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2624,6 +2624,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			}
 		}
 
+		/* initialize FW coalescing state machines in RAM */
+		bnx2x_update_coalesce(bp);
+
 		/* setup the leading queue */
 		rc = bnx2x_setup_leading(bp);
 		if (rc) {
@@ -4746,11 +4749,11 @@ static void storm_memset_hc_disable(struct bnx2x *bp, u8 port,
 	u32 enable_flag = disable ? 0 : (1 << HC_INDEX_DATA_HC_ENABLED_SHIFT);
 	u32 addr = BAR_CSTRORM_INTMEM +
 		   CSTORM_STATUS_BLOCK_DATA_FLAGS_OFFSET(fw_sb_id, sb_index);
-	u16 flags = REG_RD16(bp, addr);
+	u8 flags = REG_RD8(bp, addr);
 	/* clear and set */
 	flags &= ~HC_INDEX_DATA_HC_ENABLED;
 	flags |= enable_flag;
-	REG_WR16(bp, addr, flags);
+	REG_WR8(bp, addr, flags);
 	DP(NETIF_MSG_IFUP,
 	   "port %x fw_sb_id %d sb_index %d disable %d\n",
 	   port, fw_sb_id, sb_index, disable);
-- 
1.8.1.227.g44fe835
