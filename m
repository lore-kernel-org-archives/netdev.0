From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] fsl/fman: fix error handling
Date: Mon,  4 Jul 2016 07:46:42 +0200
Message-ID: <1467611202-15168-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: davem@davemloft.net, igal.liberman@freescale.com,
	rdunlap@infradead.org, standby24x7@gmail.com, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:53464 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbcGDFqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 01:46:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is likely that checking 'fman->fifo_offset' instead of
'fman->cam_offset' is expected here.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

---

The type of 'fifo_offset' may also need to be changed.
---
 drivers/net/ethernet/freescale/fman/fman.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index 1de2e1e..f634e769 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2036,7 +2036,7 @@ static int fman_init(struct fman *fman)
 	/* allocate MURAM for FIFO according to total size */
 	fman->fifo_offset = fman_muram_alloc(fman->muram,
 					     fman->state->total_fifo_size);
-	if (IS_ERR_VALUE(fman->cam_offset)) {
+	if (IS_ERR_VALUE(fman->fifo_offset)) {
 		free_init_resources(fman);
 		dev_err(fman->dev, "%s: MURAM alloc for BMI FIFO failed\n",
 			__func__);
-- 
2.7.4
