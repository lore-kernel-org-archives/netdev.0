From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.10-rc1 2/5] dscc4: code factorisation
Date: Fri, 14 Jan 2005 01:10:54 +0100
Message-ID: <20050114001054.GB2219@electric-eye.fr.zoreil.com>
References: <20050114000732.GA28864@electric-eye.fr.zoreil.com> <20050114000941.GA2219@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050114000941.GA2219@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Small code factorization.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/wan/dscc4.c~dscc4-010 drivers/net/wan/dscc4.c
--- linux-2.6.11-rc1/drivers/net/wan/dscc4.c~dscc4-010	2005-01-14 00:54:44.287823008 +0100
+++ linux-2.6.11-rc1-fr/drivers/net/wan/dscc4.c	2005-01-14 00:54:44.291822356 +0100
@@ -892,17 +892,14 @@ static int dscc4_found1(struct pci_dev *
 
 	for (i = 0; i < dev_per_card; i++) {
 		root[i].dev = alloc_hdlcdev(root + i);
-		if (!root[i].dev) {
-			while (i--)
-				free_netdev(root[i].dev);
+		if (!root[i].dev)
 			goto err_free_dev;
-		}
 	}
 
 	ppriv = (struct dscc4_pci_priv *) kmalloc(sizeof(*ppriv), GFP_KERNEL);
 	if (!ppriv) {
 		printk(KERN_ERR "%s: can't allocate private data\n", DRV_NAME);
-		goto err_free_dev2;
+		goto err_free_dev;
 	}
 	memset(ppriv, 0, sizeof(struct dscc4_pci_priv));
 
@@ -958,15 +955,15 @@ static int dscc4_found1(struct pci_dev *
 	return ret;
 
 err_unregister:
-	while (--i >= 0) {
+	while (i-- > 0) {
 		dscc4_release_ring(root + i);
 		unregister_hdlc_device(dscc4_to_dev(&root[i]));
 	}
 	kfree(ppriv);
-err_free_dev2:
-	for (i = 0; i < dev_per_card; i++)
-		free_netdev(root[i].dev);
+	i = dev_per_card;
 err_free_dev:
+	while (i-- > 0)
+		free_netdev(root[i].dev);
 	kfree(root);
 err_out:
 	return ret;

_
