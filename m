From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 08/15] net: jme: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:13:33 +0900
Message-ID: <004001cece03$24b94b30$6e2be190$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Guo-Fu Tseng' <cooldavid@cooldavid.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:52229 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab3JUCNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:13:34 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00KSGY5HKRE0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:13:34 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
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
index b56d2a2..f5685c0 100644
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
