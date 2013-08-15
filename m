From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v3 5/7] net: sunhme: use platform_{get,set}_drvdata()
Date: Thu, 15 Aug 2013 21:01:44 +0800
Message-ID: <520CD138.8030204@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jg1.han@samsung.com>, Bill Pemberton <wfp5p@virginia.edu>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/sun/sunhme.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 171f5b0..4900ea8 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -3111,7 +3111,7 @@ static int happy_meal_pci_probe(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}

-	dev_set_drvdata(&pdev->dev, hp);
+	platform_set_drvdata(pdev, hp);

 	if (!qfe_slot) {
 		struct pci_dev *qpdev = qp->quattro_dev;
@@ -3159,7 +3159,7 @@ err_out:

 static void happy_meal_pci_remove(struct pci_dev *pdev)
 {
-	struct happy_meal *hp = dev_get_drvdata(&pdev->dev);
+	struct happy_meal *hp = platform_get_drvdata(pdev);
 	struct net_device *net_dev = hp->dev;

 	unregister_netdev(net_dev);
@@ -3231,7 +3231,7 @@ static int hme_sbus_probe(struct platform_device *op)

 static int hme_sbus_remove(struct platform_device *op)
 {
-	struct happy_meal *hp = dev_get_drvdata(&op->dev);
+	struct happy_meal *hp = platform_get_drvdata(op);
 	struct net_device *net_dev = hp->dev;

 	unregister_netdev(net_dev);
-- 
1.7.1
