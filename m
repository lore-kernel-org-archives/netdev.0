From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] fsl/fman: double free on probe failure
Date: Wed, 6 Jan 2016 12:59:10 +0300
Message-ID: <20160106095910.GD23185@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Igal Liberman <igal.liberman@freescale.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"priv" is allocated with devm_kzalloc() so freeing it here with kfree()
will lead to a double free.

Fixes: 3933961682a3 ('fsl/fman: Add FMan MAC driver')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 743a393..e33d9d2 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -961,7 +961,6 @@ _return_of_node_put:
 	of_node_put(dev_node);
 _return_dev_set_drvdata:
 	kfree(priv->fixed_link);
-	kfree(priv);
 	dev_set_drvdata(dev, NULL);
 _return:
 	return err;
