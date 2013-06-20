From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/4] bnx2x: VF ndo sanity
Date: Thu, 20 Jun 2013 17:39:09 +0300
Message-ID: <1371739151-15744-3-git-send-email-yuvalmin@broadcom.com>
References: <1371739151-15744-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4974 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757713Ab3FTOjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 10:39:25 -0400
In-Reply-To: <1371739151-15744-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

If iproute2 VF callbacks are invoked before PF is loaded,
abort gracefully.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2a8ad6d..f6177ba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3083,6 +3083,11 @@ void bnx2x_disable_sriov(struct bnx2x *bp)
 static int bnx2x_vf_ndo_sanity(struct bnx2x *bp, int vfidx,
 			       struct bnx2x_virtf *vf)
 {
+	if (bp->state != BNX2X_STATE_OPEN) {
+		BNX2X_ERR("vf ndo called though PF is down\n");
+		return -EINVAL;
+	}
+
 	if (!IS_SRIOV(bp)) {
 		BNX2X_ERR("vf ndo called though sriov is disabled\n");
 		return -EINVAL;
-- 
1.8.1.227.g44fe835
