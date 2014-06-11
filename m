From: Yuval Mintz <yuval.mintz@qlogic.com>
Subject: [PATCH net 4/4] bnx2x: Enlarge the dorq threshold for VFs
Date: Wed, 11 Jun 2014 16:27:28 +0300
Message-ID: <1402493248-5427-5-git-send-email-yuval.mintz@qlogic.com>
References: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, Yuval Mintz <yuval.mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53330 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753168AbaFKN1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 09:27:51 -0400
In-Reply-To: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariel.elior@qlogic.com>

A malicious VF might try to starve the other VFs & PF by creating
contineous doorbell floods. In order to negate this, HW has a threshold of
doorbells per client, which will stop the client doorbells from arriving
if crossed.

The threshold currently configured for VFs is too low - under extreme traffic
scenarios, it's possible for a VF to reach the threshold and thus for its
fastpath to stop working.

Signed-off-by: Ariel Elior <ariel.elior@qlogic.com>
Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index a93c7af..f7edb42 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1071,8 +1071,10 @@ void bnx2x_iov_init_dq(struct bnx2x *bp)
 	REG_WR(bp, DORQ_REG_VF_TYPE_MIN_MCID_0, 0);
 	REG_WR(bp, DORQ_REG_VF_TYPE_MAX_MCID_0, 0x1ffff);
 
-	/* set the VF doorbell threshold */
-	REG_WR(bp, DORQ_REG_VF_USAGE_CT_LIMIT, 4);
+	/* set the VF doorbell threshold. This threshold represents the amount
+	 * of doorbells allowed in the main DORQ fifo for a specific VF.
+	 */
+	REG_WR(bp, DORQ_REG_VF_USAGE_CT_LIMIT, 64);
 }
 
 void bnx2x_iov_init_dmae(struct bnx2x *bp)
-- 
1.8.1.4
