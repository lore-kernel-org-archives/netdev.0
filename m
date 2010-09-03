From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 07/15] pcmcia: move config_{base, index,
	regs} to struct pcmcia_device
Date: Fri,  3 Sep 2010 12:57:06 +0200
Message-ID: <1283511434-21620-7-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-scsi@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	laforge@gnumonks.org, linux-ide@vger.kernel.org,
	linux-mtd@lists.infradead.org,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-serial@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20100903105628.GA21255@comet.dominikbrodowski.net>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Several drivers prefer to explicitly set config_{base,index,regs},
formerly known as ConfigBase, ConfigIndex and Present. Instead of
passing these values inside config_req_t, store it in struct
pcmcia_device.

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
 drivers/bluetooth/bluecard_cs.c                  |    2 +-
 drivers/char/pcmcia/ipwireless/main.c            |    2 +-
 drivers/char/pcmcia/synclink_cs.c                |    6 ++--
 drivers/ide/ide-cs.c                             |    3 +-
 drivers/isdn/hardware/avm/avm_cs.c               |    4 +-
 drivers/isdn/hisax/avma1_cs.c                    |    4 +-
 drivers/isdn/hisax/elsa_cs.c                     |    2 +-
 drivers/isdn/hisax/sedlbauer_cs.c                |    2 +-
 drivers/isdn/hisax/teles_cs.c                    |    2 +-
 drivers/mtd/maps/pcmciamtd.c                     |    2 +-
 drivers/net/pcmcia/3c574_cs.c                    |    2 +-
 drivers/net/pcmcia/3c589_cs.c                    |    2 +-
 drivers/net/pcmcia/axnet_cs.c                    |    6 ++--
 drivers/net/pcmcia/fmvj18x_cs.c                  |   22 ++++++------
 drivers/net/pcmcia/ibmtr_cs.c                    |    4 +-
 drivers/net/pcmcia/nmclan_cs.c                   |    4 +-
 drivers/net/pcmcia/pcnet_cs.c                    |    6 ++--
 drivers/net/pcmcia/smc91c92_cs.c                 |   10 +++---
 drivers/net/pcmcia/xirc2ps_cs.c                  |    2 +-
 drivers/net/wireless/airo_cs.c                   |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c          |    2 +-
 drivers/net/wireless/ray_cs.c                    |    2 +-
 drivers/net/wireless/wl3501_cs.c                 |    2 +-
 drivers/parport/parport_cs.c                     |    2 +-
 drivers/pcmcia/cs_internal.h                     |    3 --
 drivers/pcmcia/ds.c                              |    8 ++--
 drivers/pcmcia/pcmcia_cis.c                      |    2 +-
 drivers/pcmcia/pcmcia_resource.c                 |   38 +++++++++++-----------
 drivers/scsi/pcmcia/aha152x_stub.c               |    2 +-
 drivers/scsi/pcmcia/fdomain_stub.c               |    2 +-
 drivers/scsi/pcmcia/nsp_cs.c                     |    2 +-
 drivers/scsi/pcmcia/qlogic_stub.c                |    2 +-
 drivers/serial/serial_cs.c                       |    6 ++--
 drivers/staging/comedi/drivers/cb_das16_cs.c     |    2 +-
 drivers/staging/comedi/drivers/das08_cs.c        |    2 +-
 drivers/staging/comedi/drivers/ni_daq_700.c      |    2 +-
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |    2 +-
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |    2 +-
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |    2 +-
 drivers/staging/wlags49_h2/wl_cs.c               |    4 +-
 drivers/usb/host/sl811_cs.c                      |    2 +-
 include/pcmcia/cs.h                              |   15 --------
 include/pcmcia/ds.h                              |   14 ++++++++
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    6 ++--
 sound/pcmcia/vx/vxpocket.c                       |    4 +-
 45 files changed, 107 insertions(+), 112 deletions(-)

diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 4cb2dfe..08f4818 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -885,7 +885,7 @@ static int bluecard_config(struct pcmcia_device *link)
 	bluecard_info_t *info = link->priv;
 	int i, n;
 
-	link->conf.ConfigIndex = 0x20;
+	link->config_index = 0x20;
 
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	link->resource[0]->end = 64;
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 0f0be4d..05c4e68 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -92,7 +92,7 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 
 	/* 0x40 causes it to generate level mode interrupts. */
 	/* 0x04 enables IREQ pin. */
-	p_dev->conf.ConfigIndex = cfg->index | 0x44;
+	p_dev->config_index = cfg->index | 0x44;
 	p_dev->io_lines = 16;
 	ret = pcmcia_request_io(p_dev);
 	if (ret)
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index ba7ccf5..535aa08 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -594,8 +594,8 @@ static int mgslpc_config(struct pcmcia_device *link)
 	    goto failed;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.ConfigIndex = 8;
-    link->conf.Present = PRESENT_OPTION;
+    link->config_index = 8;
+    link->config_regs = PRESENT_OPTION;
 
     ret = pcmcia_request_irq(link, mgslpc_isr);
     if (ret)
@@ -608,7 +608,7 @@ static int mgslpc_config(struct pcmcia_device *link)
     info->irq_level = link->irq;
 
     dev_info(&link->dev, "index 0x%02x:",
-	    link->conf.ConfigIndex);
+	    link->config_index);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	    printk(", irq %d", link->irq);
     if (link->resource[0])
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index cf7cb49..07e3787 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -227,8 +227,7 @@ static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
 		pdev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-
-		pdev->conf.ConfigIndex = cfg->index;
+		pdev->config_index = cfg->index;
 		pdev->resource[0]->start = io->win[0].base;
 		if (!(io->flags & CISTPL_IO_16BIT)) {
 			pdev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 938ca41..2d8bbbf 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -80,8 +80,8 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
-    p_dev->conf.ConfigIndex = 1;
-    p_dev->conf.Present = PRESENT_OPTION;
+    p_dev->config_index = 1;
+    p_dev->config_regs = PRESENT_OPTION;
 
     return avmcs_config(p_dev);
 } /* avmcs_attach */
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 7d5ff20..e25f6c7 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -85,8 +85,8 @@ static int __devinit avma1cs_probe(struct pcmcia_device *p_dev)
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
-    p_dev->conf.ConfigIndex = 1;
-    p_dev->conf.Present = PRESENT_OPTION;
+    p_dev->config_index = 1;
+    p_dev->config_regs = PRESENT_OPTION;
 
     return avma1cs_config(p_dev);
 } /* avma1cs_attach */
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index df360c8..f276e84 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -211,7 +211,7 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
 
     /* Finally, report what we've done */
     dev_info(&link->dev, "index 0x%02x: ",
-	    link->conf.ConfigIndex);
+	    link->config_index);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	printk(", irq %d", link->irq);
     if (link->resource[0])
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 169061f..43d0a4e 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -253,7 +253,7 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
 
     /* Finally, report what we've done */
     dev_info(&link->dev, "index 0x%02x:",
-	   link->conf.ConfigIndex);
+	   link->config_index);
     if (link->vpp)
 	printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 46e72a1..614afc6 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -191,7 +191,7 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
 
     /* Finally, report what we've done */
     dev_info(&link->dev, "index 0x%02x:",
-	    link->conf.ConfigIndex);
+	    link->config_index);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	    printk(", irq %d", link->irq);
     if (link->resource[0])
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 663b48b..99c7257 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -575,7 +575,7 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 		link->vpp = 0;
 	}
 
-	link->conf.ConfigIndex = 0;
+	link->config_index = 0;
 	DEBUG(2, "Setting Configuration");
 	ret = pcmcia_request_configuration(link, &link->conf);
 	if (ret != 0) {
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 41ecb27..4b670b3 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -281,7 +281,7 @@ static int tc574_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 32;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.ConfigIndex = 1;
+	link->config_index = 1;
 
 	dev->netdev_ops = &el3_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 6888672..6549e2c 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -217,7 +217,7 @@ static int tc589_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.ConfigIndex = 1;
+    link->config_index = 1;
 
     dev->netdev_ops = &el3_netdev_ops;
     dev->watchdog_timeo = TX_TIMEOUT;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 4d4928a..2c273ce 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -230,7 +230,7 @@ static int get_prom(struct pcmcia_device *link)
     };
 
     /* Not much of a test, but the alternatives are messy */
-    if (link->conf.ConfigBase != 0x03c0)
+    if (link->config_base != 0x03c0)
 	return 0;
 
     axnet_reset_8390(dev);
@@ -297,7 +297,7 @@ static int axnet_configcheck(struct pcmcia_device *p_dev,
 	if (cfg->index == 0 || cfg->io.nwin == 0)
 		return -ENODEV;
 
-	p_dev->conf.ConfigIndex = 0x05;
+	p_dev->config_index = 0x05;
 	/* For multifunction cards, by convention, we configure the
 	   network function with window 0, and serial with window 1 */
 	if (io->nwin > 1) {
@@ -325,7 +325,7 @@ static int axnet_config(struct pcmcia_device *link)
     dev_dbg(&link->dev, "axnet_config(0x%p)\n", link);
 
     /* don't trust the CIS on this; Linksys got it wrong */
-    link->conf.Present = 0x63;
+    link->config_regs = 0x63;
     ret = pcmcia_loop_config(link, axnet_configcheck, NULL);
     if (ret != 0)
 	goto failed;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index caf2b2e..23f5333 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -312,7 +312,7 @@ static int ungermann_try_io_port(struct pcmcia_device *link)
 	ret = pcmcia_request_io(link);
 	if (ret == 0) {
 	    /* calculate ConfigIndex value */
-	    link->conf.ConfigIndex = 
+	    link->config_index =
 		((link->resource[0]->start & 0x0f0) >> 3) | 0x22;
 	    return ret;
 	}
@@ -361,28 +361,28 @@ static int fmvj18x_config(struct pcmcia_device *link)
 		link->card_id == PRODID_TDK_NP9610 ||
 		link->card_id == PRODID_TDK_MN3200) {
 		/* MultiFunction Card */
-		link->conf.ConfigBase = 0x800;
-		link->conf.ConfigIndex = 0x47;
+		link->config_base = 0x800;
+		link->config_index = 0x47;
 		link->resource[1]->end = 8;
 	    }
 	    break;
 	case MANFID_NEC:
 	    cardtype = NEC; /* MultiFunction Card */
-	    link->conf.ConfigBase = 0x800;
-	    link->conf.ConfigIndex = 0x47;
+	    link->config_base = 0x800;
+	    link->config_index = 0x47;
 	    link->resource[1]->end = 8;
 	    break;
 	case MANFID_KME:
 	    cardtype = KME; /* MultiFunction Card */
-	    link->conf.ConfigBase = 0x800;
-	    link->conf.ConfigIndex = 0x47;
+	    link->config_base = 0x800;
+	    link->config_index = 0x47;
 	    link->resource[1]->end = 8;
 	    break;
 	case MANFID_CONTEC:
 	    cardtype = CONTEC;
 	    break;
 	case MANFID_FUJITSU:
-	    if (link->conf.ConfigBase == 0x0fe0)
+	    if (link->config_base == 0x0fe0)
 		cardtype = MBH10302;
 	    else if (link->card_id == PRODID_FUJITSU_MBH10302) 
                 /* RATOC REX-5588/9822/4886's PRODID are 0004(=MBH10302),
@@ -402,10 +402,10 @@ static int fmvj18x_config(struct pcmcia_device *link)
 	case MANFID_FUJITSU:
 	    if (link->card_id == PRODID_FUJITSU_MBH10304) {
 		cardtype = XXX10304;    /* MBH10304 with buggy CIS */
-	        link->conf.ConfigIndex = 0x20;
+		link->config_index = 0x20;
 	    } else {
 		cardtype = MBH10302;    /* NextCom NC5310, etc. */
-		link->conf.ConfigIndex = 1;
+		link->config_index = 1;
 	    }
 	    break;
 	case MANFID_UNGERMANN:
@@ -413,7 +413,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
 	    break;
 	default:
 	    cardtype = MBH10302;
-	    link->conf.ConfigIndex = 1;
+	    link->config_index = 1;
 	}
     }
 
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 1327f08..feedeeb 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -153,7 +153,7 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[0]->end = 4;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.Present = PRESENT_OPTION;
+    link->config_regs = PRESENT_OPTION;
 
     info->dev = dev;
 
@@ -212,8 +212,8 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "ibmtr_config\n");
 
-    link->conf.ConfigIndex = 0x61;
     link->io_lines = 16;
+    link->config_index = 0x61;
 
     /* Determine if this is PRIMARY or ALTERNATE. */
 
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 90d1728..98c4a69 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -461,8 +461,8 @@ static int nmclan_probe(struct pcmcia_device *link)
     link->resource[0]->end = 32;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.ConfigIndex = 1;
-    link->conf.Present = PRESENT_OPTION;
+    link->config_index = 1;
+    link->config_regs = PRESENT_OPTION;
 
     lp->tx_free_frames=AM2150_MAX_TX_FRAMES;
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 0924ed6..49f463f 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -420,7 +420,7 @@ static hw_info_t *get_ax88190(struct pcmcia_device *link)
     int i, j;
 
     /* Not much of a test, but the alternatives are messy */
-    if (link->conf.ConfigBase != 0x03c0)
+    if (link->config_base != 0x03c0)
 	return NULL;
 
     outb_p(0x01, ioaddr + EN0_DCFG);	/* Set word-wide access. */
@@ -557,7 +557,7 @@ static int pcnet_config(struct pcmcia_device *link)
 
     if ((link->manf_id == MANFID_IBM) &&
 	(link->card_id == PRODID_IBM_HOME_AND_AWAY))
-	link->conf.ConfigIndex |= 0x10;
+	link->config_index |= 0x10;
 
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
@@ -573,7 +573,7 @@ static int pcnet_config(struct pcmcia_device *link)
 	dev->if_port = 0;
     }
 
-    if ((link->conf.ConfigBase == 0x03c0) &&
+    if ((link->config_base == 0x03c0) &&
 	(link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
 	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
 	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 2c2a878..59f5034 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -411,9 +411,9 @@ static int mhz_3288_power(struct pcmcia_device *link)
     mdelay(200);
 
     /* Now read and write the COR... */
-    tmp = readb(smc->base + link->conf.ConfigBase + CISREG_COR);
+    tmp = readb(smc->base + link->config_base + CISREG_COR);
     udelay(5);
-    writeb(tmp, smc->base + link->conf.ConfigBase + CISREG_COR);
+    writeb(tmp, smc->base + link->config_base + CISREG_COR);
 
     return 0;
 }
@@ -464,7 +464,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 
     smc->base = ioremap(link->resource[2]->start,
 		    resource_size(link->resource[2]));
-    offset = (smc->manfid == MANFID_MOTOROLA) ? link->conf.ConfigBase : 0;
+    offset = (smc->manfid == MANFID_MOTOROLA) ? link->config_base : 0;
     i = pcmcia_map_mem_page(link, link->resource[2], offset);
     if ((i == 0) &&
 	(smc->manfid == MANFID_MEGAHERTZ) &&
@@ -643,8 +643,8 @@ static int osi_config(struct pcmcia_device *link)
     link->resource[1]->end = 8;
 
     /* Enable Hard Decode, LAN, Modem */
-    link->conf.ConfigIndex = 0x23;
     link->io_lines = 16;
+    link->config_index = 0x23;
 
     for (i = j = 0; j < 4; j++) {
 	link->resource[1]->start = com[j];
@@ -654,7 +654,7 @@ static int osi_config(struct pcmcia_device *link)
     }
     if (i != 0) {
 	/* Fallback: turn off hard decode */
-	link->conf.ConfigIndex = 0x03;
+	link->config_index = 0x03;
 	link->resource[1]->end = 0;
 	i = pcmcia_request_io(link);
     }
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 1776f49..1c8ebf2 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -530,7 +530,7 @@ xirc2ps_probe(struct pcmcia_device *link)
 
     /* General socket configuration */
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.ConfigIndex = 1;
+    link->config_index = 1;
 
     /* Fill in card specific entries */
     dev->netdev_ops = &netdev_ops;
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index ccb2fdd..40f9ed7 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -240,7 +240,7 @@ static int airo_config(struct pcmcia_device *link)
 
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x: ",
-	       link->conf.ConfigIndex);
+	       link->config_index);
 	if (link->vpp)
 		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
 	printk(", irq %d", link->irq);
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 0fe6f82..5704d3f 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -601,7 +601,7 @@ static int prism2_config(struct pcmcia_device *link)
 
 	/* Finally, report what we've done */
 	printk(KERN_INFO "%s: index 0x%02x: ",
-	       dev_info, link->conf.ConfigIndex);
+	       dev_info, link->config_index);
 	if (link->vpp)
 		printk(", Vpp %d.%d", link->vpp / 10,
 		       link->vpp % 10);
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 30cfd88..7fb66cc 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -319,7 +319,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 
 	/* General socket configuration */
 	p_dev->conf.Attributes = CONF_ENABLE_IRQ;
-	p_dev->conf.ConfigIndex = 1;
+	p_dev->config_index = 1;
 
 	p_dev->priv = dev;
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 92a9ad5..3947cf8 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1889,7 +1889,7 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 
 	/* General socket configuration */
 	p_dev->conf.Attributes	= CONF_ENABLE_IRQ;
-	p_dev->conf.ConfigIndex	= 1;
+	p_dev->config_index	= 1;
 
 	dev = alloc_etherdev(sizeof(struct wl3501_card));
 	if (!dev)
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index afd946e..8faf634 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -144,7 +144,7 @@ static int parport_config_check(struct pcmcia_device *p_dev,
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
 		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
 		if (epp_mode)
-			p_dev->conf.ConfigIndex |= FORCE_EPP_MODE;
+			p_dev->config_index |= FORCE_EPP_MODE;
 		p_dev->resource[0]->start = io->win[0].base;
 		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin == 2) {
diff --git a/drivers/pcmcia/cs_internal.h b/drivers/pcmcia/cs_internal.h
index a0c5adb..42eef43 100644
--- a/drivers/pcmcia/cs_internal.h
+++ b/drivers/pcmcia/cs_internal.h
@@ -34,9 +34,6 @@ typedef struct config_t {
 	struct kref	ref;
 	unsigned int	state;
 	unsigned int	Attributes;
-	unsigned int	ConfigBase;
-	unsigned char	Option;
-	unsigned int	CardValues;
 
 	struct resource io[MAX_IO_WIN]; /* io ports */
 	struct resource mem[MAX_WIN];   /* mem areas */
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 55570d9..00db600 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -276,13 +276,13 @@ static int pcmcia_device_probe(struct device *dev)
 	ret = pccard_read_tuple(p_dev->socket, p_dev->func, CISTPL_CONFIG,
 				&cis_config);
 	if (!ret) {
-		p_dev->conf.ConfigBase = cis_config.base;
-		p_dev->conf.Present = cis_config.rmask[0];
+		p_dev->config_base = cis_config.base;
+		p_dev->config_regs = cis_config.rmask[0];
 	} else {
 		dev_printk(KERN_INFO, dev,
 			   "pcmcia: could not parse base and rmask0 of CIS\n");
-		p_dev->conf.ConfigBase = 0;
-		p_dev->conf.Present = 0;
+		p_dev->config_base = 0;
+		p_dev->config_regs = 0;
 	}
 
 	ret = p_drv->probe(p_dev);
diff --git a/drivers/pcmcia/pcmcia_cis.c b/drivers/pcmcia/pcmcia_cis.c
index 0ac54da..ac47cc4 100644
--- a/drivers/pcmcia/pcmcia_cis.c
+++ b/drivers/pcmcia/pcmcia_cis.c
@@ -151,7 +151,7 @@ static int pcmcia_do_loop_config(tuple_t *tuple, cisparse_t *parse, void *priv)
 	struct pcmcia_cfg_mem *cfg_mem = priv;
 
 	/* default values */
-	cfg_mem->p_dev->conf.ConfigIndex = cfg->index;
+	cfg_mem->p_dev->config_index = cfg->index;
 	if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
 		cfg_mem->dflt = *cfg;
 
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 660f394..ff83ab1 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -168,7 +168,7 @@ static int pcmcia_access_config(struct pcmcia_device *p_dev,
 		return -EACCES;
 	}
 
-	addr = (c->ConfigBase + where) >> 1;
+	addr = (p_dev->config_base + where) >> 1;
 
 	ret = accessf(s, 1, addr, 1, val);
 
@@ -443,6 +443,7 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	pccard_io_map iomap;
 	unsigned char status = 0;
 	unsigned char ext_status = 0;
+	unsigned char option = 0;
 
 	if (!(s->state & SOCKET_PRESENT))
 		return -ENODEV;
@@ -473,7 +474,7 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	if (req->Attributes & CONF_ENABLE_SPKR) {
 		s->socket.flags |= SS_SPKR_ENA;
 		status = CCSR_AUDIO_ENA;
-		if (!(req->Present & PRESENT_STATUS))
+		if (!(p_dev->config_regs & PRESENT_STATUS))
 			dev_warn(&p_dev->dev, "speaker requested, but "
 					      "PRESENT_STATUS not set!\n");
 	}
@@ -482,54 +483,53 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	else
 		s->socket.io_irq = 0;
 	if (req->Attributes & CONF_ENABLE_ESR) {
-		req->Present |= PRESENT_EXT_STATUS;
+		p_dev->config_regs |= PRESENT_EXT_STATUS;
 		ext_status = ESR_REQ_ATTN_ENA;
 	}
 	s->ops->set_socket(s, &s->socket);
 	s->lock_count++;
 
 	/* Set up CIS configuration registers */
-	base = c->ConfigBase = req->ConfigBase;
-	c->CardValues = req->Present;
-	if (req->Present & PRESENT_COPY) {
+	base = p_dev->config_base;
+	if (p_dev->config_regs & PRESENT_COPY) {
 		u16 tmp = 0;
 		dev_warn(&p_dev->dev, "invalid write to CISREG_SCR\n");
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_SCR)>>1, 1, &tmp);
 	}
-	if (req->Present & PRESENT_PIN_REPLACE) {
+	if (p_dev->config_regs & PRESENT_PIN_REPLACE) {
 		u16 tmp = 0;
 		dev_warn(&p_dev->dev, "invalid write to CISREG_PRR\n");
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_PRR)>>1, 1, &tmp);
 	}
-	if (req->Present & PRESENT_OPTION) {
+	if (p_dev->config_regs & PRESENT_OPTION) {
 		if (s->functions == 1) {
-			c->Option = req->ConfigIndex & COR_CONFIG_MASK;
+			option = p_dev->config_index & COR_CONFIG_MASK;
 		} else {
-			c->Option = req->ConfigIndex & COR_MFC_CONFIG_MASK;
-			c->Option |= COR_FUNC_ENA|COR_IREQ_ENA;
-			if (req->Present & PRESENT_IOBASE_0)
-				c->Option |= COR_ADDR_DECODE;
+			option = p_dev->config_index & COR_MFC_CONFIG_MASK;
+			option |= COR_FUNC_ENA|COR_IREQ_ENA;
+			if (p_dev->config_regs & PRESENT_IOBASE_0)
+				option |= COR_ADDR_DECODE;
 		}
 		if ((req->Attributes & CONF_ENABLE_IRQ) &&
 			!(req->Attributes & CONF_ENABLE_PULSE_IRQ))
-			c->Option |= COR_LEVEL_REQ;
-		pcmcia_write_cis_mem(s, 1, (base + CISREG_COR)>>1, 1, &c->Option);
+			option |= COR_LEVEL_REQ;
+		pcmcia_write_cis_mem(s, 1, (base + CISREG_COR)>>1, 1, &option);
 		mdelay(40);
 	}
-	if (req->Present & PRESENT_STATUS)
+	if (p_dev->config_regs & PRESENT_STATUS)
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_CCSR)>>1, 1, &status);
 
-	if (req->Present & PRESENT_EXT_STATUS)
+	if (p_dev->config_regs & PRESENT_EXT_STATUS)
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_ESR)>>1, 1,
 					&ext_status);
 
-	if (req->Present & PRESENT_IOBASE_0) {
+	if (p_dev->config_regs & PRESENT_IOBASE_0) {
 		u8 b = c->io[0].start & 0xff;
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_IOBASE_0)>>1, 1, &b);
 		b = (c->io[0].start >> 8) & 0xff;
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_IOBASE_1)>>1, 1, &b);
 	}
-	if (req->Present & PRESENT_IOSIZE) {
+	if (p_dev->config_regs & PRESENT_IOSIZE) {
 		u8 b = resource_size(&c->io[0]) + resource_size(&c->io[1]) - 1;
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_IOSIZE)>>1, 1, &b);
 	}
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index 3c0046e..c368249 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -103,7 +103,7 @@ static int aha152x_probe(struct pcmcia_device *link)
     link->resource[0]->end = 0x20;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
-    link->conf.Present = PRESENT_OPTION;
+    link->config_regs = PRESENT_OPTION;
 
     return aha152x_config_cs(link);
 } /* aha152x_attach */
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 8ff7603..bb909e1 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -86,7 +86,7 @@ static int fdomain_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 0x10;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.Present = PRESENT_OPTION;
+	link->config_regs = PRESENT_OPTION;
 
 	return fdomain_config(link);
 } /* fdomain_attach */
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 7059526..a63c460 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1745,7 +1745,7 @@ static int nsp_cs_config(struct pcmcia_device *link)
 
 	/* Finally, report what we've done */
 	printk(KERN_INFO "nsp_cs: index 0x%02x: ",
-	       link->conf.ConfigIndex);
+	       link->config_index);
 	if (link->vpp) {
 		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
 	}
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 77f46a2..5e2cbe0 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -159,7 +159,7 @@ static int qlogic_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 16;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.Present = PRESENT_OPTION;
+	link->config_regs = PRESENT_OPTION;
 
 	return qlogic_config(link);
 }				/* qlogic_attach */
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index a1906b5..8f25cc1 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -493,7 +493,7 @@ static int simple_config(struct pcmcia_device *link)
 
 found_port:
 	if (info->multi && (info->manfid == MANFID_3COM))
-		link->conf.ConfigIndex &= ~(0x08);
+		link->config_index &= ~(0x08);
 
 	/*
 	 * Apply any configuration quirks.
@@ -590,8 +590,8 @@ static int multi_config(struct pcmcia_device *link)
 				info->prodid == PRODID_POSSIO_GCC)) {
 		int err;
 
-		if (link->conf.ConfigIndex == 1 ||
-		    link->conf.ConfigIndex == 3) {
+		if (link->config_index == 1 ||
+		    link->config_index == 3) {
 			err = setup_serial(link, info, base2,
 					link->irq);
 			base2 = link->resource[0]->start;;
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index 11271b6..034cbfc 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -772,7 +772,7 @@ static void das16cs_pcmcia_config(struct pcmcia_device *link)
 		goto failed;
 
 	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x", link->config_index);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %u", link->irq);
 	if (link->resource[0])
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index 319aad4..e37ea79 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -268,7 +268,7 @@ static void das08_pcmcia_config(struct pcmcia_device *link)
 		goto failed;
 
 	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x", link->config_index);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %u", link->irq);
 	if (link->resource[0])
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index d269bbd..8107e40 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -607,7 +607,7 @@ static void dio700_config(struct pcmcia_device *link)
 		goto failed;
 
 	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x", link->config_index);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
 	if (link->resource[0])
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index fcaa829..4f9daa3 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -358,7 +358,7 @@ static void dio24_config(struct pcmcia_device *link)
 		goto failed;
 
 	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x", link->config_index);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
 	if (link->resource[0])
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index a936c11..2e27a30 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -336,7 +336,7 @@ static void labpc_config(struct pcmcia_device *link)
 		goto failed;
 
 	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x", link->config_index);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
 	if (link->resource[0])
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index cd818fb..a2a32de 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1137,7 +1137,7 @@ static void daqp_cs_config(struct pcmcia_device *link)
 		goto failed;
 
 	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x", link->config_index);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %u", link->irq);
 	if (link->resource[0])
diff --git a/drivers/staging/wlags49_h2/wl_cs.c b/drivers/staging/wlags49_h2/wl_cs.c
index b2efff6..778800f 100644
--- a/drivers/staging/wlags49_h2/wl_cs.c
+++ b/drivers/staging/wlags49_h2/wl_cs.c
@@ -148,8 +148,8 @@ static int wl_adapter_attach(struct pcmcia_device *link)
 	link->resource[0]->end  = HCF_NUM_IO_PORTS;
 	link->resource[0]->flags= IO_DATA_PATH_WIDTH_16;
 	link->conf.Attributes   = CONF_ENABLE_IRQ;
-	link->conf.ConfigIndex  = 5;
-	link->conf.Present      = PRESENT_OPTION;
+	link->config_index      = 5;
+	link->config_regs       = PRESENT_OPTION;
 
 	link->priv = dev;
 	lp = wl_priv(dev);
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 78bad51..5904053 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -200,7 +200,7 @@ static int sl811_cs_config(struct pcmcia_device *link)
 		goto failed;
 
 	dev_info(&link->dev, "index 0x%02x: ",
-		link->conf.ConfigIndex);
+		link->config_index);
 	if (link->vpp)
 		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
 	printk(", irq %d", link->irq);
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 674edbc..47b6092 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -22,9 +22,6 @@
 /* For RequestConfiguration */
 typedef struct config_req_t {
     u_int	Attributes;
-    u_int	ConfigBase;
-    u_char	ConfigIndex;
-    u_int	Present;
 } config_req_t;
 
 /* Attributes for RequestConfiguration */
@@ -35,16 +32,4 @@ typedef struct config_req_t {
 #define CONF_ENABLE_ESR		0x10
 #define CONF_VALID_CLIENT	0x100
 
-/* Configuration registers present */
-#define PRESENT_OPTION		0x001
-#define PRESENT_STATUS		0x002
-#define PRESENT_PIN_REPLACE	0x004
-#define PRESENT_COPY		0x008
-#define PRESENT_EXT_STATUS	0x010
-#define PRESENT_IOBASE_0	0x020
-#define PRESENT_IOBASE_1	0x040
-#define PRESENT_IOBASE_2	0x080
-#define PRESENT_IOBASE_3	0x100
-#define PRESENT_IOSIZE		0x200
-
 #endif /* _LINUX_CS_H */
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 6137fbc..bc28f96 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -97,6 +97,9 @@ struct pcmcia_device {
 	unsigned int		vpp;
 
 	unsigned int		io_lines; /* number of I/O lines */
+	unsigned int		config_base;
+	unsigned int		config_index;
+	unsigned int		config_regs;	/* PRESENT_ flags below */
 
 	/* Is the device suspended? */
 	u16			suspended:1;
@@ -250,6 +253,17 @@ static inline int pcmcia_io_cfg_data_width(unsigned int flags)
 					0x0c -> 2
 					0x10 -> 3 */
 
+/* config_reg{ister}s present for this PCMCIA device */
+#define PRESENT_OPTION		0x001
+#define PRESENT_STATUS		0x002
+#define PRESENT_PIN_REPLACE	0x004
+#define PRESENT_COPY		0x008
+#define PRESENT_EXT_STATUS	0x010
+#define PRESENT_IOBASE_0	0x020
+#define PRESENT_IOBASE_1	0x040
+#define PRESENT_IOBASE_2	0x080
+#define PRESENT_IOBASE_3	0x100
+#define PRESENT_IOSIZE		0x200
 
 #endif /* __KERNEL__ */
 
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 2e1282d..4df07fc 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -143,8 +143,8 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 	link->resource[0]->end = 16;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
-	link->conf.ConfigIndex = 1;
-	link->conf.Present = PRESENT_OPTION;
+	link->config_index = 1;
+	link->config_regs = PRESENT_OPTION;
 
 	return pdacf_config(link);
 }
@@ -216,7 +216,7 @@ static int pdacf_config(struct pcmcia_device *link)
 	int ret;
 
 	snd_printdd(KERN_DEBUG "pdacf_config called\n");
-	link->conf.ConfigIndex = 0x5;
+	link->config_index = 0x5;
 
 	ret = pcmcia_request_io(link);
 	if (ret)
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index a48b3ee..16186ad 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -163,8 +163,8 @@ static int snd_vxpocket_new(struct snd_card *card, int ibl,
 	link->resource[0]->end = 16;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.ConfigIndex = 1;
-	link->conf.Present = PRESENT_OPTION;
+	link->config_index = 1;
+	link->config_regs = PRESENT_OPTION;
 
 	*chip_ret = vxp;
 	return 0;
-- 
1.7.0.4
