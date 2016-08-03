From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net: arc_emac: add missing of_node_put() in arc_emac_probe()
Date: Wed,  3 Aug 2016 10:58:35 +0000
Message-ID: <1470221915-5880-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Peter Chen <peter.chen@nxp.com>,
	Caesar Wang <wxt@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34030 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757746AbcHCK6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 06:58:48 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so13892826pac.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 03:58:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a94efbd7cc45 ("ethernet: arc: emac_main: add missing of_node_put
after calling of_parse_phandle") added missing of_node_put after calling
of_parse_phandle, but missing the devm_ioremap_resource() error handling
case.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 4bff0f3..b0da969 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -771,8 +771,10 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 	priv->dev = dev;
 
 	priv->regs = devm_ioremap_resource(dev, &res_regs);
-	if (IS_ERR(priv->regs))
-		return PTR_ERR(priv->regs);
+	if (IS_ERR(priv->regs)) {
+		err = PTR_ERR(priv->regs);
+		goto out_put_node;
+	}
 
 	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs);
