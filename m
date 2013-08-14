From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH RESEND 8/8] net: davinci_mdio: use platform_{get,set}_drvdata()
Date: Wed, 14 Aug 2013 11:40:22 +0800
Message-ID: <520AFC26.9070508@huawei.com>
References: <5208E231.60104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>, <bigeasy@linutronix.de>,
	<prabhakar.csengg@gmail.com>, <b-liu@ti.com>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E231.60104@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We can use the wrapper functions platform_{get,set}_drvdata() instead of
dev_{get,set}_drvdata() with &pdev->dev, it is convenient for user.

Also, unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.


Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 16ddfc3..2249b2c 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -421,8 +421,7 @@ bail_out:

 static int davinci_mdio_remove(struct platform_device *pdev)
 {
-	struct device *dev = &pdev->dev;
-	struct davinci_mdio_data *data = dev_get_drvdata(dev);
+	struct davinci_mdio_data *data = platform_get_drvdata(pdev);

 	if (data->bus) {
 		mdiobus_unregister(data->bus);
@@ -434,7 +433,6 @@ static int davinci_mdio_remove(struct platform_device *pdev)
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);

-	dev_set_drvdata(dev, NULL);

 	kfree(data);

-- 
1.7.1
