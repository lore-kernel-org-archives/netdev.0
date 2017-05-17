From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 2/8] net/wan/fsl_ucc_hdlc: fix unitialized variable warnings
Date: Wed, 17 May 2017 17:24:33 +0200
Message-ID: <20170517152439.8817-2-holger.brunck@keymile.com>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47372 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753426AbdEQPbj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:39 -0400
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following compiler warnings:
drivers/net/wan/fsl_ucc_hdlc.c: In function 'ucc_hdlc_poll':
warning: 'skb' may be used uninitialized in this function
[-Wmaybe-uninitialized]
  skb->mac_header = skb->data - skb->head;

and

drivers/net/wan/fsl_ucc_hdlc.c: In function 'ucc_hdlc_probe':
drivers/net/wan/fsl_ucc_hdlc.c:1127:3: warning: 'utdm' may be used
uninitialized in this function [-Wmaybe-uninitialized]
   kfree(utdm);

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 0ae10a58ffca..6ef6d719545d 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -440,7 +440,7 @@ static int hdlc_tx_done(struct ucc_hdlc_private *priv)
 static int hdlc_rx_done(struct ucc_hdlc_private *priv, int rx_work_limit)
 {
 	struct net_device *dev = priv->ndev;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	struct qe_bd *bd;
 	u16 bd_status;
@@ -968,7 +968,7 @@ static int ucc_hdlc_probe(struct platform_device *pdev)
 	struct device_node *np = pdev->dev.of_node;
 	struct ucc_hdlc_private *uhdlc_priv = NULL;
 	struct ucc_tdm_info *ut_info;
-	struct ucc_tdm *utdm;
+	struct ucc_tdm *utdm = NULL;
 	struct resource res;
 	struct net_device *dev;
 	hdlc_device *hdlc;
-- 
2.12.0.rc1
