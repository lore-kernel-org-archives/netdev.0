From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.10-rc1 5/5] dscc4: removal of unneeded variable
Date: Fri, 14 Jan 2005 01:15:16 +0100
Message-ID: <20050114001516.GE2219@electric-eye.fr.zoreil.com>
References: <20050114000732.GA28864@electric-eye.fr.zoreil.com> <20050114000941.GA2219@electric-eye.fr.zoreil.com> <20050114001054.GB2219@electric-eye.fr.zoreil.com> <20050114001212.GC2219@electric-eye.fr.zoreil.com> <20050114001318.GD2219@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050114001318.GD2219@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removal of unneeded variable and more spaces for my eyes.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/wan/dscc4.c~dscc4-040 drivers/net/wan/dscc4.c
--- linux-2.6.11-rc1/drivers/net/wan/dscc4.c~dscc4-040	2005-01-14 00:54:59.425357736 +0100
+++ linux-2.6.11-rc1-fr/drivers/net/wan/dscc4.c	2005-01-14 00:55:22.581586543 +0100
@@ -691,7 +691,7 @@ static void dscc4_free1(struct pci_dev *
 	root = ppriv->root;
 
 	for (i = 0; i < dev_per_card; i++)
-		unregister_hdlc_device(dscc4_to_dev(&root[i]));
+		unregister_hdlc_device(dscc4_to_dev(root + i));
 
 	pci_set_drvdata(pdev, NULL);
 
@@ -706,7 +706,6 @@ static int __devinit dscc4_init_one(stru
 {
 	struct dscc4_pci_priv *priv;
 	struct dscc4_dev_priv *dpriv;
-	static int cards_found = 0;
 	void __iomem *ioaddr;
 	int i, rc;
 
@@ -812,8 +811,6 @@ static int __devinit dscc4_init_one(stru
 
 	writel(0xff200001, ioaddr + GCMDR);
 
-	cards_found++;
-
 	rc = 0;
 out:
 	return rc;
@@ -966,7 +963,7 @@ static int dscc4_found1(struct pci_dev *
 err_unregister:
 	while (i-- > 0) {
 		dscc4_release_ring(root + i);
-		unregister_hdlc_device(dscc4_to_dev(&root[i]));
+		unregister_hdlc_device(dscc4_to_dev(root + i));
 	}
 	kfree(ppriv);
 	i = dev_per_card;

_
