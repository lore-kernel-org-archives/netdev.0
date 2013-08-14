From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH RESEND 6/8] net: sunhme: use platform_{get,set}_drvdata()
Date: Wed, 14 Aug 2013 11:40:01 +0800
Message-ID: <520AFC11.2000208@huawei.com>
References: <5208E229.9070300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <jg1.han@samsung.com>,
	Bill Pemberton <wfp5p@virginia.edu>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E229.9070300@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We can use the wrapper functions platform_{get,set}_drvdata() instead of
dev_{get,set}_drvdata() with &pdev->dev, it is convenient for user.

Also, unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/sun/sunhme.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 171f5b0..a111f29 100644
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
@@ -3171,7 +3171,6 @@ static void happy_meal_pci_remove(struct pci_dev *pdev)

 	free_netdev(net_dev);

-	dev_set_drvdata(&pdev->dev, NULL);
 }

 static DEFINE_PCI_DEVICE_TABLE(happymeal_pci_ids) = {
@@ -3231,7 +3230,7 @@ static int hme_sbus_probe(struct platform_device *op)

 static int hme_sbus_remove(struct platform_device *op)
 {
-	struct happy_meal *hp = dev_get_drvdata(&op->dev);
+	struct happy_meal *hp = platform_get_drvdata(op);
 	struct net_device *net_dev = hp->dev;

 	unregister_netdev(net_dev);
@@ -3250,7 +3249,6 @@ static int hme_sbus_remove(struct platform_device *op)

 	free_netdev(net_dev);

-	dev_set_drvdata(&op->dev, NULL);

 	return 0;
 }
-- 
1.7.1
