From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix HW initialization using fw 7.8.x
Date: Mon, 29 Oct 2012 09:59:04 +0200
Message-ID: <1351497544-13272-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3572 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690Ab2J2H7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 03:59:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 96bed4b9 (use FW 7.8.2) BRB HW block needs to be
initialized using fw values for all devices.
Otherwise ETS on 57712/578xx will not work.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d5648fc..baa9a36 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6794,8 +6794,9 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, BLOCK_DORQ, init_phase);
 
+	bnx2x_init_block(bp, BLOCK_BRB1, init_phase);
+
 	if (CHIP_IS_E1(bp) || CHIP_IS_E1H(bp)) {
-		bnx2x_init_block(bp, BLOCK_BRB1, init_phase);
 
 		if (IS_MF(bp))
 			low = ((bp->flags & ONE_PORT_FLAG) ? 160 : 246);
-- 
1.7.7.2
