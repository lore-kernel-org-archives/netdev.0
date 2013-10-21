From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 01/15] net: tulip: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:09:26 +0900
Message-ID: <003901cece02$91b4ba40$b51e2ec0$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:35351 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab3JUCJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:09:29 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00AZOXWZD3E0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:09:27 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/dec/tulip/de2104x.c     |    1 -
 drivers/net/ethernet/dec/tulip/dmfe.c        |    3 ---
 drivers/net/ethernet/dec/tulip/tulip_core.c  |    1 -
 drivers/net/ethernet/dec/tulip/uli526x.c     |    2 --
 drivers/net/ethernet/dec/tulip/winbond-840.c |    3 ---
 drivers/net/ethernet/dec/tulip/xircom_cb.c   |    2 --
 6 files changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index eaab73c..38148b0 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -2110,7 +2110,6 @@ static void de_remove_one(struct pci_dev *pdev)
 	iounmap(de->regs);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 8313930..5ad9e3e 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -523,7 +523,6 @@ err_out_res:
 err_out_disable:
 	pci_disable_device(pdev);
 err_out_free:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 
 	return err;
@@ -548,8 +547,6 @@ static void dmfe_remove_one(struct pci_dev *pdev)
 					db->buf_pool_ptr, db->buf_pool_dma_ptr);
 		pci_release_regions(pdev);
 		free_netdev(dev);	/* free board information */
-
-		pci_set_drvdata(pdev, NULL);
 	}
 
 	DMFE_DBUG(0, "dmfe_remove_one() exit", 0);
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 4e8cfa2..add05f1 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1939,7 +1939,6 @@ static void tulip_remove_one(struct pci_dev *pdev)
 	pci_iounmap(pdev, tp->base_addr);
 	free_netdev (dev);
 	pci_release_regions (pdev);
-	pci_set_drvdata (pdev, NULL);
 
 	/* pci_power_off (pdev, -1); */
 }
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 93845af..a5397b1 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -429,7 +429,6 @@ err_out_release:
 err_out_disable:
 	pci_disable_device(pdev);
 err_out_free:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 
 	return err;
@@ -450,7 +449,6 @@ static void uli526x_remove_one(struct pci_dev *pdev)
 				db->buf_pool_ptr, db->buf_pool_dma_ptr);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index c7b04ec..62fe512 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -468,7 +468,6 @@ static int w840_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 err_out_cleardev:
-	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, ioaddr);
 err_out_free_res:
 	pci_release_regions(pdev);
@@ -1542,8 +1541,6 @@ static void w840_remove1(struct pci_dev *pdev)
 		pci_iounmap(pdev, np->base_addr);
 		free_netdev(dev);
 	}
-
-	pci_set_drvdata(pdev, NULL);
 }
 
 #ifdef CONFIG_PM
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 9b84cb0..ab7ebac 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -289,7 +289,6 @@ out:
 err_unmap:
 	pci_iounmap(pdev, private->ioaddr);
 reg_fail:
-	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, private->tx_buffer, private->tx_dma_handle);
 tx_buf_fail:
 	dma_free_coherent(d, 8192, private->rx_buffer, private->rx_dma_handle);
@@ -317,7 +316,6 @@ static void xircom_remove(struct pci_dev *pdev)
 
 	unregister_netdev(dev);
 	pci_iounmap(pdev, card->ioaddr);
-	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, card->tx_buffer, card->tx_dma_handle);
 	dma_free_coherent(d, 8192, card->rx_buffer, card->rx_dma_handle);
 	free_netdev(dev);
-- 
1.7.10.4
