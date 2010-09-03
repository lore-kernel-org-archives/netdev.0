From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 06/15] pcmcia: simplify IntType
Date: Fri,  3 Sep 2010 12:57:05 +0200
Message-ID: <1283511434-21620-6-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-usb@vger.kernel.org,
	laforge@gnumonks.org, linux-mtd@lists.infradead.org,
	linux-bluetooth@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-serial@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	linux-scsi@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:44078 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757471Ab0ICK57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 06:57:59 -0400
In-Reply-To: <20100903105628.GA21255@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IntType was only set to INT_MEMORY (driver pcmciamtd) or INT_MEMORY_AND_IO
(all other drivers). As this flags seems to relate to ioport access, make
it conditional to the driver having requested IO port access. There are two
drivers which do not request IO ports, but did set INT_MEMORY_AND_IO:
ray_cs and b43. For those, we consistently only set INT_MEMORY in future.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-ide@vger.kernel.org
CC: linux-usb@vger.kernel.org
CC: laforge@gnumonks.org
CC: linux-mtd@lists.infradead.org
CC: linux-bluetooth@vger.kernel.org
CC: alsa-devel@alsa-project.org
CC: linux-serial@vger.kernel.org
CC: Jiri Kosina <jkosina@suse.cz>
CC: linux-scsi@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/ata/pata_pcmcia.c                        |    1 -
 drivers/bluetooth/bluecard_cs.c                  |    1 -
 drivers/bluetooth/bt3c_cs.c                      |    1 -
 drivers/bluetooth/btuart_cs.c                    |    1 -
 drivers/bluetooth/dtl1_cs.c                      |    1 -
 drivers/char/pcmcia/cm4000_cs.c                  |    3 ---
 drivers/char/pcmcia/cm4040_cs.c                  |    3 ---
 drivers/char/pcmcia/ipwireless/main.c            |    1 -
 drivers/char/pcmcia/synclink_cs.c                |    2 --
 drivers/ide/ide-cs.c                             |    1 -
 drivers/isdn/hardware/avm/avm_cs.c               |    1 -
 drivers/isdn/hisax/avma1_cs.c                    |    1 -
 drivers/isdn/hisax/elsa_cs.c                     |    1 -
 drivers/isdn/hisax/sedlbauer_cs.c                |    1 -
 drivers/isdn/hisax/teles_cs.c                    |    1 -
 drivers/mtd/maps/pcmciamtd.c                     |    2 --
 drivers/net/pcmcia/3c574_cs.c                    |    1 -
 drivers/net/pcmcia/3c589_cs.c                    |    1 -
 drivers/net/pcmcia/axnet_cs.c                    |    1 -
 drivers/net/pcmcia/com20020_cs.c                 |    1 -
 drivers/net/pcmcia/fmvj18x_cs.c                  |    1 -
 drivers/net/pcmcia/ibmtr_cs.c                    |    1 -
 drivers/net/pcmcia/nmclan_cs.c                   |    1 -
 drivers/net/pcmcia/pcnet_cs.c                    |    1 -
 drivers/net/pcmcia/smc91c92_cs.c                 |    1 -
 drivers/net/pcmcia/xirc2ps_cs.c                  |    1 -
 drivers/net/wireless/airo_cs.c                   |    1 -
 drivers/net/wireless/atmel_cs.c                  |    1 -
 drivers/net/wireless/b43/pcmcia.c                |    1 -
 drivers/net/wireless/hostap/hostap_cs.c          |    1 -
 drivers/net/wireless/libertas/if_cs.c            |    1 -
 drivers/net/wireless/orinoco/orinoco_cs.c        |    1 -
 drivers/net/wireless/orinoco/spectrum_cs.c       |    1 -
 drivers/net/wireless/ray_cs.c                    |    1 -
 drivers/net/wireless/wl3501_cs.c                 |    1 -
 drivers/parport/parport_cs.c                     |    1 -
 drivers/pcmcia/cs_internal.h                     |    1 -
 drivers/pcmcia/pcmcia_resource.c                 |   10 +---------
 drivers/scsi/pcmcia/aha152x_stub.c               |    1 -
 drivers/scsi/pcmcia/fdomain_stub.c               |    1 -
 drivers/scsi/pcmcia/nsp_cs.c                     |    1 -
 drivers/scsi/pcmcia/qlogic_stub.c                |    1 -
 drivers/scsi/pcmcia/sym53c500_cs.c               |    1 -
 drivers/serial/serial_cs.c                       |    2 --
 drivers/staging/comedi/drivers/cb_das16_cs.c     |    1 -
 drivers/staging/comedi/drivers/das08_cs.c        |    1 -
 drivers/staging/comedi/drivers/ni_daq_700.c      |    1 -
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |    1 -
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |    1 -
 drivers/staging/comedi/drivers/ni_mio_cs.c       |    1 -
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |    1 -
 drivers/staging/wlags49_h2/wl_cs.c               |    1 -
 drivers/telephony/ixj_pcmcia.c                   |    1 -
 drivers/usb/host/sl811_cs.c                      |    1 -
 include/pcmcia/cs.h                              |    7 -------
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    1 -
 sound/pcmcia/vx/vxpocket.c                       |    1 -
 57 files changed, 1 insertions(+), 78 deletions(-)

diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 12cdc9f..c2679c0 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -250,7 +250,6 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	pdev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	pdev->conf.Attributes = CONF_ENABLE_IRQ;
-	pdev->conf.IntType = INT_MEMORY_AND_IO;
 
 	/* See if we have a manufacturer identifier. Use it to set is_kme for
 	   vendor quirks */
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index d52e90a..4cb2dfe 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -866,7 +866,6 @@ static int bluecard_probe(struct pcmcia_device *link)
 	link->priv = info;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return bluecard_config(link);
 }
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 2c8d981..fb01807 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -661,7 +661,6 @@ static int bt3c_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 8;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return bt3c_config(link);
 }
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 7ea6fa4..897c7c7 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -590,7 +590,6 @@ static int btuart_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 8;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return btuart_config(link);
 }
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index db7c8db..b4c9a2e 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -576,7 +576,6 @@ static int dtl1_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 8;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return dtl1_config(link);
 }
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index ec73d9f..d2accd6 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -1767,8 +1767,6 @@ static int cm4000_config(struct pcmcia_device * link, int devno)
 	if (pcmcia_loop_config(link, cm4000_config_check, NULL))
 		goto cs_release;
 
-	link->conf.IntType = 00000002;
-
 	if (pcmcia_request_configuration(link, &link->conf))
 		goto cs_release;
 
@@ -1829,7 +1827,6 @@ static int cm4000_probe(struct pcmcia_device *link)
 
 	dev->p_dev = link;
 	link->priv = dev;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 	dev_table[i] = link;
 
 	init_waitqueue_head(&dev->devq);
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index 815cde1..a32eba0 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -547,8 +547,6 @@ static int reader_config(struct pcmcia_device *link, int devno)
 	if (pcmcia_loop_config(link, cm4040_config_check, NULL))
 		goto cs_release;
 
-	link->conf.IntType = 00000002;
-
 	fail_rc = pcmcia_request_configuration(link, &link->conf);
 	if (fail_rc != 0) {
 		dev_printk(KERN_INFO, &link->dev,
@@ -599,7 +597,6 @@ static int reader_probe(struct pcmcia_device *link)
 	link->priv = dev;
 	dev->p_dev = link;
 
-	link->conf.IntType = INT_MEMORY_AND_IO;
 	dev_table[i] = link;
 
 	init_waitqueue_head(&dev->devq);
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 8d2b86a..0f0be4d 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -173,7 +173,6 @@ static int config_ipwireless(struct ipw_dev *ipw)
 		return ret;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	INIT_WORK(&ipw->work_reboot, signalled_reboot_work);
 
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 9ecd6be..ba7ccf5 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -551,7 +551,6 @@ static int mgslpc_probe(struct pcmcia_device *link)
     /* Initialize the struct pcmcia_device structure */
 
     link->conf.Attributes = 0;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     ret = mgslpc_config(link);
     if (ret)
@@ -595,7 +594,6 @@ static int mgslpc_config(struct pcmcia_device *link)
 	    goto failed;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 8;
     link->conf.Present = PRESENT_OPTION;
 
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 82690e4..cf7cb49 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -100,7 +100,6 @@ static int ide_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     return ide_config(link);
 } /* ide_attach */
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 09b1795..938ca41 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -80,7 +80,6 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
-    p_dev->conf.IntType = INT_MEMORY_AND_IO;
     p_dev->conf.ConfigIndex = 1;
     p_dev->conf.Present = PRESENT_OPTION;
 
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 94263c2..7d5ff20 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -85,7 +85,6 @@ static int __devinit avma1cs_probe(struct pcmcia_device *p_dev)
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
-    p_dev->conf.IntType = INT_MEMORY_AND_IO;
     p_dev->conf.ConfigIndex = 1;
     p_dev->conf.Present = PRESENT_OPTION;
 
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index b3c08aa..df360c8 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -130,7 +130,6 @@ static int __devinit elsa_cs_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     return elsa_cs_config(link);
 } /* elsa_cs_attach */
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 40001ad..169061f 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -133,7 +133,6 @@ static int __devinit sedlbauer_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
     link->conf.Attributes = 0;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     return sedlbauer_config(link);
 } /* sedlbauer_attach */
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 7296102..46e72a1 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -110,7 +110,6 @@ static int __devinit teles_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     return teles_cs_config(link);
 } /* teles_attach */
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index ab94c8a..663b48b 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -575,7 +575,6 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 		link->vpp = 0;
 	}
 
-	link->conf.IntType = INT_MEMORY;
 	link->conf.ConfigIndex = 0;
 	DEBUG(2, "Setting Configuration");
 	ret = pcmcia_request_configuration(link, &link->conf);
@@ -720,7 +719,6 @@ static int pcmciamtd_probe(struct pcmcia_device *link)
 	link->priv = dev;
 
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY;
 
 	return pcmciamtd_config(link);
 }
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index c683f77..41ecb27 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -281,7 +281,6 @@ static int tc574_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 32;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
 
 	dev->netdev_ops = &el3_netdev_ops;
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 61f9cf2..6888672 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -217,7 +217,6 @@ static int tc589_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
 
     dev->netdev_ops = &el3_netdev_ops;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 8734ed8..4d4928a 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -167,7 +167,6 @@ static int axnet_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = dev;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     dev->netdev_ops = &axnet_netdev_ops;
 
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 3c400cf..a58eafe 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -161,7 +161,6 @@ static int com20020_probe(struct pcmcia_device *p_dev)
     p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
     p_dev->resource[0]->end = 16;
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
-    p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
     info->dev = dev;
     p_dev->priv = info;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index dfd3284..caf2b2e 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -253,7 +253,6 @@ static int fmvj18x_probe(struct pcmcia_device *link)
 
     /* General socket configuration */
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     dev->netdev_ops = &fjn_netdev_ops;
     dev->watchdog_timeo = TX_TIMEOUT;
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index dbdea7f..1327f08 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -153,7 +153,6 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[0]->end = 4;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
 
     info->dev = dev;
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 68f2dee..90d1728 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -461,7 +461,6 @@ static int nmclan_probe(struct pcmcia_device *link)
     link->resource[0]->end = 32;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
     link->conf.Present = PRESENT_OPTION;
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 1dd0dfa..0924ed6 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -261,7 +261,6 @@ static int pcnet_probe(struct pcmcia_device *link)
     link->priv = dev;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     dev->netdev_ops = &pcnet_netdev_ops;
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 2031a27..2c2a878 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -327,7 +327,6 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->resource[0]->end = 16;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     /* The SMC91c92-specific entries in the device structure. */
     dev->netdev_ops = &smc_netdev_ops;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 59398a6..1776f49 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -530,7 +530,6 @@ xirc2ps_probe(struct pcmcia_device *link)
 
     /* General socket configuration */
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
 
     /* Fill in card specific entries */
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index ab60f10..ccb2fdd 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -104,7 +104,6 @@ static int airo_probe(struct pcmcia_device *p_dev)
 	  device, and can be hard-wired here.
 	*/
 	p_dev->conf.Attributes = 0;
-	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
 	/* Allocate space for private device-specific data */
 	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index d6d585c..8b75158 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -114,7 +114,6 @@ static int atmel_probe(struct pcmcia_device *p_dev)
 	  device, and can be hard-wired here.
 	*/
 	p_dev->conf.Attributes = 0;
-	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
 	/* Allocate space for private device-specific data */
 	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 618d9b5..138b26f 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -73,7 +73,6 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	err = -ENODEV;
 
 	dev->conf.Attributes = CONF_ENABLE_IRQ;
-	dev->conf.IntType = INT_MEMORY_AND_IO;
 
 	dev->resource[2]->flags |=  WIN_ENABLE | WIN_DATA_WIDTH_16 |
 			 WIN_USE_WAIT;
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 3fa285b..0fe6f82 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -437,7 +437,6 @@ static int hostap_cs_probe(struct pcmcia_device *p_dev)
 	int ret;
 
 	PDEBUG(DEBUG_HW, "%s: setting Vcc=33 (constant)\n", dev_info);
-	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
 	ret = prism2_config(p_dev);
 	if (ret) {
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 9c29839..814b7fa 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -836,7 +836,6 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	p_dev->priv = card;
 
 	p_dev->conf.Attributes = 0;
-	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
 	if (pcmcia_loop_config(p_dev, if_cs_ioprobe, NULL)) {
 		lbs_pr_err("error in pcmcia_loop_config\n");
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index f7e3fa6..1147d6b 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -123,7 +123,6 @@ orinoco_cs_probe(struct pcmcia_device *link)
 	 * number, sizes, and attributes of IO windows) are fixed by
 	 * the nature of the device, and can be hard-wired here. */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return orinoco_cs_config(link);
 }				/* orinoco_cs_attach */
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 1bbad10..20b08ab 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -185,7 +185,6 @@ spectrum_cs_probe(struct pcmcia_device *link)
 	 * number, sizes, and attributes of IO windows) are fixed by
 	 * the nature of the device, and can be hard-wired here. */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return spectrum_cs_config(link);
 }				/* spectrum_cs_attach */
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index ab34cb8..30cfd88 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -319,7 +319,6 @@ static int ray_probe(struct pcmcia_device *p_dev)
 
 	/* General socket configuration */
 	p_dev->conf.Attributes = CONF_ENABLE_IRQ;
-	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 	p_dev->conf.ConfigIndex = 1;
 
 	p_dev->priv = dev;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index a1cc2d4..92a9ad5 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1889,7 +1889,6 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 
 	/* General socket configuration */
 	p_dev->conf.Attributes	= CONF_ENABLE_IRQ;
-	p_dev->conf.IntType	= INT_MEMORY_AND_IO;
 	p_dev->conf.ConfigIndex	= 1;
 
 	dev = alloc_etherdev(sizeof(struct wl3501_card));
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index 23e50f4..afd946e 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -104,7 +104,6 @@ static int parport_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
 
     return parport_config(link);
 } /* parport_attach */
diff --git a/drivers/pcmcia/cs_internal.h b/drivers/pcmcia/cs_internal.h
index 7ef464d..a0c5adb 100644
--- a/drivers/pcmcia/cs_internal.h
+++ b/drivers/pcmcia/cs_internal.h
@@ -34,7 +34,6 @@ typedef struct config_t {
 	struct kref	ref;
 	unsigned int	state;
 	unsigned int	Attributes;
-	unsigned int	IntType;
 	unsigned int	ConfigBase;
 	unsigned char	Option;
 	unsigned int	CardValues;
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index e119663..660f394 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -447,11 +447,6 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	if (!(s->state & SOCKET_PRESENT))
 		return -ENODEV;
 
-	if (req->IntType & INT_CARDBUS) {
-		dev_dbg(&s->dev, "IntType may not be INT_CARDBUS\n");
-		return -EINVAL;
-	}
-
 	mutex_lock(&s->ops_mutex);
 	c = p_dev->function_config;
 	if (c->state & CONFIG_LOCKED) {
@@ -470,12 +465,9 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	}
 
 	/* Pick memory or I/O card, DMA mode, interrupt */
-	c->IntType = req->IntType;
 	c->Attributes = req->Attributes;
-	if (req->IntType & INT_MEMORY_AND_IO)
+	if (p_dev->_io)
 		s->socket.flags |= SS_IOCARD;
-	if (req->IntType & INT_ZOOMED_VIDEO)
-		s->socket.flags |= SS_ZVCARD | SS_IOCARD;
 	if (req->Attributes & CONF_ENABLE_DMA)
 		s->socket.flags |= SS_DMA_MODE;
 	if (req->Attributes & CONF_ENABLE_SPKR) {
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index 61f49bd..3c0046e 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -103,7 +103,6 @@ static int aha152x_probe(struct pcmcia_device *link)
     link->resource[0]->end = 0x20;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
 
     return aha152x_config_cs(link);
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 13dbe5c..8ff7603 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -86,7 +86,6 @@ static int fdomain_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 0x10;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
 
 	return fdomain_config(link);
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index e14fcd1..7059526 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1563,7 +1563,6 @@ static int nsp_cs_probe(struct pcmcia_device *link)
 
 	/* General socket configuration */
 	link->conf.Attributes	 = CONF_ENABLE_IRQ;
-	link->conf.IntType	 = INT_MEMORY_AND_IO;
 
 	ret = nsp_cs_config(link);
 
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index eb775f1..77f46a2 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -159,7 +159,6 @@ static int qlogic_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 16;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
 
 	return qlogic_config(link);
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 321e390..9aaf974 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -862,7 +862,6 @@ SYM53C500_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 16;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return SYM53C500_config(link);
 } /* SYM53C500_attach */
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 8035f1e..a1906b5 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -337,8 +337,6 @@ static int serial_probe(struct pcmcia_device *link)
 	if (do_sound)
 		link->conf.Attributes |= CONF_ENABLE_SPKR;
 
-	link->conf.IntType = INT_MEMORY_AND_IO;
-
 	return serial_config(link);
 }
 
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index f8ede11..11271b6 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -694,7 +694,6 @@ static int das16cs_pcmcia_attach(struct pcmcia_device *link)
 
 	/* Initialize the pcmcia_device structure */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	cur_dev = link;
 
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index 48d9fb1..319aad4 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -170,7 +170,6 @@ static int das08_pcmcia_attach(struct pcmcia_device *link)
 	   device, and can be hard-wired here.
 	 */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	cur_dev = link;
 
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 8cf56cb..d269bbd 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -499,7 +499,6 @@ static int dio700_cs_attach(struct pcmcia_device *link)
 	   device, and can be hard-wired here.
 	 */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	pcmcia_cur_dev = link;
 
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index ba69343..fcaa829 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -251,7 +251,6 @@ static int dio24_cs_attach(struct pcmcia_device *link)
 	   device, and can be hard-wired here.
 	 */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	pcmcia_cur_dev = link;
 
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 5d5f11f..a936c11 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -227,7 +227,6 @@ static int labpc_cs_attach(struct pcmcia_device *link)
 	   device, and can be hard-wired here.
 	 */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	pcmcia_cur_dev = link;
 
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index 1f24263..be7e021 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -266,7 +266,6 @@ static int cs_attach(struct pcmcia_device *link)
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 	link->resource[0]->end = 16;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	cur_dev = link;
 
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index bf489d7..cd818fb 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1039,7 +1039,6 @@ static int daqp_cs_attach(struct pcmcia_device *link)
 	   device, and can be hard-wired here.
 	 */
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	daqp_cs_config(link);
 
diff --git a/drivers/staging/wlags49_h2/wl_cs.c b/drivers/staging/wlags49_h2/wl_cs.c
index 19c3354..b2efff6 100644
--- a/drivers/staging/wlags49_h2/wl_cs.c
+++ b/drivers/staging/wlags49_h2/wl_cs.c
@@ -148,7 +148,6 @@ static int wl_adapter_attach(struct pcmcia_device *link)
 	link->resource[0]->end  = HCF_NUM_IO_PORTS;
 	link->resource[0]->flags= IO_DATA_PATH_WIDTH_16;
 	link->conf.Attributes   = CONF_ENABLE_IRQ;
-	link->conf.IntType      = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex  = 5;
 	link->conf.Present      = PRESENT_OPTION;
 
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index a1900e5..5ccc6d0 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -34,7 +34,6 @@ static int ixj_probe(struct pcmcia_device *p_dev)
 	/* Create new ixj device */
 	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 	p_dev->priv = kzalloc(sizeof(struct ixj_info_t), GFP_KERNEL);
 	if (!p_dev->priv) {
 		return -ENOMEM;
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 8e84752..78bad51 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -228,7 +228,6 @@ static int sl811_cs_probe(struct pcmcia_device *link)
 	link->priv = local;
 
 	link->conf.Attributes = 0;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return sl811_cs_config(link);
 }
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 29d693f..674edbc 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -22,7 +22,6 @@
 /* For RequestConfiguration */
 typedef struct config_req_t {
     u_int	Attributes;
-    u_int	IntType;
     u_int	ConfigBase;
     u_char	ConfigIndex;
     u_int	Present;
@@ -36,12 +35,6 @@ typedef struct config_req_t {
 #define CONF_ENABLE_ESR		0x10
 #define CONF_VALID_CLIENT	0x100
 
-/* IntType field */
-#define INT_MEMORY		0x01
-#define INT_MEMORY_AND_IO	0x02
-#define INT_CARDBUS		0x04
-#define INT_ZOOMED_VIDEO	0x08
-
 /* Configuration registers present */
 #define PRESENT_OPTION		0x001
 #define PRESENT_STATUS		0x002
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 7ab9174..2e1282d 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -143,7 +143,6 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 16;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
 	link->conf.Present = PRESENT_OPTION;
 
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index a6edfc3..a48b3ee 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -163,7 +163,6 @@ static int snd_vxpocket_new(struct snd_card *card, int ibl,
 	link->resource[0]->end = 16;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
 	link->conf.Present = PRESENT_OPTION;
 
-- 
1.7.0.4

