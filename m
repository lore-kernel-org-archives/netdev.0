From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.10-rc1 1/5] dscc4: use of uncompletely initialized struct
Date: Fri, 14 Jan 2005 01:09:41 +0100
Message-ID: <20050114000941.GA2219@electric-eye.fr.zoreil.com>
References: <20050114000732.GA28864@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050114000732.GA28864@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dscc4_set_quartz() is issued with an argument in an unitialized state and
the kernel does not like it.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/wan/dscc4.c~dscc4-000 drivers/net/wan/dscc4.c
--- linux-2.6.11-rc1/drivers/net/wan/dscc4.c~dscc4-000	2005-01-13 23:57:53.017533390 +0100
+++ linux-2.6.11-rc1-fr/drivers/net/wan/dscc4.c	2005-01-14 00:06:01.600966142 +0100
@@ -905,9 +905,7 @@ static int dscc4_found1(struct pci_dev *
 		goto err_free_dev2;
 	}
 	memset(ppriv, 0, sizeof(struct dscc4_pci_priv));
-	ret = dscc4_set_quartz(root, quartz);
-	if (ret < 0)
-		goto err_free_priv;
+
 	ppriv->root = root;
 	spin_lock_init(&ppriv->lock);
 
@@ -951,6 +949,11 @@ static int dscc4_found1(struct pci_dev *
 			goto err_unregister;
 	        }
 	}
+
+	ret = dscc4_set_quartz(root, quartz);
+	if (ret < 0)
+		goto err_unregister;
+
 	pci_set_drvdata(pdev, ppriv);
 	return ret;
 
@@ -959,7 +962,6 @@ err_unregister:
 		dscc4_release_ring(root + i);
 		unregister_hdlc_device(dscc4_to_dev(&root[i]));
 	}
-err_free_priv:
 	kfree(ppriv);
 err_free_dev2:
 	for (i = 0; i < dev_per_card; i++)

_
