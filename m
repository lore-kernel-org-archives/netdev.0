From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 05/17] can: remove unused variable
Date: Tue, 18 Nov 2014 21:37:35 +0100
Message-ID: <1416343067-9810-6-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Sudip Mukherjee <sudip@vectorindia.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>

these variable were only assigned some values, but then never
reused again.
so they are safe to be removed.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/kvaser_pci.c | 5 +----
 drivers/net/can/usb/ems_usb.c        | 3 +--
 drivers/net/can/usb/esd_usb2.c       | 2 --
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index 8ff3424d5147..15c00faeec61 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -214,7 +214,7 @@ static int kvaser_pci_add_chan(struct pci_dev *pdev, int channel,
 	struct net_device *dev;
 	struct sja1000_priv *priv;
 	struct kvaser_pci *board;
-	int err, init_step;
+	int err;
 
 	dev = alloc_sja1000dev(sizeof(struct kvaser_pci));
 	if (dev == NULL)
@@ -235,7 +235,6 @@ static int kvaser_pci_add_chan(struct pci_dev *pdev, int channel,
 	if (channel == 0) {
 		board->xilinx_ver =
 			ioread8(board->res_addr + XILINX_VERINT) >> 4;
-		init_step = 2;
 
 		/* Assert PTADR# - we're in passive mode so the other bits are
 		   not important */
@@ -264,8 +263,6 @@ static int kvaser_pci_add_chan(struct pci_dev *pdev, int channel,
 	priv->irq_flags = IRQF_SHARED;
 	dev->irq = pdev->irq;
 
-	init_step = 4;
-
 	dev_info(&pdev->dev, "reg_base=%p conf_addr=%p irq=%d\n",
 		 priv->reg_base, board->conf_addr, dev->irq);
 
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 00f2534dde73..29d3f0938eb8 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -434,10 +434,9 @@ static void ems_usb_read_bulk_callback(struct urb *urb)
 	if (urb->actual_length > CPC_HEADER_SIZE) {
 		struct ems_cpc_msg *msg;
 		u8 *ibuf = urb->transfer_buffer;
-		u8 msg_count, again, start;
+		u8 msg_count, start;
 
 		msg_count = ibuf[0] & ~0x80;
-		again = ibuf[0] & 0x80;
 
 		start = CPC_HEADER_SIZE;
 
diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index 7a90075529c3..c063a54ab8dd 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -464,7 +464,6 @@ static void esd_usb2_write_bulk_callback(struct urb *urb)
 {
 	struct esd_tx_urb_context *context = urb->context;
 	struct esd_usb2_net_priv *priv;
-	struct esd_usb2 *dev;
 	struct net_device *netdev;
 	size_t size = sizeof(struct esd_usb2_msg);
 
@@ -472,7 +471,6 @@ static void esd_usb2_write_bulk_callback(struct urb *urb)
 
 	priv = context->priv;
 	netdev = priv->netdev;
-	dev = priv->usb2;
 
 	/* free up our allocated buffer */
 	usb_free_coherent(urb->dev, size,
-- 
2.1.3

