From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 3/3] be2net: Bug fix to properly update ethtool
	tx-checksumming after ethtool -K <ifname> tx off
Date: Mon, 5 Oct 2009 17:52:19 +0530
Message-ID: <20091005122207.GA22935@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:62211 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753310AbZJEMWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 08:22:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a fix for a bug which was a result of wrong use of checksum offload flag.
The status of tx-checksumming was not changed from on to off
after a 'ethtool -K <ifname> tx off' operation.
Use the proper checksum offload flag NETIF_F_HW_CSUM instead of 
NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM.
Patch is against net-2.6 tree.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_ethtool.c |    2 +-
 drivers/net/benet/be_main.c    |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 11445df..cda5bf2 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -358,7 +358,7 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_rx_csum = be_get_rx_csum,
 	.set_rx_csum = be_set_rx_csum,
 	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_hw_csum,
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = ethtool_op_get_tso,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index e86b2f3..6d5e81f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1899,8 +1899,8 @@ static void be_netdev_init(struct net_device *netdev)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	netdev->features |= NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_GRO;
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_HW_CSUM |
+		NETIF_F_GRO;
 
 	netdev->flags |= IFF_MULTICAST;
 
-- 
1.6.0.4

