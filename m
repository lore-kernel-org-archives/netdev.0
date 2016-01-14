From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] fsl/fman: Delete one function call "put_device" in
 dtsec_config()
Date: Thu, 14 Jan 2016 16:00:46 +0100
Message-ID: <5697B81E.4050303@users.sourceforge.net>
References: <5696BFAD.9030905@users.sourceforge.net>
 <20160113213537.GD4399@mwanda> <20160113220923.GE5527@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Andrew Lunn <andrew@lunn.ch>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Igal Liberman <igal.liberman@freescale.com>,
	netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160113220923.GE5527@lunn.ch>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 14 Jan 2016 15:46:28 +0100

The Coccinelle semantic patch script "deref_null.cocci" pointed a problem
out in the implementation of the function "dtsec_config".

A null pointer was assigned to the data structure member "tbiphy" of the
variable "dtsec" if a matching device was not found.
A call of the function "put_device" was unnecessary then because
a previous call of the function "get_device" was not triggered.
Thus remove the function call "put_device" after the printing of the
desired error message.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/freescale/fman/fman_dtsec.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
index 6b1261c..7c92eb8 100644
--- a/drivers/net/ethernet/freescale/fman/fman_dtsec.c
+++ b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
@@ -1434,7 +1434,6 @@ struct fman_mac *dtsec_config(struct fman_mac_params *params)
 	dtsec->tbiphy = of_phy_find_device(params->internal_phy_node);
 	if (!dtsec->tbiphy) {
 		pr_err("of_phy_find_device (TBI PHY) failed\n");
-		put_device(&dtsec->tbiphy->mdio.dev);
 		goto err_dtsec_drv_param;
 	}
 
-- 
2.6.3

