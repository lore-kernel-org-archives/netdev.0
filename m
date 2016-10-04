From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 06/13] fsl/fman: return a phy_dev pointer from init
Date: Tue, 4 Oct 2016 10:32:52 +0300
Message-ID: <1475566379-5078-7-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
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
 drivers/net/ethernet/freescale/fman/mac.c | 22 +++++++++++-----------
 drivers/net/ethernet/freescale/fman/mac.h |  3 ++-
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index dc04e61..e4378c2 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -469,9 +469,9 @@ static void adjust_link_memac(struct net_device *net_dev)
 /* Initializes driver's PHY state, and attaches to the PHY.
  * Returns 0 on success.
  */
-static int init_phy(struct net_device *net_dev,
-		    struct mac_device *mac_dev,
-		    void (*adj_lnk)(struct net_device *))
+static struct phy_device *init_phy(struct net_device *net_dev,
+				   struct mac_device *mac_dev,
+				   void (*adj_lnk)(struct net_device *))
 {
 	struct phy_device	*phy_dev;
 	struct mac_priv_s	*priv = mac_dev->priv;
@@ -480,7 +480,7 @@ static int init_phy(struct net_device *net_dev,
 				 priv->phy_if);
 	if (!phy_dev) {
 		netdev_err(net_dev, "Could not connect to PHY\n");
-		return -ENODEV;
+		return NULL;
 	}
 
 	/* Remove any features not supported by the controller */
@@ -493,23 +493,23 @@ static int init_phy(struct net_device *net_dev,
 
 	mac_dev->phy_dev = phy_dev;
 
-	return 0;
+	return phy_dev;
 }
 
-static int dtsec_init_phy(struct net_device *net_dev,
-			  struct mac_device *mac_dev)
+static struct phy_device *dtsec_init_phy(struct net_device *net_dev,
+					 struct mac_device *mac_dev)
 {
 	return init_phy(net_dev, mac_dev, &adjust_link_dtsec);
 }
 
-static int tgec_init_phy(struct net_device *net_dev,
-			 struct mac_device *mac_dev)
+static struct phy_device *tgec_init_phy(struct net_device *net_dev,
+					struct mac_device *mac_dev)
 {
 	return init_phy(net_dev, mac_dev, adjust_link_void);
 }
 
-static int memac_init_phy(struct net_device *net_dev,
-			  struct mac_device *mac_dev)
+static struct phy_device *memac_init_phy(struct net_device *net_dev,
+					 struct mac_device *mac_dev)
 {
 	return init_phy(net_dev, mac_dev, &adjust_link_memac);
 }
diff --git a/drivers/net/ethernet/freescale/fman/mac.h b/drivers/net/ethernet/freescale/fman/mac.h
index 0211cc9..d7313f0 100644
--- a/drivers/net/ethernet/freescale/fman/mac.h
+++ b/drivers/net/ethernet/freescale/fman/mac.h
@@ -58,7 +58,8 @@ struct mac_device {
 	bool tx_pause_active;
 	bool promisc;
 
-	int (*init_phy)(struct net_device *net_dev, struct mac_device *mac_dev);
+	struct phy_device *(*init_phy)(struct net_device *net_dev,
+				       struct mac_device *mac_dev);
 	int (*init)(struct mac_device *mac_dev);
 	int (*start)(struct mac_device *mac_dev);
 	int (*stop)(struct mac_device *mac_dev);
-- 
2.1.0
