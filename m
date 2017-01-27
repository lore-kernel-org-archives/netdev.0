From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 7/8] crypto:chcr- Fix wrong typecasting
Date: Fri, 27 Jan 2017 16:09:11 +0530
Message-ID: <7600b6af17ac5aed704ff8425245107419fc6312.1485501429.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hariprasad@chelsio.com, netdev@vger.kernel.org, arjun@chelsio.com,
        atul.gupta@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Typecast the pointer with correct structure.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
---
 drivers/crypto/chelsio/chcr_core.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
index 2bfd61a..c28e018 100644
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
