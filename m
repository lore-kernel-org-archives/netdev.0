From: Pan Bian <bianpan2016@163.com>
Subject: net: hns: set correct return value
Date: Sun, 29 Oct 2017 22:35:32 +0800
Message-ID: <1509287732-32172-1-git-send-email-bianpan2016@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>,
        lipeng <lipeng321@huawei.com>, Kejian Yan <yankejian@huawei.com>,
        Lin Yun Sheng <linyunsheng@huawei.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function of_parse_phandle() returns a NULL pointer if it cannot
resolve a phandle property to a device_node pointer. In function
hns_nic_dev_probe(), its return value is passed to PTR_ERR to extract
the error code. However, in this case, the extracted error code will
always be zero, which is unexpected.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 3652063..e771926 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -2369,8 +2369,8 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 			priv->enet_ver = AE_VERSION_2;
 
 		ae_node = of_parse_phandle(dev->of_node, "ae-handle", 0);
-		if (IS_ERR_OR_NULL(ae_node)) {
-			ret = PTR_ERR(ae_node);
+		if (!ae_node) {
+			ret = -ENODEV;
 			dev_err(dev, "not find ae-handle\n");
 			goto out_read_prop_fail;
 		}
-- 
1.9.1
