From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] ethtool: provide default behavior for a few sub-ioctls
Date: Sun, 2 Sep 2007 07:17:22 -0400
Message-ID: <20070902111722.GA30359@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51322 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754282AbXIBLRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 07:17:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Just checked this in...



commit 2c0205e3480ac39f5b52b2220ff0c77141502936
Author: Jeff Garzik <jeff@garzik.org>
Date:   Sun Sep 2 07:13:36 2007 -0400

    [ETHTOOL] Provide default behaviors for a few ethtool sub-ioctls
    
    For the operations
    	get-tx-csum
    	get-sg
    	get-tso
    	get-ufo
    the default ethtool_op_xxx behavior is fine for all drivers, so we
    permit op==NULL to imply the default behavior.
    
    This provides a more uniform behavior across all drivers, eliminating
    ethtool(8) "ioctl not supported" errors on older drivers that had
    not been updated for the latest sub-ioctls.
    
    The ethtool_op_xxx() functions are left exported, in case anyone
    wishes to call them directly from a driver-private implementation --
    a not-uncommon case.  Should an ethtool_op_xxx() helper remain unused
    for a while, except by net/core/ethtool.c, we can un-export it at a
    later date.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 drivers/net/8139cp.c                    |    3 ---
 drivers/net/atl1/atl1_ethtool.c         |    3 ---
 drivers/net/bnx2.c                      |    3 ---
 drivers/net/bonding/bond_main.c         |    4 ----
 drivers/net/chelsio/cxgb2.c             |    3 ---
 drivers/net/cxgb3/cxgb3_main.c          |    3 ---
 drivers/net/e1000/e1000_ethtool.c       |    2 --
 drivers/net/ehea/ehea_ethtool.c         |    3 ---
 drivers/net/epic100.c                   |    2 --
 drivers/net/fealnx.c                    |    2 --
 drivers/net/fec_8xx/fec_main.c          |    2 --
 drivers/net/forcedeth.c                 |    3 ---
 drivers/net/fs_enet/fs_enet-main.c      |    2 --
 drivers/net/ibm_emac/ibm_emac_core.c    |    2 --
 drivers/net/ibmveth.c                   |    2 --
 drivers/net/ixgb/ixgb_ethtool.c         |    2 --
 drivers/net/loopback.c                  |    1 -
 drivers/net/macvlan.c                   |    4 ----
 drivers/net/mv643xx_eth.c               |    1 -
 drivers/net/myri10ge/myri10ge.c         |    3 ---
 drivers/net/ne2k-pci.c                  |    2 --
 drivers/net/netxen/netxen_nic_ethtool.c |    3 ---
 drivers/net/pcnet32.c                   |    3 ---
 drivers/net/r8169.c                     |    3 ---
 drivers/net/s2io.c                      |    3 ---
 drivers/net/sc92031.c                   |    4 ----
 drivers/net/skge.c                      |    2 --
 drivers/net/sky2.c                      |    3 ---
 drivers/net/spider_net_ethtool.c        |    1 -
 drivers/net/tg3.c                       |    3 ---
 drivers/net/tulip/de2104x.c             |    2 --
 drivers/net/tulip/winbond-840.c         |    2 --
 drivers/net/typhoon.c                   |    3 ---
 drivers/net/ucc_geth_ethtool.c          |    2 --
 drivers/net/via-rhine.c                 |    2 --
 drivers/net/xen-netfront.c              |    3 ---
 net/bridge/br_device.c                  |    3 ---
 net/core/ethtool.c                      |   32 +++++++++++++++++---------------
 38 files changed, 17 insertions(+), 109 deletions(-)

2c0205e3480ac39f5b52b2220ff0c77141502936
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a79f28c..9e674c9 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1567,11 +1567,8 @@ static const struct ethtool_ops cp_ethtool_ops = {
 	.set_msglevel		= cp_set_msglevel,
 	.get_rx_csum		= cp_get_rx_csum,
 	.set_rx_csum		= cp_set_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_csum, /* local! */
-	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= ethtool_op_set_tso,
 	.get_regs		= cp_get_regs,
 	.get_wol		= cp_get_wol,
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index 1f616c5..53353b6 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -489,15 +489,12 @@ const struct ethtool_ops atl1_ethtool_ops = {
 	.get_pauseparam		= atl1_get_pauseparam,
 	.set_pauseparam 	= atl1_set_pauseparam,
 	.get_rx_csum		= atl1_get_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_hw_csum,
 	.get_link		= ethtool_op_get_link,
-	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= atl1_get_strings,
 	.nway_reset		= atl1_nway_reset,
 	.get_ethtool_stats	= atl1_get_ethtool_stats,
 	.get_stats_count	= atl1_get_stats_count,
-	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= ethtool_op_set_tso,
 };
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 24e7f9a..87df593 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6257,11 +6257,8 @@ static const struct ethtool_ops bnx2_ethtool_ops = {
 	.set_pauseparam		= bnx2_set_pauseparam,
 	.get_rx_csum		= bnx2_get_rx_csum,
 	.set_rx_csum		= bnx2_set_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= bnx2_set_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= bnx2_set_tso,
 	.self_test_count	= bnx2_self_test_count,
 	.self_test		= bnx2_self_test,
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1afda32..c318e9d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4195,10 +4195,6 @@ static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
 }
 
 static const struct ethtool_ops bond_ethtool_ops = {
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.get_tso		= ethtool_op_get_tso,
-	.get_ufo		= ethtool_op_get_ufo,
-	.get_sg			= ethtool_op_get_sg,
 	.get_drvinfo		= bond_ethtool_get_drvinfo,
 };
 
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 231ce43..69b3d15 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -790,9 +790,7 @@ static const struct ethtool_ops t1_ethtool_ops = {
 	.set_pauseparam    = set_pauseparam,
 	.get_rx_csum       = get_rx_csum,
 	.set_rx_csum       = set_rx_csum,
-	.get_tx_csum       = ethtool_op_get_tx_csum,
 	.set_tx_csum       = ethtool_op_set_tx_csum,
-	.get_sg            = ethtool_op_get_sg,
 	.set_sg            = ethtool_op_set_sg,
 	.get_link          = ethtool_op_get_link,
 	.get_strings       = get_strings,
@@ -800,7 +798,6 @@ static const struct ethtool_ops t1_ethtool_ops = {
 	.get_ethtool_stats = get_stats,
 	.get_regs_len      = get_regs_len,
 	.get_regs          = get_regs,
-	.get_tso           = ethtool_op_get_tso,
 	.set_tso           = set_tso,
 };
 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index dc5d269..63a31b2 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1568,9 +1568,7 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
 	.set_pauseparam = set_pauseparam,
 	.get_rx_csum = get_rx_csum,
 	.set_rx_csum = set_rx_csum,
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_csum,
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_link = ethtool_op_get_link,
 	.get_strings = get_strings,
@@ -1581,7 +1579,6 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_regs_len = get_regs_len,
 	.get_regs = get_regs,
 	.get_wol = get_wol,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 };
 
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 4c3785c..fc07f05 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1965,9 +1965,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.set_rx_csum            = e1000_set_rx_csum,
 	.get_tx_csum            = e1000_get_tx_csum,
 	.set_tx_csum            = e1000_set_tx_csum,
-	.get_sg                 = ethtool_op_get_sg,
 	.set_sg                 = ethtool_op_set_sg,
-	.get_tso                = ethtool_op_get_tso,
 	.set_tso                = e1000_set_tso,
 	.self_test_count        = e1000_diag_test_count,
 	.self_test              = e1000_diag_test,
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index decec8c..fe9207a 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -247,9 +247,6 @@ const struct ethtool_ops ehea_ethtool_ops = {
 	.get_msglevel = ehea_get_msglevel,
 	.set_msglevel = ehea_set_msglevel,
 	.get_link = ethtool_op_get_link,
-	.get_tx_csum = ethtool_op_get_tx_csum,
-	.get_sg = ethtool_op_get_sg,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 	.get_strings = ehea_get_strings,
 	.get_stats_count = ehea_get_stats_count,
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 1197784..43dbf96 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1495,8 +1495,6 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
-	.get_sg			= ethtool_op_get_sg,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.begin			= ethtool_begin,
 	.complete		= ethtool_complete
 };
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index ff9f177..d52e2a0 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1892,8 +1892,6 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
-	.get_sg			= ethtool_op_get_sg,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 };
 
 static int mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
diff --git a/drivers/net/fec_8xx/fec_main.c b/drivers/net/fec_8xx/fec_main.c
index e5502af..d82e7d7 100644
--- a/drivers/net/fec_8xx/fec_main.c
+++ b/drivers/net/fec_8xx/fec_main.c
@@ -1042,9 +1042,7 @@ static const struct ethtool_ops fec_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 	.get_msglevel	= fec_get_msglevel,
 	.set_msglevel	= fec_set_msglevel,
-	.get_tx_csum	= ethtool_op_get_tx_csum,
 	.set_tx_csum	= ethtool_op_set_tx_csum,	/* local! */
-	.get_sg		= ethtool_op_get_sg,
 	.set_sg		= ethtool_op_set_sg,
 	.get_regs	= fec_get_regs,
 };
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1938d6d..7f248ab 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4707,7 +4707,6 @@ static const struct ethtool_ops ops = {
 	.get_regs_len = nv_get_regs_len,
 	.get_regs = nv_get_regs,
 	.nway_reset = nv_nway_reset,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = nv_set_tso,
 	.get_ringparam = nv_get_ringparam,
 	.set_ringparam = nv_set_ringparam,
@@ -4715,9 +4714,7 @@ static const struct ethtool_ops ops = {
 	.set_pauseparam = nv_set_pauseparam,
 	.get_rx_csum = nv_get_rx_csum,
 	.set_rx_csum = nv_set_rx_csum,
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = nv_set_tx_csum,
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = nv_set_sg,
 	.get_strings = nv_get_strings,
 	.get_stats_count = nv_get_stats_count,
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a4a2a0e..a5af728 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -915,9 +915,7 @@ static const struct ethtool_ops fs_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = fs_get_msglevel,
 	.set_msglevel = fs_set_msglevel,
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_csum,	/* local! */
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_regs = fs_get_regs,
 };
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index f752e5f..bd7ac43 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -1900,8 +1900,6 @@ static const struct ethtool_ops emac_ethtool_ops = {
 	.get_ethtool_stats = emac_ethtool_get_ethtool_stats,
 
 	.get_link = ethtool_op_get_link,
-	.get_tx_csum = ethtool_op_get_tx_csum,
-	.get_sg = ethtool_op_get_sg,
 };
 
 static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index acba90f..4f641d6 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -638,8 +638,6 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_settings		= netdev_get_settings,
 	.get_link		= netdev_get_link,
-	.get_sg			= ethtool_op_get_sg,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 };
 
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 0413cd9..4432acc 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -714,11 +714,9 @@ static const struct ethtool_ops ixgb_ethtool_ops = {
 	.set_rx_csum = ixgb_set_rx_csum,
 	.get_tx_csum = ixgb_get_tx_csum,
 	.set_tx_csum = ixgb_set_tx_csum,
-	.get_sg	= ethtool_op_get_sg,
 	.set_sg	= ethtool_op_set_sg,
 	.get_msglevel = ixgb_get_msglevel,
 	.set_msglevel = ixgb_set_msglevel,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = ixgb_set_tso,
 	.get_strings = ixgb_get_strings,
 	.phys_id = ixgb_phys_id,
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 5106c23..ee38515 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -192,7 +192,6 @@ static u32 always_on(struct net_device *dev)
 
 static const struct ethtool_ops loopback_ethtool_ops = {
 	.get_link		= always_on,
-	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= ethtool_op_set_tso,
 	.get_tx_csum		= always_on,
 	.get_sg			= always_on,
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index dc74d00..75c7799 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -282,10 +282,6 @@ static u32 macvlan_ethtool_get_rx_csum(struct net_device *dev)
 static const struct ethtool_ops macvlan_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_rx_csum		= macvlan_ethtool_get_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.get_tso		= ethtool_op_get_tso,
-	.get_ufo		= ethtool_op_get_ufo,
-	.get_sg			= ethtool_op_get_sg,
 	.get_drvinfo		= macvlan_ethtool_get_drvinfo,
 };
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..7a17487 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2763,7 +2763,6 @@ static const struct ethtool_ops mv643xx_ethtool_ops = {
 	.set_settings           = mv643xx_set_settings,
 	.get_drvinfo            = mv643xx_get_drvinfo,
 	.get_link               = mv643xx_eth_get_link,
-	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_stats_count        = mv643xx_get_stats_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 1c42266..ac5a6dd 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1469,11 +1469,8 @@ static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.get_ringparam = myri10ge_get_ringparam,
 	.get_rx_csum = myri10ge_get_rx_csum,
 	.set_rx_csum = myri10ge_set_rx_csum,
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_hw_csum,
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 	.get_link = ethtool_op_get_link,
 	.get_strings = myri10ge_get_strings,
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index f81d939..e8c1ebb 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -636,8 +636,6 @@ static void ne2k_pci_get_drvinfo(struct net_device *dev,
 
 static const struct ethtool_ops ne2k_pci_ethtool_ops = {
 	.get_drvinfo		= ne2k_pci_get_drvinfo,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
 };
 
 static void __devexit ne2k_pci_remove_one (struct pci_dev *pdev)
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index a6138b4..08c76b3 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -744,11 +744,8 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_ringparam = netxen_nic_get_ringparam,
 	.get_pauseparam = netxen_nic_get_pauseparam,
 	.set_pauseparam = netxen_nic_set_pauseparam,
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_csum,
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 	.self_test_count = netxen_nic_diag_test_count,
 	.self_test = netxen_nic_diag_test,
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index e6a6753..a3cc1dc 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1506,9 +1506,6 @@ static const struct ethtool_ops pcnet32_ethtool_ops = {
 	.get_link		= pcnet32_get_link,
 	.get_ringparam		= pcnet32_get_ringparam,
 	.set_ringparam		= pcnet32_set_ringparam,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
-	.get_tso		= ethtool_op_get_tso,
 	.get_strings		= pcnet32_get_strings,
 	.self_test_count	= pcnet32_self_test_count,
 	.self_test		= pcnet32_ethtool_test,
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b85ab4a..4f8c831 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1060,11 +1060,8 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.set_msglevel		= rtl8169_set_msglevel,
 	.get_rx_csum		= rtl8169_get_rx_csum,
 	.set_rx_csum		= rtl8169_set_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= ethtool_op_set_tso,
 	.get_regs		= rtl8169_get_regs,
 	.get_wol		= rtl8169_get_wol,
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 24feb00..b9394ca 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5936,13 +5936,10 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.set_pauseparam = s2io_ethtool_setpause_data,
 	.get_rx_csum = s2io_ethtool_get_rx_csum,
 	.set_rx_csum = s2io_ethtool_set_rx_csum,
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = s2io_ethtool_op_set_tx_csum,
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = s2io_ethtool_op_get_tso,
 	.set_tso = s2io_ethtool_op_set_tso,
-	.get_ufo = ethtool_op_get_ufo,
 	.set_ufo = ethtool_op_set_ufo,
 	.self_test_count = s2io_ethtool_self_test_count,
 	.self_test = s2io_ethtool_test,
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 872cb1c..02c472e 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1396,13 +1396,9 @@ static struct ethtool_ops sc92031_ethtool_ops = {
 	.set_wol		= sc92031_ethtool_set_wol,
 	.nway_reset		= sc92031_ethtool_nway_reset,
 	.get_link		= ethtool_op_get_link,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
-	.get_tso		= ethtool_op_get_tso,
 	.get_strings		= sc92031_ethtool_get_strings,
 	.get_stats_count	= sc92031_ethtool_get_stats_count,
 	.get_ethtool_stats	= sc92031_ethtool_get_ethtool_stats,
-	.get_ufo		= ethtool_op_get_ufo,
 };
 
 static int __devinit sc92031_probe(struct pci_dev *pdev,
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index e3d8520..9e41be6 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -811,9 +811,7 @@ static const struct ethtool_ops skge_ethtool_ops = {
 	.set_pauseparam = skge_set_pauseparam,
 	.get_coalesce	= skge_get_coalesce,
 	.set_coalesce	= skge_set_coalesce,
-	.get_sg		= ethtool_op_get_sg,
 	.set_sg		= skge_set_sg,
-	.get_tx_csum	= ethtool_op_get_tx_csum,
 	.set_tx_csum	= skge_set_tx_csum,
 	.get_rx_csum	= skge_get_rx_csum,
 	.set_rx_csum	= skge_set_rx_csum,
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index e6d937e..e0aaffd 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3534,11 +3534,8 @@ static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_eeprom_len	= sky2_get_eeprom_len,
 	.get_eeprom	= sky2_get_eeprom,
 	.set_eeprom	= sky2_set_eeprom,
-	.get_sg 	= ethtool_op_get_sg,
 	.set_sg 	= ethtool_op_set_sg,
-	.get_tx_csum	= ethtool_op_get_tx_csum,
 	.set_tx_csum	= sky2_set_tx_csum,
-	.get_tso	= ethtool_op_get_tso,
 	.set_tso	= sky2_set_tso,
 	.get_rx_csum	= sky2_get_rx_csum,
 	.set_rx_csum	= sky2_set_rx_csum,
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_ethtool.c
index d940474..1460d50 100644
--- a/drivers/net/spider_net_ethtool.c
+++ b/drivers/net/spider_net_ethtool.c
@@ -188,7 +188,6 @@ const struct ethtool_ops spider_net_ethtool_ops = {
 	.nway_reset		= spider_net_ethtool_nway_reset,
 	.get_rx_csum		= spider_net_ethtool_get_rx_csum,
 	.set_rx_csum		= spider_net_ethtool_set_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_ringparam          = spider_net_ethtool_get_ringparam,
 	.get_strings		= spider_net_get_strings,
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5874042..2b32643 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9280,11 +9280,8 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_pauseparam		= tg3_set_pauseparam,
 	.get_rx_csum		= tg3_get_rx_csum,
 	.set_rx_csum		= tg3_set_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= tg3_set_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= tg3_set_tso,
 	.self_test_count	= tg3_get_test_count,
 	.self_test		= tg3_self_test,
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index d380e0b..8e8ec2d 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1670,8 +1670,6 @@ static void de_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 
 static const struct ethtool_ops de_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
 	.get_drvinfo		= de_get_drvinfo,
 	.get_regs_len		= de_get_regs_len,
 	.get_settings		= de_get_settings,
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 5824f6a..abcf51c 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1452,8 +1452,6 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
-	.get_sg			= ethtool_op_get_sg,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 0358720..0dd2187 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1235,11 +1235,8 @@ static const struct ethtool_ops typhoon_ethtool_ops = {
 	.set_wol		= typhoon_set_wol,
 	.get_link		= ethtool_op_get_link,
 	.get_rx_csum		= typhoon_get_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= ethtool_op_set_tso,
 	.get_ringparam		= typhoon_get_ringparam,
 };
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 64bef7c..73aa677 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -373,9 +373,7 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.set_ringparam          = uec_set_ringparam,
 	.get_pauseparam         = uec_get_pauseparam,
 	.set_pauseparam         = uec_set_pauseparam,
-	.get_sg                 = ethtool_op_get_sg,
 	.set_sg                 = ethtool_op_set_sg,
-	.get_tso                = ethtool_op_get_tso,
 	.get_stats_count        = uec_get_stats_count,
 	.get_strings            = uec_get_strings,
 	.get_ethtool_stats      = uec_get_ethtool_stats,
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index b56dff2..abdb1f2 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1809,8 +1809,6 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.set_msglevel		= netdev_set_msglevel,
 	.get_wol		= rhine_get_wol,
 	.set_wol		= rhine_set_wol,
-	.get_sg			= ethtool_op_get_sg,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 4445810..c704c00 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1661,11 +1661,8 @@ static void backend_changed(struct xenbus_device *dev,
 
 static struct ethtool_ops xennet_ethtool_ops =
 {
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_csum,
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = xennet_set_sg,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = xennet_set_tso,
 	.get_link = ethtool_op_get_link,
 };
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 0eded17..446cd50 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -150,11 +150,8 @@ static int br_set_tx_csum(struct net_device *dev, u32 data)
 static struct ethtool_ops br_ethtool_ops = {
 	.get_drvinfo = br_getinfo,
 	.get_link = ethtool_op_get_link,
-	.get_sg = ethtool_op_get_sg,
 	.set_sg = br_set_sg,
-	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = br_set_tx_csum,
-	.get_tso = ethtool_op_get_tso,
 	.set_tso = br_set_tso,
 };
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c5e0593..747df44 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -479,10 +479,10 @@ static int ethtool_get_tx_csum(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata = { ETHTOOL_GTXCSUM };
 
-	if (!dev->ethtool_ops->get_tx_csum)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_tx_csum(dev);
+	if (dev->ethtool_ops->get_tx_csum)
+		edata.data = dev->ethtool_ops->get_tx_csum(dev);
+	else
+		edata.data = ethtool_op_get_tx_csum(dev);
 
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
@@ -531,10 +531,10 @@ static int ethtool_get_sg(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata = { ETHTOOL_GSG };
 
-	if (!dev->ethtool_ops->get_sg)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_sg(dev);
+	if (dev->ethtool_ops->get_sg)
+		edata.data = dev->ethtool_ops->get_sg(dev);
+	else
+		edata.data = ethtool_op_get_sg(dev);
 
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
@@ -562,10 +562,10 @@ static int ethtool_get_tso(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata = { ETHTOOL_GTSO };
 
-	if (!dev->ethtool_ops->get_tso)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_tso(dev);
+	if (dev->ethtool_ops->get_tso)
+		edata.data = dev->ethtool_ops->get_tso(dev);
+	else
+		edata.data = ethtool_op_get_tso(dev);
 
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
@@ -592,9 +592,11 @@ static int ethtool_get_ufo(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata = { ETHTOOL_GUFO };
 
-	if (!dev->ethtool_ops->get_ufo)
-		return -EOPNOTSUPP;
-	edata.data = dev->ethtool_ops->get_ufo(dev);
+	if (dev->ethtool_ops->get_ufo)
+		edata.data = dev->ethtool_ops->get_ufo(dev);
+	else
+		edata.data = ethtool_op_get_ufo(dev);
+
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		 return -EFAULT;
 	return 0;
