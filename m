From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/6] net: hisilicon: constify ethtool_ops structures
Date: Wed, 31 Aug 2016 09:30:46 +0200
Message-ID: <1472628648-3603-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
        Salil Mehta <salil.mehta@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for ethtool_ops structures that are only stored in the ethtool_ops
field of a net_device structure or passed as the second argument to
netdev_set_default_ethtool_ops.  These contexts are declared const, so
ethtool_ops structures that have these properties can be declared as const
also.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct ethtool_ops i@p = { ... };

@ok1@
identifier r.i;
struct net_device e;
position p;
@@
e.ethtool_ops = &i@p;

@ok2@
identifier r.i;
expression e;
position p;
@@
netdev_set_default_ethtool_ops(e, &i@p)

@bad@
position p != {r.p,ok1.p,ok2.p};
identifier r.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct ethtool_ops i = { ... };
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/hisilicon/hip04_eth.c       |    2 +-
 drivers/net/ethernet/hisilicon/hisi_femac.c      |    2 +-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c    |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 0c4afe9..a90ab40 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -755,7 +755,7 @@ static void hip04_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
 }
 
-static struct ethtool_ops hip04_ethtool_ops = {
+static const struct ethtool_ops hip04_ethtool_ops = {
 	.get_coalesce		= hip04_get_coalesce,
 	.set_coalesce		= hip04_set_coalesce,
 	.get_drvinfo		= hip04_get_drvinfo,
diff --git a/drivers/net/ethernet/hisilicon/hisi_femac.c b/drivers/net/ethernet/hisilicon/hisi_femac.c
index b5d7ad0..ca68e22 100644
--- a/drivers/net/ethernet/hisilicon/hisi_femac.c
+++ b/drivers/net/ethernet/hisilicon/hisi_femac.c
@@ -699,7 +699,7 @@ static int hisi_femac_net_ioctl(struct net_device *dev,
 	return phy_mii_ioctl(dev->phydev, ifreq, cmd);
 }
 
-static struct ethtool_ops hisi_femac_ethtools_ops = {
+static const struct ethtool_ops hisi_femac_ethtools_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
 	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index 275618b..e69a6be 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -750,7 +750,7 @@ static const struct net_device_ops hix5hd2_netdev_ops = {
 	.ndo_set_mac_address	= hix5hd2_net_set_mac_address,
 };
 
-static struct ethtool_ops hix5hd2_ethtools_ops = {
+static const struct ethtool_ops hix5hd2_ethtools_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index ab33487..5eb3245 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1264,7 +1264,7 @@ static int hns_get_rxnfc(struct net_device *netdev,
 	return 0;
 }
 
-static struct ethtool_ops hns_ethtool_ops = {
+static const struct ethtool_ops hns_ethtool_ops = {
 	.get_drvinfo = hns_nic_get_drvinfo,
 	.get_link  = hns_nic_get_link,
 	.get_settings  = hns_nic_get_settings,
