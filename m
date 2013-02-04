From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/8] can: Remove unnecessary alloc/OOM messages
Date: Sun,  3 Feb 2013 19:28:09 -0800
Message-ID: <4bcd953ce87ecab86e000443df36a2867927c96e.1359939013.git.joe@perches.com>
References: <cover.1359939012.git.joe@perches.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1359939012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc failures already get standardized OOM
messages and a dump_stack.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/can/sja1000/ems_pci.c            | 1 -
 drivers/net/can/sja1000/peak_pci.c           | 5 +----
 drivers/net/can/sja1000/peak_pcmcia.c        | 1 -
 drivers/net/can/sja1000/plx_pci.c            | 1 -
 drivers/net/can/usb/ems_usb.c                | 4 +---
 drivers/net/can/usb/kvaser_usb.c             | 2 --
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 5 -----
 drivers/net/can/usb/usb_8dev.c               | 4 +---
 8 files changed, 3 insertions(+), 20 deletions(-)

diff --git a/drivers/net/can/sja1000/ems_pci.c b/drivers/net/can/sja1000/ems_pci.c
index 036a326..36d298d 100644
--- a/drivers/net/can/sja1000/ems_pci.c
+++ b/drivers/net/can/sja1000/ems_pci.c
@@ -238,7 +238,6 @@ static int ems_pci_add_card(struct pci_dev *pdev,
 	/* Allocating card structures to hold addresses, ... */
 	card = kzalloc(sizeof(struct ems_pci_card), GFP_KERNEL);
 	if (card == NULL) {
-		dev_err(&pdev->dev, "Unable to allocate memory\n");
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 600ac72..d1e7f10 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -450,11 +450,8 @@ static int peak_pciec_probe(struct pci_dev *pdev, struct net_device *dev)
 	} else {
 		/* create the bit banging I2C adapter structure */
 		card = kzalloc(sizeof(struct peak_pciec_card), GFP_KERNEL);
-		if (!card) {
-			dev_err(&pdev->dev,
-				 "failed allocating memory for i2c chip\n");
+		if (!card)
 			return -ENOMEM;
-		}
 
 		card->cfg_base = chan->cfg_base;
 		card->reg_base = priv->reg_base;
diff --git a/drivers/net/can/sja1000/peak_pcmcia.c b/drivers/net/can/sja1000/peak_pcmcia.c
index f117514..1a7020b 100644
--- a/drivers/net/can/sja1000/peak_pcmcia.c
+++ b/drivers/net/can/sja1000/peak_pcmcia.c
@@ -660,7 +660,6 @@ static int pcan_probe(struct pcmcia_device *pdev)
 
 	card = kzalloc(sizeof(struct pcan_pccard), GFP_KERNEL);
 	if (!card) {
-		dev_err(&pdev->dev, "couldn't allocate card memory\n");
 		err = -ENOMEM;
 		goto probe_err_2;
 	}
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index 11d1062..a042cdc 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -508,7 +508,6 @@ static int plx_pci_add_card(struct pci_dev *pdev,
 	/* Allocate card structures to hold addresses, ... */
 	card = kzalloc(sizeof(*card), GFP_KERNEL);
 	if (!card) {
-		dev_err(&pdev->dev, "Unable to allocate memory\n");
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index c69f0b7..0e7bde7 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -1014,10 +1014,8 @@ static int ems_usb_probe(struct usb_interface *intf,
 	}
 
 	dev->intr_in_buffer = kzalloc(INTR_IN_BUFFER_SIZE, GFP_KERNEL);
-	if (!dev->intr_in_buffer) {
-		dev_err(&intf->dev, "Couldn't alloc Intr buffer\n");
+	if (!dev->intr_in_buffer)
 		goto cleanup_intr_urb;
-	}
 
 	dev->tx_msg_buffer = kzalloc(CPC_HEADER_SIZE +
 				     sizeof(struct ems_cpc_msg), GFP_KERNEL);
diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 5b58a4d..45cb9f3 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -561,7 +561,6 @@ static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
 
 	buf = kmalloc(sizeof(struct kvaser_msg), GFP_ATOMIC);
 	if (!buf) {
-		netdev_err(netdev, "No memory left for USB buffer\n");
 		usb_free_urb(urb);
 		return -ENOMEM;
 	}
@@ -1268,7 +1267,6 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 
 	buf = kmalloc(sizeof(struct kvaser_msg), GFP_ATOMIC);
 	if (!buf) {
-		netdev_err(netdev, "No memory left for USB buffer\n");
 		stats->tx_dropped++;
 		goto nobufmem;
 	}
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index d9290ea..a0f647f 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -386,7 +386,6 @@ static int peak_usb_start(struct peak_usb_device *dev)
 
 		buf = kmalloc(dev->adapter->rx_buffer_size, GFP_KERNEL);
 		if (!buf) {
-			netdev_err(netdev, "No memory left for USB buffer\n");
 			usb_free_urb(urb);
 			err = -ENOMEM;
 			break;
@@ -442,7 +441,6 @@ static int peak_usb_start(struct peak_usb_device *dev)
 
 		buf = kmalloc(dev->adapter->tx_buffer_size, GFP_KERNEL);
 		if (!buf) {
-			netdev_err(netdev, "No memory left for USB buffer\n");
 			usb_free_urb(urb);
 			err = -ENOMEM;
 			break;
@@ -634,7 +632,6 @@ static int peak_usb_restart(struct peak_usb_device *dev)
 	/* also allocate enough space for the commands to send */
 	buf = kmalloc(PCAN_USB_MAX_CMD_LEN, GFP_ATOMIC);
 	if (!buf) {
-		netdev_err(dev->netdev, "no memory left for async cmd\n");
 		usb_free_urb(urb);
 		return -ENOMEM;
 	}
@@ -729,8 +726,6 @@ static int peak_usb_create_dev(struct peak_usb_adapter *peak_usb_adapter,
 	/* allocate a buffer large enough to send commands */
 	dev->cmd_buf = kmalloc(PCAN_USB_MAX_CMD_LEN, GFP_KERNEL);
 	if (!dev->cmd_buf) {
-		dev_err(&intf->dev, "%s: couldn't alloc cmd buffer\n",
-			PCAN_USB_DRIVER_NAME);
 		err = -ENOMEM;
 		goto lbl_set_intf_data;
 	}
diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
index f789e6f..6e15ef0 100644
--- a/drivers/net/can/usb/usb_8dev.c
+++ b/drivers/net/can/usb/usb_8dev.c
@@ -958,10 +958,8 @@ static int usb_8dev_probe(struct usb_interface *intf,
 
 	priv->cmd_msg_buffer = kzalloc(sizeof(struct usb_8dev_cmd_msg),
 				      GFP_KERNEL);
-	if (!priv->cmd_msg_buffer) {
-		netdev_err(netdev, "Couldn't alloc Tx buffer\n");
+	if (!priv->cmd_msg_buffer)
 		goto cleanup_candev;
-	}
 
 	usb_set_intfdata(intf, priv);
 
-- 
1.8.0.dirty
