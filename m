From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 6/7] net: hns: fix warning of passing zero to 'PTR_ERR'
Date: Thu, 24 Mar 2016 19:08:05 +0800
Message-ID: <1458817686-159708-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

There is a misuse of PTR as shown below:

	ae_node = (void *)of_parse_phandle(dev->of_node,
					   "ae-handle",
					   0);
	if (IS_ERR_OR_NULL(ae_node)) {
		ret = PTR_ERR(ae_node);
		dev_err(dev, "not find ae-handle\n");
		goto out_read_prop_fail;
	}

if the ae_node is NULL, PTR_ERR(ae_node) means it returns success. And the
return value should be -ENODEV.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 66d1652..687204b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1814,7 +1814,7 @@ static int hns_nic_try_get_ae(struct net_device *ndev)
 	h = hnae_get_handle(&priv->netdev->dev,
 			    priv->ae_node, priv->port_id, NULL);
 	if (IS_ERR_OR_NULL(h)) {
-		ret = PTR_ERR(h);
+		ret = -ENODEV;
 		dev_dbg(priv->dev, "has not handle, register notifier!\n");
 		goto out;
 	}
-- 
1.9.1
