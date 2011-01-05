From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v3 01/10] net/fec: fix MMFR_OP type in fec_enet_mdio_write
Date: Wed, 5 Jan 2011 22:07:28 +0800
Message-ID: <1294236457-17476-2-git-send-email-shawn.guo@freescale.com>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:35981 "EHLO
	TX2EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab1AEOGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 09:06:06 -0500
In-Reply-To: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC_MMFR_OP_WRITE should be used than FEC_MMFR_OP_READ in
a mdio write operation.

It's probably a typo introduced by commit:

e6b043d512fa8d9a3801bf5d72bfa3b8fc3b3cc8
netdev/fec.c: add phylib supporting to enable carrier detection (v2)

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
 drivers/net/fec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index cce32d4..52e9ca8 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -651,8 +651,8 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	fep->mii_timeout = 0;
 	init_completion(&fep->mdio_done);
 
-	/* start a read op */
-	writel(FEC_MMFR_ST | FEC_MMFR_OP_READ |
+	/* start a write op */
+	writel(FEC_MMFR_ST | FEC_MMFR_OP_WRITE |
 		FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) |
 		FEC_MMFR_TA | FEC_MMFR_DATA(value),
 		fep->hwp + FEC_MII_DATA);
-- 
1.7.1


