From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] wan/fsl_ucc_hdlc: avoid possible NULL pointer dereference
Date: Sun, 31 Jul 2016 13:14:23 +0200
Message-ID: <1469963663-3005-1-git-send-email-xypron.glpk@gmx.de>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Zhao Qiang <qiang.zhao@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63061 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbcGaLOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 07:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All assignments to components of priv should only
occur after the check if prif is NULL.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 2fc50ec..6f04445 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -862,7 +862,7 @@ static int uhdlc_suspend(struct device *dev)
 static int uhdlc_resume(struct device *dev)
 {
 	struct ucc_hdlc_private *priv = dev_get_drvdata(dev);
-	struct ucc_tdm *utdm = priv->utdm;
+	struct ucc_tdm *utdm;
 	struct ucc_tdm_info *ut_info;
 	struct ucc_fast __iomem *uf_regs;
 	struct ucc_fast_private *uccf;
@@ -877,6 +877,7 @@ static int uhdlc_resume(struct device *dev)
 	if (!netif_running(priv->ndev))
 		return 0;
 
+	utdm = priv->utdm;
 	ut_info = priv->ut_info;
 	uf_info = &ut_info->uf_info;
 	uf_regs = priv->uf_regs;
-- 
2.8.1
