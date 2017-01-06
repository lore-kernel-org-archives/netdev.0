From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 8/8] crypto:chcr- Fix wrong typecasting
Date: Fri,  6 Jan 2017 14:01:39 +0530
Message-ID: <cbbe6ac7440e36e42d2464c66cc8c14aa079e9f6.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>, Atul Gupta <atul.gupta@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:27114 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939666AbdAFIc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:32:27 -0500
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Typecast the pointer with correct structure.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
---
 drivers/crypto/chelsio/chcr_core.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
index 1c65f07..aec3562 100644
--- a/drivers/crypto/chelsio/chcr_core.c
+++ b/drivers/crypto/chelsio/chcr_core.c
@@ -151,18 +151,17 @@ int chcr_uld_rx_handler(void *handle, const __be64 *rsp,
 {
 	struct uld_ctx *u_ctx = (struct uld_ctx *)handle;
 	struct chcr_dev *dev = u_ctx->dev;
-	const struct cpl_act_establish *rpl = (struct cpl_act_establish
-					       *)rsp;
+	const struct cpl_fw6_pld *rpl = (struct cpl_fw6_pld *)rsp;
 
-	if (rpl->ot.opcode != CPL_FW6_PLD) {
+	if (rpl->opcode != CPL_FW6_PLD) {
 		pr_err("Unsupported opcode\n");
 		return 0;
 	}
 
 	if (!pgl)
-		work_handlers[rpl->ot.opcode](dev, (unsigned char *)&rsp[1]);
+		work_handlers[rpl->opcode](dev, (unsigned char *)&rsp[1]);
 	else
-		work_handlers[rpl->ot.opcode](dev, pgl->va);
+		work_handlers[rpl->opcode](dev, pgl->va);
 	return 0;
 }
 
-- 
1.8.2.3
