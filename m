From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 13/13] pcmcia: rework the irq_req_t typedef
Date: Wed, 11 Nov 2009 21:38:19 +0100
Message-ID: <1257971899-9274-13-git-send-email-linux@dominikbrodowski.net>
References: <20091111203303.GA7939@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org, alsa-devel@alsa-project.org,
	Jaroslav Kysela <perex@perex.cz>,
	Jiri Kosina <jkosina@suse.cz>,
	Karsten Keil <isdn@linux-pingi.de>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20091111203303.GA7939@comet.dominikbrodowski.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the irq_req_t typedef'd struct can be re-worked quite
easily:

(1) IRQInfo2 was unused in any case, so drop it.

(2) IRQInfo1 was used write-only, so drop it.

(3) Instance (private data to be passed to the IRQ handler):
	Most PCMCIA drivers using pcmcia_request_irq() to actually
	register an IRQ handler set the "dev_id" to the same pointer
	as the "priv" pointer in struct pcmcia_device. Modify the two
	exceptions (ipwireless, ibmtr_cs) to also work this waym and
	set the IRQ handler's "dev_id" to p_dev->priv unconditionally.

(4) Handler is to be of type irq_handler_t.

(5) Handler != NULL already tells whether an IRQ handler is present.
	Therefore, we do not need the IRQ_HANDLER_PRESENT flag in
	irq_req_t.Attributes.

CC: netdev@vger.kernel.org
CC: linux-bluetooth@vger.kernel.org
CC: linux-ide@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-scsi@vger.kernel.org
CC: alsa-devel@alsa-project.org
CC: Jaroslav Kysela <perex@perex.cz>
CC: Jiri Kosina <jkosina@suse.cz>
CC: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/ata/pata_pcmcia.c                        |    1 -
 drivers/bluetooth/bluecard_cs.c                  |    4 +---
 drivers/bluetooth/bt3c_cs.c                      |    4 +---
 drivers/bluetooth/btuart_cs.c                    |    4 +---
 drivers/bluetooth/dtl1_cs.c                      |    4 +---
 drivers/char/pcmcia/ipwireless/hardware.c        |    8 ++++----
 drivers/char/pcmcia/ipwireless/main.c            |    6 +-----
 drivers/char/pcmcia/synclink_cs.c                |    3 ---
 drivers/ide/ide-cs.c                             |    1 -
 drivers/isdn/hardware/avm/avm_cs.c               |    2 --
 drivers/isdn/hisax/avma1_cs.c                    |    2 --
 drivers/isdn/hisax/elsa_cs.c                     |    1 -
 drivers/isdn/hisax/sedlbauer_cs.c                |    1 -
 drivers/isdn/hisax/teles_cs.c                    |    1 -
 drivers/net/pcmcia/3c574_cs.c                    |    4 +---
 drivers/net/pcmcia/3c589_cs.c                    |    4 +---
 drivers/net/pcmcia/axnet_cs.c                    |    1 -
 drivers/net/pcmcia/com20020_cs.c                 |    8 +++-----
 drivers/net/pcmcia/fmvj18x_cs.c                  |    6 ++----
 drivers/net/pcmcia/ibmtr_cs.c                    |   13 +++++++++----
 drivers/net/pcmcia/nmclan_cs.c                   |    4 +---
 drivers/net/pcmcia/pcnet_cs.c                    |    1 -
 drivers/net/pcmcia/smc91c92_cs.c                 |    8 +++-----
 drivers/net/pcmcia/xirc2ps_cs.c                  |    3 ---
 drivers/net/wireless/airo_cs.c                   |    1 -
 drivers/net/wireless/atmel_cs.c                  |    1 -
 drivers/net/wireless/b43/pcmcia.c                |    2 --
 drivers/net/wireless/hostap/hostap_cs.c          |    5 +----
 drivers/net/wireless/libertas/if_cs.c            |    1 -
 drivers/net/wireless/netwave_cs.c                |    5 +----
 drivers/net/wireless/orinoco/orinoco_cs.c        |    4 +---
 drivers/net/wireless/orinoco/spectrum_cs.c       |    4 +---
 drivers/net/wireless/ray_cs.c                    |    4 +---
 drivers/net/wireless/wavelan_cs.c                |    5 ++---
 drivers/net/wireless/wl3501_cs.c                 |    5 ++---
 drivers/parport/parport_cs.c                     |    1 -
 drivers/pcmcia/pcmcia_resource.c                 |   18 +++++++++---------
 drivers/scsi/pcmcia/aha152x_stub.c               |    1 -
 drivers/scsi/pcmcia/fdomain_stub.c               |    1 -
 drivers/scsi/pcmcia/nsp_cs.c                     |    4 +---
 drivers/scsi/pcmcia/qlogic_stub.c                |    1 -
 drivers/scsi/pcmcia/sym53c500_cs.c               |    1 -
 drivers/serial/serial_cs.c                       |    1 -
 drivers/staging/comedi/drivers/cb_das16_cs.c     |    1 -
 drivers/staging/comedi/drivers/das08_cs.c        |    1 -
 drivers/staging/comedi/drivers/ni_daq_700.c      |    1 -
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |    1 -
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |    1 -
 drivers/staging/comedi/drivers/ni_mio_cs.c       |    4 ----
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |    4 +---
 drivers/usb/host/sl811_cs.c                      |    1 -
 include/pcmcia/cs.h                              |   14 ++++++++------
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    4 +---
 sound/pcmcia/vx/vxpocket.c                       |    4 +---
 54 files changed, 59 insertions(+), 136 deletions(-)

diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 5f94e21..1b392c9 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -268,7 +268,6 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	pdev->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
 	pdev->io.IOAddrLines = 3;
 	pdev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	pdev->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	pdev->conf.Attributes = CONF_ENABLE_IRQ;
 	pdev->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 1e0c4d8..2acdc60 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -867,11 +867,9 @@ static int bluecard_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 
 	link->irq.Handler = bluecard_interrupt;
-	link->irq.Instance = info;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 9787fda..d814a27 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -659,11 +659,9 @@ static int bt3c_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 
 	link->irq.Handler = bt3c_interrupt;
-	link->irq.Instance = info;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index f44d752..d339464 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -588,11 +588,9 @@ static int btuart_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 
 	link->irq.Handler = btuart_interrupt;
-	link->irq.Instance = info;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 7cd8614..4f02a6f 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -573,11 +573,9 @@ static int dtl1_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 
 	link->irq.Handler = dtl1_interrupt;
-	link->irq.Instance = info;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/char/pcmcia/ipwireless/hardware.c b/drivers/char/pcmcia/ipwireless/hardware.c
index 4c1820c..99cffda 100644
--- a/drivers/char/pcmcia/ipwireless/hardware.c
+++ b/drivers/char/pcmcia/ipwireless/hardware.c
@@ -1213,12 +1213,12 @@ static irqreturn_t ipwireless_handle_v2_v3_interrupt(int irq,
 
 irqreturn_t ipwireless_interrupt(int irq, void *dev_id)
 {
-	struct ipw_hardware *hw = dev_id;
+	struct ipw_dev *ipw = dev_id;
 
-	if (hw->hw_version == HW_VERSION_1)
-		return ipwireless_handle_v1_interrupt(irq, hw);
+	if (ipw->hardware->hw_version == HW_VERSION_1)
+		return ipwireless_handle_v1_interrupt(irq, ipw->hardware);
 	else
-		return ipwireless_handle_v2_v3_interrupt(irq, hw);
+		return ipwireless_handle_v2_v3_interrupt(irq, ipw->hardware);
 }
 
 static void flush_packets_to_hw(struct ipw_hardware *hw)
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 082146a..dff24da 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -93,8 +93,6 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	p_dev->io.NumPorts1 = cfg->io.win[0].len;
 	p_dev->io.IOAddrLines = 16;
 
-	p_dev->irq.IRQInfo1 = cfg->irq.IRQInfo1;
-
 	/* 0x40 causes it to generate level mode interrupts. */
 	/* 0x04 enables IREQ pin. */
 	p_dev->conf.ConfigIndex = cfg->index | 0x44;
@@ -197,9 +195,8 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->irq.Handler = ipwireless_interrupt;
-	link->irq.Instance = ipw->hardware;
 
 	INIT_WORK(&ipw->work_reboot, signalled_reboot_work);
 
@@ -315,7 +312,6 @@ static int ipwireless_attach(struct pcmcia_device *link)
 
 	ipw->link = link;
 	link->priv = ipw;
-	link->irq.Instance = ipw;
 
 	/* Link this device into our device list. */
 	link->dev_node = &ipw->nodes[0];
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 09b2590..c31a0d9 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -554,7 +554,6 @@ static int mgslpc_probe(struct pcmcia_device *link)
 
     /* Interrupt setup */
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.IRQInfo1   = IRQ_LEVEL_ID;
     link->irq.Handler = NULL;
 
     link->conf.Attributes = 0;
@@ -609,9 +608,7 @@ static int mgslpc_config(struct pcmcia_device *link)
     link->conf.ConfigIndex = 8;
     link->conf.Present = PRESENT_OPTION;
 
-    link->irq.Attributes |= IRQ_HANDLE_PRESENT;
     link->irq.Handler     = mgslpc_isr;
-    link->irq.Instance    = info;
 
     ret = pcmcia_request_irq(link, &link->irq);
     if (ret)
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 6cee6c8..dd63963 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -103,7 +103,6 @@ static int ide_probe(struct pcmcia_device *link)
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.IOAddrLines = 3;
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index d388ead..5a6ae64 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -111,8 +111,6 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
     p_dev->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
     p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
 
-    p_dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
-
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
     p_dev->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 6d963f9..f9bdff3 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -123,8 +123,6 @@ static int avma1cs_probe(struct pcmcia_device *p_dev)
     p_dev->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
     p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
 
-    p_dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
-
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
     p_dev->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index cdcd297..a2f709f 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -138,7 +138,6 @@ static int elsa_cs_probe(struct pcmcia_device *link)
 
     /* Interrupt setup */
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID|IRQ_SHARE_ID;
     link->irq.Handler = NULL;
 
     /*
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 331716f..af5d393 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -145,7 +145,6 @@ static int sedlbauer_probe(struct pcmcia_device *link)
 
     /* Interrupt setup */
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->irq.Handler = NULL;
 
     /*
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 7b11c15..ea70539 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -128,7 +128,6 @@ static int teles_probe(struct pcmcia_device *link)
 
     /* Interrupt setup */
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID|IRQ_SHARE_ID;
     link->irq.Handler = NULL;
 
     /*
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 8b65e18..17a2722 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -283,10 +283,8 @@ static int tc574_probe(struct pcmcia_device *link)
 	spin_lock_init(&lp->window_lock);
 	link->io.NumPorts1 = 32;
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->irq.Handler = &el3_interrupt;
-	link->irq.Instance = dev;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index c43c21d..6f8d7e2 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -194,10 +194,8 @@ static int tc589_probe(struct pcmcia_device *link)
     spin_lock_init(&lp->lock);
     link->io.NumPorts1 = 16;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.Handler = &el3_interrupt;
-    link->irq.Instance = dev;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 0552ddd..800597b 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -170,7 +170,6 @@ static int axnet_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = dev;
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 51e9cb0..21d9c9d 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -164,11 +164,10 @@ static int com20020_probe(struct pcmcia_device *p_dev)
     p_dev->io.NumPorts1 = 16;
     p_dev->io.IOAddrLines = 16;
     p_dev->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-    p_dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
     p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
-    p_dev->irq.Instance = info->dev = dev;
+    info->dev = dev;
     p_dev->priv = info;
 
     return com20020_config(p_dev);
@@ -275,9 +274,8 @@ static int com20020_config(struct pcmcia_device *link)
     ioaddr = dev->base_addr = link->io.BasePort1;
     dev_dbg(&link->dev, "got ioaddr %Xh\n", ioaddr);
 
-    dev_dbg(&link->dev, "request IRQ %d (%Xh/%Xh)\n",
-	   link->irq.AssignedIRQ,
-	   link->irq.IRQInfo1, link->irq.IRQInfo2);
+    dev_dbg(&link->dev, "request IRQ %d\n",
+	    link->irq.AssignedIRQ);
     i = pcmcia_request_irq(link, &link->irq);
     if (i != 0)
     {
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 9b5ca37..6e3e1ce 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -255,10 +255,8 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     link->io.IOAddrLines = 5;
 
     /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.Handler = &fjn_interrupt;
-    link->irq.Instance = dev;
 
     /* General socket configuration */
     link->conf.Attributes = CONF_ENABLE_IRQ;
@@ -428,7 +426,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
 
     if (link->io.NumPorts2 != 0) {
     	link->irq.Attributes =
-		IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED|IRQ_HANDLE_PRESENT;
+		IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
 	ret = mfc_try_io_port(link);
 	if (ret != 0) goto failed;
     } else if (cardtype == UNGERMANN) {
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 76706e1..37f4a6f 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -119,6 +119,12 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 };
 
+static irqreturn_t ibmtr_interrupt(int irq, void *dev_id) {
+	ibmtr_dev_t *info = dev_id;
+	struct net_device *dev = info->dev;
+	return tok_interrupt(irq, dev);
+};
+
 /*======================================================================
 
     ibmtr_attach() creates an "instance" of the driver, allocating
@@ -150,14 +156,13 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts1 = 4;
     link->io.IOAddrLines = 16;
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
-    link->irq.Handler = &tok_interrupt;
+    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
+    link->irq.Handler = ibmtr_interrupt;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
 
-    link->irq.Instance = info->dev = dev;
+    info->dev = dev;
 
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 2d0c6f9..dae5ef6 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -463,10 +463,8 @@ static int nmclan_probe(struct pcmcia_device *link)
     link->io.NumPorts1 = 32;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 5;
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
     link->irq.Handler = &mace_interrupt;
-    link->irq.Instance = dev;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 30baee7..de2d100 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -266,7 +266,6 @@ static int pcnet_probe(struct pcmcia_device *link)
     link->priv = dev;
 
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 2e795de..9e0da37 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -329,10 +329,8 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->io.NumPorts1 = 16;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 4;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.Handler = &smc_interrupt;
-    link->irq.Instance = dev;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -456,7 +454,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
     link->irq.Attributes =
-	IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED|IRQ_HANDLE_PRESENT;
+	IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
     link->io.IOAddrLines = 16;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
@@ -655,7 +653,7 @@ static int osi_config(struct pcmcia_device *link)
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
     link->irq.Attributes =
-	IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED|IRQ_HANDLE_PRESENT;
+	IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
     link->io.NumPorts1 = 64;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index f75ac71..fe504b7 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -556,7 +556,6 @@ xirc2ps_probe(struct pcmcia_device *link)
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
     link->irq.Handler = xirc2ps_interrupt;
-    link->irq.Instance = dev;
 
     /* Fill in card specific entries */
     dev->netdev_ops = &netdev_ops;
@@ -835,8 +834,6 @@ xirc2ps_config(struct pcmcia_device * link)
 
     link->io.IOAddrLines =10;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-    link->irq.Attributes = IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     if (local->modem) {
 	int pass;
 
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 7d3a96f..f6036fb 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -134,7 +134,6 @@ static int airo_probe(struct pcmcia_device *p_dev)
 
 	/* Interrupt setup */
 	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	p_dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	p_dev->irq.Handler = NULL;
 
 	/*
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 18a58b8..3240791 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -143,7 +143,6 @@ static int atmel_probe(struct pcmcia_device *p_dev)
 
 	/* Interrupt setup */
 	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	p_dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	p_dev->irq.Handler = NULL;
 
 	/*
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 2588358..984174b 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -98,9 +98,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 		goto err_disable;
 
 	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	dev->irq.Handler = NULL; /* The handler is registered later. */
-	dev->irq.Instance = NULL;
 	res = pcmcia_request_irq(dev, &dev->irq);
 	if (res != 0)
 		goto err_disable;
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 243e912..c9640a3 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -641,11 +641,8 @@ static int prism2_config(struct pcmcia_device *link)
 	 * irq structure is initialized.
 	 */
 	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING |
-				       IRQ_HANDLE_PRESENT;
-		link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+		link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 		link->irq.Handler = prism2_interrupt;
-		link->irq.Instance = dev;
 		ret = pcmcia_request_irq(link, &link->irq);
 		if (ret)
 			goto failed;
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index f2b1655..b1d8459 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -837,7 +837,6 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 
 	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	p_dev->irq.Handler = NULL;
-	p_dev->irq.IRQInfo1 = IRQ_INFO2_VALID | IRQ_LEVEL_ID;
 
 	p_dev->conf.Attributes = 0;
 	p_dev->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index f5333b7..e61e6b9 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -384,8 +384,7 @@ static int netwave_probe(struct pcmcia_device *link)
     link->io.IOAddrLines = 5;
     
     /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.Handler = &netwave_interrupt;
     
     /* General socket configuration */
@@ -404,8 +403,6 @@ static int netwave_probe(struct pcmcia_device *link)
 
     dev->watchdog_timeo = TX_TIMEOUT;
 
-    link->irq.Instance = dev;
-
     return netwave_pcmcia_config( link);
 } /* netwave_attach */
 
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 688b398..f27bb83 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -120,10 +120,8 @@ orinoco_cs_probe(struct pcmcia_device *link)
 	link->priv = priv;
 
 	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->irq.Handler = orinoco_interrupt;
-	link->irq.Instance = priv;
 
 	/* General socket configuration defaults can go here.  In this
 	 * client, we assume very little, and rely on the CIS for
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index c609371..59bda24 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -194,10 +194,8 @@ spectrum_cs_probe(struct pcmcia_device *link)
 	link->priv = priv;
 
 	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->irq.Handler = orinoco_interrupt;
-	link->irq.Instance = priv;
 
 	/* General socket configuration defaults can go here.  In this
 	 * client, we assume very little, and rely on the CIS for
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 5e0f4c3..91213f9 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -323,8 +323,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	p_dev->io.IOAddrLines = 5;
 
 	/* Interrupt setup. For PCMCIA, driver takes what's given */
-	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	p_dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	p_dev->irq.Handler = &ray_interrupt;
 
 	/* General socket configuration */
@@ -333,7 +332,6 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	p_dev->conf.ConfigIndex = 1;
 
 	p_dev->priv = dev;
-	p_dev->irq.Instance = dev;
 
 	local->finder = p_dev;
 	local->card_status = CARD_INSERTED;
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index df3579a..33918fd 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -4438,8 +4438,7 @@ wavelan_probe(struct pcmcia_device *p_dev)
   p_dev->io.IOAddrLines = 3;
 
   /* Interrupt setup */
-  p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-  p_dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
+  p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
   p_dev->irq.Handler = wavelan_interrupt;
 
   /* General socket configuration */
@@ -4451,7 +4450,7 @@ wavelan_probe(struct pcmcia_device *p_dev)
   if (!dev)
       return -ENOMEM;
 
-  p_dev->priv = p_dev->irq.Instance = dev;
+  p_dev->priv = dev;
 
   lp = netdev_priv(dev);
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 9a956c7..5f0401a 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1898,8 +1898,7 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 	p_dev->io.IOAddrLines	= 5;
 
 	/* Interrupt setup */
-	p_dev->irq.Attributes	= IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	p_dev->irq.IRQInfo1	= IRQ_LEVEL_ID;
+	p_dev->irq.Attributes	= IRQ_TYPE_DYNAMIC_SHARING;
 	p_dev->irq.Handler = wl3501_interrupt;
 
 	/* General socket configuration */
@@ -1922,7 +1921,7 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 	dev->wireless_handlers	= &wl3501_handler_def;
 	SET_ETHTOOL_OPS(dev, &ops);
 	netif_stop_queue(dev);
-	p_dev->priv = p_dev->irq.Instance = dev;
+	p_dev->priv = dev;
 
 	return wl3501_config(p_dev);
 out_link:
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index e56a4de..7dd370f 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -106,7 +106,6 @@ static int parport_probe(struct pcmcia_device *link)
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 1f33ed6..e10b883 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -383,8 +383,8 @@ static int pcmcia_release_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 		s->irq.AssignedIRQ = 0;
 	}
 
-	if (req->Attributes & IRQ_HANDLE_PRESENT) {
-		free_irq(req->AssignedIRQ, req->Instance);
+	if (req->Handler) {
+		free_irq(req->AssignedIRQ, p_dev->priv);
 	}
 
 #ifdef CONFIG_PCMCIA_PROBE
@@ -664,7 +664,7 @@ int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 	/* if the underlying IRQ infrastructure allows for it, only allocate
 	 * the IRQ, but do not enable it
 	 */
-	if (!(req->Attributes & IRQ_HANDLE_PRESENT))
+	if (!(req->Handler))
 		type |= IRQ_NOAUTOEN;
 #endif /* IRQ_NOAUTOEN */
 
@@ -674,7 +674,7 @@ int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 	} else {
 		int try;
 		u32 mask = s->irq_mask;
-		void *data = &p_dev->dev.driver; /* something unique to this device */
+		void *data = p_dev; /* something unique to this device */
 
 		for (try = 0; try < 64; try++) {
 			irq = try % 32;
@@ -691,12 +691,12 @@ int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 			 * registering a dummy handle works, i.e. if the IRQ isn't
 			 * marked as used by the kernel resource management core */
 			ret = request_irq(irq,
-					  (req->Attributes & IRQ_HANDLE_PRESENT) ? req->Handler : test_action,
+					  (req->Handler) ? req->Handler : test_action,
 					  type,
 					  p_dev->devname,
-					  (req->Attributes & IRQ_HANDLE_PRESENT) ? req->Instance : data);
+					  (req->Handler) ? p_dev->priv : data);
 			if (!ret) {
-				if (!(req->Attributes & IRQ_HANDLE_PRESENT))
+				if (!req->Handler)
 					free_irq(irq, data);
 				break;
 			}
@@ -713,9 +713,9 @@ int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 		irq = s->pci_irq;
 	}
 
-	if (ret && (req->Attributes & IRQ_HANDLE_PRESENT)) {
+	if (ret && req->Handler) {
 		ret = request_irq(irq, req->Handler, type,
-				  p_dev->devname, req->Instance);
+				  p_dev->devname, p_dev->priv);
 		if (ret) {
 			dev_printk(KERN_INFO, &s->dev,
 				"request_irq() failed\n");
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index 4329e4e..528733b 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -106,7 +106,6 @@ static int aha152x_probe(struct pcmcia_device *link)
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 10;
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 5792b55..9140406 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -89,7 +89,6 @@ static int fdomain_probe(struct pcmcia_device *link)
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.IOAddrLines = 10;
 	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 9dfd6f5..c2341af 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1564,12 +1564,10 @@ static int nsp_cs_probe(struct pcmcia_device *link)
 	link->io.IOAddrLines	 = 10;	/* not used */
 
 	/* Interrupt setup */
-	link->irq.Attributes	 = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1	 = IRQ_LEVEL_ID;
+	link->irq.Attributes	 = IRQ_TYPE_EXCLUSIVE;
 
 	/* Interrupt handler */
 	link->irq.Handler	 = &nspintr;
-	link->irq.Instance       = info;
 	link->irq.Attributes     |= IRQF_SHARED;
 
 	/* General socket configuration */
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 65d7ad5..f85f094 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -162,7 +162,6 @@ static int qlogic_probe(struct pcmcia_device *link)
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.IOAddrLines = 10;
 	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 851a41c..e7564d8 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -867,7 +867,6 @@ SYM53C500_probe(struct pcmcia_device *link)
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.IOAddrLines = 10;
 	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 8d651a6..5d6f947 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -334,7 +334,6 @@ static int serial_probe(struct pcmcia_device *link)
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
 	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	if (do_sound) {
 		link->conf.Attributes |= CONF_ENABLE_SPKR;
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index 9e75802..39923cb 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -703,7 +703,6 @@ static int das16cs_pcmcia_attach(struct pcmcia_device *link)
 	/* Initialize the pcmcia_device structure */
 	/* Interrupt setup */
 	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->irq.Handler = NULL;
 
 	link->conf.Attributes = 0;
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index 384a77a..9b945e5 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -173,7 +173,6 @@ static int das08_pcmcia_attach(struct pcmcia_device *link)
 
 	/* Interrupt setup */
 	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->irq.Handler = NULL;
 
 	/*
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 7328a84..ef5e118 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -503,7 +503,6 @@ static int dio700_cs_attach(struct pcmcia_device *link)
 
 	/* Interrupt setup */
 	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->irq.Handler = NULL;
 
 	/*
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 5056315..9017be3 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -254,7 +254,6 @@ static int dio24_cs_attach(struct pcmcia_device *link)
 
 	/* Interrupt setup */
 	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->irq.Handler = NULL;
 
 	/*
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 7fb5058..7d514b3 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -230,7 +230,6 @@ static int labpc_cs_attach(struct pcmcia_device *link)
 
 	/* Interrupt setup */
 	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_FORCED_PULSE;
-	link->irq.IRQInfo1 = IRQ_INFO2_VALID | IRQ_PULSE_ID;
 	link->irq.Handler = NULL;
 
 	/*
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index ca7ab4a..d692f4b 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -274,7 +274,6 @@ static int cs_attach(struct pcmcia_device *link)
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
 	link->io.NumPorts1 = 16;
 	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -325,9 +324,6 @@ static int mio_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	p_dev->io.IOAddrLines = cfg->io.flags & CISTPL_IO_LINES_MASK;
 	p_dev->io.NumPorts2 = 0;
 
-	p_dev->irq.IRQInfo1 = cfg->irq.IRQInfo1;
-	p_dev->irq.IRQInfo2 = cfg->irq.IRQInfo2;
-
 	for (base = 0x000; base < 0x400; base += 0x20) {
 		p_dev->io.BasePort1 = base;
 		ret = pcmcia_request_io(p_dev, &p_dev->io);
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index 48e7c27..5256fd9 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1041,10 +1041,8 @@ static int daqp_cs_attach(struct pcmcia_device *link)
 	link->priv = local;
 
 	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->irq.Handler = daqp_interrupt;
-	link->irq.Instance = local;
 
 	/*
 	   General socket configuration defaults can go here.  In this
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index f87aba6..39d253e 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -243,7 +243,6 @@ static int sl811_cs_probe(struct pcmcia_device *link)
 
 	/* Initialize */
 	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	link->irq.IRQInfo1 = IRQ_INFO2_VALID|IRQ_LEVEL_ID;
 	link->irq.Handler = NULL;
 
 	link->conf.Attributes = 0;
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 904468a..afc2bfb 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -15,6 +15,10 @@
 #ifndef _LINUX_CS_H
 #define _LINUX_CS_H
 
+#ifdef __KERNEL__
+#include <linux/interrupt.h>
+#endif
+
 /* For AccessConfigurationRegister */
 typedef struct conf_reg_t {
     u_char	Function;
@@ -111,11 +115,9 @@ typedef struct io_req_t {
 
 /* For RequestIRQ and ReleaseIRQ */
 typedef struct irq_req_t {
-    u_int	Attributes;
-    u_int	AssignedIRQ;
-    u_int	IRQInfo1, IRQInfo2; /* IRQInfo2 is ignored */
-    void	*Handler;
-    void	*Instance;
+	u_int		Attributes;
+	u_int		AssignedIRQ;
+	irq_handler_t	Handler;
 } irq_req_t;
 
 /* Attributes for RequestIRQ and ReleaseIRQ */
@@ -125,7 +127,7 @@ typedef struct irq_req_t {
 #define IRQ_TYPE_DYNAMIC_SHARING	0x02
 #define IRQ_FORCED_PULSE		0x04
 #define IRQ_FIRST_SHARED		0x08
-#define IRQ_HANDLE_PRESENT		0x10
+//#define IRQ_HANDLE_PRESENT		0x10
 #define IRQ_PULSE_ALLOCATED		0x100
 
 /* Bits in IRQInfo1 field */
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 447aaae..7717e01 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -142,12 +142,10 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.NumPorts1 = 16;
 
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT | IRQ_FORCED_PULSE;
+	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_FORCED_PULSE;
 	// link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
 
-	link->irq.IRQInfo1 = 0 /* | IRQ_LEVEL_ID */;
 	link->irq.Handler = pdacf_interrupt;
-	link->irq.Instance = pdacf;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index 5a5db48..7be3b33 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -161,11 +161,9 @@ static int snd_vxpocket_new(struct snd_card *card, int ibl,
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.NumPorts1 = 16;
 
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
+	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
 
-	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->irq.Handler = &snd_vx_irq_handler;
-	link->irq.Instance = chip;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
-- 
1.6.0.4

