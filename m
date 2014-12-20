From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Re: [PATCH] e1000 in linux-3.18.0: a potential bug
Date: Sat, 20 Dec 2014 21:57:14 +0800
Message-ID: <000001d01c5c$dd9f2db0$98dd8910$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:57768 "EHLO m50-132.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbaLTN52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 08:57:28 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe the email can not be displayed fully...
I send my patch again:

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 24f3986..f6def7b 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1004,7 +1004,7 @@ static int e1000_probe(struct pci_dev *pdev, const
struct pci_device_id *ent)
 	/* make ready for any if (hw->...) below */
 	err = e1000_init_hw_struct(adapter, hw);
 	if (err)
-		goto err_sw_init;
+		goto err_dma;
 
 	/* there is a workaround being applied below that limits
 	 * 64-bit DMA addresses to 64-bit hardware.  There are some
@@ -1239,8 +1239,9 @@ err_eeprom:
 		iounmap(hw->flash_address);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
-err_dma:
 err_sw_init:
+	netif_napi_del(&adapter->napi);
+err_dma:
 err_mdio_ioremap:
 	iounmap(hw->ce4100_gbe_mdio_base_virt);
 	iounmap(hw->hw_addr);
@@ -1271,6 +1272,7 @@ static void e1000_remove(struct pci_dev *pdev)
 	e1000_down_and_stop(adapter);
 	e1000_release_manageability(adapter);
 
+	netif_napi_del(&adapter->napi);
 	unregister_netdev(netdev);
 
 	e1000_phy_hw_reset(hw);
