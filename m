From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] make ethtool_ops const
Date: Wed, 4 Jan 2012 14:59:49 -0800
Message-ID: <20120104145949.53ab334c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37721 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163Ab2ADW7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 17:59:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auditing all usage of ethtool_ops found several drivers that
are not declaring the struct const when it should be.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c  |    2 +-
 drivers/net/ethernet/freescale/fec.c                 |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c                |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c                |    6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c	2011-12-21 12:02:09.798014054 -0800
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c	2012-01-04 14:55:33.138038881 -0800
@@ -1963,7 +1963,7 @@ static int get_rxnfc(struct net_device *
 	return -EOPNOTSUPP;
 }
 
-static struct ethtool_ops cxgb_ethtool_ops = {
+static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_settings      = get_settings,
 	.set_settings      = set_settings,
 	.get_drvinfo       = get_drvinfo,
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c	2011-12-07 10:54:18.740278550 -0800
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c	2012-01-04 14:55:27.621984500 -0800
@@ -1564,7 +1564,7 @@ static void cxgb4vf_get_wol(struct net_d
  */
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 
-static struct ethtool_ops cxgb4vf_ethtool_ops = {
+static const struct ethtool_ops cxgb4vf_ethtool_ops = {
 	.get_settings		= cxgb4vf_get_settings,
 	.get_drvinfo		= cxgb4vf_get_drvinfo,
 	.get_msglevel		= cxgb4vf_get_msglevel,
--- a/drivers/net/ethernet/freescale/fec.c	2011-12-29 08:22:17.309622186 -0800
+++ b/drivers/net/ethernet/freescale/fec.c	2012-01-04 14:55:13.673846895 -0800
@@ -1152,7 +1152,7 @@ static void fec_enet_get_drvinfo(struct
 	strcpy(info->bus_info, dev_name(&ndev->dev));
 }
 
-static struct ethtool_ops fec_enet_ethtool_ops = {
+static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
--- a/drivers/net/ethernet/micrel/ksz884x.c	2011-12-07 10:54:18.828279254 -0800
+++ b/drivers/net/ethernet/micrel/ksz884x.c	2012-01-04 14:55:04.177753135 -0800
@@ -6607,7 +6607,7 @@ static int netdev_set_features(struct ne
 	return 0;
 }
 
-static struct ethtool_ops netdev_ethtool_ops = {
+static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_settings		= netdev_get_settings,
 	.set_settings		= netdev_set_settings,
 	.nway_reset		= netdev_nway_reset,
--- a/drivers/net/ethernet/renesas/sh_eth.c	2011-12-07 10:54:18.864279544 -0800
+++ b/drivers/net/ethernet/renesas/sh_eth.c	2012-01-04 14:54:45.785571357 -0800
@@ -1369,13 +1369,13 @@ static void sh_eth_get_strings(struct ne
 	}
 }
 
-static struct ethtool_ops sh_eth_ethtool_ops = {
+static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.get_settings	= sh_eth_get_settings,
 	.set_settings	= sh_eth_set_settings,
-	.nway_reset		= sh_eth_nway_reset,
+	.nway_reset	= sh_eth_nway_reset,
 	.get_msglevel	= sh_eth_get_msglevel,
 	.set_msglevel	= sh_eth_set_msglevel,
-	.get_link		= ethtool_op_get_link,
+	.get_link	= ethtool_op_get_link,
 	.get_strings	= sh_eth_get_strings,
 	.get_ethtool_stats  = sh_eth_get_ethtool_stats,
 	.get_sset_count     = sh_eth_get_sset_count,
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c	2011-12-07 10:54:18.884279704 -0800
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c	2012-01-04 14:54:22.025336167 -0800
@@ -459,7 +459,7 @@ static int stmmac_set_wol(struct net_dev
 	return 0;
 }
 
-static struct ethtool_ops stmmac_ethtool_ops = {
+static const struct ethtool_ops stmmac_ethtool_ops = {
 	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
 	.get_settings = stmmac_ethtool_getsettings,
