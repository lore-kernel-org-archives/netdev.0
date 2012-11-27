From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] net: ethernet: cpsw: fix build warnings for CPSW when CPTS not selected
Date: Tue, 27 Nov 2012 23:23:40 +0530
Message-ID: <1354038820-11095-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <richardcochran@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  CC      drivers/net/ethernet/ti/cpsw.o
drivers/net/ethernet/ti/cpsw.c: In function 'cpsw_ndo_ioctl':
drivers/net/ethernet/ti/cpsw.c:881:20: warning: unused variable 'priv'

The build warning is generated when CPTS is not selected in Kernel Build.
Fixing by passing the net_device pointer to cpts IOCTL instead of passing priv

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 02c2477..c9714e1 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -812,8 +812,9 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	__raw_writel(ETH_P_1588, &priv->regs->ts_ltype);
 }
 
-static int cpsw_hwtstamp_ioctl(struct cpsw_priv *priv, struct ifreq *ifr)
+static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 {
+	struct cpsw_priv *priv = netdev_priv(dev);
 	struct cpts *cpts = &priv->cpts;
 	struct hwtstamp_config cfg;
 
@@ -878,14 +879,12 @@ static int cpsw_hwtstamp_ioctl(struct cpsw_priv *priv, struct ifreq *ifr)
 
 static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	struct cpsw_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
 #ifdef CONFIG_TI_CPTS
 	if (cmd == SIOCSHWTSTAMP)
-		return cpsw_hwtstamp_ioctl(priv, req);
+		return cpsw_hwtstamp_ioctl(dev, req);
 #endif
 	return -ENOTSUPP;
 }
-- 
1.7.0.4

