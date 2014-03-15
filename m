From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/3] sh_eth: convert pr_*() to netdev_*() calls
Date: Sat, 15 Mar 2014 03:27:54 +0300
Message-ID: <201403150327.55110.sergei.shtylyov@cogentembedded.com>
References: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:55827 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165AbaCNX1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 19:27:54 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so2301203lab.27
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 16:27:53 -0700 (PDT)
In-Reply-To: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert pr_*() to netdev_*() calls as the latter provide info on a device.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -400,7 +400,8 @@ static void sh_eth_select_mii(struct net
 		value = 0x0;
 		break;
 	default:
-		pr_warn("PHY interface mode was not setup. Set to MII.\n");
+		netdev_warn(ndev,
+			    "PHY interface mode was not setup. Set to MII.\n");
 		value = 0x1;
 		break;
 	}
@@ -854,7 +855,7 @@ static int sh_eth_check_reset(struct net
 		cnt--;
 	}
 	if (cnt <= 0) {
-		pr_err("Device reset failed\n");
+		netdev_err(ndev, "Device reset failed\n");
 		ret = -ETIMEDOUT;
 	}
 	return ret;
@@ -2924,8 +2925,8 @@ static int sh_eth_drv_probe(struct platf
 	}
 
 	/* print device information */
-	pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
-		(u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
+	netdev_info(ndev, "Base address at 0x%x, %pM, IRQ %d.\n",
+		    (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
 
 	platform_set_drvdata(pdev, ndev);
 
