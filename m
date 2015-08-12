From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next] net: fec: Remove unneeded use of IS_ERR_VALUE() macro
Date: Wed, 12 Aug 2015 12:10:23 -0300
Message-ID: <1439392223-28350-1-git-send-email-festevam@gmail.com>
Cc: Julia.Lawall@lip6.fr, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:35513 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932147AbbHLPKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 11:10:48 -0400
Received: by ykdz80 with SMTP id z80so16384901ykd.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 08:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

There is no need to use the IS_ERR_VALUE() macro for checking
the return value from pm_runtime_* functions.

Just do a simple negative test instead.

The semantic patch that makes this change is available
in scripts/coccinelle/api/pm_runtime.cocci.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3cebf93..787da8e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1779,7 +1779,7 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	int ret = 0;
 
 	ret = pm_runtime_get_sync(dev);
-	if (IS_ERR_VALUE(ret))
+	if (ret < 0)
 		return ret;
 
 	fep->mii_timeout = 0;
@@ -1818,7 +1818,7 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	int ret = 0;
 
 	ret = pm_runtime_get_sync(dev);
-	if (IS_ERR_VALUE(ret))
+	if (ret < 0)
 		return ret;
 
 	fep->mii_timeout = 0;
@@ -2870,7 +2870,7 @@ fec_enet_open(struct net_device *ndev)
 	int ret;
 
 	ret = pm_runtime_get_sync(&fep->pdev->dev);
-	if (IS_ERR_VALUE(ret))
+	if (ret < 0)
 		return ret;
 
 	pinctrl_pm_select_default_state(&fep->pdev->dev);
-- 
1.9.1
