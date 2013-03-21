From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix unused variable warning
Date: Fri, 22 Mar 2013 01:59:00 +0300
Message-ID: <201303220159.00633.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:35664 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353Ab3CUV5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:57:42 -0400
Received: by mail-la0-f46.google.com with SMTP id fq12so6142574lab.19
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 14:57:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d5e07e69218fd9aa21d6c8c5ccc629d92bdb9b0f (sh_eth: use managed device API)
has caused this warning (due to my overlook):

drivers/net/ethernet/renesas/sh_eth.c: In function `sh_eth_drv_remove':
drivers/net/ethernet/renesas/sh_eth.c:2482:25: warning: unused variable `mdp'
[-Wunused-variable]

Kill the darn variable now...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the David Miller's net-next.git repo.

 drivers/net/ethernet/renesas/sh_eth.c |    1 -
 1 file changed, 1 deletion(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2479,7 +2479,6 @@ out:
 static int sh_eth_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct sh_eth_private *mdp = netdev_priv(ndev);
 
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
