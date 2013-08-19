From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v4 4/7] net: sunbmac: use platform_{get,set}_drvdata()
Date: Mon, 19 Aug 2013 19:59:25 +0800
Message-ID: <5212089D.1010203@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <emilio@elopez.com.ar>, Greg KH <gregkh@linuxfoundation.org>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &of->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/sun/sunbmac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 0d43fa9..0a32ca5 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1239,7 +1239,7 @@ static int bigmac_sbus_probe(struct platform_device *op)

 static int bigmac_sbus_remove(struct platform_device *op)
 {
-	struct bigmac *bp = dev_get_drvdata(&op->dev);
+	struct bigmac *bp = platform_get_drvdata(op);
 	struct device *parent = op->dev.parent;
 	struct net_device *net_dev = bp->dev;
 	struct platform_device *qec_op;
-- 
1.7.1
