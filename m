From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net] bnx2x: Fix configuration of doorbell block
Date: Mon, 9 Sep 2013 14:51:27 +0300
Message-ID: <1378727487-6921-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2210 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397Ab3IILua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 07:50:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of VF RSS feature doorbell block was configured not to use dpm, but
a small part of configuration was left out, preventing the driver from sending
tx messages to the device. This patch adds the missing configuration.

Reported-by: Eric Dumazet <eric.dumazet@gmil.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    3 ---
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 634a793..2f8dbbb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7645,6 +7645,7 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, BLOCK_TM, init_phase);
 	bnx2x_init_block(bp, BLOCK_DORQ, init_phase);
+	REG_WR(bp, DORQ_REG_MODE_ACT, 1); /* no dpm */
 
 	bnx2x_iov_init_dq(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index b26eb83..2604b62 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1756,9 +1756,6 @@ void bnx2x_iov_init_dq(struct bnx2x *bp)
 	REG_WR(bp, DORQ_REG_VF_TYPE_MIN_MCID_0, 0);
 	REG_WR(bp, DORQ_REG_VF_TYPE_MAX_MCID_0, 0x1ffff);
 
-	/* set the number of VF allowed doorbells to the full DQ range */
-	REG_WR(bp, DORQ_REG_VF_NORM_MAX_CID_COUNT, 0x20000);
-
 	/* set the VF doorbell threshold */
 	REG_WR(bp, DORQ_REG_VF_USAGE_CT_LIMIT, 4);
 }
-- 
1.7.1
