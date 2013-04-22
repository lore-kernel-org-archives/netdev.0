From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix vlan bitmask changes in EHEA driver.
Date: Mon, 22 Apr 2013 19:35:26 -0400 (EDT)
Message-ID: <20130422.193526.963629892294191139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810Ab3DVXf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 19:35:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This driver uses the crummy "| foo" style, putting the
logical operation at the beginning of lines.  Then
when the VLAN tag flag bits got changed the operator
ended up at both the end and the beginning of some lines.

Fix the build error by having it uniformly use the operator
at the end of the line.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 1901ceb..90ea0b1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3021,12 +3021,12 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev->netdev_ops = &ehea_netdev_ops;
 	ehea_set_ethtool_ops(dev);
 
-	dev->hw_features = NETIF_F_SG | NETIF_F_TSO
-		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_CTAG_TX;
-	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
-		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM |
-		      | NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
-		      | NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_RXCSUM;
+	dev->hw_features = NETIF_F_SG | NETIF_F_TSO |
+		      NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_CTAG_TX;
+	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO |
+		      NETIF_F_HIGHDMA | NETIF_F_IP_CSUM |
+		      NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
+		      NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_RXCSUM;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_HIGHDMA |
 			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
-- 
1.7.11.7
