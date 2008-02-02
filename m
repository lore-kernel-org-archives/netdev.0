From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/phy/fixed.c: fix a use-after-free
Date: Sat, 2 Feb 2008 23:15:02 +0200
Message-ID: <20080202211502.GC9375@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:53754 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934109AbYBBVOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 16:14:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a use-after-free introduced by
commit a79d8e93d300adb84cccc38ac396cfb118c238ad and spotted by the 
Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
20c51455b2faed63c3026fd4d7139e5a6a917d31 
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 73b6d39..ca9b040 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -236,12 +236,12 @@ module_init(fixed_mdio_bus_init);
 static void __exit fixed_mdio_bus_exit(void)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
-	struct fixed_phy *fp;
+	struct fixed_phy *fp, *tmp;
 
 	mdiobus_unregister(&fmb->mii_bus);
 	platform_device_unregister(pdev);
 
-	list_for_each_entry(fp, &fmb->phys, node) {
+	list_for_each_entry_safe(fp, tmp, &fmb->phys, node) {
 		list_del(&fp->node);
 		kfree(fp);
 	}

