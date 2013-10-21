From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 14/15] net: neterion: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:16:38 +0900
Message-ID: <004601cece03$92c8f3f0$b85adbd0$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Jon Mason' <jdmason@kudzu.us>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:20462 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319Ab3JUCQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:16:39 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00EF9YAERAG0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:16:38 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
Acked-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/neterion/s2io.c           |    2 --
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 51b0094..9eeddbd 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -8185,7 +8185,6 @@ mem_alloc_failed:
 	free_shared_mem(sp);
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 
 	return ret;
@@ -8221,7 +8220,6 @@ static void s2io_rem_nic(struct pci_dev *pdev)
 	iounmap(sp->bar0);
 	iounmap(sp->bar1);
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 5a20eaf..8614eeb 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -4739,7 +4739,6 @@ _exit6:
 _exit5:
 	vxge_device_unregister(hldev);
 _exit4:
-	pci_set_drvdata(pdev, NULL);
 	vxge_hw_device_terminate(hldev);
 	pci_disable_sriov(pdev);
 _exit3:
@@ -4782,7 +4781,6 @@ static void vxge_remove(struct pci_dev *pdev)
 		vxge_free_mac_add_list(&vdev->vpaths[i]);
 
 	vxge_device_unregister(hldev);
-	pci_set_drvdata(pdev, NULL);
 	/* Do not call pci_disable_sriov here, as it will break child devices */
 	vxge_hw_device_terminate(hldev);
 	iounmap(vdev->bar0);
-- 
1.7.10.4
