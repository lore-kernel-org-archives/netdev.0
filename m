From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/4] bnx2x: Clean the sp rtnl task upon unload
Date: Sun, 17 Nov 2013 08:59:26 +0200
Message-ID: <1384671569-30105-2-git-send-email-yuvalmin@broadcom.com>
References: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, dmitry@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4178 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab3KQG7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 01:59:44 -0500
In-Reply-To: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

While unloading, bnx2x needs to clean the sp_rtnl_state to prevent
configuration made before the unload to be applied afterwards with
stale values.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 74d6486..f8cc9c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2959,6 +2959,10 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 
 	bp->port.pmf = 0;
 
+	/* clear pending work in rtnl task */
+	bp->sp_rtnl_state = 0;
+	smp_mb();
+
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 	if (CNIC_LOADED(bp))
-- 
1.8.1.227.g44fe835
