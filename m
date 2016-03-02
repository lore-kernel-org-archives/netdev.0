From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: moxa: fix an error code
Date: Wed, 2 Mar 2016 13:11:10 +0300
Message-ID: <20160302101110.GI5533@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luis de Bethencourt <luis@debethencourt.com>,
	Arnd Bergmann <arnd@arndb.de>,
	=?iso-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We accidentally return IS_ERR(priv->base) which is 1 instead of
PTR_ERR(priv->base) which is the error code.

Fixes: 6c821bd9edc9 ('net: Add MOXA ART SoCs ethernet driver')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 00cfd95..3e67f45 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -474,9 +474,9 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	ndev->base_addr = res->start;
 	priv->base = devm_ioremap_resource(p_dev, res);
-	ret = IS_ERR(priv->base);
-	if (ret) {
+	if (IS_ERR(priv->base)) {
 		dev_err(p_dev, "devm_ioremap_resource failed\n");
+		ret = PTR_ERR(priv->base);
 		goto init_fail;
 	}
 
