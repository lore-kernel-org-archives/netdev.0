From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/5] bnx2x: Add support for single-port DCBx
Date: Tue, 16 Feb 2016 18:07:59 +0200
Message-ID: <1455638881-2527-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:52382 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932261AbcBPQIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:08:49 -0500
In-Reply-To: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver is currently looking at shared information for determining whether
DCBx can be supported for a given port.
On 4-port devices, up-to-date management firmware can support DCBx on
each port of a given engine independently - but that would cause bnx2x to
misinterpert the support and assume DCBx is supported on both.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5d6b2d9..c584525 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12429,8 +12429,10 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 
 	if (SHMEM2_HAS(bp, dcbx_lldp_params_offset) &&
 	    SHMEM2_HAS(bp, dcbx_lldp_dcbx_stat_offset) &&
+	    SHMEM2_HAS(bp, dcbx_en) &&
 	    SHMEM2_RD(bp, dcbx_lldp_params_offset) &&
-	    SHMEM2_RD(bp, dcbx_lldp_dcbx_stat_offset)) {
+	    SHMEM2_RD(bp, dcbx_lldp_dcbx_stat_offset) &&
+	    SHMEM2_RD(bp, dcbx_en[BP_PORT(bp)])) {
 		bnx2x_dcbx_set_state(bp, true, BNX2X_DCBX_ENABLED_ON_NEG_ON);
 		bnx2x_dcbx_init_params(bp);
 	} else {
-- 
1.9.3
