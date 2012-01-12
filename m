From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/15] drivers/net/ethernet/tundra/tsi108_eth.c: add missing iounmap
Date: Thu, 12 Jan 2012 10:55:04 +0100
Message-ID: <1326362117-29371-2-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Add missing iounmap in error handling code, in a case where the function
already preforms iounmap on some other execution path.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e;
statement S,S1;
int ret;
@@
e = \(ioremap\|ioremap_nocache\)(...)
... when != iounmap(e)
if (<+...e...+>) S
... when any
    when != iounmap(e)
*if (...)
   { ... when != iounmap(e)
     return ...; }
... when any
iounmap(e);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/tundra/tsi108_eth.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index a9ce01b..164fb77 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1604,7 +1604,7 @@ tsi108_init_one(struct platform_device *pdev)
 	data->phyregs = ioremap(einfo->phyregs, 0x400);
 	if (NULL == data->phyregs) {
 		err = -ENOMEM;
-		goto regs_fail;
+		goto phyregs_fail;
 	}
 /* MII setup */
 	data->mii_if.dev = dev;
@@ -1663,9 +1663,11 @@ tsi108_init_one(struct platform_device *pdev)
 	return 0;
 
 register_fail:
-	iounmap(data->regs);
 	iounmap(data->phyregs);
 
+phyregs_fail:
+	iounmap(data->regs);
+
 regs_fail:
 	free_netdev(dev);
 	return err;
