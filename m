From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 19/52] net: be2net: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:39:36 +0900
Message-ID: <005d01ceaec2$106bed00$3143c700$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Sathya Perla' <sathya.perla@emulex.com>,
	'Subbu Seetharaman' <subbu.seetharaman@emulex.com>,
	'Ajit Khaparde' <ajit.khaparde@emulex.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:53602 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab3IKHjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:39:41 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY008F8ALGXAO0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:39:37 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3224d28..80a819a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4097,7 +4097,6 @@ static void be_remove(struct pci_dev *pdev)
 
 	pci_disable_pcie_error_reporting(pdev);
 
-	pci_set_drvdata(pdev, NULL);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 
@@ -4427,7 +4426,6 @@ ctrl_clean:
 	be_ctrl_cleanup(adapter);
 free_netdev:
 	free_netdev(netdev);
-	pci_set_drvdata(pdev, NULL);
 rel_reg:
 	pci_release_regions(pdev);
 disable_dev:
-- 
1.7.10.4
