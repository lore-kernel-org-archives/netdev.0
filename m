From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 1/2] dpaa_eth: cleanup after init_phy() failure
Date: Wed, 4 Jan 2017 13:21:29 +0200
Message-ID: <1483528890-8621-2-git-send-email-madalin.bucur@nxp.com>
References: <1483528890-8621-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
 linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1483528890-8621-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 624ba90..77517aa 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2291,7 +2291,8 @@ static int dpaa_open(struct net_device *net_dev)
 	net_dev->phydev = mac_dev->init_phy(net_dev, priv->mac_dev);
 	if (!net_dev->phydev) {
 		netif_err(priv, ifup, net_dev, "init_phy() failed\n");
-		return -ENODEV;
+		err = -ENODEV;
+		goto phy_init_failed;
 	}
 
 	for (i = 0; i < ARRAY_SIZE(mac_dev->port); i++) {
@@ -2314,6 +2315,7 @@ static int dpaa_open(struct net_device *net_dev)
 	for (i = 0; i < ARRAY_SIZE(mac_dev->port); i++)
 		fman_port_disable(mac_dev->port[i]);
 
+phy_init_failed:
 	dpaa_eth_napi_disable(priv);
 
 	return err;
-- 
2.1.0
