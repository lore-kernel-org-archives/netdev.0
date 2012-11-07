From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net] cxgb4: Fix initialization of SGE_CONTROL register
Date: Wed,  7 Nov 2012 19:15:46 +0530
Message-ID: <1352295946-32146-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31313 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab2KGNt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 08:49:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

INGPADBOUNDARY_MASK is already shifted. No need to shift it again. On reloading
a driver it was resulting in a bad SGE FL MTU sizes [1536, 9088] error. This
only causes an issue on systems that have L1 cache size of 32B, 128B, 512B,
2048B or 4096B.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 01fa5b7..730ae2c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2831,7 +2831,7 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 		     HOSTPAGESIZEPF7(sge_hps));
 
 	t4_set_reg_field(adap, SGE_CONTROL,
-			 INGPADBOUNDARY(INGPADBOUNDARY_MASK) |
+			 INGPADBOUNDARY_MASK |
 			 EGRSTATUSPAGESIZE_MASK,
 			 INGPADBOUNDARY(fl_align_log - 5) |
 			 EGRSTATUSPAGESIZE(stat_len != 64));
-- 
1.7.1
