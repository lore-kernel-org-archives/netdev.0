From: John Rigby <jrigby@freescale.com>
Subject: [PATCH 1/2][Rev4] fs_enet: change fec_t to struct fec
Date: Wed, 18 Jun 2008 09:15:53 -0600
Message-ID: <1213802154-28968-2-git-send-email-jrigby@freescale.com>
References: <1213802154-28968-1-git-send-email-jrigby@freescale.com>
Cc: netdev@vger.kernel.org, John Rigby <jrigby@freescale.com>
To: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:35029 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbYFRPwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 11:52:19 -0400
In-Reply-To: <1213802154-28968-1-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation of adding support for
MPC5121 FEC.  The 5121 patch needs to add a different
struct fec because it has a different register layout.

This patch allows the 5121 patch to not include a typedef
fec_t which checkpatch complains about.

Signed-off-by: John Rigby <jrigby@freescale.com>
---
 drivers/net/fs_enet/mac-fec.c |   30 +++++++++++++++---------------
 drivers/net/fs_enet/mii-fec.c |    8 ++++----
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 8a311d1..053b360 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -83,7 +83,7 @@
  */
 #define FEC_RESET_DELAY		50
 
-static int whack_reset(fec_t __iomem *fecp)
+static int whack_reset(struct fec __iomem *fecp)
 {
 	int i;
 
@@ -189,7 +189,7 @@ static void cleanup_data(struct net_device *dev)
 static void set_promiscuous_mode(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, r_cntrl, FEC_RCNTRL_PROM);
 }
@@ -237,7 +237,7 @@ static void set_multicast_one(struct net_device *dev, const u8 *mac)
 static void set_multicast_finish(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
@@ -271,7 +271,7 @@ static void restart(struct net_device *dev)
 	u32 cptr;
 #endif
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 	const struct fs_platform_info *fpi = fep->fpi;
 	dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
 	int r;
@@ -399,7 +399,7 @@ static void stop(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	struct fec_info* feci= fep->phydev->bus->priv;
 
@@ -461,7 +461,7 @@ static void post_free_irq(struct net_device *dev, int irq)
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -469,7 +469,7 @@ static void napi_clear_rx_event(struct net_device *dev)
 static void napi_enable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -477,7 +477,7 @@ static void napi_enable_rx(struct net_device *dev)
 static void napi_disable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FC(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -485,7 +485,7 @@ static void napi_disable_rx(struct net_device *dev)
 static void rx_bd_done(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, r_des_active, 0x01000000);
 }
@@ -493,7 +493,7 @@ static void rx_bd_done(struct net_device *dev)
 static void tx_kickstart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, x_des_active, 0x01000000);
 }
@@ -501,7 +501,7 @@ static void tx_kickstart(struct net_device *dev)
 static u32 get_int_events(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	return FR(fecp, ievent) & FR(fecp, imask);
 }
@@ -509,7 +509,7 @@ static u32 get_int_events(struct net_device *dev)
 static void clear_int_events(struct net_device *dev, u32 int_events)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, int_events);
 }
@@ -524,17 +524,17 @@ static int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-	if (*sizep < sizeof(fec_t))
+	if (*sizep < sizeof(struct fec))
 		return -EINVAL;
 
-	memcpy_fromio(p, fep->fec.fecp, sizeof(fec_t));
+	memcpy_fromio(p, fep->fec.fecp, sizeof(struct fec));
 
 	return 0;
 }
 
 static int get_regs_len(struct net_device *dev)
 {
-	return sizeof(fec_t);
+	return sizeof(struct fec);
 }
 
 static void tx_restart(struct net_device *dev)
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index f0014cf..83fe5e9 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -70,7 +70,7 @@ static int match_has_phy (struct device *dev, void* data)
 static int fs_mii_fec_init(struct fec_info* fec, struct fs_mii_fec_platform_info *fmpi)
 {
 	struct resource *r;
-	fec_t __iomem *fecp;
+	struct fec __iomem *fecp;
 	char* name = "fsl-cpm-fec";
 
 	/* we need fec in order to be useful */
@@ -85,7 +85,7 @@ static int fs_mii_fec_init(struct fec_info* fec, struct fs_mii_fec_platform_info
 
 	r = platform_get_resource_byname(fec_pdev, IORESOURCE_MEM, "regs");
 
-	fec->fecp = fecp = ioremap(r->start,sizeof(fec_t));
+	fec->fecp = fecp = ioremap(r->start,sizeof(struct fec));
 	fec->mii_speed = fmpi->mii_speed;
 
 	setbits32(&fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
@@ -100,7 +100,7 @@ static int fs_mii_fec_init(struct fec_info* fec, struct fs_mii_fec_platform_info
 static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
+	struct fec __iomem *fecp = fec->fecp;
 	int i, ret = -1;
 
 	if ((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0)
@@ -124,7 +124,7 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
+	struct fec __iomem *fecp = fec->fecp;
 	int i;
 
 	/* this must never happen */
-- 
1.5.6.rc0.46.gd2b3

