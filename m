From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next] net/wan/fsl_ucc_hdlc: fix muram allocation error
Date: Mon, 22 May 2017 09:31:15 +0200
Message-ID: <20170522073115.16393-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:38018 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbdEVHbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 03:31:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sizeof(priv->ucc_pram) is 4 as it is the size of a pointer, but we want
to reserve space for the struct ucc_hdlc_param.

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index e9b2d687f150..33df76405b86 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -189,7 +189,7 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	}
 
 	/* Alloc parameter ram for ucc hdlc */
-	priv->ucc_pram_offset = qe_muram_alloc(sizeof(priv->ucc_pram),
+	priv->ucc_pram_offset = qe_muram_alloc(sizeof(struct ucc_hdlc_param),
 				ALIGNMENT_OF_UCC_HDLC_PRAM);
 
 	if (priv->ucc_pram_offset < 0) {
-- 
2.12.0.rc1
