From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/3] sh_eth: kill unneeded typecast in sh_eth_drv_probe()
Date: Thu, 21 Mar 2013 23:39:22 +0300
Message-ID: <201303212339.22356.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:53915 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab3CUTiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 15:38:04 -0400
Received: by mail-la0-f54.google.com with SMTP id gw10so5789002lab.41
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 12:38:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sh_eth_drv_probe() does cast from 'void *' when assigning to the 'pd'  variable
which is automatic anyway. Turn the assignment into initializer, while removing
the cast...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2351,7 +2351,7 @@ static int sh_eth_drv_probe(struct platf
 	struct resource *res;
 	struct net_device *ndev = NULL;
 	struct sh_eth_private *mdp = NULL;
-	struct sh_eth_plat_data *pd;
+	struct sh_eth_plat_data *pd = pdev->dev.platform_data;
 
 	/* get base addr */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2401,7 +2401,6 @@ static int sh_eth_drv_probe(struct platf
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_resume(&pdev->dev);
 
-	pd = (struct sh_eth_plat_data *)(pdev->dev.platform_data);
 	/* get PHY ID */
 	mdp->phy_id = pd->phy;
 	mdp->phy_interface = pd->phy_interface;
