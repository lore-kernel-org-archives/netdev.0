From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] sunlance: fix compilation on sparc-UP
Date: Thu, 27 Jul 2006 13:35:20 +0400
Message-ID: <20060727093520.GA6825@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:7185 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932543AbWG0JfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 05:35:22 -0400
Received: by ug-out-1314.google.com with SMTP id m3so167660ugc
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2006 02:35:21 -0700 (PDT)
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1537,7 +1537,7 @@ static int __init sparc_lance_init(void)
 {
 	if ((idprom->id_machtype == (SM_SUN4|SM_4_330)) ||
 	    (idprom->id_machtype == (SM_SUN4|SM_4_470))) {
-		memset(&sun4_sdev, 0, sizeof(sdev));
+		memset(&sun4_sdev, 0, sizeof(struct sbus_dev));
 		sun4_sdev.reg_addrs[0].phys_addr = sun4_eth_physaddr;
 		sun4_sdev.irqs[0] = 6;
 		return sparc_lance_probe_one(&sun4_sdev, NULL, NULL);
@@ -1547,16 +1547,16 @@ static int __init sparc_lance_init(void)
 
 static int __exit sunlance_sun4_remove(void)
 {
-	struct lance_private *lp = dev_get_drvdata(&sun4_sdev->dev);
+	struct lance_private *lp = dev_get_drvdata(&sun4_sdev.ofdev.dev);
 	struct net_device *net_dev = lp->dev;
 
 	unregister_netdevice(net_dev);
 
-	lance_free_hwresources(root_lance_dev);
+	lance_free_hwresources(lp);
 
 	free_netdev(net_dev);
 
-	dev_set_drvdata(&sun4_sdev->dev, NULL);
+	dev_set_drvdata(&sun4_sdev.ofdev.dev, NULL);
 
 	return 0;
 }

