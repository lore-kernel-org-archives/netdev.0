From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 1/2] ftgmac100: Increase reset timeout
Date: Mon, 24 Jul 2017 16:59:01 +1000
Message-ID: <1500879541.10674.62.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joel Stanley <joel.stanley@au1.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39715 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751389AbdGXG7K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 02:59:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had reports of 50us not being sufficient to reset the MAC,
thus hitting the "Hardware reset failed" error bringing the
interface up on some AST2400 based machines.

This bumps the timeout to 200us.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index b166666128d3..2b17f7023d91 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -125,7 +125,7 @@ static int ftgmac100_reset_mac(struct ftgmac100 *priv, u32 maccr)
 	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
 	iowrite32(maccr | FTGMAC100_MACCR_SW_RST,
 		  priv->base + FTGMAC100_OFFSET_MACCR);
-	for (i = 0; i < 50; i++) {
+	for (i = 0; i < 200; i++) {
 		unsigned int maccr;
 
 		maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
