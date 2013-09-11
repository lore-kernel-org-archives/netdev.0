From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 23/52] net: jme: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:46:35 +0900
Message-ID: <006101ceaec3$0a966fd0$1fc34f70$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Guo-Fu Tseng' <cooldavid@cooldavid.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:45758 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3IKHqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:46:38 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00MC5AWPV0K0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:46:36 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/jme.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 23de82a..37dcd97 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3192,7 +3192,6 @@ jme_init_one(struct pci_dev *pdev,
 err_out_unmap:
 	iounmap(jme->regs);
 err_out_free_netdev:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 err_out_release_regions:
 	pci_release_regions(pdev);
@@ -3210,7 +3209,6 @@ jme_remove_one(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 	iounmap(jme->regs);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-- 
1.7.10.4
