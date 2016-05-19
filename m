From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH v2 1/1] net: hns: avoid null pointer dereference
Date: Thu, 19 May 2016 21:20:55 +0200
Message-ID: <1463685655-3277-1-git-send-email-xypron.glpk@gmx.de>
References: <063D6719AE5E284EB5DD2968C1650D6D5F4C22D9@AcuExch.aculab.com>
Cc: David Laight <David.Laight@aculab.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>,
	Kejian Yan <yankejian@huawei.com>,
	Lisheng <lisheng011@huawei.com>, Andrew Lunn <andrew@lunn.ch>,
	Salil <salil.mehta@huawei.com>, Ivan Vecera <ivecera@redhat.com>,
	Chenny Xu <chenny.xu@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:62709 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752727AbcESTXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 15:23:41 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4C22D9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the statement
  assert(priv || priv->ae_handle);
the right side of || is only evaluated if priv is null.

v2:
	As suggested by David Leight and David Miller the assert
	statements are removed.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3d746c8..67a648c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -46,7 +46,6 @@ static u32 hns_nic_get_link(struct net_device *net_dev)
 	u32 link_stat = priv->link;
 	struct hnae_handle *h;
 
-	assert(priv && priv->ae_handle);
 	h = priv->ae_handle;
 
 	if (priv->phy) {
@@ -646,8 +645,6 @@ static void hns_nic_get_drvinfo(struct net_device *net_dev,
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 
-	assert(priv);
-
 	strncpy(drvinfo->version, HNAE_DRIVER_VERSION,
 		sizeof(drvinfo->version));
 	drvinfo->version[sizeof(drvinfo->version) - 1] = '\0';
@@ -720,8 +717,6 @@ static int hns_set_pauseparam(struct net_device *net_dev,
 	struct hnae_handle *h;
 	struct hnae_ae_ops *ops;
 
-	assert(priv || priv->ae_handle);
-
 	h = priv->ae_handle;
 	ops = h->dev->ops;
 
@@ -780,8 +775,6 @@ static int hns_set_coalesce(struct net_device *net_dev,
 	struct hnae_ae_ops *ops;
 	int ret;
 
-	assert(priv || priv->ae_handle);
-
 	ops = priv->ae_handle->dev->ops;
 
 	if (ec->tx_coalesce_usecs != ec->rx_coalesce_usecs)
@@ -1111,8 +1104,6 @@ void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_ae_ops *ops;
 
-	assert(priv || priv->ae_handle);
-
 	ops = priv->ae_handle->dev->ops;
 
 	cmd->version = HNS_CHIP_VERSION;
@@ -1135,8 +1126,6 @@ static int hns_get_regs_len(struct net_device *net_dev)
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_ae_ops *ops;
 
-	assert(priv || priv->ae_handle);
-
 	ops = priv->ae_handle->dev->ops;
 	if (!ops->get_regs_len) {
 		netdev_err(net_dev, "ops->get_regs_len is null!\n");
-- 
2.1.4
