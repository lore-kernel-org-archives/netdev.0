From: Peter Chen <peter.chen@nxp.com>
Subject: RE: [PATCH] net: arc_emac: add missing of_node_put() in
 arc_emac_probe()
Date: Thu, 4 Aug 2016 06:20:46 +0000
Message-ID: <HE1PR04MB1450E5B957ED8C1D511FAFE58B070@HE1PR04MB1450.eurprd04.prod.outlook.com>
References: <1470221915-5880-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	"Philippe Reynes" <tremyfr@gmail.com>,
	Caesar Wang <wxt@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0071.outbound.protection.outlook.com ([104.47.2.71]:43200
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754252AbcHDGy1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 02:54:27 -0400
In-Reply-To: <1470221915-5880-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>
>Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
>---
> drivers/net/ethernet/arc/emac_main.c | 6 ++++--
> 1 file changed, 4 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/ethernet/arc/emac_main.c
>b/drivers/net/ethernet/arc/emac_main.c
>index 4bff0f3..b0da969 100644
>--- a/drivers/net/ethernet/arc/emac_main.c
>+++ b/drivers/net/ethernet/arc/emac_main.c
>@@ -771,8 +771,10 @@ int arc_emac_probe(struct net_device *ndev, int interface)
> 	priv->dev = dev;
>
> 	priv->regs = devm_ioremap_resource(dev, &res_regs);
>-	if (IS_ERR(priv->regs))
>-		return PTR_ERR(priv->regs);
>+	if (IS_ERR(priv->regs)) {
>+		err = PTR_ERR(priv->regs);
>+		goto out_put_node;
>+	}
>
> 	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs);

Thanks, I missed that error path.

Reviewed-by: Peter Chen <peter.chen@nxp.com>

Peter
