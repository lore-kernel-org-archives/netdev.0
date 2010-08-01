From: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH 05/11] pcmcia: do not use io_req_t when calling pcmcia_request_io()
Date: Sun,  1 Aug 2010 14:59:04 +0200
Message-ID: <1280667550-3040-5-git-send-email-linux@dominikbrodowski.net>
References: <20100801125749.GA2564@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
To: <linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100801125749.GA2564-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of io_req_t, drivers are now requested to fill out
struct pcmcia_device *p_dev->resource[0,1] for up to two ioport
ranges. After a call to pcmcia_request_io(), the ports found there
are reserved, after calling pcmcia_request_configuration(), they may
be used.

CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org
CC: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
CC: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
CC: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
---
 Documentation/pcmcia/driver-changes.txt          |    7 ++++
 drivers/ata/pata_pcmcia.c                        |   29 ++++++++-------
 drivers/bluetooth/bluecard_cs.c                  |   13 +++----
 drivers/bluetooth/bt3c_cs.c                      |   18 +++++-----
 drivers/bluetooth/btuart_cs.c                    |   18 +++++-----
 drivers/bluetooth/dtl1_cs.c                      |   21 +++++------
 drivers/char/pcmcia/cm4000_cs.c                  |   17 +++------
 drivers/char/pcmcia/cm4040_cs.c                  |   20 +++-------
 drivers/char/pcmcia/ipwireless/main.c            |   10 +++---
 drivers/char/pcmcia/synclink_cs.c                |   21 +++++------
 drivers/ide/ide-cs.c                             |   30 ++++++++-------
 drivers/isdn/hardware/avm/avm_cs.c               |   15 +++-----
 drivers/isdn/hisax/avma1_cs.c                    |   20 ++++------
 drivers/isdn/hisax/elsa_cs.c                     |   15 ++++----
 drivers/isdn/hisax/sedlbauer_cs.c                |   28 +++++++--------
 drivers/isdn/hisax/teles_cs.c                    |   15 ++++----
 drivers/net/pcmcia/3c574_cs.c                    |   11 +++---
 drivers/net/pcmcia/3c589_cs.c                    |   11 +++---
 drivers/net/pcmcia/axnet_cs.c                    |   40 +++++++++++----------
 drivers/net/pcmcia/com20020_cs.c                 |   19 ++++++----
 drivers/net/pcmcia/fmvj18x_cs.c                  |   31 ++++++++--------
 drivers/net/pcmcia/ibmtr_cs.c                    |   14 ++++----
 drivers/net/pcmcia/nmclan_cs.c                   |    8 ++--
 drivers/net/pcmcia/pcnet_cs.c                    |   40 +++++++++++----------
 drivers/net/pcmcia/smc91c92_cs.c                 |   43 +++++++++++-----------
 drivers/net/pcmcia/xirc2ps_cs.c                  |   34 +++++++++---------
 drivers/net/wireless/airo_cs.c                   |   22 +++++------
 drivers/net/wireless/atmel_cs.c                  |   22 +++++------
 drivers/net/wireless/b43/pcmcia.c                |    4 --
 drivers/net/wireless/hostap/hostap_cs.c          |   28 ++++++---------
 drivers/net/wireless/libertas/if_cs.c            |    8 ++--
 drivers/net/wireless/orinoco/orinoco_cs.c        |   24 ++++++-------
 drivers/net/wireless/orinoco/spectrum_cs.c       |   24 ++++++-------
 drivers/net/wireless/ray_cs.c                    |    5 +--
 drivers/net/wireless/wl3501_cs.c                 |   12 +++---
 drivers/parport/parport_cs.c                     |   16 ++++----
 drivers/pcmcia/pcmcia_resource.c                 |   37 +++++--------------
 drivers/scsi/pcmcia/aha152x_stub.c               |   14 ++++----
 drivers/scsi/pcmcia/fdomain_stub.c               |   10 +++---
 drivers/scsi/pcmcia/nsp_cs.c                     |   30 +++++++--------
 drivers/scsi/pcmcia/qlogic_stub.c                |   14 ++++----
 drivers/scsi/pcmcia/sym53c500_cs.c               |   14 ++++----
 drivers/serial/serial_cs.c                       |   37 ++++++++++---------
 drivers/staging/comedi/drivers/cb_das16_cs.c     |   24 ++++++-------
 drivers/staging/comedi/drivers/das08_cs.c        |   23 ++++++------
 drivers/staging/comedi/drivers/ni_daq_700.c      |   24 ++++++-------
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |   24 ++++++-------
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |   24 ++++++-------
 drivers/staging/comedi/drivers/ni_mio_cs.c       |   13 +++----
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |   24 ++++++-------
 drivers/staging/wlags49_h2/wl_cs.c               |    8 ++--
 drivers/telephony/ixj_pcmcia.c                   |   16 ++++----
 drivers/usb/host/sl811_cs.c                      |   12 +++---
 include/pcmcia/cs.h                              |   17 ---------
 include/pcmcia/ds.h                              |   21 ++++++++++-
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    6 ++--
 sound/pcmcia/vx/vxpocket.c                       |    6 ++--
 57 files changed, 527 insertions(+), 584 deletions(-)

diff --git a/Documentation/pcmcia/driver-changes.txt b/Documentation/pcmcia/driver-changes.txt
index ff5f0be..26c0f9c 100644
--- a/Documentation/pcmcia/driver-changes.txt
+++ b/Documentation/pcmcia/driver-changes.txt
@@ -1,4 +1,11 @@
 This file details changes in 2.6 which affect PCMCIA card driver authors:
+* pcmcia_request_io changes (as of 2.6.36)
+   Instead of io_req_t, drivers are now requested to fill out
+   struct pcmcia_device *p_dev->resource[0,1] for up to two ioport
+   ranges. After a call to pcmcia_request_io(), the ports found there
+   are reserved, after calling pcmcia_request_configuration(), they may
+   be used.
+
 * No dev_info_t, no cs_types.h (as of 2.6.36)
    dev_info_t and a few other typedefs are removed. No longer use them
    in PCMCIA device drivers. Also, do not include pcmcia/cs_types.h, as
diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 1fcd065..e944aa0 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -200,21 +200,23 @@ static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		pdev->io.BasePort1 = io->win[0].base;
-		pdev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			pdev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		pdev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		pdev->resource[0]->start = io->win[0].base;
+		if (!(io->flags & CISTPL_IO_16BIT)) {
+			pdev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+			pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+		}
 		if (io->nwin == 2) {
-			pdev->io.NumPorts1 = 8;
-			pdev->io.BasePort2 = io->win[1].base;
-			pdev->io.NumPorts2 = (stk->is_kme) ? 2 : 1;
-			if (pcmcia_request_io(pdev, &pdev->io) != 0)
+			pdev->resource[0]->end = 8;
+			pdev->resource[1]->start = io->win[1].base;
+			pdev->resource[1]->end = (stk->is_kme) ? 2 : 1;
+			if (pcmcia_request_io(pdev) != 0)
 				return -ENODEV;
 			stk->ctl_base = pdev->resource[1]->start;
 		} else if ((io->nwin == 1) && (io->win[0].len >= 16)) {
-			pdev->io.NumPorts1 = io->win[0].len;
-			pdev->io.NumPorts2 = 0;
-			if (pcmcia_request_io(pdev, &pdev->io) != 0)
+			pdev->resource[0]->end = io->win[0].len;
+			pdev->resource[1]->end = 0;
+			if (pcmcia_request_io(pdev) != 0)
 				return -ENODEV;
 			stk->ctl_base = pdev->resource[0]->start + 0x0e;
 		} else
@@ -245,9 +247,8 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	struct ata_port_operations *ops = &pcmcia_port_ops;
 
 	/* Set up attributes in order to probe card and get resources */
-	pdev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	pdev->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-	pdev->io.IOAddrLines = 3;
+	pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	pdev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	pdev->conf.Attributes = CONF_ENABLE_IRQ;
 	pdev->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 24d2007..d52e90a 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -865,9 +865,6 @@ static int bluecard_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->io.NumPorts1 = 8;
-
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -890,12 +887,14 @@ static int bluecard_config(struct pcmcia_device *link)
 	int i, n;
 
 	link->conf.ConfigIndex = 0x20;
-	link->io.NumPorts1 = 64;
-	link->io.IOAddrLines = 6;
+
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	link->resource[0]->end = 64;
+	link->io_lines = 6;
 
 	for (n = 0; n < 0x400; n += 0x40) {
-		link->io.BasePort1 = n ^ 0x300;
-		i = pcmcia_request_io(link, &link->io);
+		link->resource[0]->start = n ^ 0x300;
+		i = pcmcia_request_io(link);
 		if (i == 0)
 			break;
 	}
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 8ab494c..7ab8f29 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -657,8 +657,8 @@ static int bt3c_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->io.NumPorts1 = 8;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	link->resource[0]->end = 8;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -683,14 +683,14 @@ static int bt3c_check_config(struct pcmcia_device *p_dev,
 {
 	unsigned long try = (unsigned long) priv_data;
 
+	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
+
 	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
 		p_dev->conf.Vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
 	    (cf->io.win[0].base != 0)) {
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		p_dev->io.IOAddrLines = (try == 0) ? 16 :
-			cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		p_dev->resource[0]->start = cf->io.win[0].base;
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
 	return -ENODEV;
@@ -707,9 +707,9 @@ static int bt3c_check_config_notpicky(struct pcmcia_device *p_dev,
 
 	if ((cf->io.nwin > 0) && ((cf->io.flags & CISTPL_IO_LINES_MASK) <= 3)) {
 		for (j = 0; j < 5; j++) {
-			p_dev->io.BasePort1 = base[j];
-			p_dev->io.IOAddrLines = base[j] ? 16 : 3;
-			if (!pcmcia_request_io(p_dev, &p_dev->io))
+			p_dev->resource[0]->start = base[j];
+			p_dev->io_lines = base[j] ? 16 : 3;
+			if (!pcmcia_request_io(p_dev))
 				return 0;
 		}
 	}
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 7e770d4..1c4f5e8 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -586,8 +586,8 @@ static int btuart_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->io.NumPorts1 = 8;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	link->resource[0]->end = 8;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -612,14 +612,14 @@ static int btuart_check_config(struct pcmcia_device *p_dev,
 {
 	int *try = priv_data;
 
+	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
+
 	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
 		p_dev->conf.Vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
 	    (cf->io.win[0].base != 0)) {
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		p_dev->io.IOAddrLines = (*try == 0) ? 16 :
-			cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		p_dev->resource[0]->start = cf->io.win[0].base;
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
 	return -ENODEV;
@@ -636,9 +636,9 @@ static int btuart_check_config_notpicky(struct pcmcia_device *p_dev,
 
 	if ((cf->io.nwin > 0) && ((cf->io.flags & CISTPL_IO_LINES_MASK) <= 3)) {
 		for (j = 0; j < 5; j++) {
-			p_dev->io.BasePort1 = base[j];
-			p_dev->io.IOAddrLines = base[j] ? 16 : 3;
-			if (!pcmcia_request_io(p_dev, &p_dev->io))
+			p_dev->resource[0]->start = base[j];
+			p_dev->io_lines = base[j] ? 16 : 3;
+			if (!pcmcia_request_io(p_dev))
 				return 0;
 		}
 	}
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index bfe9313..18ecc57 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -572,8 +572,8 @@ static int dtl1_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->io.NumPorts1 = 8;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	link->resource[0]->end = 8;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -597,14 +597,13 @@ static int dtl1_confcheck(struct pcmcia_device *p_dev,
 			  unsigned int vcc,
 			  void *priv_data)
 {
-	if ((cf->io.nwin == 1) && (cf->io.win[0].len > 8)) {
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		p_dev->io.NumPorts1 = cf->io.win[0].len;	/*yo */
-		p_dev->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
-			return 0;
-	}
-	return -ENODEV;
+	if ((cf->io.nwin != 1) || (cf->io.win[0].len <= 8))
+		return -ENODEV;
+
+	p_dev->resource[0]->start = cf->io.win[0].base;
+	p_dev->resource[0]->end = cf->io.win[0].len;	/*yo */
+	p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
+	return pcmcia_request_io(p_dev);
 }
 
 static int dtl1_config(struct pcmcia_device *link)
@@ -613,7 +612,7 @@ static int dtl1_config(struct pcmcia_device *link)
 	int i;
 
 	/* Look for a generic full-sized window */
-	link->io.NumPorts1 = 8;
+	link->resource[0]->end = 8;
 	if (pcmcia_loop_config(link, dtl1_confcheck, NULL) < 0)
 		goto failed;
 
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index 18484ed..ec73d9f 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -1751,17 +1751,12 @@ static int cm4000_config_check(struct pcmcia_device *p_dev,
 	if (!cfg->io.nwin)
 		return -ENODEV;
 
-	/* Get the IOaddr */
-	p_dev->io.BasePort1 = cfg->io.win[0].base;
-	p_dev->io.NumPorts1 = cfg->io.win[0].len;
-	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	if (!(cfg->io.flags & CISTPL_IO_8BIT))
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-	if (!(cfg->io.flags & CISTPL_IO_16BIT))
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	p_dev->io.IOAddrLines = cfg->io.flags & CISTPL_IO_LINES_MASK;
-
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
+	p_dev->resource[0]->flags |= pcmcia_io_cfg_data_width(cfg->io.flags);
+	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int cm4000_config(struct pcmcia_device * link, int devno)
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index a6bbf19..815cde1 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -527,16 +527,12 @@ static int cm4040_config_check(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Get the IOaddr */
-	p_dev->io.BasePort1 = cfg->io.win[0].base;
-	p_dev->io.NumPorts1 = cfg->io.win[0].len;
-	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	if (!(cfg->io.flags & CISTPL_IO_8BIT))
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-	if (!(cfg->io.flags & CISTPL_IO_16BIT))
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	p_dev->io.IOAddrLines = cfg->io.flags & CISTPL_IO_LINES_MASK;
-
-	rc = pcmcia_request_io(p_dev, &p_dev->io);
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
+	p_dev->resource[0]->flags |= pcmcia_io_cfg_data_width(cfg->io.flags);
+	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
+	rc = pcmcia_request_io(p_dev);
+
 	dev_printk(KERN_INFO, &p_dev->dev,
 		   "pcmcia_request_io returned 0x%x\n", rc);
 	return rc;
@@ -548,10 +544,6 @@ static int reader_config(struct pcmcia_device *link, int devno)
 	struct reader_dev *dev;
 	int fail_rc;
 
-	link->io.BasePort2 = 0;
-	link->io.NumPorts2 = 0;
-	link->io.Attributes2 = 0;
-
 	if (pcmcia_loop_config(link, cm4040_config_check, NULL))
 		goto cs_release;
 
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 9467994..5f87b9f 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -88,15 +88,15 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	memreq_t memreq_common_memory;
 	int ret;
 
-	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	p_dev->io.BasePort1 = cfg->io.win[0].base;
-	p_dev->io.NumPorts1 = cfg->io.win[0].len;
-	p_dev->io.IOAddrLines = 16;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
 
 	/* 0x40 causes it to generate level mode interrupts. */
 	/* 0x04 enables IREQ pin. */
 	p_dev->conf.ConfigIndex = cfg->index | 0x44;
-	ret = pcmcia_request_io(p_dev, &p_dev->io);
+	p_dev->io_lines = 16;
+	ret = pcmcia_request_io(p_dev);
 	if (ret)
 		return ret;
 
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 8ded9b0..9ecd6be 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -571,18 +571,15 @@ static int mgslpc_ioprobe(struct pcmcia_device *p_dev,
 			  unsigned int vcc,
 			  void *priv_data)
 {
-	if (cfg->io.nwin > 0) {
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(cfg->io.flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(cfg->io.flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = cfg->io.flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = cfg->io.win[0].base;
-		p_dev->io.NumPorts1 = cfg->io.win[0].len;
-		return pcmcia_request_io(p_dev, &p_dev->io);
-	}
-	return -ENODEV;
+	if (!cfg->io.nwin)
+		return -ENODEV;
+
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
+	p_dev->resource[0]->flags |= pcmcia_io_cfg_data_width(cfg->io.flags);
+	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
+
+	return pcmcia_request_io(p_dev);
 }
 
 static int mgslpc_config(struct pcmcia_device *link)
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 34eafaf..c1a16f3 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -97,9 +97,8 @@ static int ide_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = info;
 
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-    link->io.IOAddrLines = 3;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -228,22 +227,25 @@ static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
+		pdev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+
 		pdev->conf.ConfigIndex = cfg->index;
-		pdev->io.BasePort1 = io->win[0].base;
-		pdev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			pdev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		pdev->resource[0]->start = io->win[0].base;
+		if (!(io->flags & CISTPL_IO_16BIT)) {
+			pdev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+			pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+		}
 		if (io->nwin == 2) {
-			pdev->io.NumPorts1 = 8;
-			pdev->io.BasePort2 = io->win[1].base;
-			pdev->io.NumPorts2 = (stk->is_kme) ? 2 : 1;
-			if (pcmcia_request_io(pdev, &pdev->io) != 0)
+			pdev->resource[0]->end = 8;
+			pdev->resource[1]->start = io->win[1].base;
+			pdev->resource[1]->end = (stk->is_kme) ? 2 : 1;
+			if (pcmcia_request_io(pdev) != 0)
 				return -ENODEV;
 			stk->ctl_base = pdev->resource[1]->start;
 		} else if ((io->nwin == 1) && (io->win[0].len >= 16)) {
-			pdev->io.NumPorts1 = io->win[0].len;
-			pdev->io.NumPorts2 = 0;
-			if (pcmcia_request_io(pdev, &pdev->io) != 0)
+			pdev->resource[0]->end = io->win[0].len;
+			pdev->resource[1]->end = 0;
+			if (pcmcia_request_io(pdev) != 0)
 				return -ENODEV;
 			stk->ctl_base = pdev->resource[1]->start + 0x0e;
 		} else
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 7c8c51f..09b1795 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -75,9 +75,8 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
 {
 
     /* The io structure describes IO port mapping */
-    p_dev->io.NumPorts1 = 16;
-    p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-    p_dev->io.NumPorts2 = 0;
+    p_dev->resource[0]->end = 16;
+    p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
@@ -119,13 +118,9 @@ static int avmcs_configcheck(struct pcmcia_device *p_dev,
 	if (cf->io.nwin <= 0)
 		return -ENODEV;
 
-	p_dev->io.BasePort1 = cf->io.win[0].base;
-	p_dev->io.NumPorts1 = cf->io.win[0].len;
-	p_dev->io.NumPorts2 = 0;
-	printk(KERN_INFO "avm_cs: testing i/o %#x-%#x\n",
-	       p_dev->io.BasePort1,
-	       p_dev->io.BasePort1+p_dev->io.NumPorts1-1);
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	p_dev->resource[0]->start = cf->io.win[0].base;
+	p_dev->resource[0]->end = cf->io.win[0].len;
+	return pcmcia_request_io(p_dev);
 }
 
 static int avmcs_config(struct pcmcia_device *link)
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 8889963..94263c2 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -78,11 +78,10 @@ static int __devinit avma1cs_probe(struct pcmcia_device *p_dev)
     dev_dbg(&p_dev->dev, "avma1cs_attach()\n");
 
     /* The io structure describes IO port mapping */
-    p_dev->io.NumPorts1 = 16;
-    p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-    p_dev->io.NumPorts2 = 16;
-    p_dev->io.Attributes2 = IO_DATA_PATH_WIDTH_16;
-    p_dev->io.IOAddrLines = 5;
+    p_dev->resource[0]->end = 16;
+    p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+    p_dev->resource[1]->end = 16;
+    p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_16;
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
@@ -126,13 +125,10 @@ static int avma1cs_configcheck(struct pcmcia_device *p_dev,
 	if (cf->io.nwin <= 0)
 		return -ENODEV;
 
-	p_dev->io.BasePort1 = cf->io.win[0].base;
-	p_dev->io.NumPorts1 = cf->io.win[0].len;
-	p_dev->io.NumPorts2 = 0;
-	printk(KERN_INFO "avma1_cs: testing i/o %#x-%#x\n",
-	       p_dev->io.BasePort1,
-	       p_dev->io.BasePort1+p_dev->io.NumPorts1-1);
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	p_dev->resource[0]->start = cf->io.win[0].base;
+	p_dev->resource[0]->end = cf->io.win[0].len;
+	p_dev->io_lines = 5;
+	return pcmcia_request_io(p_dev);
 }
 
 
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index c10bfd3..b3c08aa 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -126,9 +126,8 @@ static int __devinit elsa_cs_probe(struct pcmcia_device *link)
       and attributes of IO windows) are fixed by the nature of the
       device, and can be hard-wired here.
     */
-    link->io.NumPorts1 = 8;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-    link->io.IOAddrLines = 3;
+    link->resource[0]->end = 8;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
@@ -173,16 +172,18 @@ static int elsa_cs_configcheck(struct pcmcia_device *p_dev,
 {
 	int j;
 
+	p_dev->io_lines = 3;
+
 	if ((cf->io.nwin > 0) && cf->io.win[0].base) {
 		printk(KERN_INFO "(elsa_cs: looks like the 96 model)\n");
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		p_dev->resource[0]->start = cf->io.win[0].base;
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	} else {
 		printk(KERN_INFO "(elsa_cs: looks like the 97 model)\n");
 		for (j = 0x2f0; j > 0x100; j -= 0x10) {
-			p_dev->io.BasePort1 = j;
-			if (!pcmcia_request_io(p_dev, &p_dev->io))
+			p_dev->resource[0]->start = j;
+			if (!pcmcia_request_io(p_dev))
 				return 0;
 		}
 	}
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index cecb35a..4755eb4 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -129,9 +129,8 @@ static int __devinit sedlbauer_probe(struct pcmcia_device *link)
     /* from old sedl_cs 
     */
     /* The io structure describes IO port mapping */
-    link->io.NumPorts1 = 8;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-    link->io.IOAddrLines = 3;
+    link->resource[0]->end = 8;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
     link->conf.Attributes = 0;
     link->conf.IntType = INT_MEMORY_AND_IO;
@@ -201,23 +200,22 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+					pcmcia_io_cfg_data_width(io->flags);
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		p_dev->io_lines = 3;
+		if (pcmcia_request_io(p_dev) != 0)
 			return -ENODEV;
 	}
 
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 3787fc7..7296102 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -106,9 +106,8 @@ static int __devinit teles_probe(struct pcmcia_device *link)
       and attributes of IO windows) are fixed by the nature of the
       device, and can be hard-wired here.
     */
-    link->io.NumPorts1 = 96;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-    link->io.IOAddrLines = 5;
+    link->resource[0]->end = 96;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
@@ -153,16 +152,18 @@ static int teles_cs_configcheck(struct pcmcia_device *p_dev,
 {
 	int j;
 
+	p_dev->io_lines = 5;
+
 	if ((cf->io.nwin > 0) && cf->io.win[0].base) {
 		printk(KERN_INFO "(teles_cs: looks like the 96 model)\n");
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		p_dev->resource[0]->start = cf->io.win[0].base;
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	} else {
 		printk(KERN_INFO "(teles_cs: looks like the 97 model)\n");
 		for (j = 0x2f0; j > 0x100; j -= 0x10) {
-			p_dev->io.BasePort1 = j;
-			if (!pcmcia_request_io(p_dev, &p_dev->io))
+			p_dev->resource[0]->start = j;
+			if (!pcmcia_request_io(p_dev))
 				return 0;
 		}
 	}
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index b5ea9b8..c683f77 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -278,8 +278,8 @@ static int tc574_probe(struct pcmcia_device *link)
 	lp->p_dev = link;
 
 	spin_lock_init(&lp->window_lock);
-	link->io.NumPorts1 = 32;
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+	link->resource[0]->end = 32;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
@@ -337,10 +337,11 @@ static int tc574_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "3c574_config()\n");
 
-	link->io.IOAddrLines = 16;
+	link->io_lines = 16;
+
 	for (i = j = 0; j < 0x400; j += 0x20) {
-		link->io.BasePort1 = j ^ 0x300;
-		i = pcmcia_request_io(link, &link->io);
+		link->resource[0]->start = j ^ 0x300;
+		i = pcmcia_request_io(link);
 		if (i == 0)
 			break;
 	}
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 122ef4a..61f9cf2 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -213,8 +213,8 @@ static int tc589_probe(struct pcmcia_device *link)
     lp->p_dev = link;
 
     spin_lock_init(&lp->lock);
-    link->io.NumPorts1 = 16;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+    link->resource[0]->end = 16;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
@@ -277,12 +277,13 @@ static int tc589_config(struct pcmcia_device *link)
 		   "3Com card??\n");
     multi = (link->card_id == PRODID_3COM_3C562);
 
+    link->io_lines = 16;
+
     /* For the 3c562, the base address must be xx00-xx7f */
-    link->io.IOAddrLines = 16;
     for (i = j = 0; j < 0x400; j += 0x10) {
 	if (multi && (j & 0x80)) continue;
-	link->io.BasePort1 = j ^ 0x300;
-	i = pcmcia_request_io(link, &link->io);
+	link->resource[0]->start = j ^ 0x300;
+	i = pcmcia_request_io(link);
 	if (i == 0)
 		break;
     }
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index c52fdf3..5f05ffb 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -259,28 +259,30 @@ static int get_prom(struct pcmcia_device *link)
 static int try_io_port(struct pcmcia_device *link)
 {
     int j, ret;
-    if (link->io.NumPorts1 == 32) {
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+    link->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+    link->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+    if (link->resource[0]->end == 32) {
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	/* for master/slave multifunction cards */
-	if (link->io.NumPorts2 > 0)
-	    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
+	if (link->resource[1]->end > 0)
+	    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     } else {
 	/* This should be two 16-port windows */
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->io.Attributes2 = IO_DATA_PATH_WIDTH_16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	link->resource[1]->flags |= IO_DATA_PATH_WIDTH_16;
     }
-    if (link->io.BasePort1 == 0) {
-	link->io.IOAddrLines = 16;
+    if (link->resource[0]->start == 0) {
 	for (j = 0; j < 0x400; j += 0x20) {
-	    link->io.BasePort1 = j ^ 0x300;
-	    link->io.BasePort2 = (j ^ 0x300) + 0x10;
-	    ret = pcmcia_request_io(link, &link->io);
+	    link->resource[0]->start = j ^ 0x300;
+	    link->resource[1]->start = (j ^ 0x300) + 0x10;
+	    link->io_lines = 16;
+	    ret = pcmcia_request_io(link);
 	    if (ret == 0)
 		    return ret;
 	}
 	return ret;
     } else {
-	return pcmcia_request_io(link, &link->io);
+	return pcmcia_request_io(link);
     }
 }
 
@@ -301,15 +303,15 @@ static int axnet_configcheck(struct pcmcia_device *p_dev,
 	   network function with window 0, and serial with window 1 */
 	if (io->nwin > 1) {
 		i = (io->win[1].len > io->win[0].len);
-		p_dev->io.BasePort2 = io->win[1-i].base;
-		p_dev->io.NumPorts2 = io->win[1-i].len;
+		p_dev->resource[1]->start = io->win[1-i].base;
+		p_dev->resource[1]->end = io->win[1-i].len;
 	} else {
-		i = p_dev->io.NumPorts2 = 0;
+		i = p_dev->resource[1]->end = 0;
 	}
-	p_dev->io.BasePort1 = io->win[i].base;
-	p_dev->io.NumPorts1 = io->win[i].len;
-	p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-	if (p_dev->io.NumPorts1 + p_dev->io.NumPorts2 >= 32)
+	p_dev->resource[0]->start = io->win[i].base;
+	p_dev->resource[0]->end = io->win[i].len;
+	p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+	if (p_dev->resource[0]->end + p_dev->resource[1]->end >= 32)
 		return try_io_port(p_dev);
 
 	return -ENODEV;
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 3b53818..3c400cf 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -158,9 +158,8 @@ static int com20020_probe(struct pcmcia_device *p_dev)
     /* fill in our module parameters as defaults */
     dev->dev_addr[0] = node;
 
-    p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-    p_dev->io.NumPorts1 = 16;
-    p_dev->io.IOAddrLines = 16;
+    p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+    p_dev->resource[0]->end = 16;
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
     p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -245,20 +244,24 @@ static int com20020_config(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "com20020_config\n");
 
-    dev_dbg(&link->dev, "baseport1 is %Xh\n", link->io.BasePort1);
+    dev_dbg(&link->dev, "baseport1 is %Xh\n",
+	    (unsigned int) link->resource[0]->start);
+
     i = -ENODEV;
-    if (!link->io.BasePort1)
+    link->io_lines = 16;
+
+    if (!link->resource[0]->start)
     {
 	for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10)
 	{
-	    link->io.BasePort1 = ioaddr;
-	    i = pcmcia_request_io(link, &link->io);
+	    link->resource[0]->start = ioaddr;
+	    i = pcmcia_request_io(link);
 	    if (i == 0)
 		break;
 	}
     }
     else
-	i = pcmcia_request_io(link, &link->io);
+	i = pcmcia_request_io(link);
     
     if (i != 0)
     {
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index bba6369..6993044 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -248,9 +248,8 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     lp->base = NULL;
 
     /* The io structure describes IO port mapping */
-    link->io.NumPorts1 = 32;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-    link->io.IOAddrLines = 5;
+    link->resource[0]->end = 32;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
     /* General socket configuration */
     link->conf.Attributes = CONF_ENABLE_IRQ;
@@ -288,13 +287,13 @@ static int mfc_try_io_port(struct pcmcia_device *link)
 	{ 0x3f8, 0x2f8, 0x3e8, 0x2e8, 0x0 };
 
     for (i = 0; i < 5; i++) {
-	link->io.BasePort2 = serial_base[i];
-	link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-	if (link->io.BasePort2 == 0) {
-	    link->io.NumPorts2 = 0;
+	link->resource[1]->start = serial_base[i];
+	link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+	if (link->resource[1]->start == 0) {
+	    link->resource[1]->end = 0;
 	    printk(KERN_NOTICE "fmvj18x_cs: out of resource for serial\n");
 	}
-	ret = pcmcia_request_io(link, &link->io);
+	ret = pcmcia_request_io(link);
 	if (ret == 0)
 		return ret;
     }
@@ -310,8 +309,8 @@ static int ungermann_try_io_port(struct pcmcia_device *link)
 	0x380,0x3c0 only for ioport.
     */
     for (ioaddr = 0x300; ioaddr < 0x3e0; ioaddr += 0x20) {
-	link->io.BasePort1 = ioaddr;
-	ret = pcmcia_request_io(link, &link->io);
+	link->resource[0]->start = ioaddr;
+	ret = pcmcia_request_io(link);
 	if (ret == 0) {
 	    /* calculate ConfigIndex value */
 	    link->conf.ConfigIndex = 
@@ -345,6 +344,8 @@ static int fmvj18x_config(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "fmvj18x_config\n");
 
+    link->io_lines = 5;
+
     len = pcmcia_get_tuple(link, CISTPL_FUNCE, &buf);
     kfree(buf);
 
@@ -363,20 +364,20 @@ static int fmvj18x_config(struct pcmcia_device *link)
 		/* MultiFunction Card */
 		link->conf.ConfigBase = 0x800;
 		link->conf.ConfigIndex = 0x47;
-		link->io.NumPorts2 = 8;
+		link->resource[1]->end = 8;
 	    }
 	    break;
 	case MANFID_NEC:
 	    cardtype = NEC; /* MultiFunction Card */
 	    link->conf.ConfigBase = 0x800;
 	    link->conf.ConfigIndex = 0x47;
-	    link->io.NumPorts2 = 8;
+	    link->resource[1]->end = 8;
 	    break;
 	case MANFID_KME:
 	    cardtype = KME; /* MultiFunction Card */
 	    link->conf.ConfigBase = 0x800;
 	    link->conf.ConfigIndex = 0x47;
-	    link->io.NumPorts2 = 8;
+	    link->resource[1]->end = 8;
 	    break;
 	case MANFID_CONTEC:
 	    cardtype = CONTEC;
@@ -417,14 +418,14 @@ static int fmvj18x_config(struct pcmcia_device *link)
 	}
     }
 
-    if (link->io.NumPorts2 != 0) {
+    if (link->resource[1]->end != 0) {
 	ret = mfc_try_io_port(link);
 	if (ret != 0) goto failed;
     } else if (cardtype == UNGERMANN) {
 	ret = ungermann_try_io_port(link);
 	if (ret != 0) goto failed;
     } else { 
-	    ret = pcmcia_request_io(link, &link->io);
+	    ret = pcmcia_request_io(link);
 	    if (ret)
 		    goto failed;
     }
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index e99abaa..3fd8595 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -151,9 +151,8 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
     link->priv = info;
     info->ti = netdev_priv(dev);
 
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-    link->io.NumPorts1 = 4;
-    link->io.IOAddrLines = 16;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+    link->resource[0]->end = 4;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
@@ -218,16 +217,17 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     dev_dbg(&link->dev, "ibmtr_config\n");
 
     link->conf.ConfigIndex = 0x61;
+    link->io_lines = 16;
 
     /* Determine if this is PRIMARY or ALTERNATE. */
 
     /* Try PRIMARY card at 0xA20-0xA23 */
-    link->io.BasePort1 = 0xA20;
-    i = pcmcia_request_io(link, &link->io);
+    link->resource[0]->start = 0xA20;
+    i = pcmcia_request_io(link);
     if (i != 0) {
 	/* Couldn't get 0xA20-0xA23.  Try ALTERNATE at 0xA24-0xA27. */
-	link->io.BasePort1 = 0xA24;
-	ret = pcmcia_request_io(link, &link->io);
+	link->resource[0]->start = 0xA24;
+	ret = pcmcia_request_io(link);
 	if (ret)
 		goto failed;
     }
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 9980cbb..68f2dee 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -458,9 +458,8 @@ static int nmclan_probe(struct pcmcia_device *link)
     link->priv = dev;
     
     spin_lock_init(&lp->bank_lock);
-    link->io.NumPorts1 = 32;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-    link->io.IOAddrLines = 5;
+    link->resource[0]->end = 32;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
@@ -644,7 +643,8 @@ static int nmclan_config(struct pcmcia_device *link)
 
   dev_dbg(&link->dev, "nmclan_config\n");
 
-  ret = pcmcia_request_io(link, &link->io);
+  link->io_lines = 5;
+  ret = pcmcia_request_io(link);
   if (ret)
 	  goto failed;
   ret = pcmcia_request_exclusive_irq(link, mace_interrupt);
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index c9cd237..9c5fc9d 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -477,29 +477,31 @@ static hw_info_t *get_hwired(struct pcmcia_device *link)
 static int try_io_port(struct pcmcia_device *link)
 {
     int j, ret;
-    if (link->io.NumPorts1 == 32) {
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	if (link->io.NumPorts2 > 0) {
+    link->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+    link->resource[1]->flags &= ~IO_DATA_PATH_WIDTH;
+    if (link->resource[0]->end == 32) {
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	if (link->resource[1]->end > 0) {
 	    /* for master/slave multifunction cards */
-	    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
+	    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	}
     } else {
 	/* This should be two 16-port windows */
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->io.Attributes2 = IO_DATA_PATH_WIDTH_16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	link->resource[1]->flags |= IO_DATA_PATH_WIDTH_16;
     }
-    if (link->io.BasePort1 == 0) {
-	link->io.IOAddrLines = 16;
+    if (link->resource[0]->start == 0) {
 	for (j = 0; j < 0x400; j += 0x20) {
-	    link->io.BasePort1 = j ^ 0x300;
-	    link->io.BasePort2 = (j ^ 0x300) + 0x10;
-	    ret = pcmcia_request_io(link, &link->io);
+	    link->resource[0]->start = j ^ 0x300;
+	    link->resource[1]->start = (j ^ 0x300) + 0x10;
+	    link->io_lines = 16;
+	    ret = pcmcia_request_io(link);
 	    if (ret == 0)
 		    return ret;
 	}
 	return ret;
     } else {
-	return pcmcia_request_io(link, &link->io);
+	return pcmcia_request_io(link);
     }
 }
 
@@ -520,18 +522,18 @@ static int pcnet_confcheck(struct pcmcia_device *p_dev,
 	   network function with window 0, and serial with window 1 */
 	if (io->nwin > 1) {
 		i = (io->win[1].len > io->win[0].len);
-		p_dev->io.BasePort2 = io->win[1-i].base;
-		p_dev->io.NumPorts2 = io->win[1-i].len;
+		p_dev->resource[1]->start = io->win[1-i].base;
+		p_dev->resource[1]->end = io->win[1-i].len;
 	} else {
-		i = p_dev->io.NumPorts2 = 0;
+		i = p_dev->resource[1]->end = 0;
 	}
 
 	*has_shmem = ((cfg->mem.nwin == 1) &&
 		      (cfg->mem.win[0].len >= 0x4000));
-	p_dev->io.BasePort1 = io->win[i].base;
-	p_dev->io.NumPorts1 = io->win[i].len;
-	p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-	if (p_dev->io.NumPorts1 + p_dev->io.NumPorts2 >= 32)
+	p_dev->resource[0]->start = io->win[i].base;
+	p_dev->resource[0]->end = io->win[i].len;
+	p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+	if (p_dev->resource[0]->end + p_dev->resource[1]->end >= 32)
 		return try_io_port(p_dev);
 
 	return 0;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 1b0b323..a5e4779 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -324,9 +324,8 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->priv = dev;
 
     spin_lock_init(&smc->lock);
-    link->io.NumPorts1 = 16;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-    link->io.IOAddrLines = 4;
+    link->resource[0]->end = 16;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -427,12 +426,13 @@ static int mhz_mfc_config_check(struct pcmcia_device *p_dev,
 				void *priv_data)
 {
 	int k;
-	p_dev->io.BasePort2 = cf->io.win[0].base;
+	p_dev->resource[1]->start = cf->io.win[0].base;
 	for (k = 0; k < 0x400; k += 0x10) {
 		if (k & 0x80)
 			continue;
-		p_dev->io.BasePort1 = k ^ 0x300;
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		p_dev->resource[0]->start = k ^ 0x300;
+		p_dev->io_lines = 16;
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
 	return -ENODEV;
@@ -448,9 +448,8 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
-    link->io.IOAddrLines = 16;
-    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-    link->io.NumPorts2 = 8;
+    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+    link->resource[1]->end = 8;
 
     /* The Megahertz combo cards have modem-like CIS entries, so
        we have to explicitly try a bunch of port combinations. */
@@ -601,9 +600,9 @@ static int smc_configcheck(struct pcmcia_device *p_dev,
 			   unsigned int vcc,
 			   void *priv_data)
 {
-	p_dev->io.BasePort1 = cf->io.win[0].base;
-	p_dev->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	p_dev->resource[0]->start = cf->io.win[0].base;
+	p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
+	return pcmcia_request_io(p_dev);
 }
 
 static int smc_config(struct pcmcia_device *link)
@@ -611,7 +610,7 @@ static int smc_config(struct pcmcia_device *link)
     struct net_device *dev = link->priv;
     int i;
 
-    link->io.NumPorts1 = 16;
+    link->resource[0]->end = 16;
     i = pcmcia_loop_config(link, smc_configcheck, NULL);
     if (!i)
 	    dev->base_addr = link->resource[0]->start;
@@ -646,25 +645,25 @@ static int osi_config(struct pcmcia_device *link)
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
-    link->io.NumPorts1 = 64;
-    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-    link->io.NumPorts2 = 8;
-    link->io.IOAddrLines = 16;
+    link->resource[0]->end = 64;
+    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
+    link->resource[1]->end = 8;
 
     /* Enable Hard Decode, LAN, Modem */
     link->conf.ConfigIndex = 0x23;
+    link->io_lines = 16;
 
     for (i = j = 0; j < 4; j++) {
-	link->io.BasePort2 = com[j];
-	i = pcmcia_request_io(link, &link->io);
+	link->resource[1]->start = com[j];
+	i = pcmcia_request_io(link);
 	if (i == 0)
 		break;
     }
     if (i != 0) {
 	/* Fallback: turn off hard decode */
 	link->conf.ConfigIndex = 0x03;
-	link->io.NumPorts2 = 0;
-	i = pcmcia_request_io(link, &link->io);
+	link->resource[1]->end = 0;
+	i = pcmcia_request_io(link);
     }
     dev->base_addr = link->resource[0]->start + 0x10;
     return i;
@@ -803,7 +802,7 @@ static int check_sig(struct pcmcia_device *link)
     }
 
     /* Try setting bus width */
-    width = (link->io.Attributes1 == IO_DATA_PATH_WIDTH_AUTO);
+    width = (link->resource[0]->flags == IO_DATA_PATH_WIDTH_AUTO);
     s = inb(ioaddr + CONFIG);
     if (width)
 	s |= CFG_16BIT;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 1577b00..e051d3a 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -677,9 +677,9 @@ xirc2ps_config_modem(struct pcmcia_device *p_dev,
 
 	if (cf->io.nwin > 0  &&  (cf->io.win[0].base & 0xf) == 8) {
 		for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
-			p_dev->io.BasePort2 = cf->io.win[0].base;
-			p_dev->io.BasePort1 = ioaddr;
-			if (!pcmcia_request_io(p_dev, &p_dev->io))
+			p_dev->resource[1]->start = cf->io.win[0].base;
+			p_dev->resource[0]->start = ioaddr;
+			if (!pcmcia_request_io(p_dev))
 				return 0;
 		}
 	}
@@ -696,11 +696,11 @@ xirc2ps_config_check(struct pcmcia_device *p_dev,
 	int *pass = priv_data;
 
 	if (cf->io.nwin > 0 && (cf->io.win[0].base & 0xf) == 8) {
-		p_dev->io.BasePort2 = cf->io.win[0].base;
-		p_dev->io.BasePort1 = p_dev->io.BasePort2
+		p_dev->resource[1]->start = cf->io.win[0].base;
+		p_dev->resource[0]->start = p_dev->resource[1]->start
 			+ (*pass ? (cf->index & 0x20 ? -24:8)
 			   : (cf->index & 0x20 ?   8:-24));
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
 	return -ENODEV;
@@ -807,8 +807,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	goto failure;
     }
 
-    link->io.IOAddrLines =10;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
     if (local->modem) {
 	int pass;
 
@@ -816,16 +815,16 @@ xirc2ps_config(struct pcmcia_device * link)
 	    link->conf.Attributes |= CONF_ENABLE_SPKR;
 	    link->conf.Status |= CCSR_AUDIO_ENA;
 	}
-	link->io.NumPorts2 = 8;
-	link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
+	link->resource[1]->end = 8;
+	link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	if (local->dingo) {
 	    /* Take the Modem IO port from the CIS and scan for a free
 	     * Ethernet port */
-	    link->io.NumPorts1 = 16; /* no Mako stuff anymore */
+	    link->resource[0]->end = 16; /* no Mako stuff anymore */
 	    if (!pcmcia_loop_config(link, xirc2ps_config_modem, NULL))
 		    goto port_found;
 	} else {
-	    link->io.NumPorts1 = 18;
+	    link->resource[0]->end = 18;
 	    /* We do 2 passes here: The first one uses the regular mapping and
 	     * the second tries again, thereby considering that the 32 ports are
 	     * mirrored every 32 bytes. Actually we use a mirrored port for
@@ -840,14 +839,15 @@ xirc2ps_config(struct pcmcia_device * link)
 	}
 	printk(KNOT_XIRC "no ports available\n");
     } else {
-	link->io.NumPorts1 = 16;
+	link->io_lines = 10;
+	link->resource[0]->end = 16;
 	for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
-	    link->io.BasePort1 = ioaddr;
-	    if (!(err=pcmcia_request_io(link, &link->io)))
+	    link->resource[0]->start = ioaddr;
+	    if (!(err = pcmcia_request_io(link)))
 		goto port_found;
 	}
-	link->io.BasePort1 = 0; /* let CS decide */
-	if ((err=pcmcia_request_io(link, &link->io)))
+	link->resource[0]->start = 0; /* let CS decide */
+	if ((err = pcmcia_request_io(link)))
 	    goto config_error;
     }
   port_found:
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index b7e7f50..d241b4a 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -175,25 +175,23 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+					pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 	}
 
 	/* This reserves IO space but doesn't actually enable it */
-	if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+	if (pcmcia_request_io(p_dev) != 0)
 		return -ENODEV;
 
 	/*
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 65b3aed..3b63216 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -190,25 +190,23 @@ static int atmel_config_check(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+					pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 	}
 
 	/* This reserves IO space but doesn't actually enable it */
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	return pcmcia_request_io(p_dev);
 }
 
 static int atmel_config(struct pcmcia_device *link)
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index f71bc78..7c9af82 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -77,10 +77,6 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	dev->conf.Attributes = CONF_ENABLE_IRQ;
 	dev->conf.IntType = INT_MEMORY_AND_IO;
 
-	dev->io.BasePort2 = 0;
-	dev->io.NumPorts2 = 0;
-	dev->io.Attributes2 = 0;
-
 	win.Attributes = WIN_ADDR_SPACE_MEM | WIN_MEMORY_TYPE_CM |
 			 WIN_ENABLE | WIN_DATA_WIDTH_16 |
 			 WIN_USE_WAIT;
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 6db7fd1..04edfa9 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -519,30 +519,24 @@ static int prism2_config_check(struct pcmcia_device *p_dev,
 	PDEBUG(DEBUG_EXTRA, "IO window settings: cfg->io.nwin=%d "
 	       "dflt->io.nwin=%d\n",
 	       cfg->io.nwin, dflt->io.nwin);
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		PDEBUG(DEBUG_EXTRA, "io->flags = 0x%04X, "
-		       "io.base=0x%04x, len=%d\n", io->flags,
-		       io->win[0].base, io->win[0].len);
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags &
-			CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+					pcmcia_io_cfg_data_width(io->flags);
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 	}
 
 	/* This reserves IO space but doesn't actually enable it */
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	return pcmcia_request_io(p_dev);
 }
 
 static int prism2_config(struct pcmcia_device *link)
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index be4c475..9c29839 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -801,9 +801,9 @@ static int if_cs_ioprobe(struct pcmcia_device *p_dev,
 			 unsigned int vcc,
 			 void *priv_data)
 {
-	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	p_dev->io.BasePort1 = cfg->io.win[0].base;
-	p_dev->io.NumPorts1 = cfg->io.win[0].len;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
 
 	/* Do we need to allocate an interrupt? */
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
@@ -815,7 +815,7 @@ static int if_cs_ioprobe(struct pcmcia_device *p_dev,
 	}
 
 	/* This reserves IO space but doesn't actually enable it */
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	return pcmcia_request_io(p_dev);
 }
 
 static int if_cs_probe(struct pcmcia_device *p_dev)
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 6d514b5..ef46a2d 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -191,25 +191,23 @@ static int orinoco_cs_config_check(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 
 		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		if (pcmcia_request_io(p_dev) != 0)
 			goto next_entry;
 	}
 	return 0;
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 4f8f55e..873877e 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -253,25 +253,23 @@ static int spectrum_cs_config_check(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 
 		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		if (pcmcia_request_io(p_dev) != 0)
 			goto next_entry;
 	}
 	return 0;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 165beb6..b83d5ef 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -315,9 +315,8 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	local->finder = p_dev;
 
 	/* The io structure describes IO port mapping. None used here */
-	p_dev->io.NumPorts1 = 0;
-	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	p_dev->io.IOAddrLines = 5;
+	p_dev->resource[0]->end = 0;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
 	/* General socket configuration */
 	p_dev->conf.Attributes = CONF_ENABLE_IRQ;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index a32f220..a1cc2d4 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1884,9 +1884,8 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 	struct wl3501_card *this;
 
 	/* The io structure describes IO port mapping */
-	p_dev->io.NumPorts1	= 16;
-	p_dev->io.Attributes1	= IO_DATA_PATH_WIDTH_8;
-	p_dev->io.IOAddrLines	= 5;
+	p_dev->resource[0]->end	= 16;
+	p_dev->resource[0]->flags	= IO_DATA_PATH_WIDTH_8;
 
 	/* General socket configuration */
 	p_dev->conf.Attributes	= CONF_ENABLE_IRQ;
@@ -1932,13 +1931,14 @@ static int wl3501_config(struct pcmcia_device *link)
 	/* Try allocating IO ports.  This tries a few fixed addresses.  If you
 	 * want, you can also read the card's config table to pick addresses --
 	 * see the serial driver for an example. */
+	link->io_lines = 5;
 
 	for (j = 0x280; j < 0x400; j += 0x20) {
 		/* The '^0x300' is so that we probe 0x300-0x3ff first, then
 		 * 0x200-0x2ff, and so on, because this seems safer */
-		link->io.BasePort1 = j;
-		link->io.BasePort2 = link->io.BasePort1 + 0x10;
-		i = pcmcia_request_io(link, &link->io);
+		link->resource[0]->start = j;
+		link->resource[1]->start = link->resource[0]->start + 0x10;
+		i = pcmcia_request_io(link);
 		if (i == 0)
 			break;
 	}
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index fc1639c..23e50f4 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -101,8 +101,8 @@ static int parport_probe(struct pcmcia_device *link)
     link->priv = info;
     info->p_dev = link;
 
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+    link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -143,16 +143,16 @@ static int parport_config_check(struct pcmcia_device *p_dev,
 {
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
 		if (epp_mode)
 			p_dev->conf.ConfigIndex |= FORCE_EPP_MODE;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin == 2) {
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
-		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		if (pcmcia_request_io(p_dev) != 0)
 			return -ENODEV;
 		return 0;
 	}
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index fcd48da..a48d4a9 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -70,7 +70,8 @@ static int alloc_io_space(struct pcmcia_socket *s, struct resource *res,
 
 	res->flags |= IORESOURCE_IO;
 
-	dev_dbg(&s->dev, "alloc_io_space request for %pR\n", res);
+	dev_dbg(&s->dev, "alloc_io_space request for %pR, %d lines\n",
+		res, lines);
 
 	align = base ? (lines ? 1<<lines : 0) : 1;
 	if (align && (align < num)) {
@@ -541,38 +542,25 @@ EXPORT_SYMBOL(pcmcia_request_configuration);
  * pcmcia_request_io() - attempt to reserve port ranges for PCMCIA devices
  *
  * pcmcia_request_io() attepts to reserve the IO port ranges specified in
- * struct pcmcia_device *p_dev->resource[0] and *p_dev->resource[1]. The
+ * &struct pcmcia_device @p_dev->resource[0] and @p_dev->resource[1]. The
  * "start" value is the requested start of the IO port resource; "end"
- * relfects the number of ports requested.
- *
- * If io_req_t is passed, those values are converted automatically.
+ * reflects the number of ports requested. The number of IO lines requested
+ * is specified in &struct pcmcia_device @p_dev->io_lines.
  */
-int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req)
+int pcmcia_request_io(struct pcmcia_device *p_dev)
 {
 	struct pcmcia_socket *s = p_dev->socket;
-	config_t *c;
+	config_t *c = p_dev->function_config;
 	int ret = -EINVAL;
-	unsigned int lines = req->IOAddrLines;
 
 	mutex_lock(&s->ops_mutex);
+	dev_dbg(&s->dev, "pcmcia_request_io: %pR , %pR", &c->io[0], &c->io[1]);
 
 	if (!(s->state & SOCKET_PRESENT)) {
 		dev_dbg(&s->dev, "pcmcia_request_io: No card present\n");
 		goto out;
 	}
 
-	c = p_dev->function_config;
-	if (req) {
-		c->io[0].start = req->BasePort1;
-		c->io[0].end = req->NumPorts1;
-		c->io[0].flags |= req->Attributes1;
-		c->io[1].start = req->BasePort2;
-		c->io[1].end = req->NumPorts2;
-		c->io[1].flags |= req->Attributes2;
-	}
-
-	dev_dbg(&s->dev, "pcmcia_request_io: %pR , %pR", &c->io[0], &c->io[1]);
-
 	if (c->state & CONFIG_LOCKED) {
 		dev_dbg(&s->dev, "Configuration is locked\n");
 		goto out;
@@ -582,12 +570,12 @@ int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req)
 		goto out;
 	}
 
-	ret = alloc_io_space(s, &c->io[0], lines);
+	ret = alloc_io_space(s, &c->io[0], p_dev->io_lines);
 	if (ret)
 		goto out;
 
 	if (c->io[1].end) {
-		ret = alloc_io_space(s, &c->io[1], lines);
+		ret = alloc_io_space(s, &c->io[1], p_dev->io_lines);
 		if (ret) {
 			release_io_space(s, &c->io[0]);
 			goto out;
@@ -598,11 +586,6 @@ int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req)
 	c->state |= CONFIG_IO_REQ;
 	p_dev->_io = 1;
 
-	if (!ret) {
-		req->BasePort1 = c->io[0].start;
-		req->BasePort2 = c->io[1].start;
-	}
-
 	dev_dbg(&s->dev, "pcmcia_request_io succeeded: %pR , %pR",
 		&c->io[0], &c->io[1]);
 out:
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index 3e040f5..61f49bd 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -100,9 +100,8 @@ static int aha152x_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = info;
 
-    link->io.NumPorts1 = 0x20;
-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-    link->io.IOAddrLines = 10;
+    link->resource[0]->end = 0x20;
+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
@@ -130,15 +129,16 @@ static int aha152x_config_check(struct pcmcia_device *p_dev,
 				unsigned int vcc,
 				void *priv_data)
 {
+	p_dev->io_lines = 10;
 	/* For New Media T&J, look for a SCSI window */
 	if (cfg->io.win[0].len >= 0x20)
-		p_dev->io.BasePort1 = cfg->io.win[0].base;
+		p_dev->resource[0]->start = cfg->io.win[0].base;
 	else if ((cfg->io.nwin > 1) &&
 		 (cfg->io.win[1].len >= 0x20))
-		p_dev->io.BasePort1 = cfg->io.win[1].base;
+		p_dev->resource[0]->start = cfg->io.win[1].base;
 	if ((cfg->io.nwin > 0) &&
-	    (p_dev->io.BasePort1 < 0xffff)) {
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+	    (p_dev->resource[0]->start < 0xffff)) {
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
 	return -EINVAL;
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 49a9a0a..13dbe5c 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -83,9 +83,8 @@ static int fdomain_probe(struct pcmcia_device *link)
 
 	info->p_dev = link;
 	link->priv = info;
-	link->io.NumPorts1 = 0x10;
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	link->io.IOAddrLines = 10;
+	link->resource[0]->end = 0x10;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
@@ -112,8 +111,9 @@ static int fdomain_config_check(struct pcmcia_device *p_dev,
 				unsigned int vcc,
 				void *priv_data)
 {
-	p_dev->io.BasePort1 = cfg->io.win[0].base;
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	p_dev->io_lines = 10;
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	return pcmcia_request_io(p_dev);
 }
 
 
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 964c913..ad8e896 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1558,9 +1558,8 @@ static int nsp_cs_probe(struct pcmcia_device *link)
 	nsp_dbg(NSP_DEBUG_INIT, "info=0x%p", info);
 
 	/* The io structure describes IO port mapping */
-	link->io.NumPorts1	 = 0x10;
-	link->io.Attributes1	 = IO_DATA_PATH_WIDTH_AUTO;
-	link->io.IOAddrLines	 = 10;	/* not used */
+	link->resource[0]->end	 = 0x10;
+	link->resource[0]->flags = IO_DATA_PATH_WIDTH_AUTO;
 
 	/* General socket configuration */
 	link->conf.Attributes	 = CONF_ENABLE_IRQ;
@@ -1641,24 +1640,23 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 		/* IO window settings */
-		p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+		p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 		if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 			cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-			if (!(io->flags & CISTPL_IO_8BIT))
-				p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-			if (!(io->flags & CISTPL_IO_16BIT))
-				p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-			p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-			p_dev->io.BasePort1 = io->win[0].base;
-			p_dev->io.NumPorts1 = io->win[0].len;
+			p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+			p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+			p_dev->resource[0]->flags |=
+				pcmcia_io_cfg_data_width(io->flags);
+			p_dev->resource[0]->start = io->win[0].base;
+			p_dev->resource[0]->end = io->win[0].len;
 			if (io->nwin > 1) {
-				p_dev->io.Attributes2 = p_dev->io.Attributes1;
-				p_dev->io.BasePort2 = io->win[1].base;
-				p_dev->io.NumPorts2 = io->win[1].len;
+				p_dev->resource[1]->flags =
+					p_dev->resource[0]->flags;
+				p_dev->resource[1]->start = io->win[1].base;
+				p_dev->resource[1]->end = io->win[1].len;
 			}
 			/* This reserves IO space but doesn't actually enable it */
-			if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+			if (pcmcia_request_io(p_dev) != 0)
 				goto next_entry;
 		}
 
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 4e2b83f..eb775f1 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -156,9 +156,8 @@ static int qlogic_probe(struct pcmcia_device *link)
 		return -ENOMEM;
 	info->p_dev = link;
 	link->priv = info;
-	link->io.NumPorts1 = 16;
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	link->io.IOAddrLines = 10;
+	link->resource[0]->end = 16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
@@ -185,13 +184,14 @@ static int qlogic_config_check(struct pcmcia_device *p_dev,
 			       unsigned int vcc,
 			       void *priv_data)
 {
-	p_dev->io.BasePort1 = cfg->io.win[0].base;
-	p_dev->io.NumPorts1 = cfg->io.win[0].len;
+	p_dev->io_lines = 10;
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
 
-	if (p_dev->io.BasePort1 == 0)
+	if (p_dev->resource[0]->start == 0)
 		return -ENODEV;
 
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	return pcmcia_request_io(p_dev);
 }
 
 static int qlogic_config(struct pcmcia_device * link)
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index d99c0cb..321e390 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -690,13 +690,14 @@ static int SYM53C500_config_check(struct pcmcia_device *p_dev,
 				  unsigned int vcc,
 				  void *priv_data)
 {
-	p_dev->io.BasePort1 = cfg->io.win[0].base;
-	p_dev->io.NumPorts1 = cfg->io.win[0].len;
+	p_dev->io_lines = 10;
+	p_dev->resource[0]->start = cfg->io.win[0].base;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
 
-	if (p_dev->io.BasePort1 == 0)
+	if (p_dev->resource[0]->start == 0)
 		return -ENODEV;
 
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	return pcmcia_request_io(p_dev);
 }
 
 static int
@@ -858,9 +859,8 @@ SYM53C500_probe(struct pcmcia_device *link)
 		return -ENOMEM;
 	info->p_dev = link;
 	link->priv = info;
-	link->io.NumPorts1 = 16;
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	link->io.IOAddrLines = 10;
+	link->resource[0]->end = 16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index fe7adcd..141c695 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -335,8 +335,8 @@ static int serial_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->io.NumPorts1 = 8;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	link->resource[0]->end = 8;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	if (do_sound) {
 		link->conf.Attributes |= CONF_ENABLE_SPKR;
@@ -424,12 +424,13 @@ static int simple_config_check(struct pcmcia_device *p_dev,
 		p_dev->conf.Vpp =
 			cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
+	p_dev->io_lines = ((*try & 0x1) == 0) ?
+			16 : cf->io.flags & CISTPL_IO_LINES_MASK;
+
 	if ((cf->io.nwin > 0) && (cf->io.win[0].len == size_table[(*try >> 1)])
 	    && (cf->io.win[0].base != 0)) {
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		p_dev->io.IOAddrLines = ((*try & 0x1) == 0) ?
-			16 : cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		p_dev->resource[0]->start = cf->io.win[0].base;
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
 	return -EINVAL;
@@ -446,9 +447,9 @@ static int simple_config_check_notpicky(struct pcmcia_device *p_dev,
 
 	if ((cf->io.nwin > 0) && ((cf->io.flags & CISTPL_IO_LINES_MASK) <= 3)) {
 		for (j = 0; j < 5; j++) {
-			p_dev->io.BasePort1 = base[j];
-			p_dev->io.IOAddrLines = base[j] ? 16 : 3;
-			if (!pcmcia_request_io(p_dev, &p_dev->io))
+			p_dev->resource[0]->start = base[j];
+			p_dev->io_lines = base[j] ? 16 : 3;
+			if (!pcmcia_request_io(p_dev))
 				return 0;
 		}
 	}
@@ -521,9 +522,9 @@ static int multi_config_check(struct pcmcia_device *p_dev,
 	/* The quad port cards have bad CIS's, so just look for a
 	   window larger than 8 ports and assume it will be right */
 	if ((cf->io.nwin == 1) && (cf->io.win[0].len > 8)) {
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		p_dev->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev, &p_dev->io)) {
+		p_dev->resource[0]->start = cf->io.win[0].base;
+		p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
+		if (!pcmcia_request_io(p_dev)) {
 			*base2 = p_dev->resource[0]->start + 8;
 			return 0;
 		}
@@ -540,10 +541,10 @@ static int multi_config_check_notpicky(struct pcmcia_device *p_dev,
 	int *base2 = priv_data;
 
 	if (cf->io.nwin == 2) {
-		p_dev->io.BasePort1 = cf->io.win[0].base;
-		p_dev->io.BasePort2 = cf->io.win[1].base;
-		p_dev->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
-		if (!pcmcia_request_io(p_dev, &p_dev->io)) {
+		p_dev->resource[0]->start = cf->io.win[0].base;
+		p_dev->resource[1]->start = cf->io.win[1].base;
+		p_dev->io_lines = cf->io.flags & CISTPL_IO_LINES_MASK;
+		if (!pcmcia_request_io(p_dev)) {
 			*base2 = p_dev->resource[1]->start;
 			return 0;
 		}
@@ -557,10 +558,10 @@ static int multi_config(struct pcmcia_device *link)
 	int i, base2 = 0;
 
 	/* First, look for a generic full-sized window */
-	link->io.NumPorts1 = info->multi * 8;
+	link->resource[0]->end = info->multi * 8;
 	if (pcmcia_loop_config(link, multi_config_check, &base2)) {
 		/* If that didn't work, look for two windows */
-		link->io.NumPorts1 = link->io.NumPorts2 = 8;
+		link->resource[0]->end = link->resource[1]->end = 8;
 		info->multi = 2;
 		if (pcmcia_loop_config(link, multi_config_check_notpicky,
 				       &base2)) {
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index 208f1b7..7cf0ccb 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -736,24 +736,22 @@ static int das16cs_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 		/* This reserves IO space but doesn't actually enable it */
-		return pcmcia_request_io(p_dev, &p_dev->io);
+		return pcmcia_request_io(p_dev);
 	}
 
 	return 0;
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index c4cfcff..9ee677f 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -224,24 +224,23 @@ static int das08_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
 		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 		/* This reserves IO space but doesn't actually enable it */
-		return pcmcia_request_io(p_dev, &p_dev->io);
+		return pcmcia_request_io(p_dev);
 	}
 	return 0;
 }
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 6d56957..7e41ad9 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -571,24 +571,22 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		if (pcmcia_request_io(p_dev) != 0)
 			return -ENODEV;
 	}
 
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 29e1daf..b2483f8 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -323,24 +323,22 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		if (pcmcia_request_io(p_dev) != 0)
 			return -ENODEV;
 	}
 
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index fb10987..c1444b4 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -301,24 +301,22 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		if (pcmcia_request_io(p_dev) != 0)
 			return -ENODEV;
 	}
 
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index f37dc22..d50b6c4 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -264,8 +264,8 @@ static const dev_info_t dev_info = "ni_mio_cs";
 
 static int cs_attach(struct pcmcia_device *link)
 {
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-	link->io.NumPorts1 = 16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
+	link->resource[0]->end = 16;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -310,13 +310,12 @@ static int mio_pcmcia_config_loop(struct pcmcia_device *p_dev,
 {
 	int base, ret;
 
-	p_dev->io.NumPorts1 = cfg->io.win[0].len;
-	p_dev->io.IOAddrLines = cfg->io.flags & CISTPL_IO_LINES_MASK;
-	p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = cfg->io.win[0].len;
+	p_dev->io_lines = cfg->io.flags & CISTPL_IO_LINES_MASK;
 
 	for (base = 0x000; base < 0x400; base += 0x20) {
-		p_dev->io.BasePort1 = base;
-		ret = pcmcia_request_io(p_dev, &p_dev->io);
+		p_dev->resource[0]->start = base;
+		ret = pcmcia_request_io(p_dev);
 		if (!ret)
 			return 0;
 	}
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index 80b8d57..25f4e67 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1102,26 +1102,24 @@ static int daqp_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-		if (!(io->flags & CISTPL_IO_8BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-		if (!(io->flags & CISTPL_IO_16BIT))
-			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+			pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 		if (io->nwin > 1) {
-			p_dev->io.Attributes2 = p_dev->io.Attributes1;
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
 	}
 
 	/* This reserves IO space but doesn't actually enable it */
-	return pcmcia_request_io(p_dev, &p_dev->io);
+	return pcmcia_request_io(p_dev);
 }
 
 static void daqp_cs_config(struct pcmcia_device *link)
diff --git a/drivers/staging/wlags49_h2/wl_cs.c b/drivers/staging/wlags49_h2/wl_cs.c
index 2361537..f15afd2 100644
--- a/drivers/staging/wlags49_h2/wl_cs.c
+++ b/drivers/staging/wlags49_h2/wl_cs.c
@@ -145,9 +145,8 @@ static int wl_adapter_attach(struct pcmcia_device *link)
 	return -ENOMEM;
     }
 
-    link->io.NumPorts1      = HCF_NUM_IO_PORTS;
-    link->io.Attributes1    = IO_DATA_PATH_WIDTH_16;
-    link->io.IOAddrLines    = 6;
+    link->resource[0]->end      = HCF_NUM_IO_PORTS;
+    link->resource[0]->flags    = IO_DATA_PATH_WIDTH_16;
     link->conf.Attributes   = CONF_ENABLE_IRQ;
     link->conf.IntType      = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex  = 5;
@@ -305,8 +304,9 @@ void wl_adapter_insert( struct pcmcia_device *link )
 
     /* Do we need to allocate an interrupt? */
     link->conf.Attributes |= CONF_ENABLE_IRQ;
+    link->io_lines = 6;
 
-    ret = pcmcia_request_io(link, &link->io);
+    ret = pcmcia_request_io(link);
     if (ret != 0)
         goto failed;
 
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index a801036..a1900e5 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -32,9 +32,8 @@ static int ixj_probe(struct pcmcia_device *p_dev)
 {
 	dev_dbg(&p_dev->dev, "ixj_attach()\n");
 	/* Create new ixj device */
-	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	p_dev->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-	p_dev->io.IOAddrLines = 3;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 	p_dev->priv = kzalloc(sizeof(struct ixj_info_t), GFP_KERNEL);
 	if (!p_dev->priv) {
@@ -120,13 +119,14 @@ static int ixj_config_check(struct pcmcia_device *p_dev,
 {
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
+		p_dev->io_lines = 3;
 		if (io->nwin == 2) {
-			p_dev->io.BasePort2 = io->win[1].base;
-			p_dev->io.NumPorts2 = io->win[1].len;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
-		if (!pcmcia_request_io(p_dev, &p_dev->io))
+		if (!pcmcia_request_io(p_dev))
 			return 0;
 	}
 	return -ENODEV;
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 22e04f2..0e13a00 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -162,16 +162,16 @@ static int sl811_cs_config_check(struct pcmcia_device *p_dev,
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
-	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
 
-		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-		p_dev->io.BasePort1 = io->win[0].base;
-		p_dev->io.NumPorts1 = io->win[0].len;
+		p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
 
-		return pcmcia_request_io(p_dev, &p_dev->io);
+		return pcmcia_request_io(p_dev);
 	}
 	pcmcia_disable_device(p_dev);
 	return -ENODEV;
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 0cd8c70..ad71bb5 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -56,23 +56,6 @@ typedef struct config_req_t {
 #define INT_CARDBUS		0x04
 #define INT_ZOOMED_VIDEO	0x08
 
-/* For RequestIO and ReleaseIO */
-typedef struct io_req_t {
-    u_int	BasePort1;
-    u_int	NumPorts1;
-    u_int	Attributes1;
-    u_int	BasePort2;
-    u_int	NumPorts2;
-    u_int	Attributes2;
-    u_int	IOAddrLines;
-} io_req_t;
-
-/* Attributes for RequestIO and ReleaseIO */
-#define IO_DATA_PATH_WIDTH	0x18
-#define IO_DATA_PATH_WIDTH_8	0x00
-#define IO_DATA_PATH_WIDTH_16	0x08
-#define IO_DATA_PATH_WIDTH_AUTO	0x10
-
 /* Bits in IRQInfo1 field */
 #define IRQ_NMI_ID		0x01
 #define IRQ_IOCK_ID		0x02
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 3dafd7d..0748bec 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -80,7 +80,6 @@ struct pcmcia_device {
 	struct list_head	socket_device_list;
 
 	/* deprecated, will be cleaned up soon */
-	io_req_t		io;
 	config_req_t		conf;
 	window_handle_t		win;
 
@@ -88,6 +87,8 @@ struct pcmcia_device {
 	unsigned int		irq;
 	struct resource		*resource[MAX_IO_WIN];
 
+	unsigned int		io_lines; /* number of I/O lines */
+
 	/* Is the device suspended? */
 	u16			suspended:1;
 
@@ -179,7 +180,7 @@ int pcmcia_read_config_byte(struct pcmcia_device *p_dev, off_t where, u8 *val);
 int pcmcia_write_config_byte(struct pcmcia_device *p_dev, off_t where, u8 val);
 
 /* device configuration */
-int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req);
+int pcmcia_request_io(struct pcmcia_device *p_dev);
 
 int __must_check
 __pcmcia_request_exclusive_irq(struct pcmcia_device *p_dev,
@@ -206,6 +207,22 @@ int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t win,
 int pcmcia_modify_configuration(struct pcmcia_device *p_dev, modconf_t *mod);
 void pcmcia_disable_device(struct pcmcia_device *p_dev);
 
+/* IO ports */
+#define IO_DATA_PATH_WIDTH	0x18
+#define IO_DATA_PATH_WIDTH_8	0x00
+#define IO_DATA_PATH_WIDTH_16	0x08
+#define IO_DATA_PATH_WIDTH_AUTO	0x10
+
+/* convert flag found in cfgtable to data path width parameter */
+static inline int pcmcia_io_cfg_data_width(unsigned int flags)
+{
+	if (!(flags & CISTPL_IO_8BIT))
+		return IO_DATA_PATH_WIDTH_16;
+	if (!(flags & CISTPL_IO_16BIT))
+		return IO_DATA_PATH_WIDTH_8;
+	return IO_DATA_PATH_WIDTH_AUTO;
+}
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_DS_H */
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 9f897bc..7ab9174 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -139,8 +139,8 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 	pdacf->p_dev = link;
 	link->priv = pdacf;
 
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	link->io.NumPorts1 = 16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	link->resource[0]->end = 16;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -219,7 +219,7 @@ static int pdacf_config(struct pcmcia_device *link)
 	snd_printdd(KERN_DEBUG "pdacf_config called\n");
 	link->conf.ConfigIndex = 0x5;
 
-	ret = pcmcia_request_io(link, &link->io);
+	ret = pcmcia_request_io(link);
 	if (ret)
 		goto failed;
 
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index f23c235..a6edfc3 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -159,8 +159,8 @@ static int snd_vxpocket_new(struct snd_card *card, int ibl,
 	vxp->p_dev = link;
 	link->priv = chip;
 
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	link->io.NumPorts1 = 16;
+	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
+	link->resource[0]->end = 16;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -226,7 +226,7 @@ static int vxpocket_config(struct pcmcia_device *link)
 		strcpy(chip->card->driver, vxp440_hw.name);
 	}
 
-	ret = pcmcia_request_io(link, &link->io);
+	ret = pcmcia_request_io(link);
 	if (ret)
 		goto failed;
 
-- 
1.7.0.4
