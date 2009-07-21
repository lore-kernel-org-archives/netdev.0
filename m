From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 3/10] bnx2x: Fan failure early detection
Date: Tue, 21 Jul 2009 18:47:30 +0300
Message-ID: <1248191251.18195.46.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2313 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbZGUPrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:47:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if fan failure happened before the driver was loaded and notify the user

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ae8b7b5..d946c9e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -5185,6 +5185,11 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	mmiowb();
 
 	bnx2x_int_enable(bp);
+
+	/* Check for SPIO5 */
+	bnx2x_attn_int_deasserted0(bp,
+		REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_1_FUNC_0 + BP_PORT(bp)*4) &
+				   AEU_INPUTS_ATTN_BITS_SPIO5);
 }
 
 /* end of nic init */
-- 
1.5.4.3




