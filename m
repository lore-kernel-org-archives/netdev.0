From: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH 11/15] pcmcia: use autoconfiguration feature for ioports and iomem
Date: Fri,  3 Sep 2010 12:57:10 +0200
Message-ID: <1283511434-21620-11-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100903105628.GA21255-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When CONF_AUTO_SET_IO or CONF_AUTO_SET_IOMEM are set, the corresponding
fields in struct pcmcia_device *p_dev->resource[0,1,2] are set
accordinly. Drivers wishing to override certain settings may do so in
the callback function, but they no longer need to parse the CIS entries
stored in cistpl_cftable_entry_t themselves.

CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org
CC: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
CC: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
CC: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
CC: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
---
 Documentation/pcmcia/driver-changes.txt          |   12 ++
 drivers/ata/pata_pcmcia.c                        |   52 +++------
 drivers/bluetooth/bt3c_cs.c                      |   53 +++++----
 drivers/bluetooth/btuart_cs.c                    |   51 ++++----
 drivers/bluetooth/dtl1_cs.c                      |   18 +--
 drivers/char/pcmcia/cm4000_cs.c                  |   15 +--
 drivers/char/pcmcia/cm4040_cs.c                  |   22 +---
 drivers/char/pcmcia/ipwireless/main.c            |   26 +---
 drivers/char/pcmcia/synclink_cs.c                |   16 +--
 drivers/ide/ide-cs.c                             |   53 +++------
 drivers/isdn/hardware/avm/avm_cs.c               |   19 +---
 drivers/isdn/hisax/avma1_cs.c                    |   22 +---
 drivers/isdn/hisax/elsa_cs.c                     |   23 +---
 drivers/isdn/hisax/sedlbauer_cs.c                |   38 +-----
 drivers/isdn/hisax/teles_cs.c                    |   16 +--
 drivers/net/pcmcia/axnet_cs.c                    |   32 +----
 drivers/net/pcmcia/fmvj18x_cs.c                  |    5 +-
 drivers/net/pcmcia/pcnet_cs.c                    |   34 ++----
 drivers/net/pcmcia/smc91c92_cs.c                 |   39 +++----
 drivers/net/pcmcia/xirc2ps_cs.c                  |   69 ++++++-----
 drivers/net/wireless/airo_cs.c                   |   34 +-----
 drivers/net/wireless/atmel_cs.c                  |   28 +----
 drivers/net/wireless/hostap/hostap_cs.c          |   43 +-------
 drivers/net/wireless/libertas/if_cs.c            |   16 +--
 drivers/net/wireless/orinoco/orinoco_cs.c        |   41 +------
 drivers/net/wireless/orinoco/spectrum_cs.c       |   45 +-------
 drivers/parport/parport_cs.c                     |   34 ++----
 drivers/pcmcia/pcmcia_cis.c                      |   77 +++++++++++--
 drivers/scsi/pcmcia/aha152x_stub.c               |   34 +++---
 drivers/scsi/pcmcia/fdomain_stub.c               |   13 +--
 drivers/scsi/pcmcia/nsp_cs.c                     |   47 ++------
 drivers/scsi/pcmcia/qlogic_stub.c                |   13 +--
 drivers/scsi/pcmcia/sym53c500_cs.c               |   13 +--
 drivers/serial/serial_cs.c                       |  134 +++++++++++-----------
 drivers/staging/comedi/drivers/cb_das16_cs.c     |   31 +----
 drivers/staging/comedi/drivers/das08_cs.c        |   33 +-----
 drivers/staging/comedi/drivers/ni_daq_700.c      |   32 +-----
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |   32 +-----
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |   32 +-----
 drivers/staging/comedi/drivers/ni_mio_cs.c       |   14 +--
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |   32 +-----
 drivers/telephony/ixj_pcmcia.c                   |   32 ++----
 drivers/usb/host/sl811_cs.c                      |   28 +----
 include/pcmcia/ds.h                              |   30 ++----
 44 files changed, 503 insertions(+), 980 deletions(-)

diff --git a/Documentation/pcmcia/driver-changes.txt b/Documentation/pcmcia/driver-changes.txt
index 62a029f..dd04361 100644
--- a/Documentation/pcmcia/driver-changes.txt
+++ b/Documentation/pcmcia/driver-changes.txt
@@ -1,4 +1,16 @@
 This file details changes in 2.6 which affect PCMCIA card driver authors:
+* pcmcia_loop_config() and autoconfiguration (as of 2.6.36)
+   If struct pcmcia_device *p_dev->config_flags is set accordingly,
+   pcmcia_loop_config() now sets up certain configuration values
+   automatically, though the driver may still override the settings
+   in the callback function. The following autoconfiguration options
+   are provided at the moment:
+	CONF_AUTO_CHECK_VCC : check for matching Vcc
+	CONF_AUTO_SET_VPP   : set Vpp
+	CONF_AUTO_AUDIO     : auto-enable audio line, if required
+	CONF_AUTO_SET_IO    : set ioport resources (->resource[0,1])
+	CONF_AUTO_SET_IOMEM : set first iomem resource (->resource[2])
+
 * pcmcia_request_configuration -> pcmcia_enable_device (as of 2.6.36)
    pcmcia_request_configuration() got renamed to pcmcia_enable_device(),
    as it mirrors pcmcia_disable_device(). Configuration settings are now
diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 954f43c..eb95ad5 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -172,40 +172,28 @@ struct pcmcia_config_check {
 	int is_kme;
 };
 
-static int pcmcia_check_one_config(struct pcmcia_device *pdev,
-				   cistpl_cftable_entry_t *cfg,
-				   cistpl_cftable_entry_t *dflt,
-				   void *priv_data)
+static int pcmcia_check_one_config(struct pcmcia_device *pdev, void *priv_data)
 {
 	struct pcmcia_config_check *stk = priv_data;
 
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		pdev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		pdev->resource[0]->start = io->win[0].base;
-		if (!(io->flags & CISTPL_IO_16BIT)) {
-			pdev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-			pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-		}
-		if (io->nwin == 2) {
-			pdev->resource[0]->end = 8;
-			pdev->resource[1]->start = io->win[1].base;
-			pdev->resource[1]->end = (stk->is_kme) ? 2 : 1;
-			if (pcmcia_request_io(pdev) != 0)
-				return -ENODEV;
-			stk->ctl_base = pdev->resource[1]->start;
-		} else if ((io->nwin == 1) && (io->win[0].len >= 16)) {
-			pdev->resource[0]->end = io->win[0].len;
-			pdev->resource[1]->end = 0;
-			if (pcmcia_request_io(pdev) != 0)
-				return -ENODEV;
-			stk->ctl_base = pdev->resource[0]->start + 0x0e;
-		} else
+	if (!(pdev->resource[0]->flags & IO_DATA_PATH_WIDTH_8)) {
+		pdev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	}
+	pdev->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+	pdev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+
+	if (pdev->resource[1]->end) {
+		pdev->resource[0]->end = 8;
+		pdev->resource[1]->end = (stk->is_kme) ? 2 : 1;
+		stk->ctl_base = pdev->resource[1]->start;
+	} else {
+		if (pdev->resource[0]->end < 16)
 			return -ENODEV;
-		/* If we've got this far, we're done */
-		return 0;
+		stk->ctl_base = pdev->resource[0]->start + 0x0e;
 	}
-	return -ENODEV;
+
+	return pcmcia_request_io(pdev);
 }
 
 /**
@@ -228,10 +216,8 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	struct ata_port_operations *ops = &pcmcia_port_ops;
 
 	/* Set up attributes in order to probe card and get resources */
-	pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	pdev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-	pdev->config_flags |= CONF_ENABLE_IRQ;
-	pdev->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
+	pdev->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO |
+		CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
 
 	/* See if we have a manufacturer identifier. Use it to set is_kme for
 	   vendor quirks */
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 97338a3..8b8be35 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -656,10 +656,8 @@ static int bt3c_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-	link->resource[0]->end = 8;
-
-	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP |
+		CONF_AUTO_SET_IO;
 
 	return bt3c_config(link);
 }
@@ -673,38 +671,41 @@ static void bt3c_detach(struct pcmcia_device *link)
 	kfree(info);
 }
 
-static int bt3c_check_config(struct pcmcia_device *p_dev,
-			     cistpl_cftable_entry_t *cf,
-			     cistpl_cftable_entry_t *dflt,
-			     void *priv_data)
+static int bt3c_check_config(struct pcmcia_device *p_dev, void *priv_data)
 {
-	unsigned long try = (unsigned long) priv_data;
-	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
+	int *try = priv_data;
 
-	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
-	    (cf->io.win[0].base != 0)) {
-		p_dev->resource[0]->start = cf->io.win[0].base;
-		if (!pcmcia_request_io(p_dev))
-			return 0;
-	}
-	return -ENODEV;
+	if (try == 0)
+		p_dev->io_lines = 16;
+
+	if ((p_dev->resource[0]->end != 8) || (p_dev->resource[0]->start == 0))
+		return -EINVAL;
+
+	p_dev->resource[0]->end = 8;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int bt3c_check_config_notpicky(struct pcmcia_device *p_dev,
-				      cistpl_cftable_entry_t *cf,
-				      cistpl_cftable_entry_t *dflt,
 				      void *priv_data)
 {
 	static unsigned int base[5] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8, 0x0 };
 	int j;
 
-	if ((cf->io.nwin > 0) && ((cf->io.flags & CISTPL_IO_LINES_MASK) <= 3)) {
-		for (j = 0; j < 5; j++) {
-			p_dev->resource[0]->start = base[j];
-			p_dev->io_lines = base[j] ? 16 : 3;
-			if (!pcmcia_request_io(p_dev))
-				return 0;
-		}
+	if (p_dev->io_lines > 3)
+		return -ENODEV;
+
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[0]->end = 8;
+
+	for (j = 0; j < 5; j++) {
+		p_dev->resource[0]->start = base[j];
+		p_dev->io_lines = base[j] ? 16 : 3;
+		if (!pcmcia_request_io(p_dev))
+			return 0;
 	}
 	return -ENODEV;
 }
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 8a6864f..9f9bb69 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -585,10 +585,8 @@ static int btuart_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-	link->resource[0]->end = 8;
-
-	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP |
+		CONF_AUTO_SET_IO;
 
 	return btuart_config(link);
 }
@@ -602,38 +600,41 @@ static void btuart_detach(struct pcmcia_device *link)
 	kfree(info);
 }
 
-static int btuart_check_config(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cf,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int btuart_check_config(struct pcmcia_device *p_dev, void *priv_data)
 {
 	int *try = priv_data;
-	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
 
-	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
-	    (cf->io.win[0].base != 0)) {
-		p_dev->resource[0]->start = cf->io.win[0].base;
-		if (!pcmcia_request_io(p_dev))
-			return 0;
-	}
-	return -ENODEV;
+	if (try == 0)
+		p_dev->io_lines = 16;
+
+	if ((p_dev->resource[0]->end != 8) || (p_dev->resource[0]->start == 0))
+		return -EINVAL;
+
+	p_dev->resource[0]->end = 8;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int btuart_check_config_notpicky(struct pcmcia_device *p_dev,
-					cistpl_cftable_entry_t *cf,
-					cistpl_cftable_entry_t *dflt,
 					void *priv_data)
 {
 	static unsigned int base[5] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8, 0x0 };
 	int j;
 
-	if ((cf->io.nwin > 0) && ((cf->io.flags & CISTPL_IO_LINES_MASK) <= 3)) {
-		for (j = 0; j < 5; j++) {
-			p_dev->resource[0]->start = base[j];
-			p_dev->io_lines = base[j] ? 16 : 3;
-			if (!pcmcia_request_io(p_dev))
-				return 0;
-		}
+	if (p_dev->io_lines > 3)
+		return -ENODEV;
+
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[0]->end = 8;
+
+	for (j = 0; j < 5; j++) {
+		p_dev->resource[0]->start = base[j];
+		p_dev->io_lines = base[j] ? 16 : 3;
+		if (!pcmcia_request_io(p_dev))
+			return 0;
 	}
 	return -ENODEV;
 }
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 4620cc3..12cd177 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -571,10 +571,7 @@ static int dtl1_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-	link->resource[0]->end = 8;
-
-	link->config_flags |= CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 
 	return dtl1_config(link);
 }
@@ -589,17 +586,14 @@ static void dtl1_detach(struct pcmcia_device *link)
 	kfree(info);
 }
 
-static int dtl1_confcheck(struct pcmcia_device *p_dev,
-			  cistpl_cftable_entry_t *cf,
-			  cistpl_cftable_entry_t *dflt,
-			  void *priv_data)
+static int dtl1_confcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if ((cf->io.nwin != 1) || (cf->io.win[0].len <= 8))
+	if ((p_dev->resource[1]->end) || (p_dev->resource[1]->end < 8))
 		return -ENODEV;
 
-	p_dev->resource[0]->start = cf->io.win[0].base;
-	p_dev->resource[0]->end = cf->io.win[0].len;	/*yo */
-	p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+
 	return pcmcia_request_io(p_dev);
 }
 
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index 0b2f3b9..79de9cc 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -1741,19 +1741,8 @@ static void cmm_cm4000_release(struct pcmcia_device * link)
 
 /*==== Interface to PCMCIA Layer =======================================*/
 
-static int cm4000_config_check(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cfg,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int cm4000_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (!cfg->io.nwin)
-		return -ENODEV;
-
-	p_dev->resource[0]->start = cfg->io.win[0].base;
-	p_dev->resource[0]->end = cfg->io.win[0].len;
-	p_dev->resource[0]->flags |= pcmcia_io_cfg_data_width(cfg->io.flags);
-	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
-
 	return pcmcia_request_io(p_dev);
 }
 
@@ -1761,6 +1750,8 @@ static int cm4000_config(struct pcmcia_device * link, int devno)
 {
 	struct cm4000_dev *dev;
 
+	link->config_flags |= CONF_AUTO_SET_IO;
+
 	/* read the config-tuples */
 	if (pcmcia_loop_config(link, cm4000_config_check, NULL))
 		goto cs_release;
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index acf88d5..bf012d2 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -515,25 +515,9 @@ static void cm4040_reader_release(struct pcmcia_device *link)
 	return;
 }
 
-static int cm4040_config_check(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cfg,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int cm4040_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	int rc;
-	if (!cfg->io.nwin)
-		return -ENODEV;
-
-	/* Get the IOaddr */
-	p_dev->resource[0]->start = cfg->io.win[0].base;
-	p_dev->resource[0]->end = cfg->io.win[0].len;
-	p_dev->resource[0]->flags |= pcmcia_io_cfg_data_width(cfg->io.flags);
-	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
-	rc = pcmcia_request_io(p_dev);
-
-	dev_printk(KERN_INFO, &p_dev->dev,
-		   "pcmcia_request_io returned 0x%x\n", rc);
-	return rc;
+	return pcmcia_request_io(p_dev);
 }
 
 
@@ -542,6 +526,8 @@ static int reader_config(struct pcmcia_device *link, int devno)
 	struct reader_dev *dev;
 	int fail_rc;
 
+	link->config_flags |= CONF_AUTO_SET_IO;
+
 	if (pcmcia_loop_config(link, cm4040_config_check, NULL))
 		goto cs_release;
 
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 1b7f092..594c23b 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -75,22 +75,18 @@ static void signalled_reboot_callback(void *callback_data)
 	schedule_work(&ipw->work_reboot);
 }
 
-static int ipwireless_probe(struct pcmcia_device *p_dev,
-			    cistpl_cftable_entry_t *cfg,
-			    cistpl_cftable_entry_t *dflt,
-			    void *priv_data)
+static int ipwireless_probe(struct pcmcia_device *p_dev, void *priv_data)
 {
 	struct ipw_dev *ipw = priv_data;
 	struct resource *io_resource;
 	int ret;
 
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
 	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	p_dev->resource[0]->start = cfg->io.win[0].base;
-	p_dev->resource[0]->end = cfg->io.win[0].len;
 
 	/* 0x40 causes it to generate level mode interrupts. */
 	/* 0x04 enables IREQ pin. */
-	p_dev->config_index = cfg->index | 0x44;
+	p_dev->config_index |= 0x44;
 	p_dev->io_lines = 16;
 	ret = pcmcia_request_io(p_dev);
 	if (ret)
@@ -100,26 +96,18 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 				resource_size(p_dev->resource[0]),
 				IPWIRELESS_PCCARD_NAME);
 
-	if (cfg->mem.nwin == 0)
-		return 0;
-
 	p_dev->resource[2]->flags |=
 		WIN_DATA_WIDTH_16 | WIN_MEMORY_TYPE_CM | WIN_ENABLE;
-	p_dev->resource[2]->start = cfg->mem.win[0].host_addr;
-	p_dev->resource[2]->end = cfg->mem.win[0].len;
-	if (p_dev->resource[2]->end < 0x1000)
-		p_dev->resource[2]->end = 0x1000;
 
 	ret = pcmcia_request_window(p_dev, p_dev->resource[2], 0);
 	if (ret != 0)
 		goto exit1;
 
-	ret = pcmcia_map_mem_page(p_dev, p_dev->resource[2],
-				cfg->mem.win[0].card_addr);
+	ret = pcmcia_map_mem_page(p_dev, p_dev->resource[2], p_dev->card_addr);
 	if (ret != 0)
 		goto exit2;
 
-	ipw->is_v2_card = cfg->mem.win[0].len == 0x100;
+	ipw->is_v2_card = resource_size(p_dev->resource[2]) == 0x100;
 
 	ipw->attr_memory = ioremap(p_dev->resource[2]->start,
 				resource_size(p_dev->resource[2]));
@@ -165,13 +153,13 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	int ret = 0;
 
 	ipw->is_v2_card = 0;
+	link->config_flags |= CONF_AUTO_SET_IO | CONF_AUTO_SET_IOMEM |
+		CONF_ENABLE_IRQ;
 
 	ret = pcmcia_loop_config(link, ipwireless_probe, ipw);
 	if (ret != 0)
 		return ret;
 
-	link->config_flags |= CONF_ENABLE_IRQ;
-
 	INIT_WORK(&ipw->work_reboot, signalled_reboot_work);
 
 	ipwireless_init_hardware_v1(ipw->hardware, link->resource[0]->start,
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index c701434..a343b8f 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -561,19 +561,8 @@ static int mgslpc_probe(struct pcmcia_device *link)
 /* Card has been inserted.
  */
 
-static int mgslpc_ioprobe(struct pcmcia_device *p_dev,
-			  cistpl_cftable_entry_t *cfg,
-			  cistpl_cftable_entry_t *dflt,
-			  void *priv_data)
+static int mgslpc_ioprobe(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (!cfg->io.nwin)
-		return -ENODEV;
-
-	p_dev->resource[0]->start = cfg->io.win[0].base;
-	p_dev->resource[0]->end = cfg->io.win[0].len;
-	p_dev->resource[0]->flags |= pcmcia_io_cfg_data_width(cfg->io.flags);
-	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
-
 	return pcmcia_request_io(p_dev);
 }
 
@@ -585,11 +574,12 @@ static int mgslpc_config(struct pcmcia_device *link)
     if (debug_level >= DEBUG_LEVEL_INFO)
 	    printk("mgslpc_config(0x%p)\n", link);
 
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
+
     ret = pcmcia_loop_config(link, mgslpc_ioprobe, NULL);
     if (ret != 0)
 	    goto failed;
 
-    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_index = 8;
     link->config_regs = PRESENT_OPTION;
 
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 25b8a10..44a8918 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -96,10 +96,8 @@ static int ide_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = info;
 
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-    link->config_flags |= CONF_ENABLE_IRQ;
-    link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO |
+	    CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
 
     return ide_config(link);
 } /* ide_attach */
@@ -199,41 +197,28 @@ struct pcmcia_config_check {
 	int is_kme;
 };
 
-static int pcmcia_check_one_config(struct pcmcia_device *pdev,
-				   cistpl_cftable_entry_t *cfg,
-				   cistpl_cftable_entry_t *dflt,
-				   void *priv_data)
+static int pcmcia_check_one_config(struct pcmcia_device *pdev, void *priv_data)
 {
 	struct pcmcia_config_check *stk = priv_data;
 
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		pdev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		pdev->config_index = cfg->index;
-		pdev->resource[0]->start = io->win[0].base;
-		if (!(io->flags & CISTPL_IO_16BIT)) {
-			pdev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-			pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-		}
-		if (io->nwin == 2) {
-			pdev->resource[0]->end = 8;
-			pdev->resource[1]->start = io->win[1].base;
-			pdev->resource[1]->end = (stk->is_kme) ? 2 : 1;
-			if (pcmcia_request_io(pdev) != 0)
-				return -ENODEV;
-			stk->ctl_base = pdev->resource[1]->start;
-		} else if ((io->nwin == 1) && (io->win[0].len >= 16)) {
-			pdev->resource[0]->end = io->win[0].len;
-			pdev->resource[1]->end = 0;
-			if (pcmcia_request_io(pdev) != 0)
-				return -ENODEV;
-			stk->ctl_base = pdev->resource[0]->start + 0x0e;
-		} else
+	if (!(pdev->resource[0]->flags & IO_DATA_PATH_WIDTH_8)) {
+		pdev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	}
+	pdev->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+	pdev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+
+	if (pdev->resource[1]->end) {
+		pdev->resource[0]->end = 8;
+		pdev->resource[1]->end = (stk->is_kme) ? 2 : 1;
+		stk->ctl_base = pdev->resource[1]->start;
+	} else {
+		if (pdev->resource[0]->end < 16)
 			return -ENODEV;
-		/* If we've got this far, we're done */
-		return 0;
+		stk->ctl_base = pdev->resource[0]->start + 0x0e;
 	}
-	return -ENODEV;
+
+	return pcmcia_request_io(pdev);
 }
 
 static int ide_config(struct pcmcia_device *link)
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 9dbab9c..403a995 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -72,13 +72,8 @@ static void avmcs_detach(struct pcmcia_device *p_dev);
 
 static int avmcs_probe(struct pcmcia_device *p_dev)
 {
-
-    /* The io structure describes IO port mapping */
-    p_dev->resource[0]->end = 16;
-    p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-
     /* General socket configuration */
-    p_dev->config_flags |= CONF_ENABLE_IRQ;
+    p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
     p_dev->config_index = 1;
     p_dev->config_regs = PRESENT_OPTION;
 
@@ -107,16 +102,12 @@ static void avmcs_detach(struct pcmcia_device *link)
     
 ======================================================================*/
 
-static int avmcs_configcheck(struct pcmcia_device *p_dev,
-			     cistpl_cftable_entry_t *cf,
-			     cistpl_cftable_entry_t *dflt,
-			     void *priv_data)
+static int avmcs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cf->io.nwin <= 0)
-		return -ENODEV;
+	p_dev->resource[0]->end = 16;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
-	p_dev->resource[0]->start = cf->io.win[0].base;
-	p_dev->resource[0]->end = cf->io.win[0].len;
 	return pcmcia_request_io(p_dev);
 }
 
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 2f2b000..cb09f0c 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -76,14 +76,8 @@ static int __devinit avma1cs_probe(struct pcmcia_device *p_dev)
 {
     dev_dbg(&p_dev->dev, "avma1cs_attach()\n");
 
-    /* The io structure describes IO port mapping */
-    p_dev->resource[0]->end = 16;
-    p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-    p_dev->resource[1]->end = 16;
-    p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_16;
-
     /* General socket configuration */
-    p_dev->config_flags |= CONF_ENABLE_IRQ;
+    p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
     p_dev->config_index = 1;
     p_dev->config_regs = PRESENT_OPTION;
 
@@ -114,17 +108,13 @@ static void __devexit avma1cs_detach(struct pcmcia_device *link)
     
 ======================================================================*/
 
-static int avma1cs_configcheck(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cf,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int avma1cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cf->io.nwin <= 0)
-		return -ENODEV;
-
-	p_dev->resource[0]->start = cf->io.win[0].base;
-	p_dev->resource[0]->end = cf->io.win[0].len;
+	p_dev->resource[0]->end = 16;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	p_dev->io_lines = 5;
+
 	return pcmcia_request_io(p_dev);
 }
 
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 0a65280..f203a52 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -118,16 +118,6 @@ static int __devinit elsa_cs_probe(struct pcmcia_device *link)
 
     local->cardnr = -1;
 
-    /*
-      General socket configuration defaults can go here.  In this
-      client, we assume very little, and rely on the CIS for almost
-      everything.  In most clients, many details (i.e., number, sizes,
-      and attributes of IO windows) are fixed by the nature of the
-      device, and can be hard-wired here.
-    */
-    link->resource[0]->end = 8;
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-
     return elsa_cs_config(link);
 } /* elsa_cs_attach */
 
@@ -160,18 +150,17 @@ static void __devexit elsa_cs_detach(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static int elsa_cs_configcheck(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cf,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int elsa_cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
 	int j;
 
 	p_dev->io_lines = 3;
+	p_dev->resource[0]->end = 8;
+	p_dev->resource[0]->flags &= IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
-	if ((cf->io.nwin > 0) && cf->io.win[0].base) {
+	if ((p_dev->resource[0]->end) && p_dev->resource[0]->start) {
 		printk(KERN_INFO "(elsa_cs: looks like the 96 model)\n");
-		p_dev->resource[0]->start = cf->io.win[0].base;
 		if (!pcmcia_request_io(p_dev))
 			return 0;
 	} else {
@@ -194,6 +183,8 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
     dev_dbg(&link->dev, "elsa_config(0x%p)\n", link);
     dev = link->priv;
 
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
+
     i = pcmcia_loop_config(link, elsa_cs_configcheck, NULL);
     if (i != 0)
 	goto failed;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index b69eccf..a88c88f 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -128,8 +128,6 @@ static int __devinit sedlbauer_probe(struct pcmcia_device *link)
     /* from old sedl_cs 
     */
     /* The io structure describes IO port mapping */
-    link->resource[0]->end = 8;
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
     return sedlbauer_config(link);
 } /* sedlbauer_attach */
@@ -161,35 +159,13 @@ static void __devexit sedlbauer_detach(struct pcmcia_device *link)
     device available to the system.
     
 ======================================================================*/
-static int sedlbauer_config_check(struct pcmcia_device *p_dev,
-				  cistpl_cftable_entry_t *cfg,
-				  cistpl_cftable_entry_t *dflt,
-				  void *priv_data)
+static int sedlbauer_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-					pcmcia_io_cfg_data_width(io->flags);
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		/* This reserves IO space but doesn't actually enable it */
-		p_dev->io_lines = 3;
-		if (pcmcia_request_io(p_dev) != 0)
-			return -ENODEV;
-	}
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	return 0;
+	p_dev->io_lines = 3;
+	return pcmcia_request_io(p_dev);
 }
 
 
@@ -202,7 +178,7 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
     dev_dbg(&link->dev, "sedlbauer_config(0x%p)\n", link);
 
     link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_CHECK_VCC |
-	    CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO;
+	    CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO | CONF_AUTO_SET_IO;
 
     /*
       In this loop, we scan the CIS for configuration table entries,
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 6605480..05a5631 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -105,10 +105,7 @@ static int __devinit teles_probe(struct pcmcia_device *link)
       and attributes of IO windows) are fixed by the nature of the
       device, and can be hard-wired here.
     */
-    link->resource[0]->end = 96;
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-
-    link->config_flags |= CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 
     return teles_cs_config(link);
 } /* teles_attach */
@@ -142,18 +139,17 @@ static void __devexit teles_detach(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static int teles_cs_configcheck(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cf,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int teles_cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
 	int j;
 
 	p_dev->io_lines = 5;
+	p_dev->resource[0]->end = 96;
+	p_dev->resource[0]->flags &= IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
-	if ((cf->io.nwin > 0) && cf->io.win[0].base) {
+	if ((p_dev->resource[0]->end) && p_dev->resource[0]->start) {
 		printk(KERN_INFO "(teles_cs: looks like the 96 model)\n");
-		p_dev->resource[0]->start = cf->io.win[0].base;
 		if (!pcmcia_request_io(p_dev))
 			return 0;
 	} else {
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 17f1040..9d9d997 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -284,34 +284,16 @@ static int try_io_port(struct pcmcia_device *link)
     }
 }
 
-static int axnet_configcheck(struct pcmcia_device *p_dev,
-			     cistpl_cftable_entry_t *cfg,
-			     cistpl_cftable_entry_t *dflt,
-			     void *priv_data)
+static int axnet_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
-	int i;
-	cistpl_io_t *io = &cfg->io;
-
-	if (cfg->index == 0 || cfg->io.nwin == 0)
-		return -ENODEV;
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
 	p_dev->config_index = 0x05;
-	/* For multifunction cards, by convention, we configure the
-	   network function with window 0, and serial with window 1 */
-	if (io->nwin > 1) {
-		i = (io->win[1].len > io->win[0].len);
-		p_dev->resource[1]->start = io->win[1-i].base;
-		p_dev->resource[1]->end = io->win[1-i].len;
-	} else {
-		i = p_dev->resource[1]->end = 0;
-	}
-	p_dev->resource[0]->start = io->win[i].base;
-	p_dev->resource[0]->end = io->win[i].len;
-	p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-	if (p_dev->resource[0]->end + p_dev->resource[1]->end >= 32)
-		return try_io_port(p_dev);
+	if (p_dev->resource[0]->end + p_dev->resource[1]->end < 32)
+		return -ENODEV;
 
-	return -ENODEV;
+	return try_io_port(p_dev);
 }
 
 static int axnet_config(struct pcmcia_device *link)
@@ -324,6 +306,7 @@ static int axnet_config(struct pcmcia_device *link)
 
     /* don't trust the CIS on this; Linksys got it wrong */
     link->config_regs = 0x63;
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
     ret = pcmcia_loop_config(link, axnet_configcheck, NULL);
     if (ret != 0)
 	goto failed;
@@ -331,7 +314,6 @@ static int axnet_config(struct pcmcia_device *link)
     if (!link->irq)
 	    goto failed;
 
-    link->config_flags |= CONF_ENABLE_IRQ;
     if (resource_size(link->resource[1]) == 8)
 	link->config_flags |= CONF_ENABLE_SPKR;
     
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index c1479e3..792ab38 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -319,10 +319,7 @@ static int ungermann_try_io_port(struct pcmcia_device *link)
     return ret;	/* RequestIO failed */
 }
 
-static int fmvj18x_ioprobe(struct pcmcia_device *p_dev,
-			   cistpl_cftable_entry_t *cfg,
-			   cistpl_cftable_entry_t *dflt,
-			   void *priv_data)
+static int fmvj18x_ioprobe(struct pcmcia_device *p_dev, void *priv_data)
 {
 	return 0; /* strange, but that's what the code did already before... */
 }
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 301f3d4..0abf4f8 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -259,7 +259,7 @@ static int pcnet_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = dev;
 
-    link->config_flags |= CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 
     dev->netdev_ops = &pcnet_netdev_ops;
 
@@ -500,37 +500,19 @@ static int try_io_port(struct pcmcia_device *link)
     }
 }
 
-static int pcnet_confcheck(struct pcmcia_device *p_dev,
-			   cistpl_cftable_entry_t *cfg,
-			   cistpl_cftable_entry_t *dflt,
-			   void *priv_data)
+static int pcnet_confcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
 	int *has_shmem = priv_data;
-	int i;
-	cistpl_io_t *io = &cfg->io;
 
-	if (cfg->index == 0 || cfg->io.nwin == 0)
-		return -EINVAL;
+	*has_shmem = (p_dev->resource[2]->end >= 0x4000);
 
-	/* For multifunction cards, by convention, we configure the
-	   network function with window 0, and serial with window 1 */
-	if (io->nwin > 1) {
-		i = (io->win[1].len > io->win[0].len);
-		p_dev->resource[1]->start = io->win[1-i].base;
-		p_dev->resource[1]->end = io->win[1-i].len;
-	} else {
-		i = p_dev->resource[1]->end = 0;
-	}
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	*has_shmem = ((cfg->mem.nwin == 1) &&
-		      (cfg->mem.win[0].len >= 0x4000));
-	p_dev->resource[0]->start = io->win[i].base;
-	p_dev->resource[0]->end = io->win[i].len;
-	p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-	if (p_dev->resource[0]->end + p_dev->resource[1]->end >= 32)
-		return try_io_port(p_dev);
+	if (p_dev->resource[0]->end + p_dev->resource[1]->end - 32)
+		return -EINVAL;
 
-	return 0;
+	return try_io_port(p_dev);
 }
 
 static int pcnet_config(struct pcmcia_device *link)
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index e127d2b..a8cef28 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -323,9 +323,6 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->priv = dev;
 
     spin_lock_init(&smc->lock);
-    link->resource[0]->end = 16;
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-    link->config_flags |= CONF_ENABLE_IRQ;
 
     /* The SMC91c92-specific entries in the device structure. */
     dev->netdev_ops = &smc_netdev_ops;
@@ -417,18 +414,21 @@ static int mhz_3288_power(struct pcmcia_device *link)
     return 0;
 }
 
-static int mhz_mfc_config_check(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cf,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int mhz_mfc_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	int k;
-	p_dev->resource[1]->start = cf->io.win[0].base;
+	p_dev->io_lines = 16;
+	p_dev->resource[1]->start = p_dev->resource[0]->start;
+	p_dev->resource[1]->end = 8;
+	p_dev->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[0]->end = 16;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	for (k = 0; k < 0x400; k += 0x10) {
 		if (k & 0x80)
 			continue;
 		p_dev->resource[0]->start = k ^ 0x300;
-		p_dev->io_lines = 16;
 		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
@@ -442,9 +442,8 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     unsigned int offset;
     int i;
 
-    link->config_flags |= CONF_ENABLE_SPKR;
-    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-    link->resource[1]->end = 8;
+    link->config_flags |= CONF_ENABLE_SPKR | CONF_ENABLE_IRQ |
+	    CONF_AUTO_SET_IO;
 
     /* The Megahertz combo cards have modem-like CIS entries, so
        we have to explicitly try a bunch of port combinations. */
@@ -586,13 +585,12 @@ static int mot_setup(struct pcmcia_device *link)
 
 /*====================================================================*/
 
-static int smc_configcheck(struct pcmcia_device *p_dev,
-			   cistpl_cftable_entry_t *cf,
-			   cistpl_cftable_entry_t *dflt,
-			   void *priv_data)
+static int smc_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 {
-	p_dev->resource[0]->start = cf->io.win[0].base;
-	p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
+	p_dev->resource[0]->end = 16;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+
 	return pcmcia_request_io(p_dev);
 }
 
@@ -601,7 +599,8 @@ static int smc_config(struct pcmcia_device *link)
     struct net_device *dev = link->priv;
     int i;
 
-    link->resource[0]->end = 16;
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
+
     i = pcmcia_loop_config(link, smc_configcheck, NULL);
     if (!i)
 	    dev->base_addr = link->resource[0]->start;
@@ -634,7 +633,7 @@ static int osi_config(struct pcmcia_device *link)
     static const unsigned int com[4] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8 };
     int i, j;
 
-    link->config_flags |= CONF_ENABLE_SPKR;
+    link->config_flags |= CONF_ENABLE_SPKR | CONF_ENABLE_IRQ;
     link->resource[0]->end = 64;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[1]->end = 8;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 2bc2eb8..cecc074 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -528,7 +528,6 @@ xirc2ps_probe(struct pcmcia_device *link)
     link->priv = dev;
 
     /* General socket configuration */
-    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_index = 1;
 
     /* Fill in card specific entries */
@@ -665,42 +664,53 @@ has_ce2_string(struct pcmcia_device * p_dev)
 }
 
 static int
-xirc2ps_config_modem(struct pcmcia_device *p_dev,
-		     cistpl_cftable_entry_t *cf,
-		     cistpl_cftable_entry_t *dflt,
-		     void *priv_data)
+xirc2ps_config_modem(struct pcmcia_device *p_dev, void *priv_data)
 {
 	unsigned int ioaddr;
 
-	if (cf->io.nwin > 0  &&  (cf->io.win[0].base & 0xf) == 8) {
-		for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
-			p_dev->resource[1]->start = cf->io.win[0].base;
-			p_dev->resource[0]->start = ioaddr;
-			if (!pcmcia_request_io(p_dev))
-				return 0;
-		}
+	if ((p_dev->resource[0]->start & 0xf) == 8)
+		return -ENODEV;
+
+	p_dev->resource[0]->end = 16;
+	p_dev->resource[1]->end = 8;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
+	p_dev->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->io_lines = 10;
+
+	p_dev->resource[1]->start = p_dev->resource[0]->start;
+	for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
+		p_dev->resource[0]->start = ioaddr;
+		if (!pcmcia_request_io(p_dev))
+			return 0;
 	}
 	return -ENODEV;
 }
 
 static int
-xirc2ps_config_check(struct pcmcia_device *p_dev,
-		     cistpl_cftable_entry_t *cf,
-		     cistpl_cftable_entry_t *dflt,
-		     void *priv_data)
+xirc2ps_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	int *pass = priv_data;
+	resource_size_t tmp = p_dev->resource[1]->start;
 
-	if (cf->io.nwin > 0 && (cf->io.win[0].base & 0xf) == 8) {
-		p_dev->resource[1]->start = cf->io.win[0].base;
-		p_dev->resource[0]->start = p_dev->resource[1]->start
-			+ (*pass ? (cf->index & 0x20 ? -24:8)
-			   : (cf->index & 0x20 ?   8:-24));
-		if (!pcmcia_request_io(p_dev))
-			return 0;
-	}
-	return -ENODEV;
+	tmp += (*pass ? (p_dev->config_index & 0x20 ? -24 : 8)
+		: (p_dev->config_index & 0x20 ?   8 : -24));
+
+	if ((p_dev->resource[0]->start & 0xf) == 8)
+		return -ENODEV;
+
+	p_dev->resource[0]->end = 18;
+	p_dev->resource[1]->end = 8;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
+	p_dev->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->io_lines = 10;
 
+	p_dev->resource[1]->start = p_dev->resource[0]->start;
+	p_dev->resource[0]->start = tmp;
+	return pcmcia_request_io(p_dev);
 }
 
 
@@ -803,21 +813,16 @@ xirc2ps_config(struct pcmcia_device * link)
 	goto failure;
     }
 
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
-    link->io_lines = 10;
     if (local->modem) {
 	int pass;
+	link->config_flags |= CONF_AUTO_SET_IO;
 
-	link->resource[1]->end = 8;
-	link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	if (local->dingo) {
 	    /* Take the Modem IO port from the CIS and scan for a free
 	     * Ethernet port */
-	    link->resource[0]->end = 16; /* no Mako stuff anymore */
 	    if (!pcmcia_loop_config(link, xirc2ps_config_modem, NULL))
 		    goto port_found;
 	} else {
-	    link->resource[0]->end = 18;
 	    /* We do 2 passes here: The first one uses the regular mapping and
 	     * the second tries again, thereby considering that the 32 ports are
 	     * mirrored every 32 bytes. Actually we use a mirrored port for
@@ -833,7 +838,9 @@ xirc2ps_config(struct pcmcia_device * link)
 	}
 	printk(KNOT_XIRC "no ports available\n");
     } else {
+	link->io_lines = 10;
 	link->resource[0]->end = 16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 	for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
 	    link->resource[0]->start = ioaddr;
 	    if (!(err = pcmcia_request_io(link)))
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 63bf662..77682f2 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -137,36 +137,12 @@ static void airo_detach(struct pcmcia_device *link)
 
   ======================================================================*/
 
-static int airo_cs_config_check(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int airo_cs_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-					pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-	}
-
-	/* This reserves IO space but doesn't actually enable it */
-	if (pcmcia_request_io(p_dev) != 0)
-		return -ENODEV;
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* If we got this far, we're cool! */
-	return 0;
+	return pcmcia_request_io(p_dev);
 }
 
 
@@ -180,7 +156,7 @@ static int airo_config(struct pcmcia_device *link)
 	dev_dbg(&link->dev, "airo_config\n");
 
 	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP |
-		CONF_AUTO_AUDIO;
+		CONF_AUTO_AUDIO | CONF_AUTO_SET_IO;
 
 	/*
 	 * In this loop, we scan the CIS for configuration table
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 812decd..2029380 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -154,31 +154,11 @@ static int card_present(void *arg)
 	return 0;
 }
 
-static int atmel_config_check(struct pcmcia_device *p_dev,
-			      cistpl_cftable_entry_t *cfg,
-			      cistpl_cftable_entry_t *dflt,
-			      void *priv_data)
+static int atmel_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-					pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-	}
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* This reserves IO space but doesn't actually enable it */
 	return pcmcia_request_io(p_dev);
 }
 
@@ -194,7 +174,7 @@ static int atmel_config(struct pcmcia_device *link)
 	dev_dbg(&link->dev, "atmel_config\n");
 
 	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP |
-		CONF_AUTO_AUDIO;
+		CONF_AUTO_AUDIO | CONF_AUTO_SET_IO;
 
 	/*
 	  In this loop, we scan the CIS for configuration table entries,
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index d4f19af..e57b201 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -469,46 +469,11 @@ static void prism2_detach(struct pcmcia_device *link)
 /* run after a CARD_INSERTION event is received to configure the PCMCIA
  * socket and make the device available to the system */
 
-static int prism2_config_check(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cfg,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int prism2_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	PDEBUG(DEBUG_EXTRA, "Checking CFTABLE_ENTRY 0x%02X "
-	       "(default 0x%02X)\n", cfg->index, dflt->index);
-
-	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-	/* IO window settings */
-	PDEBUG(DEBUG_EXTRA, "IO window settings: cfg->io.nwin=%d "
-	       "dflt->io.nwin=%d\n",
-	       cfg->io.nwin, dflt->io.nwin);
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-					pcmcia_io_cfg_data_width(io->flags);
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-	}
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* This reserves IO space but doesn't actually enable it */
 	return pcmcia_request_io(p_dev);
 }
 
@@ -531,7 +496,7 @@ static int prism2_config(struct pcmcia_device *link)
 
 	/* Look for an appropriate configuration table entry in the CIS */
 	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO |
-		CONF_AUTO_CHECK_VCC;
+		CONF_AUTO_CHECK_VCC | CONF_AUTO_SET_IO | CONF_ENABLE_IRQ;
 	if (ignore_cis_vcc)
 		link->config_flags &= ~CONF_AUTO_CHECK_VCC;
 	ret = pcmcia_loop_config(link, prism2_config_check, NULL);
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 031f3e6..2c6f28a 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -794,20 +794,12 @@ static void if_cs_release(struct pcmcia_device *p_dev)
  * insertion event.
  */
 
-static int if_cs_ioprobe(struct pcmcia_device *p_dev,
-			 cistpl_cftable_entry_t *cfg,
-			 cistpl_cftable_entry_t *dflt,
-			 void *priv_data)
+static int if_cs_ioprobe(struct pcmcia_device *p_dev, void *priv_data)
 {
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
 	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	p_dev->resource[0]->start = cfg->io.win[0].base;
-	p_dev->resource[0]->end = cfg->io.win[0].len;
 
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-	/* IO window settings */
-	if (cfg->io.nwin != 1) {
+	if (p_dev->resource[1]->end) {
 		lbs_pr_err("wrong CIS (check number of IO windows)\n");
 		return -ENODEV;
 	}
@@ -833,6 +825,8 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	card->p_dev = p_dev;
 	p_dev->priv = card;
 
+	p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
+
 	if (pcmcia_loop_config(p_dev, if_cs_ioprobe, NULL)) {
 		lbs_pr_err("error in pcmcia_loop_config\n");
 		goto out1;
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index b921738..263dfe9 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -142,42 +142,12 @@ static void orinoco_cs_detach(struct pcmcia_device *link)
  * device available to the system.
  */
 
-static int orinoco_cs_config_check(struct pcmcia_device *p_dev,
-				   cistpl_cftable_entry_t *cfg,
-				   cistpl_cftable_entry_t *dflt,
-				   void *priv_data)
+static int orinoco_cs_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cfg->index == 0)
-		goto next_entry;
-
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev) != 0)
-			goto next_entry;
-	}
-	return 0;
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-next_entry:
-	pcmcia_disable_device(p_dev);
-	return -ENODEV;
+	return pcmcia_request_io(p_dev);
 };
 
 static int
@@ -202,7 +172,8 @@ orinoco_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
+	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC |
+		CONF_AUTO_SET_IO | CONF_ENABLE_IRQ;
 	if (ignore_cis_vcc)
 		link->config_flags &= ~CONF_AUTO_CHECK_VCC;
 	ret = pcmcia_loop_config(link, orinoco_cs_config_check, NULL);
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index f462c78..7844650 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -205,48 +205,12 @@ static void spectrum_cs_detach(struct pcmcia_device *link)
  */
 
 static int spectrum_cs_config_check(struct pcmcia_device *p_dev,
-				    cistpl_cftable_entry_t *cfg,
-				    cistpl_cftable_entry_t *dflt,
 				    void *priv_data)
 {
-	if (cfg->index == 0)
-		goto next_entry;
-
-	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp =
-			cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp =
-			dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev) != 0)
-			goto next_entry;
-	}
-	return 0;
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-next_entry:
-	pcmcia_disable_device(p_dev);
-	return -ENODEV;
+	return pcmcia_request_io(p_dev);
 };
 
 static int
@@ -271,7 +235,8 @@ spectrum_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
+	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC |
+		CONF_AUTO_SET_IO | CONF_ENABLE_IRQ;
 	if (ignore_cis_vcc)
 		link->config_flags &= ~CONF_AUTO_CHECK_VCC;
 	ret = pcmcia_loop_config(link, spectrum_cs_config_check, NULL);
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index 8c2a473..3730184 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -100,9 +100,7 @@ static int parport_probe(struct pcmcia_device *link)
     link->priv = info;
     info->p_dev = link;
 
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-    link->config_flags |= CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 
     return parport_config(link);
 } /* parport_attach */
@@ -133,27 +131,14 @@ static void parport_detach(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static int parport_config_check(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int parport_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		if (epp_mode)
-			p_dev->config_index |= FORCE_EPP_MODE;
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin == 2) {
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		if (pcmcia_request_io(p_dev) != 0)
-			return -ENODEV;
-		return 0;
-	}
-	return -ENODEV;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int parport_config(struct pcmcia_device *link)
@@ -164,6 +149,9 @@ static int parport_config(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "parport_config\n");
 
+    if (epp_mode)
+	    link->config_index |= FORCE_EPP_MODE;
+
     ret = pcmcia_loop_config(link, parport_config_check, NULL);
     if (ret)
 	    goto failed;
diff --git a/drivers/pcmcia/pcmcia_cis.c b/drivers/pcmcia/pcmcia_cis.c
index d3f8d47..9745c01 100644
--- a/drivers/pcmcia/pcmcia_cis.c
+++ b/drivers/pcmcia/pcmcia_cis.c
@@ -6,7 +6,7 @@
  * are Copyright (C) 1999 David A. Hinds.  All Rights Reserved.
  *
  * Copyright (C) 1999	     David A. Hinds
- * Copyright (C) 2004-2009   Dominik Brodowski
+ * Copyright (C) 2004-2010   Dominik Brodowski
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -125,13 +125,24 @@ next_entry:
 	return ret;
 }
 
+
+/**
+ * pcmcia_io_cfg_data_width() - convert cfgtable to data path width parameter
+ */
+static int pcmcia_io_cfg_data_width(unsigned int flags)
+{
+	if (!(flags & CISTPL_IO_8BIT))
+		return IO_DATA_PATH_WIDTH_16;
+	if (!(flags & CISTPL_IO_16BIT))
+		return IO_DATA_PATH_WIDTH_8;
+	return IO_DATA_PATH_WIDTH_AUTO;
+}
+
+
 struct pcmcia_cfg_mem {
 	struct pcmcia_device *p_dev;
+	int (*conf_check) (struct pcmcia_device *p_dev, void *priv_data);
 	void *priv_data;
-	int (*conf_check) (struct pcmcia_device *p_dev,
-			   cistpl_cftable_entry_t *cfg,
-			   cistpl_cftable_entry_t *dflt,
-			   void *priv_data);
 	cisparse_t parse;
 	cistpl_cftable_entry_t dflt;
 };
@@ -184,16 +195,62 @@ static int pcmcia_do_loop_config(tuple_t *tuple, cisparse_t *parse, void *priv)
 	if ((flags & CONF_AUTO_AUDIO) && (cfg->flags & CISTPL_CFTABLE_AUDIO))
 		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
-	return cfg_mem->conf_check(cfg_mem->p_dev, cfg, &cfg_mem->dflt,
-				   cfg_mem->priv_data);
+
+	/* IO window settings? */
+	if (flags & CONF_AUTO_SET_IO) {
+		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
+		int i = 0;
+
+		p_dev->resource[0]->start = p_dev->resource[0]->end = 0;
+		p_dev->resource[1]->start = p_dev->resource[1]->end = 0;
+		if (io->nwin == 0)
+			return -ENODEV;
+
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+					pcmcia_io_cfg_data_width(io->flags);
+		if (io->nwin > 1) {
+			/* For multifunction cards, by convention, we
+			 * configure the network function with window 0,
+			 * and serial with window 1 */
+			i = (io->win[1].len > io->win[0].len);
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1-i].base;
+			p_dev->resource[1]->end = io->win[1-i].len;
+		}
+		p_dev->resource[0]->start = io->win[i].base;
+		p_dev->resource[0]->end = io->win[i].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+	}
+
+	/* MEM window settings? */
+	if (flags & CONF_AUTO_SET_IOMEM) {
+		/* so far, we only set one memory window */
+		cistpl_mem_t *mem = (cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
+
+		p_dev->resource[2]->start = p_dev->resource[2]->end = 0;
+		if (mem->nwin == 0)
+			return -ENODEV;
+
+		p_dev->resource[2]->start = mem->win[0].host_addr;
+		p_dev->resource[2]->end = mem->win[0].len;
+		if (p_dev->resource[2]->end < 0x1000)
+			p_dev->resource[2]->end = 0x1000;
+		p_dev->card_addr = mem->win[0].card_addr;
+	}
+
+	dev_dbg(&p_dev->dev, "checking configuration %d: %pR %pR %pR\n",
+		p_dev->config_index, p_dev->resource[0], p_dev->resource[1],
+		p_dev->resource[2]);
+
+	return cfg_mem->conf_check(p_dev, cfg_mem->priv_data);
 }
 
 /**
  * pcmcia_loop_config() - loop over configuration options
  * @p_dev:	the struct pcmcia_device which we need to loop for.
  * @conf_check:	function to call for each configuration option.
- *		It gets passed the struct pcmcia_device, the CIS data
- *		describing the configuration option, and private data
+ *		It gets passed the struct pcmcia_device and private data
  *		being passed to pcmcia_loop_config()
  * @priv_data:	private data to be passed to the conf_check function.
  *
@@ -203,8 +260,6 @@ static int pcmcia_do_loop_config(tuple_t *tuple, cisparse_t *parse, void *priv)
  */
 int pcmcia_loop_config(struct pcmcia_device *p_dev,
 		       int	(*conf_check)	(struct pcmcia_device *p_dev,
-						 cistpl_cftable_entry_t *cfg,
-						 cistpl_cftable_entry_t *dflt,
 						 void *priv_data),
 		       void *priv_data)
 {
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index 0b5fc2f..bd9ce09 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -99,9 +99,7 @@ static int aha152x_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = info;
 
-    link->resource[0]->end = 0x20;
-    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-    link->config_flags |= CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
     link->config_regs = PRESENT_OPTION;
 
     return aha152x_config_cs(link);
@@ -121,24 +119,24 @@ static void aha152x_detach(struct pcmcia_device *link)
 
 /*====================================================================*/
 
-static int aha152x_config_check(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int aha152x_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	p_dev->io_lines = 10;
+
 	/* For New Media T&J, look for a SCSI window */
-	if (cfg->io.win[0].len >= 0x20)
-		p_dev->resource[0]->start = cfg->io.win[0].base;
-	else if ((cfg->io.nwin > 1) &&
-		 (cfg->io.win[1].len >= 0x20))
-		p_dev->resource[0]->start = cfg->io.win[1].base;
-	if ((cfg->io.nwin > 0) &&
-	    (p_dev->resource[0]->start < 0xffff)) {
-		if (!pcmcia_request_io(p_dev))
-			return 0;
-	}
-	return -EINVAL;
+	if ((p_dev->resource[0]->end < 0x20) &&
+		(p_dev->resource[1]->end >= 0x20))
+		p_dev->resource[0]->start = p_dev->resource[1]->start;
+
+	if (p_dev->resource[0]->start >= 0xffff)
+		return -EINVAL;
+
+	p_dev->resource[1]->start = p_dev->resource[1]->end = 0;
+	p_dev->resource[0]->end = 0x20;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int aha152x_config_cs(struct pcmcia_device *link)
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 3b9f311..f2dc627 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -82,9 +82,7 @@ static int fdomain_probe(struct pcmcia_device *link)
 
 	info->p_dev = link;
 	link->priv = info;
-	link->resource[0]->end = 0x10;
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	link->config_flags |= CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 	link->config_regs = PRESENT_OPTION;
 
 	return fdomain_config(link);
@@ -103,13 +101,12 @@ static void fdomain_detach(struct pcmcia_device *link)
 
 /*====================================================================*/
 
-static int fdomain_config_check(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int fdomain_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	p_dev->io_lines = 10;
-	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = 0x10;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	return pcmcia_request_io(p_dev);
 }
 
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 9b4ac20..3d6db73 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1556,13 +1556,6 @@ static int nsp_cs_probe(struct pcmcia_device *link)
 
 	nsp_dbg(NSP_DEBUG_INIT, "info=0x%p", info);
 
-	/* The io structure describes IO port mapping */
-	link->resource[0]->end	 = 0x10;
-	link->resource[0]->flags = IO_DATA_PATH_WIDTH_AUTO;
-
-	/* General socket configuration */
-	link->config_flags	 |= CONF_ENABLE_IRQ;
-
 	ret = nsp_cs_config(link);
 
 	nsp_dbg(NSP_DEBUG_INIT, "link=0x%p", link);
@@ -1594,50 +1587,27 @@ static void nsp_cs_detach(struct pcmcia_device *link)
     ethernet device available to the system.
 ======================================================================*/
 
-static int nsp_cs_config_check(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cfg,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int nsp_cs_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	struct nsp_hw_data		*data = priv_data;
 
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-					pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev) != 0)
-			goto next_entry;
-	}
+	/* This reserves IO space but doesn't actually enable it */
+	if (pcmcia_request_io(p_dev) != 0)
+		goto next_entry;
 
-	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-		cistpl_mem_t	*mem =
-			(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
+	if (resource_size(p_dev->resource[2])) {
 		p_dev->resource[2]->flags |= (WIN_DATA_WIDTH_16 |
 					WIN_MEMORY_TYPE_CM |
 					WIN_ENABLE);
-		p_dev->resource[2]->start = mem->win[0].host_addr;
-		p_dev->resource[2]->end = mem->win[0].len;
 		if (p_dev->resource[2]->end < 0x1000)
 			p_dev->resource[2]->end = 0x1000;
 		if (pcmcia_request_window(p_dev, p_dev->resource[2], 0) != 0)
 			goto next_entry;
 		if (pcmcia_map_mem_page(p_dev, p_dev->resource[2],
-						mem->win[0].card_addr) != 0)
+						p_dev->card_addr) != 0)
 			goto next_entry;
 
 		data->MmioAddress = (unsigned long)
@@ -1664,7 +1634,8 @@ static int nsp_cs_config(struct pcmcia_device *link)
 	nsp_dbg(NSP_DEBUG_INIT, "in");
 
 	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_CHECK_VCC |
-		CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO;
+		CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO | CONF_AUTO_SET_IOMEM |
+		CONF_AUTO_SET_IO;
 
 	ret = pcmcia_loop_config(link, nsp_cs_config_check, data);
 	if (ret)
@@ -1727,7 +1698,7 @@ static int nsp_cs_config(struct pcmcia_device *link)
 		printk(", io %pR", link->resource[0]);
 	if (link->resource[1])
 		printk(" & %pR", link->resource[1]);
-	if (link->resource[1])
+	if (link->resource[2])
 		printk(", mem %pR", link->resource[2]);
 	printk("\n");
 
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 468fd12..e8a06e3 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -155,9 +155,7 @@ static int qlogic_probe(struct pcmcia_device *link)
 		return -ENOMEM;
 	info->p_dev = link;
 	link->priv = info;
-	link->resource[0]->end = 16;
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	link->config_flags |= CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 	link->config_regs = PRESENT_OPTION;
 
 	return qlogic_config(link);
@@ -176,14 +174,11 @@ static void qlogic_detach(struct pcmcia_device *link)
 
 /*====================================================================*/
 
-static int qlogic_config_check(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cfg,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int qlogic_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	p_dev->io_lines = 10;
-	p_dev->resource[0]->start = cfg->io.win[0].base;
-	p_dev->resource[0]->end = cfg->io.win[0].len;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
 	if (p_dev->resource[0]->start == 0)
 		return -ENODEV;
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 7a0bb9a..6ceb57c 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -683,14 +683,11 @@ static struct scsi_host_template sym53c500_driver_template = {
      .shost_attrs		= SYM53C500_shost_attrs
 };
 
-static int SYM53C500_config_check(struct pcmcia_device *p_dev,
-				  cistpl_cftable_entry_t *cfg,
-				  cistpl_cftable_entry_t *dflt,
-				  void *priv_data)
+static int SYM53C500_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	p_dev->io_lines = 10;
-	p_dev->resource[0]->start = cfg->io.win[0].base;
-	p_dev->resource[0]->end = cfg->io.win[0].len;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
 	if (p_dev->resource[0]->start == 0)
 		return -ENODEV;
@@ -857,9 +854,7 @@ SYM53C500_probe(struct pcmcia_device *link)
 		return -ENOMEM;
 	info->p_dev = link;
 	link->priv = info;
-	link->resource[0]->end = 16;
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	link->config_flags |= CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 
 	return SYM53C500_config(link);
 } /* SYM53C500_attach */
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 57e042b..b272443 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -332,7 +332,7 @@ static int serial_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 	if (do_sound)
 		link->config_flags |= CONF_ENABLE_SPKR;
 
@@ -403,41 +403,45 @@ static int setup_serial(struct pcmcia_device *handle, struct serial_info * info,
 
 /*====================================================================*/
 
-static int simple_config_check(struct pcmcia_device *p_dev,
-			       cistpl_cftable_entry_t *cf,
-			       cistpl_cftable_entry_t *dflt,
-			       void *priv_data)
+static int simple_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
 	static const int size_table[2] = { 8, 16 };
 	int *try = priv_data;
 
-	p_dev->io_lines = ((*try & 0x1) == 0) ?
-			16 : cf->io.flags & CISTPL_IO_LINES_MASK;
+	if (p_dev->resource[0]->start == 0)
+		return -ENODEV;
 
-	if ((cf->io.nwin > 0) && (cf->io.win[0].len == size_table[(*try >> 1)])
-	    && (cf->io.win[0].base != 0)) {
-		p_dev->resource[0]->start = cf->io.win[0].base;
-		if (!pcmcia_request_io(p_dev))
-			return 0;
-	}
-	return -EINVAL;
+	if ((*try & 0x1) == 0)
+		p_dev->io_lines = 16;
+
+	if (p_dev->resource[0]->end != size_table[(*try >> 1)])
+		return -ENODEV;
+
+	p_dev->resource[0]->end = 8;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int simple_config_check_notpicky(struct pcmcia_device *p_dev,
-					cistpl_cftable_entry_t *cf,
-					cistpl_cftable_entry_t *dflt,
 					void *priv_data)
 {
 	static const unsigned int base[5] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8, 0x0 };
 	int j;
 
-	if ((cf->io.nwin > 0) && ((cf->io.flags & CISTPL_IO_LINES_MASK) <= 3)) {
-		for (j = 0; j < 5; j++) {
-			p_dev->resource[0]->start = base[j];
-			p_dev->io_lines = base[j] ? 16 : 3;
-			if (!pcmcia_request_io(p_dev))
-				return 0;
-		}
+	if (p_dev->io_lines > 3)
+		return -ENODEV;
+
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[0]->end = 8;
+
+	for (j = 0; j < 5; j++) {
+		p_dev->resource[0]->start = base[j];
+		p_dev->io_lines = base[j] ? 16 : 3;
+		if (!pcmcia_request_io(p_dev))
+			return 0;
 	}
 	return -ENODEV;
 }
@@ -465,12 +469,9 @@ static int simple_config(struct pcmcia_device *link)
 		}
 	}
 
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-	link->resource[0]->end = 8;
-
 	/* First pass: look for a config entry that looks normal.
 	 * Two tries: without IO aliases, then with aliases */
-	link->config_flags |= CONF_AUTO_SET_VPP;
+	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_SET_IO;
 	for (try = 0; try < 4; try++)
 		if (!pcmcia_loop_config(link, simple_config_check, &try))
 			goto found_port;
@@ -501,43 +502,44 @@ found_port:
 	return setup_serial(link, info, link->resource[0]->start, link->irq);
 }
 
-static int multi_config_check(struct pcmcia_device *p_dev,
-			      cistpl_cftable_entry_t *cf,
-			      cistpl_cftable_entry_t *dflt,
-			      void *priv_data)
+static int multi_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	int *base2 = priv_data;
+	int *multi = priv_data;
+
+	if (p_dev->resource[1]->end)
+		return -EINVAL;
 
 	/* The quad port cards have bad CIS's, so just look for a
 	   window larger than 8 ports and assume it will be right */
-	if ((cf->io.nwin == 1) && (cf->io.win[0].len > 8)) {
-		p_dev->resource[0]->start = cf->io.win[0].base;
-		p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev)) {
-			*base2 = p_dev->resource[0]->start + 8;
-			return 0;
-		}
-	}
-	return -ENODEV;
+	if (p_dev->resource[0]->end <= 8)
+		return -EINVAL;
+
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[0]->end = *multi * 8;
+
+	if (pcmcia_request_io(p_dev))
+		return -ENODEV;
+	return 0;
 }
 
 static int multi_config_check_notpicky(struct pcmcia_device *p_dev,
-				       cistpl_cftable_entry_t *cf,
-				       cistpl_cftable_entry_t *dflt,
 				       void *priv_data)
 {
 	int *base2 = priv_data;
 
-	if (cf->io.nwin == 2) {
-		p_dev->resource[0]->start = cf->io.win[0].base;
-		p_dev->resource[1]->start = cf->io.win[1].base;
-		p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev)) {
-			*base2 = p_dev->resource[1]->start;
-			return 0;
-		}
-	}
-	return -ENODEV;
+	if (!p_dev->resource[0]->end || !p_dev->resource[1]->end)
+		return -ENODEV;
+
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 8;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+
+	if (pcmcia_request_io(p_dev))
+		return -ENODEV;
+
+	*base2 = p_dev->resource[0]->start + 8;
+	return 0;
 }
 
 static int multi_config(struct pcmcia_device *link)
@@ -545,12 +547,12 @@ static int multi_config(struct pcmcia_device *link)
 	struct serial_info *info = link->priv;
 	int i, base2 = 0;
 
+	link->config_flags |= CONF_AUTO_SET_IO;
 	/* First, look for a generic full-sized window */
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-	link->resource[0]->end = info->multi * 8;
-	if (pcmcia_loop_config(link, multi_config_check, &base2)) {
+	if (!pcmcia_loop_config(link, multi_config_check, &info->multi))
+		base2 = link->resource[0]->start + 8;
+	else {
 		/* If that didn't work, look for two windows */
-		link->resource[0]->end = link->resource[1]->end = 8;
 		info->multi = 2;
 		if (pcmcia_loop_config(link, multi_config_check_notpicky,
 				       &base2)) {
@@ -586,7 +588,7 @@ static int multi_config(struct pcmcia_device *link)
 		    link->config_index == 3) {
 			err = setup_serial(link, info, base2,
 					link->irq);
-			base2 = link->resource[0]->start;;
+			base2 = link->resource[0]->start;
 		} else {
 			err = setup_serial(link, info, link->resource[0]->start,
 					link->irq);
@@ -610,18 +612,18 @@ static int multi_config(struct pcmcia_device *link)
 	return 0;
 }
 
-static int serial_check_for_multi(struct pcmcia_device *p_dev,
-				  cistpl_cftable_entry_t *cf,
-				  cistpl_cftable_entry_t *dflt,
-				  void *priv_data)
+static int serial_check_for_multi(struct pcmcia_device *p_dev,  void *priv_data)
 {
 	struct serial_info *info = p_dev->priv;
 
-	if ((cf->io.nwin == 1) && (cf->io.win[0].len % 8 == 0))
-		info->multi = cf->io.win[0].len >> 3;
+	if (!p_dev->resource[0]->end)
+		return -EINVAL;
+
+	if ((!p_dev->resource[1]->end) && (p_dev->resource[0]->end % 8 == 0))
+		info->multi = p_dev->resource[0]->end >> 3;
 
-	if ((cf->io.nwin == 2) && (cf->io.win[0].len == 8) &&
-		(cf->io.win[1].len == 8))
+	if ((p_dev->resource[1]->end) && (p_dev->resource[0]->end == 8)
+		&& (p_dev->resource[1]->end == 8))
 		info->multi = 2;
 
 	return 0; /* break */
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index 678fbf6..c43c689 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -710,36 +710,12 @@ static void das16cs_pcmcia_detach(struct pcmcia_device *link)
 
 
 static int das16cs_pcmcia_config_loop(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
 				void *priv_data)
 {
-	if (cfg->index == 0)
+	if (p_dev->config_index == 0)
 		return -EINVAL;
 
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		/* This reserves IO space but doesn't actually enable it */
-		return pcmcia_request_io(p_dev);
-	}
-
-	return 0;
+	return pcmcia_request_io(p_dev);
 }
 
 static void das16cs_pcmcia_config(struct pcmcia_device *link)
@@ -748,6 +724,9 @@ static void das16cs_pcmcia_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "das16cs_pcmcia_config\n");
 
+	/* Do we need to allocate an interrupt? */
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
+
 	ret = pcmcia_loop_config(link, das16cs_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index 12a96b7..d395909 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -192,35 +192,12 @@ static void das08_pcmcia_detach(struct pcmcia_device *link)
 
 
 static int das08_pcmcia_config_loop(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
 				void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		/* This reserves IO space but doesn't actually enable it */
-		return pcmcia_request_io(p_dev);
-	}
-	return 0;
+	if (p_dev->config_index == 0)
+		return -EINVAL;
+
+	return pcmcia_request_io(p_dev);
 }
 
 
@@ -238,6 +215,8 @@ static void das08_pcmcia_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "das08_pcmcia_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
+
 	ret = pcmcia_loop_config(link, das08_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index f22dc0f..7129b0c 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -530,35 +530,12 @@ static void dio700_cs_detach(struct pcmcia_device *link)
 ======================================================================*/
 
 static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
 				void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev) != 0)
-			return -ENODEV;
-	}
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* If we got this far, we're cool! */
-	return 0;
+	return pcmcia_request_io(p_dev);
 }
 
 static void dio700_config(struct pcmcia_device *link)
@@ -570,7 +547,8 @@ static void dio700_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "dio700_config\n");
 
-	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_AUDIO;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_AUDIO |
+		CONF_AUTO_SET_IO;
 
 	ret = pcmcia_loop_config(link, dio700_pcmcia_config_loop, NULL);
 	if (ret) {
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 6dc2b06..4defdda 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -282,35 +282,12 @@ static void dio24_cs_detach(struct pcmcia_device *link)
 ======================================================================*/
 
 static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
 				void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev) != 0)
-			return -ENODEV;
-	}
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* If we got this far, we're cool! */
-	return 0;
+	return pcmcia_request_io(p_dev);
 }
 
 static void dio24_config(struct pcmcia_device *link)
@@ -321,7 +298,8 @@ static void dio24_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "dio24_config\n");
 
-	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_AUDIO;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_AUDIO |
+		CONF_AUTO_SET_IO;
 
 	ret = pcmcia_loop_config(link, dio24_pcmcia_config_loop, NULL);
 	if (ret) {
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 6eacbd7..5123b31 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -261,35 +261,12 @@ static void labpc_cs_detach(struct pcmcia_device *link)
 ======================================================================*/
 
 static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
 				void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev) != 0)
-			return -ENODEV;
-	}
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* If we got this far, we're cool! */
-	return 0;
+	return pcmcia_request_io(p_dev);
 }
 
 
@@ -300,7 +277,7 @@ static void labpc_config(struct pcmcia_device *link)
 	dev_dbg(&link->dev, "labpc_config\n");
 
 	link->config_flags |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ |
-		CONF_AUTO_AUDIO;
+		CONF_AUTO_AUDIO | CONF_AUTO_SET_IO;
 
 	ret = pcmcia_loop_config(link, labpc_pcmcia_config_loop, NULL);
 	if (ret) {
@@ -316,7 +293,6 @@ static void labpc_config(struct pcmcia_device *link)
 	   the I/O windows and the interrupt mapping, and putting the
 	   card and host interface into "Memory and IO" mode.
 	 */
-	p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index da4e2a2..f1e31d3 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -262,10 +262,6 @@ static struct pcmcia_device *cur_dev = NULL;
 
 static int cs_attach(struct pcmcia_device *link)
 {
-	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
-	link->resource[0]->end = 16;
-	link->config_flags |= CONF_ENABLE_IRQ;
-
 	cur_dev = link;
 
 	mio_cs_config(link);
@@ -299,15 +295,12 @@ static int mio_cs_resume(struct pcmcia_device *link)
 }
 
 
-static int mio_pcmcia_config_loop(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int mio_pcmcia_config_loop(struct pcmcia_device *p_dev, void *priv_data)
 {
 	int base, ret;
 
-	p_dev->resource[0]->end = cfg->io.win[0].len;
-	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 
 	for (base = 0x000; base < 0x400; base += 0x20) {
 		p_dev->resource[0]->start = base;
@@ -324,6 +317,7 @@ static void mio_cs_config(struct pcmcia_device *link)
 	int ret;
 
 	DPRINTK("mio_cs_config(link=%p)\n", link);
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 
 	ret = pcmcia_loop_config(link, mio_pcmcia_config_loop, NULL);
 	if (ret) {
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index 03a72d7..afd283d 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1068,35 +1068,11 @@ static void daqp_cs_detach(struct pcmcia_device *link)
 ======================================================================*/
 
 
-static int daqp_pcmcia_config_loop(struct pcmcia_device *p_dev,
-				cistpl_cftable_entry_t *cfg,
-				cistpl_cftable_entry_t *dflt,
-				void *priv_data)
+static int daqp_pcmcia_config_loop(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-		p_dev->resource[0]->flags |=
-			pcmcia_io_cfg_data_width(io->flags);
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		if (io->nwin > 1) {
-			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-	}
-
-	/* This reserves IO space but doesn't actually enable it */
 	return pcmcia_request_io(p_dev);
 }
 
@@ -1106,6 +1082,8 @@ static void daqp_cs_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "daqp_cs_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
+
 	ret = pcmcia_loop_config(link, daqp_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index 670a76b..76edd39 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -31,8 +31,6 @@ static int ixj_probe(struct pcmcia_device *p_dev)
 {
 	dev_dbg(&p_dev->dev, "ixj_attach()\n");
 	/* Create new ixj device */
-	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	p_dev->priv = kzalloc(sizeof(struct ixj_info_t), GFP_KERNEL);
 	if (!p_dev->priv) {
 		return -ENOMEM;
@@ -109,36 +107,28 @@ failed:
 	return;
 }
 
-static int ixj_config_check(struct pcmcia_device *p_dev,
-			    cistpl_cftable_entry_t *cfg,
-			    cistpl_cftable_entry_t *dflt,
-			    void *priv_data)
+static int ixj_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-		p_dev->io_lines = 3;
-		if (io->nwin == 2) {
-			p_dev->resource[1]->start = io->win[1].base;
-			p_dev->resource[1]->end = io->win[1].len;
-		}
-		if (!pcmcia_request_io(p_dev))
-			return 0;
-	}
-	return -ENODEV;
+	p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->io_lines = 3;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int ixj_config(struct pcmcia_device * link)
 {
 	IXJ *j;
 	ixj_info_t *info;
-	cistpl_cftable_entry_t dflt = { 0 };
 
 	info = link->priv;
 	dev_dbg(&link->dev, "ixj_config\n");
 
-	if (pcmcia_loop_config(link, ixj_config_check, &dflt))
+	link->config_flags = CONF_AUTO_SET_IO;
+
+	if (pcmcia_loop_config(link, ixj_config_check, NULL))
 		goto failed;
 
 	if (pcmcia_enable_device(link))
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index d960629..81d7eea 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -131,28 +131,12 @@ static void sl811_cs_release(struct pcmcia_device * link)
 	platform_device_unregister(&platform_dev);
 }
 
-static int sl811_cs_config_check(struct pcmcia_device *p_dev,
-				 cistpl_cftable_entry_t *cfg,
-				 cistpl_cftable_entry_t *dflt,
-				 void *priv_data)
+static int sl811_cs_config_check(struct pcmcia_device *p_dev, void *priv_data)
 {
-	if (cfg->index == 0)
-		return -ENODEV;
+	if (p_dev->config_index == 0)
+		return -EINVAL;
 
-	/* IO window settings */
-	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-
-		p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-		p_dev->resource[0]->start = io->win[0].base;
-		p_dev->resource[0]->end = io->win[0].len;
-
-		return pcmcia_request_io(p_dev);
-	}
-	pcmcia_disable_device(p_dev);
-	return -ENODEV;
+	return pcmcia_request_io(p_dev);
 }
 
 
@@ -164,7 +148,7 @@ static int sl811_cs_config(struct pcmcia_device *link)
 	dev_dbg(&link->dev, "sl811_cs_config\n");
 
 	link->config_flags |= CONF_ENABLE_IRQ |	CONF_AUTO_SET_VPP |
-		CONF_AUTO_CHECK_VCC;
+		CONF_AUTO_CHECK_VCC | CONF_AUTO_SET_IO;
 
 	if (pcmcia_loop_config(link, sl811_cs_config_check, NULL))
 		goto failed;
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 0577e5f..0b8c8d4 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -93,6 +93,7 @@ struct pcmcia_device {
 	/* device setup */
 	unsigned int		irq;
 	struct resource		*resource[PCMCIA_NUM_RESOURCES];
+	resource_size_t		card_addr;	/* for the 1st IOMEM resource */
 	unsigned int		vpp;
 
 	unsigned int		config_flags;	/* CONF_ENABLE_ flags below */
@@ -175,8 +176,6 @@ int pcmcia_parse_tuple(tuple_t *tuple, cisparse_t *parse);
 /* loop CIS entries for valid configuration */
 int pcmcia_loop_config(struct pcmcia_device *p_dev,
 		       int	(*conf_check)	(struct pcmcia_device *p_dev,
-						 cistpl_cftable_entry_t *cf,
-						 cistpl_cftable_entry_t *dflt,
 						 void *priv_data),
 		       void *priv_data);
 
@@ -225,16 +224,6 @@ void pcmcia_disable_device(struct pcmcia_device *p_dev);
 #define IO_DATA_PATH_WIDTH_16	0x08
 #define IO_DATA_PATH_WIDTH_AUTO	0x10
 
-/* convert flag found in cfgtable to data path width parameter */
-static inline int pcmcia_io_cfg_data_width(unsigned int flags)
-{
-	if (!(flags & CISTPL_IO_8BIT))
-		return IO_DATA_PATH_WIDTH_16;
-	if (!(flags & CISTPL_IO_16BIT))
-		return IO_DATA_PATH_WIDTH_8;
-	return IO_DATA_PATH_WIDTH_AUTO;
-}
-
 /* IO memory */
 #define WIN_MEMORY_TYPE_CM	0x00 /* default */
 #define WIN_MEMORY_TYPE_AM	0x20 /* MAP_ATTRIB */
@@ -264,16 +253,17 @@ static inline int pcmcia_io_cfg_data_width(unsigned int flags)
 #define PRESENT_IOSIZE		0x200
 
 /* flags to be passed to pcmcia_enable_device() */
-#define CONF_ENABLE_IRQ         0x01
-#define CONF_ENABLE_SPKR        0x02
-#define CONF_ENABLE_PULSE_IRQ   0x04
-#define CONF_ENABLE_ESR         0x08
+#define CONF_ENABLE_IRQ         0x0001
+#define CONF_ENABLE_SPKR        0x0002
+#define CONF_ENABLE_PULSE_IRQ   0x0004
+#define CONF_ENABLE_ESR         0x0008
 
 /* flags used by pcmcia_loop_config() autoconfiguration */
-#define CONF_AUTO_CHECK_VCC	0x10 /* check for matching Vcc? */
-#define CONF_AUTO_SET_VPP	0x20 /* set Vpp? */
-#define CONF_AUTO_AUDIO		0x40 /* enable audio line? */
