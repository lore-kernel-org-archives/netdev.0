From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 1/2] amd-xgbe: Properly handle feature changes via
 ethtool
Date: Wed, 22 Oct 2014 11:26:11 -0500
Message-ID: <20141022162611.31495.8598.stgit@tlendack-t1.amdoffice.net>
References: <20141022162605.31495.98889.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0142.outbound.protection.outlook.com ([157.56.111.142]:48033
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752801AbaJVQkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 12:40:45 -0400
In-Reply-To: <20141022162605.31495.98889.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ndo_set_features callback function was improperly using an unsigned
int to save the current feature value for features such as NETIF_F_RXCSUM.
Since that feature is in the upper 32 bits of a 64 bit variable the
result was always 0 making it not possible to actually turn off the
hardware RX checksum support.  Change the unsigned int type to the
netdev_features_t type in order to properly capture the current value
and perform the proper operation.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2955499..a480b23 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1465,7 +1465,7 @@ static int xgbe_set_features(struct net_device *netdev,
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	unsigned int rxcsum, rxvlan, rxvlan_filter;
+	netdev_features_t rxcsum, rxvlan, rxvlan_filter;
 
 	rxcsum = pdata->netdev_features & NETIF_F_RXCSUM;
 	rxvlan = pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_RX;
