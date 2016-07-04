From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] lpc_eth: remove unused variable
Date: Mon,  4 Jul 2016 15:19:41 +0200
Message-ID: <20160704132018.1130907-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Vladimir Zapolskiy <vz@mleia.com>,
	Sylvain Lemieux <slemieux.tyco@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Philippe Reynes <tremyfr@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:56956 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbcGDNRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:17:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A cleanup patch removed the only user of a local variable, as
indicated by a gcc warning.

drivers/net/ethernet/nxp/lpc_eth.c: In function 'lpc_eth_ioctl':
drivers/net/ethernet/nxp/lpc_eth.c:1183:24: error: unused variable 'pldat' [-Werror=unused-variable]

This removes the variable as well.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f786f3564c4f ("net: ethernet: lpc_eth: use phydev from struct net_device")
---
 drivers/net/ethernet/nxp/lpc_eth.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index ad5464fa8ac7..660d113f8b9a 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1180,7 +1180,6 @@ static void lpc_eth_set_multicast_list(struct net_device *ndev)
 
 static int lpc_eth_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
 {
-	struct netdata_local *pldat = netdev_priv(ndev);
 	struct phy_device *phydev = ndev->phydev;
 
 	if (!netif_running(ndev))
-- 
2.9.0
