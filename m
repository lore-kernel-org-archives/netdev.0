From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: [PATCH] driver/net/ethernet/ec_bhf.c: fix sparse warnings
Date: Sun, 11 May 2014 09:56:08 +0200
Message-ID: <20140511075608.GA9034@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.newterm.pl ([79.187.237.18]:44163 "EHLO apollo.newterm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756798AbaEKH4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 May 2014 03:56:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sparse was reporting quite a few warnings for the driver.
Those get fixed by this patch.
---
 drivers/net/ethernet/ec_bhf.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index 4884205..056b44b 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -134,17 +134,17 @@ struct ec_bhf_priv {
 
 	struct pci_dev *dev;
 
-	void * __iomem io;
-	void * __iomem dma_io;
+	void __iomem *io;
+	void __iomem *dma_io;
 
 	struct hrtimer hrtimer;
 
 	int tx_dma_chan;
 	int rx_dma_chan;
-	void * __iomem ec_io;
-	void * __iomem fifo_io;
-	void * __iomem mii_io;
-	void * __iomem mac_io;
+	void __iomem *ec_io;
+	void __iomem *fifo_io;
+	void __iomem *mii_io;
+	void __iomem *mac_io;
 
 	struct bhf_dma rx_buf;
 	struct rx_desc *rx_descs;
@@ -297,7 +297,7 @@ static int ec_bhf_setup_offsets(struct ec_bhf_priv *priv)
 {
 	struct device *dev = PRIV_TO_DEV(priv);
 	unsigned block_count, i;
-	void * __iomem ec_info;
+	void __iomem *ec_info;
 
 	dev_dbg(dev, "Info block:\n");
 	dev_dbg(dev, "Type of function: %x\n", (unsigned)ioread16(priv->io));
@@ -569,8 +569,8 @@ static int ec_bhf_probe(struct pci_dev *dev, const struct pci_device_id *id)
 {
 	struct net_device *net_dev;
 	struct ec_bhf_priv *priv;
-	void * __iomem dma_io;
-	void * __iomem io;
+	void __iomem *dma_io;
+	void __iomem *io;
 	int err = 0;
 
 	err = pci_enable_device(dev);
@@ -615,7 +615,7 @@ static int ec_bhf_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	}
 
 	net_dev = alloc_etherdev(sizeof(struct ec_bhf_priv));
-	if (net_dev == 0) {
+	if (net_dev == NULL) {
 		err = -ENOMEM;
 		goto err_unmap_dma_io;
 	}
-- 
1.7.10.4
