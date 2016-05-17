From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: hns: avoid null pointer dereference
Date: Tue, 17 May 2016 22:01:15 +0200
Message-ID: <1463515275-9836-1-git-send-email-xypron.glpk@gmx.de>
Cc: Yisen Zhuang <Yisen.Zhuang@huawei.com>,
	Kejian Yan <yankejian@huawei.com>,
	Lisheng <lisheng011@huawei.com>,
	Kenneth Lee <liguozhu@huawei.com>,
	Andrew Lunn <andrew@lunn.ch>, Salil <salil.mehta@huawei.com>,
	Qianqian Xie <xieqianqian@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>,
	Chenny Xu <chenny.xu@huawei.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:55655 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975AbcEQUC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 16:02:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the statement
  assert(priv || priv->ae_handle);
the right side of || is only evaluated if priv is null.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3d746c8..834a50a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -720,7 +720,7 @@ static int hns_set_pauseparam(struct net_device *net_dev,
 	struct hnae_handle *h;
 	struct hnae_ae_ops *ops;
 
-	assert(priv || priv->ae_handle);
+	assert(priv && priv->ae_handle);
 
 	h = priv->ae_handle;
 	ops = h->dev->ops;
@@ -780,7 +780,7 @@ static int hns_set_coalesce(struct net_device *net_dev,
 	struct hnae_ae_ops *ops;
 	int ret;
 
-	assert(priv || priv->ae_handle);
+	assert(priv && priv->ae_handle);
 
 	ops = priv->ae_handle->dev->ops;
 
@@ -1111,7 +1111,7 @@ void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_ae_ops *ops;
 
-	assert(priv || priv->ae_handle);
+	assert(priv && priv->ae_handle);
 
 	ops = priv->ae_handle->dev->ops;
 
@@ -1135,7 +1135,7 @@ static int hns_get_regs_len(struct net_device *net_dev)
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_ae_ops *ops;
 
-	assert(priv || priv->ae_handle);
+	assert(priv && priv->ae_handle);
 
 	ops = priv->ae_handle->dev->ops;
 	if (!ops->get_regs_len) {
-- 
2.1.4
