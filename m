From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH] net: mv643xx_eth: fix build error
Date: Thu, 24 Nov 2011 11:47:18 +0800
Message-ID: <1322106438.16201.11.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix below build error:
  CC      drivers/net/ethernet/marvell/mv643xx_eth.o
drivers/net/ethernet/marvell/mv643xx_eth.c: In function 'mv643xx_eth_get_drvinfo':
drivers/net/ethernet/marvell/mv643xx_eth.c:1505: error: 'info' undeclared (first use in this function)
drivers/net/ethernet/marvell/mv643xx_eth.c:1505: error: (Each undeclared identifier is reported only once
drivers/net/ethernet/marvell/mv643xx_eth.c:1505: error: for each function it appears in.)
make[4]: *** [drivers/net/ethernet/marvell/mv643xx_eth.o] Error 1

Signed-off-by: Axel Lin <axel.lin@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 43e3e61..e87847e 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1502,11 +1502,12 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void mv643xx_eth_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *drvinfo)
 {
-	strlcpy(drvinfo->driver, mv643xx_eth_driver_name, sizeof(info->driver));
+	strlcpy(drvinfo->driver, mv643xx_eth_driver_name,
+		sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, mv643xx_eth_driver_version,
-		sizeof(info->version));
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(info->fw_version));
-	strlcpy(drvinfo->bus_info, "platform", sizeof(info->bus_info));
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = ARRAY_SIZE(mv643xx_eth_stats);
 }
 
-- 
1.7.5.4
