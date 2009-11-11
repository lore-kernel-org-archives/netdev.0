From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 12/13] pcmcia: remove deprecated handle_to_dev() macro
Date: Wed, 11 Nov 2009 21:38:18 +0100
Message-ID: <1257971899-9274-12-git-send-email-linux@dominikbrodowski.net>
References: <20091111203303.GA7939@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-serial@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <20091111203303.GA7939@comet.dominikbrodowski.net>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update remaining users and remove deprecated handle_to_dev() macro

CC: Harald Welte <laforge@gnumonks.org>
CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-serial@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/cm4000_cs.c            |    2 +-
 drivers/char/pcmcia/cm4040_cs.c            |    6 +++---
 drivers/net/pcmcia/3c574_cs.c              |    2 +-
 drivers/net/pcmcia/3c589_cs.c              |    2 +-
 drivers/net/pcmcia/axnet_cs.c              |    2 +-
 drivers/net/pcmcia/com20020_cs.c           |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c            |    2 +-
 drivers/net/pcmcia/ibmtr_cs.c              |    2 +-
 drivers/net/pcmcia/nmclan_cs.c             |    2 +-
 drivers/net/pcmcia/pcnet_cs.c              |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c           |    2 +-
 drivers/net/pcmcia/xirc2ps_cs.c            |    2 +-
 drivers/net/wireless/airo_cs.c             |    2 +-
 drivers/net/wireless/atmel_cs.c            |    4 ++--
 drivers/net/wireless/hostap/hostap_cs.c    |    2 +-
 drivers/net/wireless/libertas/if_cs.c      |    4 ++--
 drivers/net/wireless/netwave_cs.c          |    2 +-
 drivers/net/wireless/orinoco/orinoco_cs.c  |    2 +-
 drivers/net/wireless/orinoco/spectrum_cs.c |    2 +-
 drivers/net/wireless/ray_cs.c              |    2 +-
 drivers/net/wireless/wavelan_cs.c          |    2 +-
 drivers/net/wireless/wl3501_cs.c           |    2 +-
 drivers/serial/serial_cs.c                 |    2 +-
 drivers/usb/host/sl811_cs.c                |    2 +-
 include/pcmcia/ds.h                        |    3 ---
 sound/pcmcia/pdaudiocf/pdaudiocf.c         |    2 +-
 sound/pcmcia/vx/vxpocket.c                 |    2 +-
 27 files changed, 30 insertions(+), 33 deletions(-)

diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index 1611c4f..2db4c0a 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -45,7 +45,7 @@
 
 /* #define ATR_CSUM */
 
-#define reader_to_dev(x)	(&handle_to_dev(x->p_dev))
+#define reader_to_dev(x)	(&x->p_dev->dev)
 
 /* n (debug level) is ignored */
 /* additional debug output may be enabled by re-compiling with
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index 38790db..a6a70e4 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -39,7 +39,7 @@
 #include "cm4040_cs.h"
 
 
-#define reader_to_dev(x)	(&handle_to_dev(x->p_dev))
+#define reader_to_dev(x)	(&x->p_dev->dev)
 
 /* n (debug level) is ignored */
 /* additional debug output may be enabled by re-compiling with
@@ -539,7 +539,7 @@ static int cm4040_config_check(struct pcmcia_device *p_dev,
 	p_dev->io.IOAddrLines = cfg->io.flags & CISTPL_IO_LINES_MASK;
 
 	rc = pcmcia_request_io(p_dev, &p_dev->io);
-	dev_printk(KERN_INFO, &handle_to_dev(p_dev),
+	dev_printk(KERN_INFO, &p_dev->dev,
 		   "pcmcia_request_io returned 0x%x\n", rc);
 	return rc;
 }
@@ -561,7 +561,7 @@ static int reader_config(struct pcmcia_device *link, int devno)
 
 	fail_rc = pcmcia_request_configuration(link, &link->conf);
 	if (fail_rc != 0) {
-		dev_printk(KERN_INFO, &handle_to_dev(link),
+		dev_printk(KERN_INFO, &link->dev,
 			   "pcmcia_request_configuration failed 0x%x\n",
 			   fail_rc);
 		goto cs_release;
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index dbef5d9..8b65e18 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -449,7 +449,7 @@ static int tc574_config(struct pcmcia_device *link)
 	}
 
 	link->dev_node = &lp->node;
-	SET_NETDEV_DEV(dev, &handle_to_dev(link));
+	SET_NETDEV_DEV(dev, &link->dev);
 
 	if (register_netdev(dev) != 0) {
 		printk(KERN_NOTICE "3c574_cs: register_netdev() failed\n");
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 6eac62b..c43c21d 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -316,7 +316,7 @@ static int tc589_config(struct pcmcia_device *link)
 	printk(KERN_ERR "3c589_cs: invalid if_port requested\n");
     
     link->dev_node = &lp->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_ERR "3c589_cs: register_netdev() failed\n");
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 5af2ccf..0552ddd 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -400,7 +400,7 @@ static int axnet_config(struct pcmcia_device *link)
 
     info->phy_id = (i < 32) ? i : -1;
     link->dev_node = &info->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "axnet_cs: register_netdev() failed\n");
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 9a2e500..51e9cb0 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -302,7 +302,7 @@ static int com20020_config(struct pcmcia_device *link)
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
 
     link->dev_node = &info->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     i = com20020_found(dev, 0);	/* calls register_netdev */
     
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 85f7c45..9b5ca37 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -532,7 +532,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
 
     lp->cardtype = cardtype;
     link->dev_node = &lp->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "fmvj18x_cs: register_netdev() failed\n");
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 14fe5fa..76706e1 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -287,7 +287,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     ibmtr_hw_setup(dev, mmiobase);
 
     link->dev_node = &info->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     i = ibmtr_probe_card(dev);
     if (i != 0) {
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index a536348..2d0c6f9 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -701,7 +701,7 @@ static int nmclan_config(struct pcmcia_device *link)
     printk(KERN_NOTICE "nmclan_cs: invalid if_port requested\n");
 
   link->dev_node = &lp->node;
-  SET_NETDEV_DEV(dev, &handle_to_dev(link));
+  SET_NETDEV_DEV(dev, &link->dev);
 
   i = register_netdev(dev);
   if (i != 0) {
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index d06a0ce..30baee7 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -646,7 +646,7 @@ static int pcnet_config(struct pcmcia_device *link)
 	mii_phy_probe(dev);
 
     link->dev_node = &info->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "pcnet_cs: register_netdev() failed\n");
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index c6ca376..2e795de 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -964,7 +964,7 @@ static int smc91c92_config(struct pcmcia_device *link)
     }
 
     link->dev_node = &smc->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_ERR "smc91c92_cs: register_netdev() failed\n");
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 265852a..f75ac71 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -992,7 +992,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	do_reset(dev, 1); /* a kludge to make the cem56 work */
 
     link->dev_node = &local->node;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     if ((err=register_netdev(dev))) {
 	printk(KNOT_XIRC "register_netdev() failed\n");
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 34d775c..7d3a96f 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -322,7 +322,7 @@ static int airo_config(struct pcmcia_device *link)
 		goto failed;
 	((local_info_t *)link->priv)->eth_dev =
 		init_airo_card(link->irq.AssignedIRQ,
-			       link->io.BasePort1, 1, &handle_to_dev(link));
+			       link->io.BasePort1, 1, &link->dev);
 	if (!((local_info_t *)link->priv)->eth_dev)
 		goto failed;
 
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 7838572..18a58b8 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -260,7 +260,7 @@ static int atmel_config(struct pcmcia_device *link)
 	struct pcmcia_device_id *did;
 
 	dev = link->priv;
-	did = dev_get_drvdata(&handle_to_dev(link));
+	did = dev_get_drvdata(&link->dev);
 
 	dev_dbg(&link->dev, "atmel_config\n");
 
@@ -309,7 +309,7 @@ static int atmel_config(struct pcmcia_device *link)
 		init_atmel_card(link->irq.AssignedIRQ,
 				link->io.BasePort1,
 				did ? did->driver_info : ATMEL_FW_TYPE_NONE,
-				&handle_to_dev(link),
+				&link->dev,
 				card_present,
 				link);
 	if (!((local_info_t*)link->priv)->eth_dev)
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index ca3ab84..243e912 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -623,7 +623,7 @@ static int prism2_config(struct pcmcia_device *link)
 
 	/* Need to allocate net_device before requesting IRQ handler */
 	dev = prism2_init_local_data(&prism2_pccard_funcs, 0,
-				     &handle_to_dev(link));
+				     &link->dev);
 	if (dev == NULL)
 		goto failed;
 	link->priv = dev;
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index cb40c38..f2b1655 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -590,7 +590,7 @@ static int if_cs_prog_helper(struct if_cs_card *card)
 
 	/* TODO: make firmware file configurable */
 	ret = request_firmware(&fw, "libertas_cs_helper.fw",
-		&handle_to_dev(card->p_dev));
+		&card->p_dev->dev);
 	if (ret) {
 		lbs_pr_err("can't load helper firmware\n");
 		ret = -ENODEV;
@@ -663,7 +663,7 @@ static int if_cs_prog_real(struct if_cs_card *card)
 
 	/* TODO: make firmware file configurable */
 	ret = request_firmware(&fw, "libertas_cs.fw",
-		&handle_to_dev(card->p_dev));
+		&card->p_dev->dev);
 	if (ret) {
 		lbs_pr_err("can't load firmware\n");
 		ret = -ENODEV;
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index bd4eff7..f5333b7 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -773,7 +773,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
 
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
-    SET_NETDEV_DEV(dev, &handle_to_dev(link));
+    SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_DEBUG "netwave_cs: register_netdev() failed\n");
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index da626ec..688b398 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -109,7 +109,7 @@ orinoco_cs_probe(struct pcmcia_device *link)
 	struct orinoco_private *priv;
 	struct orinoco_pccard *card;
 
-	priv = alloc_orinocodev(sizeof(*card), &handle_to_dev(link),
+	priv = alloc_orinocodev(sizeof(*card), &link->dev,
 				orinoco_cs_hard_reset, NULL);
 	if (!priv)
 		return -ENOMEM;
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 700010e..c609371 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -182,7 +182,7 @@ spectrum_cs_probe(struct pcmcia_device *link)
 	struct orinoco_private *priv;
 	struct orinoco_pccard *card;
 
-	priv = alloc_orinocodev(sizeof(*card), &handle_to_dev(link),
+	priv = alloc_orinocodev(sizeof(*card), &link->dev,
 				spectrum_cs_hard_reset,
 				spectrum_cs_stop_firmware);
 	if (!priv)
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 66e2d10..5e0f4c3 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -488,7 +488,7 @@ static int ray_config(struct pcmcia_device *link)
 		return -ENODEV;
 	}
 
-	SET_NETDEV_DEV(dev, &handle_to_dev(link));
+	SET_NETDEV_DEV(dev, &link->dev);
 	i = register_netdev(dev);
 	if (i != 0) {
 		printk("ray_config register_netdev() failed\n");
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index f8c5166..df3579a 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3899,7 +3899,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
 	     lp->mem, dev->irq, (u_int) dev->base_addr);
 #endif
 
-      SET_NETDEV_DEV(dev, &handle_to_dev(link));
+      SET_NETDEV_DEV(dev, &link->dev);
       i = register_netdev(dev);
       if(i != 0)
 	{
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 7e8e269..9a956c7 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1975,7 +1975,7 @@ static int wl3501_config(struct pcmcia_device *link)
 
 	dev->irq = link->irq.AssignedIRQ;
 	dev->base_addr = link->io.BasePort1;
-	SET_NETDEV_DEV(dev, &handle_to_dev(link));
+	SET_NETDEV_DEV(dev, &link->dev);
 	if (register_netdev(dev)) {
 		printk(KERN_NOTICE "wl3501_cs: register_netdev() failed\n");
 		goto failed;
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 3b31bee..8d651a6 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -387,7 +387,7 @@ static int setup_serial(struct pcmcia_device *handle, struct serial_info * info,
 	port.irq = irq;
 	port.flags = UPF_BOOT_AUTOCONF | UPF_SKIP_TEST | UPF_SHARE_IRQ;
 	port.uartclk = 1843200;
-	port.dev = &handle_to_dev(handle);
+	port.dev = &handle->dev;
 	if (buggy_uart)
 		port.flags |= UPF_BUGGY_UART;
 
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 4607742..f87aba6 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -185,7 +185,7 @@ static int sl811_cs_config_check(struct pcmcia_device *p_dev,
 
 static int sl811_cs_config(struct pcmcia_device *link)
 {
-	struct device		*parent = &handle_to_dev(link);
+	struct device		*parent = &link->dev;
 	local_info_t		*dev = link->priv;
 	int			ret;
 
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index d6c55fd..d403c12 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -138,9 +138,6 @@ struct pcmcia_device {
 #define to_pcmcia_dev(n) container_of(n, struct pcmcia_device, dev)
 #define to_pcmcia_drv(n) container_of(n, struct pcmcia_driver, drv)
 
-/* deprecated -- don't use! */
-#define handle_to_dev(handle) (handle->dev)
-
 
 /*
  * CIS access.
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 64b8599..447aaae 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -131,7 +131,7 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 		return err;
 	}
 
-	snd_card_set_dev(card, &handle_to_dev(link));
+	snd_card_set_dev(card, &link->dev);
 
 	pdacf->index = i;
 	card_list[i] = card;
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index 1492744..5a5db48 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -244,7 +244,7 @@ static int vxpocket_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	chip->dev = &handle_to_dev(link);
+	chip->dev = &link->dev;
 	snd_card_set_dev(chip->card, chip->dev);
 
 	if (snd_vxpocket_assign_resources(chip, link->io.BasePort1, link->irq.AssignedIRQ) < 0)
-- 
1.6.0.4

