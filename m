From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 203/493] net: remove use of __devinit
Date: Mon, 19 Nov 2012 13:22:32 -0500
Message-ID: <1353349642-3677-203-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, xen-devel@lists.xensource.com,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	virtualization@lists.linux-foundation.org, linux-hippi@sunsite.dk,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Francois Romieu <romieu@fr.zoreil.com>, Krzysztof Halasa <khc@pm.waw.pl>
To: gregkh@linuxfoundation.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: "Maciej W. Rozycki" <macro@linux-mips.org> 
Cc: Jes Sorensen <jes@trained-monkey.org> 
Cc: Shreyas Bhatewara <sbhatewara@vmware.com> 
Cc: "VMware, Inc." <pv-drivers@vmware.com> 
Cc: Francois Romieu <romieu@fr.zoreil.com> 
Cc: Krzysztof Halasa <khc@pm.waw.pl> 
Cc: netdev@vger.kernel.org 
Cc: linux-hippi@sunsite.dk 
Cc: xen-devel@lists.xensource.com 
Cc: virtualization@lists.linux-foundation.org 
---
 drivers/net/arcnet/com20020-pci.c  |  2 +-
 drivers/net/fddi/defxx.c           | 18 +++++++++---------
 drivers/net/hippi/rrunner.c        |  4 ++--
 drivers/net/ieee802154/at86rf230.c |  2 +-
 drivers/net/ieee802154/fakehard.c  |  2 +-
 drivers/net/ieee802154/fakelb.c    |  2 +-
 drivers/net/ieee802154/mrf24j40.c  |  2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c  |  2 +-
 drivers/net/wan/dscc4.c            |  2 +-
 drivers/net/wan/farsync.c          |  4 ++--
 drivers/net/wan/hd64570.c          |  4 ++--
 drivers/net/wan/hd64572.c          |  4 ++--
 drivers/net/wan/ixp4xx_hss.c       |  2 +-
 drivers/net/wan/lmc/lmc_main.c     |  2 +-
 drivers/net/wan/pc300too.c         |  2 +-
 drivers/net/wan/pci200syn.c        |  2 +-
 drivers/net/wan/wanxl.c            |  2 +-
 drivers/net/xen-netfront.c         |  4 ++--
 18 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index dcedba8..e80f04b 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -61,7 +61,7 @@ module_param(clockp, int, 0);
 module_param(clockm, int, 0);
 MODULE_LICENSE("GPL");
 
-static int __devinit com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
 	struct arcnet_local *lp;
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 538f8bb..13f42cc 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -515,7 +515,7 @@ static const struct net_device_ops dfx_netdev_ops = {
  *   initialized and the board resources are read and stored in
  *   the device structure.
  */
-static int __devinit dfx_register(struct device *bdev)
+static int dfx_register(struct device *bdev)
 {
 	static int version_disp;
 	int dfx_bus_pci = DFX_BUS_PCI(bdev);
@@ -663,7 +663,7 @@ err_out:
  *   enabled yet.
  */
 
-static void __devinit dfx_bus_init(struct net_device *dev)
+static void dfx_bus_init(struct net_device *dev)
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
@@ -866,7 +866,7 @@ static void __devexit dfx_bus_uninit(struct net_device *dev)
  *   None
  */
 
-static void __devinit dfx_bus_config_check(DFX_board_t *bp)
+static void dfx_bus_config_check(DFX_board_t *bp)
 {
 	struct device __maybe_unused *bdev = bp->bus_dev;
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
@@ -962,7 +962,7 @@ static void __devinit dfx_bus_config_check(DFX_board_t *bp)
  *   returning from this routine.
  */
 
-static int __devinit dfx_driver_init(struct net_device *dev,
+static int dfx_driver_init(struct net_device *dev,
 				     const char *print_name,
 				     resource_size_t bar_start)
 {
@@ -3619,11 +3619,11 @@ static void __devexit dfx_unregister(struct device *bdev)
 }
 
 
-static int __devinit __maybe_unused dfx_dev_register(struct device *);
+static int __maybe_unused dfx_dev_register(struct device *);
 static int __devexit __maybe_unused dfx_dev_unregister(struct device *);
 
 #ifdef CONFIG_PCI
-static int __devinit dfx_pci_register(struct pci_dev *,
+static int dfx_pci_register(struct pci_dev *,
 				      const struct pci_device_id *);
 static void __devexit dfx_pci_unregister(struct pci_dev *);
 
@@ -3640,7 +3640,7 @@ static struct pci_driver dfx_pci_driver = {
 	.remove		= dfx_pci_unregister,
 };
 
-static __devinit int dfx_pci_register(struct pci_dev *pdev,
+static int dfx_pci_register(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
 	return dfx_register(&pdev->dev);
@@ -3694,7 +3694,7 @@ static struct tc_driver dfx_tc_driver = {
 };
 #endif /* CONFIG_TC */
 
-static int __devinit __maybe_unused dfx_dev_register(struct device *dev)
+static int __maybe_unused dfx_dev_register(struct device *dev)
 {
 	int status;
 
@@ -3712,7 +3712,7 @@ static int __devexit __maybe_unused dfx_dev_unregister(struct device *dev)
 }
 
 
-static int __devinit dfx_init(void)
+static int dfx_init(void)
 {
 	int status;
 
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 4802b46..164d845 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -88,7 +88,7 @@ static const struct net_device_ops rr_netdev_ops = {
  * stack will need to know about I/O vectors or something similar.
  */
 
-static int __devinit rr_init_one(struct pci_dev *pdev,
+static int rr_init_one(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	struct net_device *dev;
@@ -503,7 +503,7 @@ static unsigned int write_eeprom(struct rr_private *rrpriv,
 }
 
 
-static int __devinit rr_init(struct net_device *dev)
+static int rr_init(struct net_device *dev)
 {
 	struct rr_private *rrpriv;
 	struct rr_regs __iomem *regs;
diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index cbb08de..1198c6b 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -778,7 +778,7 @@ static int at86rf230_fill_data(struct spi_device *spi)
 	return 0;
 }
 
-static int __devinit at86rf230_probe(struct spi_device *spi)
+static int at86rf230_probe(struct spi_device *spi)
 {
 	struct ieee802154_dev *dev;
 	struct at86rf230_local *lp;
diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 8c719e0..fd0438c 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -354,7 +354,7 @@ static void ieee802154_fake_setup(struct net_device *dev)
 }
 
 
-static int __devinit ieee802154fake_probe(struct platform_device *pdev)
+static int ieee802154fake_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct fakehard_priv *priv;
diff --git a/drivers/net/ieee802154/fakelb.c b/drivers/net/ieee802154/fakelb.c
index 2d2e027..e4b0e38 100644
--- a/drivers/net/ieee802154/fakelb.c
+++ b/drivers/net/ieee802154/fakelb.c
@@ -221,7 +221,7 @@ static void fakelb_del(struct fakelb_dev_priv *priv)
 	ieee802154_free_device(priv->dev);
 }
 
-static int __devinit fakelb_probe(struct platform_device *pdev)
+static int fakelb_probe(struct platform_device *pdev)
 {
 	struct fakelb_priv *priv;
 	struct fakelb_dev_priv *dp;
diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 90b5467..ef41051 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -618,7 +618,7 @@ out:
 	enable_irq(devrec->spi->irq);
 }
 
-static int __devinit mrf24j40_probe(struct spi_device *spi)
+static int mrf24j40_probe(struct spi_device *spi)
 {
 	int ret = -ENOMEM;
 	u8 val;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index aa1bde8..ac322e5 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2885,7 +2885,7 @@ vmxnet3_reset_work(struct work_struct *data)
 }
 
 
-static int __devinit
+static int
 vmxnet3_probe_device(struct pci_dev *pdev,
 		     const struct pci_device_id *id)
 {
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 2eddbbf..863df17 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -707,7 +707,7 @@ static void dscc4_free1(struct pci_dev *pdev)
 	kfree(ppriv);
 }
 
-static int __devinit dscc4_init_one(struct pci_dev *pdev,
+static int dscc4_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	struct dscc4_pci_priv *priv;
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 0397544..dc529aa 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2371,7 +2371,7 @@ static char *type_strings[] __devinitdata = {
 	"FarSync TE1"
 };
 
-static void __devinit
+static void
 fst_init_card(struct fst_card_info *card)
 {
 	int i;
@@ -2415,7 +2415,7 @@ static const struct net_device_ops fst_ops = {
  *      Initialise card when detected.
  *      Returns 0 to indicate success, or errno otherwise.
  */
-static int __devinit
+static int
 fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int no_of_cards_added = 0;
diff --git a/drivers/net/wan/hd64570.c b/drivers/net/wan/hd64570.c
index cf49033..c6e1a4b 100644
--- a/drivers/net/wan/hd64570.c
+++ b/drivers/net/wan/hd64570.c
@@ -676,7 +676,7 @@ static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 
 
 #ifdef NEED_DETECT_RAM
-static u32 __devinit sca_detect_ram(card_t *card, u8 __iomem *rambase,
+static u32 sca_detect_ram(card_t *card, u8 __iomem *rambase,
 				    u32 ramsize)
 {
 	/* Round RAM size to 32 bits, fill from end to start */
@@ -705,7 +705,7 @@ static u32 __devinit sca_detect_ram(card_t *card, u8 __iomem *rambase,
 #endif /* NEED_DETECT_RAM */
 
 
-static void __devinit sca_init(card_t *card, int wait_states)
+static void sca_init(card_t *card, int wait_states)
 {
 	sca_out(wait_states, WCRL, card); /* Wait Control */
 	sca_out(wait_states, WCRM, card);
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index e2779fa..f1685d9 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -605,7 +605,7 @@ static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-static u32 __devinit sca_detect_ram(card_t *card, u8 __iomem *rambase,
+static u32 sca_detect_ram(card_t *card, u8 __iomem *rambase,
 				    u32 ramsize)
 {
 	/* Round RAM size to 32 bits, fill from end to start */
@@ -625,7 +625,7 @@ static u32 __devinit sca_detect_ram(card_t *card, u8 __iomem *rambase,
 }
 
 
-static void __devinit sca_init(card_t *card, int wait_states)
+static void sca_init(card_t *card, int wait_states)
 {
 	sca_out(wait_states, WCRL, card); /* Wait Control */
 	sca_out(wait_states, WCRM, card);
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index 0fe36d7..beecbe8 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1324,7 +1324,7 @@ static const struct net_device_ops hss_hdlc_ops = {
 	.ndo_do_ioctl   = hss_hdlc_ioctl,
 };
 
-static int __devinit hss_init_one(struct platform_device *pdev)
+static int hss_init_one(struct platform_device *pdev)
 {
 	struct port *port;
 	struct net_device *dev;
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 358e25f..41a401a 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -816,7 +816,7 @@ static const struct net_device_ops lmc_ops = {
 	.ndo_get_stats  = lmc_get_stats,
 };
 
-static int __devinit lmc_init_one(struct pci_dev *pdev,
+static int lmc_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	lmc_softc_t *sc;
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index 5fe246e..a51cfa7 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -297,7 +297,7 @@ static const struct net_device_ops pc300_ops = {
 	.ndo_do_ioctl   = pc300_ioctl,
 };
 
-static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
+static int pc300_pci_init_one(struct pci_dev *pdev,
 					const struct pci_device_id *ent)
 {
 	card_t *card;
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index 9659fca..037c423 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -276,7 +276,7 @@ static const struct net_device_ops pci200_ops = {
 	.ndo_do_ioctl   = pci200_ioctl,
 };
 
-static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
+static int pci200_pci_init_one(struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
 {
 	card_t *card;
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index feb7541..b72be12 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -557,7 +557,7 @@ static const struct net_device_ops wanxl_ops = {
 	.ndo_get_stats  = wanxl_get_stats,
 };
 
-static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
+static int wanxl_pci_init_one(struct pci_dev *pdev,
 					const struct pci_device_id *ent)
 {
 	card_t *card;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3c3b93e..6f695fc 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1255,7 +1255,7 @@ static const struct net_device_ops xennet_netdev_ops = {
 #endif
 };
 
-static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev)
+static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 {
 	int i, err;
 	struct net_device *netdev;
@@ -1351,7 +1351,7 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
  * structures and the ring buffers for communication with the backend, and
  * inform the backend of the appropriate details for those.
  */
-static int __devinit netfront_probe(struct xenbus_device *dev,
+static int netfront_probe(struct xenbus_device *dev,
 				    const struct xenbus_device_id *id)
 {
 	int err;
-- 
1.8.0
