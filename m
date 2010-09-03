From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 12/15] pcmcia: remove the "Finally, report what we've done" message
Date: Fri,  3 Sep 2010 12:57:11 +0200
Message-ID: <1283511434-21620-12-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:44060 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757404Ab0ICK5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 06:57:55 -0400
In-Reply-To: <20100903105628.GA21255@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove this unnecessary message -- this info is either available
in sysfs or by enabling dynamic debug from the PCMCIA core.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-scsi@vger.kernel.org
CC: linux-usb@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/synclink_cs.c                |    7 -------
 drivers/isdn/hisax/avma1_cs.c                    |    3 ---
 drivers/isdn/hisax/elsa_cs.c                     |   10 ----------
 drivers/isdn/hisax/sedlbauer_cs.c                |   12 ------------
 drivers/isdn/hisax/teles_cs.c                    |   10 ----------
 drivers/net/wireless/airo_cs.c                   |   11 -----------
 drivers/net/wireless/hostap/hostap_cs.c          |   15 +--------------
 drivers/pcmcia/ds.c                              |    7 +++++++
 drivers/scsi/pcmcia/nsp_cs.c                     |   15 ---------------
 drivers/staging/comedi/drivers/cb_das16_cs.c     |    9 ---------
 drivers/staging/comedi/drivers/das08_cs.c        |    9 ---------
 drivers/staging/comedi/drivers/ni_daq_700.c      |    9 ---------
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |    9 ---------
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |    9 ---------
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |    9 ---------
 drivers/usb/host/sl811_cs.c                      |    8 --------
 16 files changed, 8 insertions(+), 144 deletions(-)

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index a343b8f..7c71913 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -592,13 +592,6 @@ static int mgslpc_config(struct pcmcia_device *link)
 
     info->io_base = link->resource[0]->start;
     info->irq_level = link->irq;
-
-    dev_info(&link->dev, "index 0x%02x:",
-	    link->config_index);
-    printk(", irq %d", link->irq);
-    if (link->resource[0])
-	    printk(", io %pR", link->resource[0]);
-    printk("\n");
     return 0;
 
 failed:
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index cb09f0c..47590e0 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -162,9 +162,6 @@ static int __devinit avma1cs_config(struct pcmcia_device *link)
 	return -ENODEV;
     }
 
-    printk(KERN_NOTICE "avma1_cs: checking at i/o %#x, irq %d\n",
-		(unsigned int) link->resource[0]->start, link->irq);
-
     icard.para[0] = link->irq;
     icard.para[1] = link->resource[0]->start;
     icard.protocol = isdnprot;
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index f203a52..b37b9f0 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -196,16 +196,6 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
     if (i != 0)
 	goto failed;
 
-    /* Finally, report what we've done */
-    dev_info(&link->dev, "index 0x%02x: ",
-	    link->config_index);
-    printk(", irq %d", link->irq);
-    if (link->resource[0])
-	printk(" & %pR", link->resource[0]);
-    if (link->resource[1])
-	printk(" & %pR", link->resource[1]);
-    printk("\n");
-
     icard.para[0] = link->irq;
     icard.para[1] = link->resource[0]->start;
     icard.protocol = protocol;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index a88c88f..ff17dba 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -205,18 +205,6 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    /* Finally, report what we've done */
-    dev_info(&link->dev, "index 0x%02x:",
-	   link->config_index);
-    if (link->vpp)
-	printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
-    printk(", irq %d", link->irq);
-    if (link->resource[0])
-	printk(" & %pR", link->resource[0]);
-    if (link->resource[1])
-	printk(" & %pR", link->resource[1]);
-    printk("\n");
-
     icard.para[0] = link->irq;
     icard.para[1] = link->resource[0]->start;
     icard.protocol = protocol;
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 05a5631..13ba9ab 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -183,16 +183,6 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
     if (i != 0)
       goto cs_failed;
 
-    /* Finally, report what we've done */
-    dev_info(&link->dev, "index 0x%02x:",
-	    link->config_index);
-    printk(", irq %d", link->irq);
-    if (link->resource[0])
-	printk(" & %pR", link->resource[0]);
-    if (link->resource[1])
-	printk(" & %pR", link->resource[1]);
-    printk("\n");
-
     icard.para[0] = link->irq;
     icard.para[1] = link->resource[0]->start;
     icard.protocol = protocol;
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 77682f2..4067bf1 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -193,17 +193,6 @@ static int airo_config(struct pcmcia_device *link)
 	if (!((local_info_t *)link->priv)->eth_dev)
 		goto failed;
 
-	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x: ",
-	       link->config_index);
-	if (link->vpp)
-		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
-	printk(", irq %d", link->irq);
-	if (link->resource[0])
-		printk(" & %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	printk("\n");
 	return 0;
 
  failed:
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index e57b201..d6ff0c7 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -544,19 +544,6 @@ static int prism2_config(struct pcmcia_device *link)
 
 	spin_unlock_irqrestore(&local->irq_init_lock, flags);
 
-	/* Finally, report what we've done */
-	printk(KERN_INFO "%s: index 0x%02x: ",
-	       dev_info, link->config_index);
-	if (link->vpp)
-		printk(", Vpp %d.%d", link->vpp / 10,
-		       link->vpp % 10);
-	printk(", irq %d", link->irq);
-	if (link->resource[0])
-		printk(" & %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	printk("\n");
-
 	local->shutdown = 0;
 
 	sandisk_enable_wireless(dev);
@@ -568,7 +555,7 @@ static int prism2_config(struct pcmcia_device *link)
 	return ret;
 
  failed_unlock:
-	 spin_unlock_irqrestore(&local->irq_init_lock, flags);
+	spin_unlock_irqrestore(&local->irq_init_lock, flags);
  failed:
 	kfree(hw_priv);
 	prism2_release((u_long)link);
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index dd43bd3..912c740 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -277,6 +277,8 @@ static int pcmcia_device_probe(struct device *dev)
 	if (!ret) {
 		p_dev->config_base = cis_config.base;
 		p_dev->config_regs = cis_config.rmask[0];
+		dev_dbg(dev, "base %x, regs %x", p_dev->config_base,
+			p_dev->config_regs);
 	} else {
 		dev_printk(KERN_INFO, dev,
 			   "pcmcia: could not parse base and rmask0 of CIS\n");
@@ -290,6 +292,11 @@ static int pcmcia_device_probe(struct device *dev)
 			   p_drv->drv.name, ret);
 		goto put_module;
 	}
+	dev_dbg(dev, "%s bound: Vpp %d.%d, idx %x, IRQ %d", p_drv->drv.name,
+		p_dev->vpp/10, p_dev->vpp%10, p_dev->config_index, p_dev->irq);
+	dev_dbg(dev, "resources: ioport %pR %pR iomem %pR %pR %pR",
+		p_dev->resource[0], p_dev->resource[1], p_dev->resource[2],
+		p_dev->resource[3], p_dev->resource[4]);
 
 	mutex_lock(&s->ops_mutex);
 	if ((s->pcmcia_pfc) &&
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 3d6db73..efb0e64 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1687,21 +1687,6 @@ static int nsp_cs_config(struct pcmcia_device *link)
 
 	info->host = host;
 
-	/* Finally, report what we've done */
-	printk(KERN_INFO "nsp_cs: index 0x%02x: ",
-	       link->config_index);
-	if (link->vpp) {
-		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
-	}
-	printk(", irq %d", link->irq);
-	if (link->resource[0])
-		printk(", io %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	if (link->resource[2])
-		printk(", mem %pR", link->resource[2]);
-	printk("\n");
-
 	return 0;
 
  cs_failed:
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index c43c689..0c4b27c 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -745,15 +745,6 @@ static void das16cs_pcmcia_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	printk(", irq %u", link->irq);
-	if (link->resource[0])
-		printk(", io %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(", io %pR", link->resource[1]);
-	printk("\n");
-
 	return;
 
 failed:
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index d395909..6d89325 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -235,15 +235,6 @@ static void das08_pcmcia_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	printk(", irq %u", link->irq);
-	if (link->resource[0])
-		printk(", io %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	printk("\n");
-
 	return;
 
 failed:
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 7129b0c..5244125 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -568,15 +568,6 @@ static void dio700_config(struct pcmcia_device *link)
 	if (ret != 0)
 		goto failed;
 
-	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	printk(", irq %d", link->irq);
-	if (link->resource[0])
-		printk(", io %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	printk("\n");
-
 	return;
 
 failed:
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 4defdda..54dda4a 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -319,15 +319,6 @@ static void dio24_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	printk(", irq %d", link->irq);
-	if (link->resource[0])
-		printk(" & %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	printk("\n");
-
 	return;
 
 failed:
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 5123b31..22119f2 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -297,15 +297,6 @@ static void labpc_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	printk(", irq %d", link->irq);
-	if (link->resource[0])
-		printk(" & %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	printk("\n");
-
 	return;
 
 failed:
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index afd283d..de37ff7 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1103,15 +1103,6 @@ static void daqp_cs_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/* Finally, report what we've done */
-	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	printk(", irq %u", link->irq);
-	if (link->resource[0])
-		printk(" & %pR", link->resource[0]);
-	if (link->resource[1])
-		printk(" & %pR", link->resource[1]);
-	printk("\n");
-
 	return;
 
 failed:
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 81d7eea..9ce95cd 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -164,14 +164,6 @@ static int sl811_cs_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	dev_info(&link->dev, "index 0x%02x: ",
-		link->config_index);
-	if (link->vpp)
-		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
-	printk(", irq %d", link->irq);
-	printk(", io %pR", link->resource[0]);
-	printk("\n");
-
 	if (sl811_hc_init(parent, link->resource[0]->start, link->irq)
 			< 0) {
 failed:
-- 
1.7.0.4

