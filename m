From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Fix MC1 memory offset calculation
Date: Wed, 29 Apr 2015 17:19:05 +0530
Message-ID: <1430308145-15225-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21659 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751126AbbD2GhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 02:37:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6559a7e8296002b4 ("cxgb4: Cleanup macros so they follow the same
style and look consistent") introduced a regression where reading MC1
memory in adapters where MC0 isn't present or MC0 size is not equal to MC1
size caused the adapter to crash due to incorrect computation of memoffset.
Fix is to read the size of MC0 instead of MC1 for offset calculation

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 5959e3a..e8578a7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -492,7 +492,7 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 		memoffset = (mtype * (edc_size * 1024 * 1024));
 	else {
 		mc_size = EXT_MEM0_SIZE_G(t4_read_reg(adap,
-						      MA_EXT_MEMORY1_BAR_A));
+						      MA_EXT_MEMORY0_BAR_A));
 		memoffset = (MEM_MC0 * edc_size + mc_size) * 1024 * 1024;
 	}
 
-- 
2.3.4
