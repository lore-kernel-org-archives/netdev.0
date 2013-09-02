From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 5/5] net: sunhme: use pci_{get,set}_drvdata()
Date: Mon, 02 Sep 2013 17:12:41 +0900
Message-ID: <001301cea7b4$3225c110$96714330$%han@samsung.com>
References: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jon Mason' <jdmason@kudzu.us>,
	'Francois Romieu' <romieu@fr.zoreil.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:37603 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310Ab3IBIMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 04:12:43 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSH008XPO4I5310@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 02 Sep 2013 17:12:42 +0900 (KST)
In-reply-to: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data
using pci_dev instead of using dev_{get,set}_drvdata() with
&pdev->dev, so we can directly pass a struct pci_dev. This is
a purely cosmetic change.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/sunhme.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 227c499..e37b587 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -3111,7 +3111,7 @@ static int happy_meal_pci_probe(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
-	dev_set_drvdata(&pdev->dev, hp);
+	pci_set_drvdata(pdev, hp);
 
 	if (!qfe_slot) {
 		struct pci_dev *qpdev = qp->quattro_dev;
@@ -3159,7 +3159,7 @@ err_out:
 
 static void happy_meal_pci_remove(struct pci_dev *pdev)
 {
-	struct happy_meal *hp = dev_get_drvdata(&pdev->dev);
+	struct happy_meal *hp = pci_get_drvdata(pdev);
 	struct net_device *net_dev = hp->dev;
 
 	unregister_netdev(net_dev);
@@ -3171,7 +3171,7 @@ static void happy_meal_pci_remove(struct pci_dev *pdev)
 
 	free_netdev(net_dev);
 
-	dev_set_drvdata(&pdev->dev, NULL);
+	pci_set_drvdata(pdev, NULL);
 }
 
 static DEFINE_PCI_DEVICE_TABLE(happymeal_pci_ids) = {
-- 
1.7.10.4
