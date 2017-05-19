From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix incorrect cim_la output for T6
Date: Fri, 19 May 2017 15:42:18 +0530
Message-ID: <1495188738-20546-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:6728 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751329AbdESKMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 06:12:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

take care of UpDbgLaRdPtr[0-3] restriction for T6

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index aded42b96..917b46b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -8268,6 +8268,13 @@ int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr)
 		if (ret)
 			break;
 		idx = (idx + 1) & UPDBGLARDPTR_M;
+
+		/* Bits 0-3 of UpDbgLaRdPtr can be between 0000 to 1001 to
+		 * identify the 32-bit portion of the full 312-bit data
+		 */
+		if (is_t6(adap->params.chip))
+			while ((idx & 0xf) > 9)
+				idx = (idx + 1) % UPDBGLARDPTR_M;
 	}
 restart:
 	if (cfg & UPDBGLAEN_F) {
-- 
2.1.0
