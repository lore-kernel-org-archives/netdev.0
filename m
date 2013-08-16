From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v3 RESEND 5/7] net: sunhme: use platform_{get,set}_drvdata()
Date: Fri, 16 Aug 2013 10:33:53 +0800
Message-ID: <520D8F91.2060605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jg1.han@samsung.com>, Bill Pemberton <wfp5p@virginia.edu>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &of_dev->dev,
so we can directly pass a struct platform_device.

changelog:
	remove modify about happy_meal_pci_probe && happy_meal_pci_remove

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/sun/sunhme.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 171f5b0..b90d311 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -3231,7 +3231,7 @@ static int hme_sbus_probe(struct platform_device *op)

 static int hme_sbus_remove(struct platform_device *op)
 {
-	struct happy_meal *hp = dev_get_drvdata(&op->dev);
+	struct happy_meal *hp = platform_get_drvdata(op);
 	struct net_device *net_dev = hp->dev;

 	unregister_netdev(net_dev);
-- 
1.7.1
