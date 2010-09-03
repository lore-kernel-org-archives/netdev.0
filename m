From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 08/15] pcmcia: convert pcmcia_request_configuration to pcmcia_enable_device
Date: Fri,  3 Sep 2010 12:57:07 +0200
Message-ID: <1283511434-21620-8-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-usb@vger.kernel.org,
	laforge@gnumonks.org, linux-mtd@lists.infradead.org,
	linux-bluetooth@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-serial@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	linux-scsi@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <20100903105628.GA21255@comet.dominikbrodowski.net>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pcmcia_enable_device() now replaces pcmcia_request_configuration().
Instead of config_req_t, all necessary flags are either passed as
a parameter to pcmcia_enable_device(), or (in rare circumstances)
set in struct pcmcia_device -> flags.

With the last remaining user of include/pcmcia/cs.h gone, remove
all references.

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
 Documentation/pcmcia/driver-changes.txt          |    6 ++++
 drivers/ata/pata_pcmcia.c                        |    5 +--
 drivers/bluetooth/bluecard_cs.c                  |    5 +--
 drivers/bluetooth/bt3c_cs.c                      |    5 +--
 drivers/bluetooth/btuart_cs.c                    |    5 +--
 drivers/bluetooth/dtl1_cs.c                      |    5 +--
 drivers/char/pcmcia/cm4000_cs.c                  |    3 +-
 drivers/char/pcmcia/cm4040_cs.c                  |    5 +--
 drivers/char/pcmcia/ipwireless/main.c            |    6 +--
 drivers/char/pcmcia/ipwireless/main.h            |    1 -
 drivers/char/pcmcia/ipwireless/tty.h             |    1 -
 drivers/char/pcmcia/synclink_cs.c                |   10 ++----
 drivers/ide/ide-cs.c                             |    6 ++--
 drivers/isdn/hardware/avm/avm_cs.c               |    5 +--
 drivers/isdn/hisax/avma1_cs.c                    |    5 +--
 drivers/isdn/hisax/elsa_cs.c                     |    8 +----
 drivers/isdn/hisax/sedlbauer_cs.c                |   12 ++-----
 drivers/isdn/hisax/teles_cs.c                    |    8 ++---
 drivers/mmc/host/sdricoh_cs.c                    |    1 -
 drivers/mtd/maps/pcmciamtd.c                     |    6 +---
 drivers/net/pcmcia/3c574_cs.c                    |    5 +--
 drivers/net/pcmcia/3c589_cs.c                    |    5 +--
 drivers/net/pcmcia/axnet_cs.c                    |   10 +++---
 drivers/net/pcmcia/com20020_cs.c                 |    5 +--
 drivers/net/pcmcia/fmvj18x_cs.c                  |    5 +--
 drivers/net/pcmcia/ibmtr_cs.c                    |    5 +--
 drivers/net/pcmcia/nmclan_cs.c                   |    5 +--
 drivers/net/pcmcia/pcnet_cs.c                    |    8 ++--
 drivers/net/pcmcia/smc91c92_cs.c                 |    9 ++---
 drivers/net/pcmcia/xirc2ps_cs.c                  |   12 ++++----
 drivers/net/wireless/airo_cs.c                   |   16 ++--------
 drivers/net/wireless/atmel_cs.c                  |   16 ++--------
 drivers/net/wireless/b43/pcmcia.c                |    5 +--
 drivers/net/wireless/hostap/hostap_cs.c          |   10 ++----
 drivers/net/wireless/libertas/if_cs.c            |   10 ++----
 drivers/net/wireless/orinoco/orinoco_cs.c        |   12 +------
 drivers/net/wireless/orinoco/spectrum_cs.c       |   12 +------
 drivers/net/wireless/ray_cs.c                    |    5 +--
 drivers/net/wireless/wl3501_cs.c                 |    5 +--
 drivers/parport/parport_cs.c                     |    5 +--
 drivers/pcmcia/au1000_generic.h                  |    1 -
 drivers/pcmcia/au1000_pb1x00.c                   |    1 -
 drivers/pcmcia/cistpl.c                          |    1 -
 drivers/pcmcia/cs.c                              |    1 -
 drivers/pcmcia/cs_internal.h                     |    5 ---
 drivers/pcmcia/ds.c                              |    3 +-
 drivers/pcmcia/i82092.c                          |    1 -
 drivers/pcmcia/i82365.c                          |    1 -
 drivers/pcmcia/m32r_cfc.c                        |    1 -
 drivers/pcmcia/m32r_pcc.c                        |    1 -
 drivers/pcmcia/m8xx_pcmcia.c                     |    1 -
 drivers/pcmcia/pcmcia_cis.c                      |    1 -
 drivers/pcmcia/pcmcia_resource.c                 |   33 ++++++++++----------
 drivers/pcmcia/pd6729.c                          |    1 -
 drivers/pcmcia/rsrc_iodyn.c                      |    1 -
 drivers/pcmcia/rsrc_mgr.c                        |    1 -
 drivers/pcmcia/rsrc_nonstatic.c                  |    1 -
 drivers/pcmcia/sa1100_generic.c                  |    1 -
 drivers/pcmcia/soc_common.h                      |    1 -
 drivers/pcmcia/socket_sysfs.c                    |    1 -
 drivers/pcmcia/tcic.c                            |    1 -
 drivers/pcmcia/xxs1500_ss.c                      |    1 -
 drivers/pcmcia/yenta_socket.c                    |    1 -
 drivers/scsi/pcmcia/aha152x_stub.c               |    5 +--
 drivers/scsi/pcmcia/fdomain_stub.c               |    5 +--
 drivers/scsi/pcmcia/nsp_cs.c                     |   13 +++-----
 drivers/scsi/pcmcia/qlogic_stub.c                |    7 ++--
 drivers/scsi/pcmcia/sym53c500_cs.c               |    5 +--
 drivers/serial/serial_cs.c                       |    9 ++---
 drivers/ssb/main.c                               |    1 -
 drivers/ssb/pcmcia.c                             |    1 -
 drivers/ssb/scan.c                               |    1 -
 drivers/staging/comedi/drivers/cb_das16_cs.c     |   11 ++-----
 drivers/staging/comedi/drivers/das08_cs.c        |   17 ++---------
 drivers/staging/comedi/drivers/ni_daq_700.c      |   19 ++---------
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |   19 ++---------
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |   20 +++---------
 drivers/staging/comedi/drivers/ni_mio_cs.c       |    5 +--
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |   17 ++---------
 drivers/staging/wlags49_h2/wl_cs.c               |    7 ++--
 drivers/staging/wlags49_h2/wl_internal.h         |    1 -
 drivers/telephony/ixj_pcmcia.c                   |    3 +-
 drivers/usb/host/sl811_cs.c                      |    7 +---
 include/pcmcia/cs.h                              |   35 ----------------------
 include/pcmcia/ds.h                              |   17 +++++++----
 include/pcmcia/ss.h                              |    1 -
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    5 ++-
 sound/pcmcia/pdaudiocf/pdaudiocf.h               |    1 -
 sound/pcmcia/vx/vxpocket.c                       |    6 ++--
 sound/pcmcia/vx/vxpocket.h                       |    1 -
 90 files changed, 179 insertions(+), 394 deletions(-)
 delete mode 100644 include/pcmcia/cs.h

diff --git a/Documentation/pcmcia/driver-changes.txt b/Documentation/pcmcia/driver-changes.txt
index 86e0f49..62a029f 100644
--- a/Documentation/pcmcia/driver-changes.txt
+++ b/Documentation/pcmcia/driver-changes.txt
@@ -1,4 +1,10 @@
 This file details changes in 2.6 which affect PCMCIA card driver authors:
+* pcmcia_request_configuration -> pcmcia_enable_device (as of 2.6.36)
+   pcmcia_request_configuration() got renamed to pcmcia_enable_device(),
+   as it mirrors pcmcia_disable_device(). Configuration settings are now
+   stored in struct pcmcia_device, e.g. in the fields config_flags,
+   config_index, config_base, vpp.
+
 * pcmcia_request_window changes (as of 2.6.36)
    Instead of win_req_t, drivers are now requested to fill out
    struct pcmcia_device *p_dev->resource[2,3,4,5] for up to four ioport
diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index c2679c0..76da55d 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -34,7 +34,6 @@
 #include <linux/ata.h>
 #include <linux/libata.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/cisreg.h>
@@ -249,7 +248,7 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	/* Set up attributes in order to probe card and get resources */
 	pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	pdev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-	pdev->conf.Attributes = CONF_ENABLE_IRQ;
+	pdev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* See if we have a manufacturer identifier. Use it to set is_kme for
 	   vendor quirks */
@@ -275,7 +274,7 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	if (!pdev->irq)
 		goto failed;
 
-	ret = pcmcia_request_configuration(pdev, &pdev->conf);
+	ret = pcmcia_enable_device(pdev);
 	if (ret)
 		goto failed;
 
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 08f4818..c9dd5b7 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -39,7 +39,6 @@
 #include <linux/skbuff.h>
 #include <linux/io.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -865,7 +864,7 @@ static int bluecard_probe(struct pcmcia_device *link)
 	info->p_dev = link;
 	link->priv = info;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 
 	return bluecard_config(link);
 }
@@ -905,7 +904,7 @@ static int bluecard_config(struct pcmcia_device *link)
 	if (i != 0)
 		goto failed;
 
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0)
 		goto failed;
 
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index fb01807..3db9588 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -45,7 +45,6 @@
 #include <linux/device.h>
 #include <linux/firmware.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -660,7 +659,7 @@ static int bt3c_probe(struct pcmcia_device *link)
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	link->resource[0]->end = 8;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 
 	return bt3c_config(link);
 }
@@ -741,7 +740,7 @@ found_port:
 	if (i != 0)
 		goto failed;
 
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0)
 		goto failed;
 
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 897c7c7..c5c4359 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -41,7 +41,6 @@
 #include <asm/system.h>
 #include <asm/io.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -589,7 +588,7 @@ static int btuart_probe(struct pcmcia_device *link)
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	link->resource[0]->end = 8;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 
 	return btuart_config(link);
 }
@@ -670,7 +669,7 @@ found_port:
 	if (i != 0)
 		goto failed;
 
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0)
 		goto failed;
 
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index b4c9a2e..38206df 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -41,7 +41,6 @@
 #include <asm/system.h>
 #include <asm/io.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -575,7 +574,7 @@ static int dtl1_probe(struct pcmcia_device *link)
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	link->resource[0]->end = 8;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 
 	return dtl1_config(link);
 }
@@ -619,7 +618,7 @@ static int dtl1_config(struct pcmcia_device *link)
 	if (i != 0)
 		goto failed;
 
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0)
 		goto failed;
 
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index d2accd6..75caa8c 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -34,7 +34,6 @@
 #include <linux/uaccess.h>
 #include <linux/io.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
@@ -1767,7 +1766,7 @@ static int cm4000_config(struct pcmcia_device * link, int devno)
 	if (pcmcia_loop_config(link, cm4000_config_check, NULL))
 		goto cs_release;
 
-	if (pcmcia_request_configuration(link, &link->conf))
+	if (pcmcia_enable_device(link))
 		goto cs_release;
 
 	dev = link->priv;
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index a32eba0..0c87b80 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -29,7 +29,6 @@
 #include <asm/uaccess.h>
 #include <asm/io.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
@@ -547,10 +546,10 @@ static int reader_config(struct pcmcia_device *link, int devno)
 	if (pcmcia_loop_config(link, cm4040_config_check, NULL))
 		goto cs_release;
 
-	fail_rc = pcmcia_request_configuration(link, &link->conf);
+	fail_rc = pcmcia_enable_device(link);
 	if (fail_rc != 0) {
 		dev_printk(KERN_INFO, &link->dev,
-			   "pcmcia_request_configuration failed 0x%x\n",
+			   "pcmcia_enable_device failed 0x%x\n",
 			   fail_rc);
 		goto cs_release;
 	}
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 05c4e68..cd21b2b 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -32,7 +32,6 @@
 #include <pcmcia/device_id.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/ds.h>
-#include <pcmcia/cs.h>
 
 static struct pcmcia_device_id ipw_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x02f2, 0x0100),
@@ -172,7 +171,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	if (ret != 0)
 		return ret;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 
 	INIT_WORK(&ipw->work_reboot, signalled_reboot_work);
 
@@ -210,8 +209,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	 * Do the RequestConfiguration last, because it enables interrupts.
 	 * Then we don't get any interrupts before we're ready for them.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
-
+	ret = pcmcia_enable_device(link);
 	if (ret != 0)
 		goto exit;
 
diff --git a/drivers/char/pcmcia/ipwireless/main.h b/drivers/char/pcmcia/ipwireless/main.h
index 9040219..f2cbb11 100644
--- a/drivers/char/pcmcia/ipwireless/main.h
+++ b/drivers/char/pcmcia/ipwireless/main.h
@@ -21,7 +21,6 @@
 #include <linux/sched.h>
 #include <linux/types.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
diff --git a/drivers/char/pcmcia/ipwireless/tty.h b/drivers/char/pcmcia/ipwireless/tty.h
index 3e163d4..747b2d6 100644
--- a/drivers/char/pcmcia/ipwireless/tty.h
+++ b/drivers/char/pcmcia/ipwireless/tty.h
@@ -21,7 +21,6 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 535aa08..99feaed 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -70,7 +70,6 @@
 #include <linux/workqueue.h>
 #include <linux/hdlc.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -550,8 +549,6 @@ static int mgslpc_probe(struct pcmcia_device *link)
 
     /* Initialize the struct pcmcia_device structure */
 
-    link->conf.Attributes = 0;
-
     ret = mgslpc_config(link);
     if (ret)
 	    return ret;
@@ -593,14 +590,14 @@ static int mgslpc_config(struct pcmcia_device *link)
     if (ret != 0)
 	    goto failed;
 
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_index = 8;
     link->config_regs = PRESENT_OPTION;
 
     ret = pcmcia_request_irq(link, mgslpc_isr);
     if (ret)
 	    goto failed;
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
@@ -609,8 +606,7 @@ static int mgslpc_config(struct pcmcia_device *link)
 
     dev_info(&link->dev, "index 0x%02x:",
 	    link->config_index);
-    if (link->conf.Attributes & CONF_ENABLE_IRQ)
-	    printk(", irq %d", link->irq);
+    printk(", irq %d", link->irq);
     if (link->resource[0])
 	    printk(", io %pR", link->resource[0]);
     printk("\n");
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 07e3787..87ad049 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -43,7 +43,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/cisreg.h>
@@ -99,7 +98,7 @@ static int ide_probe(struct pcmcia_device *link)
 
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
 
     return ide_config(link);
 } /* ide_attach */
@@ -284,7 +283,8 @@ static int ide_config(struct pcmcia_device *link)
 
     if (!link->irq)
 	    goto failed;
-    ret = pcmcia_request_configuration(link, &link->conf);
+
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 2d8bbbf..6ea5cd2 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -20,7 +20,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -79,7 +78,7 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
     p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
     /* General socket configuration */
-    p_dev->conf.Attributes = CONF_ENABLE_IRQ;
+    p_dev->config_flags |= CONF_ENABLE_IRQ;
     p_dev->config_index = 1;
     p_dev->config_regs = PRESENT_OPTION;
 
@@ -149,7 +148,7 @@ static int avmcs_config(struct pcmcia_device *link)
 	/*
          * configure the PCMCIA socket
 	  */
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0) {
 	    pcmcia_disable_device(link);
 	    break;
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index e25f6c7..5dd47ad 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -20,7 +20,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include "hisax_cfg.h"
@@ -84,7 +83,7 @@ static int __devinit avma1cs_probe(struct pcmcia_device *p_dev)
     p_dev->resource[1]->flags |= IO_DATA_PATH_WIDTH_16;
 
     /* General socket configuration */
-    p_dev->conf.Attributes = CONF_ENABLE_IRQ;
+    p_dev->config_flags |= CONF_ENABLE_IRQ;
     p_dev->config_index = 1;
     p_dev->config_regs = PRESENT_OPTION;
 
@@ -160,7 +159,7 @@ static int __devinit avma1cs_config(struct pcmcia_device *link)
 	/*
 	 * configure the PCMCIA socket
 	 */
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0) {
 	    pcmcia_disable_device(link);
 	    break;
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index f276e84..368c8a2 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -46,7 +46,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -129,8 +128,6 @@ static int __devinit elsa_cs_probe(struct pcmcia_device *link)
     link->resource[0]->end = 8;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
-    link->conf.Attributes = CONF_ENABLE_IRQ;
-
     return elsa_cs_config(link);
 } /* elsa_cs_attach */
 
@@ -205,15 +202,14 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
     if (!link->irq)
 	goto failed;
 
-    i = pcmcia_request_configuration(link, &link->conf);
+    i = pcmcia_enable_device(link);
     if (i != 0)
 	goto failed;
 
     /* Finally, report what we've done */
     dev_info(&link->dev, "index 0x%02x: ",
 	    link->config_index);
-    if (link->conf.Attributes & CONF_ENABLE_IRQ)
-	printk(", irq %d", link->irq);
+    printk(", irq %d", link->irq);
     if (link->resource[0])
 	printk(" & %pR", link->resource[0]);
     if (link->resource[1])
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 43d0a4e..791e23a 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -46,7 +46,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -132,8 +131,6 @@ static int __devinit sedlbauer_probe(struct pcmcia_device *link)
     link->resource[0]->end = 8;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
-    link->conf.Attributes = 0;
-
     return sedlbauer_config(link);
 } /* sedlbauer_attach */
 
@@ -175,7 +172,7 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
@@ -192,7 +189,7 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
 		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -247,7 +244,7 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
        the I/O windows and the interrupt mapping, and putting the
        card and host interface into "Memory and IO" mode.
     */
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
@@ -256,8 +253,7 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
 	   link->config_index);
     if (link->vpp)
 	printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
-    if (link->conf.Attributes & CONF_ENABLE_IRQ)
-	printk(", irq %d", link->irq);
+    printk(", irq %d", link->irq);
     if (link->resource[0])
 	printk(" & %pR", link->resource[0]);
     if (link->resource[1])
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 614afc6..2ae71e3 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -27,7 +27,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -109,7 +108,7 @@ static int __devinit teles_probe(struct pcmcia_device *link)
     link->resource[0]->end = 96;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
 
     return teles_cs_config(link);
 } /* teles_attach */
@@ -185,15 +184,14 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
     if (!link->irq)
         goto cs_failed;
 
-    i = pcmcia_request_configuration(link, &link->conf);
+    i = pcmcia_enable_device(link);
     if (i != 0)
       goto cs_failed;
 
     /* Finally, report what we've done */
     dev_info(&link->dev, "index 0x%02x:",
 	    link->config_index);
-    if (link->conf.Attributes & CONF_ENABLE_IRQ)
-	    printk(", irq %d", link->irq);
+    printk(", irq %d", link->irq);
     if (link->resource[0])
 	printk(" & %pR", link->resource[0]);
     if (link->resource[1])
diff --git a/drivers/mmc/host/sdricoh_cs.c b/drivers/mmc/host/sdricoh_cs.c
index 7aa65bb..7a7273b 100644
--- a/drivers/mmc/host/sdricoh_cs.c
+++ b/drivers/mmc/host/sdricoh_cs.c
@@ -30,7 +30,6 @@
 #include <linux/ioport.h>
 #include <linux/scatterlist.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include <linux/io.h>
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 99c7257..388db9e 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -16,7 +16,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -568,7 +567,6 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 	dev->pcmcia_map.map_priv_2 = (unsigned long)link->resource[2];
 
 	dev->vpp = (vpp) ? vpp : link->socket->socket.Vpp;
-	link->conf.Attributes = 0;
 	if(setvpp == 2) {
 		link->vpp = dev->vpp;
 	} else {
@@ -577,7 +575,7 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 
 	link->config_index = 0;
 	DEBUG(2, "Setting Configuration");
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret != 0) {
 		if (dev->win_base) {
 			iounmap(dev->win_base);
@@ -718,8 +716,6 @@ static int pcmciamtd_probe(struct pcmcia_device *link)
 	dev->p_dev = link;
 	link->priv = dev;
 
-	link->conf.Attributes = 0;
-
 	return pcmciamtd_config(link);
 }
 
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 4b670b3..8abce76 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -87,7 +87,6 @@ earlier 3Com products.
 #include <linux/bitops.h>
 #include <linux/mii.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
@@ -280,7 +279,7 @@ static int tc574_probe(struct pcmcia_device *link)
 	spin_lock_init(&lp->window_lock);
 	link->resource[0]->end = 32;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 	link->config_index = 1;
 
 	dev->netdev_ops = &el3_netdev_ops;
@@ -351,7 +350,7 @@ static int tc574_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 6549e2c..34195c4 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -41,7 +41,6 @@
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
@@ -216,7 +215,7 @@ static int tc589_probe(struct pcmcia_device *link)
     link->resource[0]->end = 16;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_index = 1;
 
     dev->netdev_ops = &el3_netdev_ops;
@@ -293,7 +292,7 @@ static int tc589_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 2c273ce..f361d28 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -39,7 +39,6 @@
 #include <linux/mii.h>
 #include "../8390.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -166,7 +165,7 @@ static int axnet_probe(struct pcmcia_device *link)
     info = PRIV(dev);
     info->p_dev = link;
     link->priv = dev;
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
 
     dev->netdev_ops = &axnet_netdev_ops;
 
@@ -332,11 +331,12 @@ static int axnet_config(struct pcmcia_device *link)
 
     if (!link->irq)
 	    goto failed;
-    
+
+    link->config_flags |= CONF_ENABLE_IRQ;
     if (resource_size(link->resource[1]) == 8)
-	link->conf.Attributes |= CONF_ENABLE_SPKR;
+	link->config_flags |= CONF_ENABLE_SPKR;
     
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index a58eafe..039731b 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -43,7 +43,6 @@
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -160,7 +159,7 @@ static int com20020_probe(struct pcmcia_device *p_dev)
 
     p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
     p_dev->resource[0]->end = 16;
-    p_dev->conf.Attributes = CONF_ENABLE_IRQ;
+    p_dev->config_flags |= CONF_ENABLE_IRQ;
 
     info->dev = dev;
     p_dev->priv = info;
@@ -281,7 +280,7 @@ static int com20020_config(struct pcmcia_device *link)
 
     dev->irq = link->irq;
 
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 23f5333..f6865ad 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -49,7 +49,6 @@
 #include <linux/ioport.h>
 #include <linux/crc32.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -252,7 +251,7 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 
     /* General socket configuration */
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
 
     dev->netdev_ops = &fjn_netdev_ops;
     dev->watchdog_timeo = TX_TIMEOUT;
@@ -431,7 +430,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
     ret = pcmcia_request_irq(link, fjn_interrupt);
     if (ret)
 	    goto failed;
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index feedeeb..b298a3d 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -57,7 +57,6 @@
 #include <linux/trdevice.h>
 #include <linux/ibmtr.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -152,7 +151,7 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
 
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[0]->end = 4;
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_regs = PRESENT_OPTION;
 
     info->dev = dev;
@@ -269,7 +268,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
 		    resource_size(link->resource[3]));
     ti->sram_phys = link->resource[3]->start;
 
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 98c4a69..51bf76d 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -146,7 +146,6 @@ Include Files
 #include <linux/ioport.h>
 #include <linux/bitops.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
@@ -460,7 +459,7 @@ static int nmclan_probe(struct pcmcia_device *link)
     spin_lock_init(&lp->bank_lock);
     link->resource[0]->end = 32;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_index = 1;
     link->config_regs = PRESENT_OPTION;
 
@@ -649,7 +648,7 @@ static int nmclan_config(struct pcmcia_device *link)
   ret = pcmcia_request_exclusive_irq(link, mace_interrupt);
   if (ret)
 	  goto failed;
-  ret = pcmcia_request_configuration(link, &link->conf);
+  ret = pcmcia_enable_device(link);
   if (ret)
 	  goto failed;
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 49f463f..ddd4bd2 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -42,7 +42,6 @@
 #include <linux/mii.h>
 #include "../8390.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -260,7 +259,7 @@ static int pcnet_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = dev;
 
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
 
     dev->netdev_ops = &pcnet_netdev_ops;
 
@@ -552,14 +551,15 @@ static int pcnet_config(struct pcmcia_device *link)
     if (!link->irq)
 	    goto failed;
 
+    link->config_flags = CONF_ENABLE_IRQ;
     if (resource_size(link->resource[1]) == 8)
-	link->conf.Attributes |= CONF_ENABLE_SPKR;
+	link->config_flags |= CONF_ENABLE_SPKR;
 
     if ((link->manf_id == MANFID_IBM) &&
 	(link->card_id == PRODID_IBM_HOME_AND_AWAY))
 	link->config_index |= 0x10;
 
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
     dev->irq = link->irq;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 59f5034..8c16ba6 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -44,7 +44,6 @@
 #include <linux/jiffies.h>
 #include <linux/firmware.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
@@ -326,7 +325,7 @@ static int smc91c92_probe(struct pcmcia_device *link)
     spin_lock_init(&smc->lock);
     link->resource[0]->end = 16;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
 
     /* The SMC91c92-specific entries in the device structure. */
     dev->netdev_ops = &smc_netdev_ops;
@@ -444,7 +443,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     unsigned int offset;
     int i;
 
-    link->conf.Attributes |= CONF_ENABLE_SPKR;
+    link->config_flags |= CONF_ENABLE_SPKR;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[1]->end = 8;
 
@@ -637,7 +636,7 @@ static int osi_config(struct pcmcia_device *link)
     static const unsigned int com[4] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8 };
     int i, j;
 
-    link->conf.Attributes |= CONF_ENABLE_SPKR;
+    link->config_flags |= CONF_ENABLE_SPKR;
     link->resource[0]->end = 64;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[1]->end = 8;
@@ -862,7 +861,7 @@ static int smc91c92_config(struct pcmcia_device *link)
     i = pcmcia_request_irq(link, smc_interrupt);
     if (i)
 	    goto config_failed;
-    i = pcmcia_request_configuration(link, &link->conf);
+    i = pcmcia_enable_device(link);
     if (i)
 	    goto config_failed;
 
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 1c8ebf2..7a4a99b 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -82,7 +82,6 @@
 #include <linux/bitops.h>
 #include <linux/mii.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
@@ -529,7 +528,7 @@ xirc2ps_probe(struct pcmcia_device *link)
     link->priv = dev;
 
     /* General socket configuration */
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_index = 1;
 
     /* Fill in card specific entries */
@@ -811,9 +810,6 @@ xirc2ps_config(struct pcmcia_device * link)
     if (local->modem) {
 	int pass;
 
-	if (do_sound)
-	    link->conf.Attributes |= CONF_ENABLE_SPKR;
-
 	link->resource[1]->end = 8;
 	link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	if (local->dingo) {
@@ -863,7 +859,11 @@ xirc2ps_config(struct pcmcia_device * link)
      * This actually configures the PCMCIA socket -- setting up
      * the I/O windows and the interrupt mapping.
      */
-    if ((err=pcmcia_request_configuration(link, &link->conf)))
+    link->config_flags |= CONF_ENABLE_IRQ;
+    if (do_sound)
+	    link->config_flags |= CONF_ENABLE_SPKR;
+
+    if ((err = pcmcia_enable_device(link)))
 	goto config_error;
 
     if (local->dingo) {
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 40f9ed7..5939d0c 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -32,7 +32,6 @@
 #include <linux/timer.h>
 #include <linux/netdevice.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -96,15 +95,6 @@ static int airo_probe(struct pcmcia_device *p_dev)
 
 	dev_dbg(&p_dev->dev, "airo_attach()\n");
 
-	/*
-	  General socket configuration defaults can go here.  In this
-	  client, we assume very little, and rely on the CIS for almost
-	  everything.  In most clients, many details (i.e., number, sizes,
-	  and attributes of IO windows) are fixed by the nature of the
-	  device, and can be hard-wired here.
-	*/
-	p_dev->conf.Attributes = 0;
-
 	/* Allocate space for private device-specific data */
 	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
 	if (!local) {
@@ -158,7 +148,7 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
@@ -167,7 +157,7 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
 		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -229,7 +219,7 @@ static int airo_config(struct pcmcia_device *link)
 	  the I/O windows and the interrupt mapping, and putting the
 	  card and host interface into "Memory and IO" mode.
 	*/
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 	((local_info_t *)link->priv)->eth_dev =
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 8b75158..080266e 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -42,7 +42,6 @@
 #include <linux/moduleparam.h>
 #include <linux/device.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -106,15 +105,6 @@ static int atmel_probe(struct pcmcia_device *p_dev)
 
 	dev_dbg(&p_dev->dev, "atmel_attach()\n");
 
-	/*
-	  General socket configuration defaults can go here.  In this
-	  client, we assume very little, and rely on the CIS for almost
-	  everything.  In most clients, many details (i.e., number, sizes,
-	  and attributes of IO windows) are fixed by the nature of the
-	  device, and can be hard-wired here.
-	*/
-	p_dev->conf.Attributes = 0;
-
 	/* Allocate space for private device-specific data */
 	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
 	if (!local) {
@@ -175,7 +165,7 @@ static int atmel_config_check(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
@@ -184,7 +174,7 @@ static int atmel_config_check(struct pcmcia_device *p_dev,
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
 		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -242,7 +232,7 @@ static int atmel_config(struct pcmcia_device *link)
 	  the I/O windows and the interrupt mapping, and putting the
 	  card and host interface into "Memory and IO" mode.
 	*/
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 138b26f..61abab1 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -26,7 +26,6 @@
 #include <linux/ssb/ssb.h>
 #include <linux/slab.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -72,7 +71,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 
 	err = -ENODEV;
 
-	dev->conf.Attributes = CONF_ENABLE_IRQ;
+	dev->config_flags |= CONF_ENABLE_IRQ;
 
 	dev->resource[2]->flags |=  WIN_ENABLE | WIN_DATA_WIDTH_16 |
 			 WIN_USE_WAIT;
@@ -89,7 +88,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	if (!dev->irq)
 		goto err_disable;
 
-	res = pcmcia_request_configuration(dev, &dev->conf);
+	res = pcmcia_enable_device(dev);
 	if (res != 0)
 		goto err_disable;
 
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 5704d3f..5b0b582 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -12,7 +12,6 @@
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -484,7 +483,7 @@ static int prism2_config_check(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
@@ -510,7 +509,7 @@ static int prism2_config_check(struct pcmcia_device *p_dev,
 		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	PDEBUG(DEBUG_EXTRA, "IO window settings: cfg->io.nwin=%d "
@@ -590,7 +589,7 @@ static int prism2_config(struct pcmcia_device *link)
 	 * the I/O windows and the interrupt mapping, and putting the
 	 * card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed_unlock;
 
@@ -605,8 +604,7 @@ static int prism2_config(struct pcmcia_device *link)
 	if (link->vpp)
 		printk(", Vpp %d.%d", link->vpp / 10,
 		       link->vpp % 10);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq);
+	printk(", irq %d", link->irq);
 	if (link->resource[0])
 		printk(" & %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 814b7fa..6020c19 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -28,7 +28,6 @@
 #include <linux/firmware.h>
 #include <linux/netdevice.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -806,7 +805,7 @@ static int if_cs_ioprobe(struct pcmcia_device *p_dev,
 	p_dev->resource[0]->end = cfg->io.win[0].len;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	if (cfg->io.nwin != 1) {
@@ -835,14 +834,11 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	card->p_dev = p_dev;
 	p_dev->priv = card;
 
-	p_dev->conf.Attributes = 0;
-
 	if (pcmcia_loop_config(p_dev, if_cs_ioprobe, NULL)) {
 		lbs_pr_err("error in pcmcia_loop_config\n");
 		goto out1;
 	}
 
-
 	/*
 	 * Allocate an interrupt line.  Note that this does not assign
 	 * a handler to the interrupt, unless the 'Handler' member of
@@ -865,9 +861,9 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	 * the I/O windows and the interrupt mapping, and putting the
 	 * card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(p_dev, &p_dev->conf);
+	ret = pcmcia_enable_device(p_dev);
 	if (ret) {
-		lbs_pr_err("error in pcmcia_request_configuration\n");
+		lbs_pr_err("error in pcmcia_enable_device\n");
 		goto out2;
 	}
 
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 1147d6b..00316a1 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -17,7 +17,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -117,13 +116,6 @@ orinoco_cs_probe(struct pcmcia_device *link)
 	card->p_dev = link;
 	link->priv = priv;
 
-	/* General socket configuration defaults can go here.  In this
-	 * client, we assume very little, and rely on the CIS for
-	 * almost everything.  In most clients, many details (i.e.,
-	 * number, sizes, and attributes of IO windows) are fixed by
-	 * the nature of the device, and can be hard-wired here. */
-	link->conf.Attributes = 0;
-
 	return orinoco_cs_config(link);
 }				/* orinoco_cs_attach */
 
@@ -187,7 +179,7 @@ static int orinoco_cs_config_check(struct pcmcia_device *p_dev,
 			dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -266,7 +258,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 	 * the I/O windows and the interrupt mapping, and putting the
 	 * card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 20b08ab..ca2c6c0 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -25,7 +25,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -179,13 +178,6 @@ spectrum_cs_probe(struct pcmcia_device *link)
 	card->p_dev = link;
 	link->priv = priv;
 
-	/* General socket configuration defaults can go here.  In this
-	 * client, we assume very little, and rely on the CIS for
-	 * almost everything.  In most clients, many details (i.e.,
-	 * number, sizes, and attributes of IO windows) are fixed by
-	 * the nature of the device, and can be hard-wired here. */
-	link->conf.Attributes = 0;
-
 	return spectrum_cs_config(link);
 }				/* spectrum_cs_attach */
 
@@ -249,7 +241,7 @@ static int spectrum_cs_config_check(struct pcmcia_device *p_dev,
 			dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -329,7 +321,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 	 * the I/O windows and the interrupt mapping, and putting the
 	 * card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 7fb66cc..1457f34 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -46,7 +46,6 @@
 #include <linux/ethtool.h>
 #include <linux/ieee80211.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -318,7 +317,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 
 	/* General socket configuration */
-	p_dev->conf.Attributes = CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 	p_dev->config_index = 1;
 
 	p_dev->priv = dev;
@@ -413,7 +412,7 @@ static int ray_config(struct pcmcia_device *link)
 	/* This actually configures the PCMCIA socket -- setting up
 	   the I/O windows and the interrupt mapping.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 3947cf8..101b6ff 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -48,7 +48,6 @@
 
 #include <net/iw_handler.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -1888,7 +1887,7 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 	p_dev->resource[0]->flags	= IO_DATA_PATH_WIDTH_8;
 
 	/* General socket configuration */
-	p_dev->conf.Attributes	= CONF_ENABLE_IRQ;
+	p_dev->config_flags	= CONF_ENABLE_IRQ;
 	p_dev->config_index	= 1;
 
 	dev = alloc_etherdev(sizeof(struct wl3501_card));
@@ -1954,7 +1953,7 @@ static int wl3501_config(struct pcmcia_device *link)
 	/* This actually configures the PCMCIA socket -- setting up the I/O
 	 * windows and the interrupt mapping.  */
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index 8faf634..63b3d3c 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -48,7 +48,6 @@
 #include <linux/parport.h>
 #include <linux/parport_pc.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/cisreg.h>
@@ -103,7 +102,7 @@ static int parport_probe(struct pcmcia_device *link)
 
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
 
     return parport_config(link);
 } /* parport_attach */
@@ -172,7 +171,7 @@ static int parport_config(struct pcmcia_device *link)
 
     if (!link->irq)
 	    goto failed;
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/pcmcia/au1000_generic.h b/drivers/pcmcia/au1000_generic.h
index 67530ce..5c36bda 100644
--- a/drivers/pcmcia/au1000_generic.h
+++ b/drivers/pcmcia/au1000_generic.h
@@ -23,7 +23,6 @@
 
 /* include the world */
 
-#include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
 #include "cs_internal.h"
diff --git a/drivers/pcmcia/au1000_pb1x00.c b/drivers/pcmcia/au1000_pb1x00.c
index 807f2d7..b239664 100644
--- a/drivers/pcmcia/au1000_pb1x00.c
+++ b/drivers/pcmcia/au1000_pb1x00.c
@@ -31,7 +31,6 @@
 #include <linux/proc_fs.h>
 #include <linux/types.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
 
diff --git a/drivers/pcmcia/cistpl.c b/drivers/pcmcia/cistpl.c
index 91414a0..884a984 100644
--- a/drivers/pcmcia/cistpl.c
+++ b/drivers/pcmcia/cistpl.c
@@ -28,7 +28,6 @@
 #include <asm/unaligned.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/cistpl.h>
 #include "cs_internal.h"
diff --git a/drivers/pcmcia/cs.c b/drivers/pcmcia/cs.c
index 2ec8ac9..d8189d4 100644
--- a/drivers/pcmcia/cs.c
+++ b/drivers/pcmcia/cs.c
@@ -33,7 +33,6 @@
 #include <asm/irq.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/pcmcia/cs_internal.h b/drivers/pcmcia/cs_internal.h
index 42eef43..7f1953f 100644
--- a/drivers/pcmcia/cs_internal.h
+++ b/drivers/pcmcia/cs_internal.h
@@ -33,14 +33,9 @@
 typedef struct config_t {
 	struct kref	ref;
 	unsigned int	state;
-	unsigned int	Attributes;
 
 	struct resource io[MAX_IO_WIN]; /* io ports */
 	struct resource mem[MAX_WIN];   /* mem areas */
-
-	struct {
-		u_int	Attributes;
-	} irq;
 } config_t;
 
 
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 00db600..dd43bd3 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -26,7 +26,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/ss.h>
@@ -1178,7 +1177,7 @@ static int pcmcia_dev_resume(struct device *dev)
 
 	if (p_dev->device_no == p_dev->func) {
 		dev_dbg(dev, "requesting configuration\n");
-		ret = pcmcia_request_configuration(p_dev, &p_dev->conf);
+		ret = pcmcia_enable_device(p_dev);
 		if (ret)
 			goto out;
 	}
diff --git a/drivers/pcmcia/i82092.c b/drivers/pcmcia/i82092.c
index 05d0879..fc7906e 100644
--- a/drivers/pcmcia/i82092.c
+++ b/drivers/pcmcia/i82092.c
@@ -16,7 +16,6 @@
 #include <linux/device.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
diff --git a/drivers/pcmcia/i82365.c b/drivers/pcmcia/i82365.c
index 61746bd..72a033a 100644
--- a/drivers/pcmcia/i82365.c
+++ b/drivers/pcmcia/i82365.c
@@ -51,7 +51,6 @@
 #include <asm/system.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 
 #include <linux/isapnp.h>
 
diff --git a/drivers/pcmcia/m32r_cfc.c b/drivers/pcmcia/m32r_cfc.c
index 24de499..2adb010 100644
--- a/drivers/pcmcia/m32r_cfc.c
+++ b/drivers/pcmcia/m32r_cfc.c
@@ -27,7 +27,6 @@
 #include <asm/system.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 
 #undef MAX_IO_WIN	/* FIXME */
 #define MAX_IO_WIN 1
diff --git a/drivers/pcmcia/m32r_pcc.c b/drivers/pcmcia/m32r_pcc.c
index 8e47238..1511ff7 100644
--- a/drivers/pcmcia/m32r_pcc.c
+++ b/drivers/pcmcia/m32r_pcc.c
@@ -28,7 +28,6 @@
 #include <asm/addrspace.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 
 /* XXX: should be moved into asm/irq.h */
 #define PCC0_IRQ 24
diff --git a/drivers/pcmcia/m8xx_pcmcia.c b/drivers/pcmcia/m8xx_pcmcia.c
index f0ecad9..99d4f23 100644
--- a/drivers/pcmcia/m8xx_pcmcia.c
+++ b/drivers/pcmcia/m8xx_pcmcia.c
@@ -59,7 +59,6 @@
 #include <asm/irq.h>
 #include <asm/fs_pd.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 
 #define pcmcia_info(args...) printk(KERN_INFO "m8xx_pcmcia: "args)
diff --git a/drivers/pcmcia/pcmcia_cis.c b/drivers/pcmcia/pcmcia_cis.c
index ac47cc4..ce8b94a 100644
--- a/drivers/pcmcia/pcmcia_cis.c
+++ b/drivers/pcmcia/pcmcia_cis.c
@@ -22,7 +22,6 @@
 #include <pcmcia/cisreg.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/ds.h>
 #include "cs_internal.h"
 
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index ff83ab1..f778e6c 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -26,7 +26,6 @@
 #include <asm/irq.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -230,7 +229,7 @@ EXPORT_SYMBOL(pcmcia_map_mem_page);
  * pcmcia_fixup_iowidth() - reduce io width to 8bit
  *
  * pcmcia_fixup_iowidth() allows a PCMCIA device driver to reduce the
- * IO width to 8bit after having called pcmcia_request_configuration()
+ * IO width to 8bit after having called pcmcia_enable_device()
  * previously.
  */
 int pcmcia_fixup_iowidth(struct pcmcia_device *p_dev)
@@ -278,7 +277,7 @@ EXPORT_SYMBOL(pcmcia_fixup_iowidth);
  * pcmcia_fixup_vpp() - set Vpp to a new voltage level
  *
  * pcmcia_fixup_vpp() allows a PCMCIA device driver to set Vpp to
- * a new voltage level between calls to pcmcia_request_configuration()
+ * a new voltage level between calls to pcmcia_enable_device()
  * and pcmcia_disable_device().
  */
 int pcmcia_fixup_vpp(struct pcmcia_device *p_dev, unsigned char new_vpp)
@@ -432,18 +431,21 @@ int pcmcia_release_window(struct pcmcia_device *p_dev, struct resource *res)
 } /* pcmcia_release_window */
 EXPORT_SYMBOL(pcmcia_release_window);
 
-
-int pcmcia_request_configuration(struct pcmcia_device *p_dev,
-				 config_req_t *req)
+/**
+ * pcmcia_enable_device() - set up and activate a PCMCIA device
+ *
+ */
+int pcmcia_enable_device(struct pcmcia_device *p_dev)
 {
 	int i;
-	u_int base;
+	unsigned int base;
 	struct pcmcia_socket *s = p_dev->socket;
 	config_t *c;
 	pccard_io_map iomap;
 	unsigned char status = 0;
 	unsigned char ext_status = 0;
 	unsigned char option = 0;
+	unsigned int flags = p_dev->config_flags;
 
 	if (!(s->state & SOCKET_PRESENT))
 		return -ENODEV;
@@ -466,23 +468,20 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	}
 
 	/* Pick memory or I/O card, DMA mode, interrupt */
-	c->Attributes = req->Attributes;
 	if (p_dev->_io)
 		s->socket.flags |= SS_IOCARD;
-	if (req->Attributes & CONF_ENABLE_DMA)
-		s->socket.flags |= SS_DMA_MODE;
-	if (req->Attributes & CONF_ENABLE_SPKR) {
+	if (flags & CONF_ENABLE_SPKR) {
 		s->socket.flags |= SS_SPKR_ENA;
 		status = CCSR_AUDIO_ENA;
 		if (!(p_dev->config_regs & PRESENT_STATUS))
 			dev_warn(&p_dev->dev, "speaker requested, but "
 					      "PRESENT_STATUS not set!\n");
 	}
-	if (req->Attributes & CONF_ENABLE_IRQ)
+	if (flags & CONF_ENABLE_IRQ)
 		s->socket.io_irq = s->pcmcia_irq;
 	else
 		s->socket.io_irq = 0;
-	if (req->Attributes & CONF_ENABLE_ESR) {
+	if (flags & CONF_ENABLE_ESR) {
 		p_dev->config_regs |= PRESENT_EXT_STATUS;
 		ext_status = ESR_REQ_ATTN_ENA;
 	}
@@ -510,8 +509,8 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 			if (p_dev->config_regs & PRESENT_IOBASE_0)
 				option |= COR_ADDR_DECODE;
 		}
-		if ((req->Attributes & CONF_ENABLE_IRQ) &&
-			!(req->Attributes & CONF_ENABLE_PULSE_IRQ))
+		if ((flags & CONF_ENABLE_IRQ) &&
+			!(flags & CONF_ENABLE_PULSE_IRQ))
 			option |= COR_LEVEL_REQ;
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_COR)>>1, 1, &option);
 		mdelay(40);
@@ -560,8 +559,8 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	p_dev->_locked = 1;
 	mutex_unlock(&s->ops_mutex);
 	return 0;
-} /* pcmcia_request_configuration */
-EXPORT_SYMBOL(pcmcia_request_configuration);
+} /* pcmcia_enable_device */
+EXPORT_SYMBOL(pcmcia_enable_device);
 
 
 /**
diff --git a/drivers/pcmcia/pd6729.c b/drivers/pcmcia/pd6729.c
index b8a869a..05d6567 100644
--- a/drivers/pcmcia/pd6729.c
+++ b/drivers/pcmcia/pd6729.c
@@ -18,7 +18,6 @@
 #include <linux/io.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 
 #include <asm/system.h>
 
diff --git a/drivers/pcmcia/rsrc_iodyn.c b/drivers/pcmcia/rsrc_iodyn.c
index 8510c35..523eb69 100644
--- a/drivers/pcmcia/rsrc_iodyn.c
+++ b/drivers/pcmcia/rsrc_iodyn.c
@@ -17,7 +17,6 @@
 #include <linux/kernel.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include "cs_internal.h"
 
diff --git a/drivers/pcmcia/rsrc_mgr.c b/drivers/pcmcia/rsrc_mgr.c
index 4e80421..aa628ed 100644
--- a/drivers/pcmcia/rsrc_mgr.c
+++ b/drivers/pcmcia/rsrc_mgr.c
@@ -17,7 +17,6 @@
 #include <linux/kernel.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include "cs_internal.h"
 
diff --git a/drivers/pcmcia/rsrc_nonstatic.c b/drivers/pcmcia/rsrc_nonstatic.c
index 96f348b..b187555 100644
--- a/drivers/pcmcia/rsrc_nonstatic.c
+++ b/drivers/pcmcia/rsrc_nonstatic.c
@@ -29,7 +29,6 @@
 #include <asm/irq.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include "cs_internal.h"
 
diff --git a/drivers/pcmcia/sa1100_generic.c b/drivers/pcmcia/sa1100_generic.c
index e098514..945857f 100644
--- a/drivers/pcmcia/sa1100_generic.c
+++ b/drivers/pcmcia/sa1100_generic.c
@@ -35,7 +35,6 @@
 #include <linux/slab.h>
 #include <linux/platform_device.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 
 #include <asm/hardware/scoop.h>
diff --git a/drivers/pcmcia/soc_common.h b/drivers/pcmcia/soc_common.h
index 3fba3a6..bbcd538 100644
--- a/drivers/pcmcia/soc_common.h
+++ b/drivers/pcmcia/soc_common.h
@@ -11,7 +11,6 @@
 
 /* include the world */
 #include <linux/cpufreq.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
 
diff --git a/drivers/pcmcia/socket_sysfs.c b/drivers/pcmcia/socket_sysfs.c
index cb0d3ac..71aeed9 100644
--- a/drivers/pcmcia/socket_sysfs.c
+++ b/drivers/pcmcia/socket_sysfs.c
@@ -27,7 +27,6 @@
 #include <asm/irq.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/pcmcia/tcic.c b/drivers/pcmcia/tcic.c
index be0d841..310160b 100644
--- a/drivers/pcmcia/tcic.c
+++ b/drivers/pcmcia/tcic.c
@@ -49,7 +49,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include "tcic.h"
 
diff --git a/drivers/pcmcia/xxs1500_ss.c b/drivers/pcmcia/xxs1500_ss.c
index fa88c36..3b67a1b 100644
--- a/drivers/pcmcia/xxs1500_ss.c
+++ b/drivers/pcmcia/xxs1500_ss.c
@@ -17,7 +17,6 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
 
diff --git a/drivers/pcmcia/yenta_socket.c b/drivers/pcmcia/yenta_socket.c
index 414d9a6..408dbaa 100644
--- a/drivers/pcmcia/yenta_socket.c
+++ b/drivers/pcmcia/yenta_socket.c
@@ -20,7 +20,6 @@
 #include <linux/slab.h>
 
 #include <pcmcia/ss.h>
-#include <pcmcia/cs.h>
 
 #include "yenta_socket.h"
 #include "i82365.h"
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index c368249..e1f7485 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -49,7 +49,6 @@
 #include <scsi/scsi_host.h>
 #include "aha152x.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -102,7 +101,7 @@ static int aha152x_probe(struct pcmcia_device *link)
 
     link->resource[0]->end = 0x20;
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-    link->conf.Attributes = CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_ENABLE_IRQ;
     link->config_regs = PRESENT_OPTION;
 
     return aha152x_config_cs(link);
@@ -159,7 +158,7 @@ static int aha152x_config_cs(struct pcmcia_device *link)
     if (!link->irq)
 	    goto failed;
 
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
     
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index bb909e1..ae263b1 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -46,7 +46,6 @@
 #include <scsi/scsi_host.h>
 #include "fdomain.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -85,7 +84,7 @@ static int fdomain_probe(struct pcmcia_device *link)
 	link->priv = info;
 	link->resource[0]->end = 0x10;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 	link->config_regs = PRESENT_OPTION;
 
 	return fdomain_config(link);
@@ -131,7 +130,7 @@ static int fdomain_config(struct pcmcia_device *link)
 
     if (!link->irq)
 	    goto failed;
-    ret = pcmcia_request_configuration(link, &link->conf);
+    ret = pcmcia_enable_device(link);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index a63c460..7cb1ae6 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -47,7 +47,6 @@
 #include <scsi/scsi.h>
 #include <scsi/scsi_ioctl.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -1562,7 +1561,7 @@ static int nsp_cs_probe(struct pcmcia_device *link)
 	link->resource[0]->flags = IO_DATA_PATH_WIDTH_AUTO;
 
 	/* General socket configuration */
-	link->conf.Attributes	 = CONF_ENABLE_IRQ;
+	link->config_flags	 |= CONF_ENABLE_IRQ;
 
 	ret = nsp_cs_config(link);
 
@@ -1608,7 +1607,7 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
@@ -1629,7 +1628,7 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 		}
 
 		/* Do we need to allocate an interrupt? */
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+		p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 		/* IO window settings */
 		p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -1700,7 +1699,7 @@ static int nsp_cs_config(struct pcmcia_device *link)
 	if (pcmcia_request_irq(link, nspintr))
 		goto cs_failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto cs_failed;
 
@@ -1749,9 +1748,7 @@ static int nsp_cs_config(struct pcmcia_device *link)
 	if (link->vpp) {
 		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
 	}
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		printk(", irq %d", link->irq);
-	}
+	printk(", irq %d", link->irq);
 	if (link->resource[0])
 		printk(", io %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 5e2cbe0..7d3f49c 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -48,7 +48,6 @@
 #include <scsi/scsi_host.h>
 #include "../qlogicfas408.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/ciscode.h>
@@ -158,7 +157,7 @@ static int qlogic_probe(struct pcmcia_device *link)
 	link->priv = info;
 	link->resource[0]->end = 16;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 	link->config_regs = PRESENT_OPTION;
 
 	return qlogic_config(link);
@@ -208,7 +207,7 @@ static int qlogic_config(struct pcmcia_device * link)
 	if (!link->irq)
 		goto failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
@@ -263,7 +262,7 @@ static int qlogic_resume(struct pcmcia_device *link)
 {
 	scsi_info_t *info = link->priv;
 
-	pcmcia_request_configuration(link, &link->conf);
+	pcmcia_enable_device(link);
 	if ((info->manf_id == MANFID_MACNICA) ||
 	    (info->manf_id == MANFID_PIONEER) ||
 	    (info->manf_id == 0x0098)) {
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 9aaf974..600630e 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -71,7 +71,6 @@
 #include <scsi/scsi.h>
 #include <scsi/scsi_host.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/ciscode.h>
@@ -721,7 +720,7 @@ SYM53C500_config(struct pcmcia_device *link)
 	if (!link->irq)
 		goto failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
@@ -861,7 +860,7 @@ SYM53C500_probe(struct pcmcia_device *link)
 	link->priv = info;
 	link->resource[0]->end = 16;
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 
 	return SYM53C500_config(link);
 } /* SYM53C500_attach */
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 8f25cc1..2285d5d 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -45,7 +45,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
@@ -184,7 +183,7 @@ static void quirk_config_socket(struct pcmcia_device *link)
 	struct serial_info *info = link->priv;
 
 	if (info->multi)
-		link->conf.Attributes |= CONF_ENABLE_ESR;
+		link->config_flags |= CONF_ENABLE_ESR;
 }
 
 static const struct serial_quirk quirks[] = {
@@ -335,7 +334,7 @@ static int serial_probe(struct pcmcia_device *link)
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	if (do_sound)
-		link->conf.Attributes |= CONF_ENABLE_SPKR;
+		link->config_flags |= CONF_ENABLE_SPKR;
 
 	return serial_config(link);
 }
@@ -501,7 +500,7 @@ found_port:
 	if (info->quirk && info->quirk->config)
 		info->quirk->config(link);
 
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0)
 		return -1;
 	return setup_serial(link, info, link->resource[0]->start, link->irq);
@@ -578,7 +577,7 @@ static int multi_config(struct pcmcia_device *link)
 	if (info->quirk && info->quirk->config)
 		info->quirk->config(link);
 
-	i = pcmcia_request_configuration(link, &link->conf);
+	i = pcmcia_enable_device(link);
 	if (i != 0)
 		return -ENODEV;
 
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 7892ac1..c68b3dc 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -20,7 +20,6 @@
 #include <linux/mmc/sdio_func.h>
 #include <linux/slab.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
diff --git a/drivers/ssb/pcmcia.c b/drivers/ssb/pcmcia.c
index 526682d..c7345db 100644
--- a/drivers/ssb/pcmcia.c
+++ b/drivers/ssb/pcmcia.c
@@ -13,7 +13,6 @@
 #include <linux/io.h>
 #include <linux/etherdevice.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/ssb/scan.c b/drivers/ssb/scan.c
index 9738cad..ee079ab 100644
--- a/drivers/ssb/scan.c
+++ b/drivers/ssb/scan.c
@@ -17,7 +17,6 @@
 #include <linux/pci.h>
 #include <linux/io.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index 034cbfc..ee91c89 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -37,7 +37,6 @@ Status: experimental
 #include <linux/delay.h>
 #include <linux/pci.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -692,9 +691,6 @@ static int das16cs_pcmcia_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/* Initialize the pcmcia_device structure */
-	link->conf.Attributes = 0;
-
 	cur_dev = link;
 
 	das16cs_pcmcia_config(link);
@@ -723,7 +719,7 @@ static int das16cs_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -EINVAL;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -767,14 +763,13 @@ static void das16cs_pcmcia_config(struct pcmcia_device *link)
 	   the I/O windows and the interrupt mapping, and putting the
 	   card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %u", link->irq);
+	printk(", irq %u", link->irq);
 	if (link->resource[0])
 		printk(", io %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index e37ea79..f8f3de5 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -48,7 +48,6 @@ Command support does not exist, but could be added for this board.
 #include "das08.h"
 
 /* pcmcia includes */
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -162,15 +161,6 @@ static int das08_pcmcia_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/*
-	   General socket configuration defaults can go here.  In this
-	   client, we assume very little, and rely on the CIS for almost
-	   everything.  In most clients, many details (i.e., number, sizes,
-	   and attributes of IO windows) are fixed by the nature of the
-	   device, and can be hard-wired here.
-	 */
-	link->conf.Attributes = 0;
-
 	cur_dev = link;
 
 	das08_pcmcia_config(link);
@@ -211,7 +201,7 @@ static int das08_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -263,14 +253,13 @@ static void das08_pcmcia_config(struct pcmcia_device *link)
 	   the I/O windows and the interrupt mapping, and putting the
 	   card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %u", link->irq);
+	printk(", irq %u", link->irq);
 	if (link->resource[0])
 		printk(", io %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 8107e40..803683b 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -47,7 +47,6 @@ IRQ is assigned but not used.
 
 #include <linux/ioport.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -491,15 +490,6 @@ static int dio700_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/*
-	   General socket configuration defaults can go here.  In this
-	   client, we assume very little, and rely on the CIS for almost
-	   everything.  In most clients, many details (i.e., number, sizes,
-	   and attributes of IO windows) are fixed by the nature of the
-	   device, and can be hard-wired here.
-	 */
-	link->conf.Attributes = 0;
-
 	pcmcia_cur_dev = link;
 
 	dio700_config(link);
@@ -550,10 +540,10 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -602,14 +592,13 @@ static void dio700_config(struct pcmcia_device *link)
 	   the I/O windows and the interrupt mapping, and putting the
 	   card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret != 0)
 		goto failed;
 
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq);
+	printk(", irq %d", link->irq);
 	if (link->resource[0])
 		printk(", io %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 4f9daa3..6512f7a 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -48,7 +48,6 @@ the PCMCIA interface.
 
 #include "8255.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -243,15 +242,6 @@ static int dio24_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/*
-	   General socket configuration defaults can go here.  In this
-	   client, we assume very little, and rely on the CIS for almost
-	   everything.  In most clients, many details (i.e., number, sizes,
-	   and attributes of IO windows) are fixed by the nature of the
-	   device, and can be hard-wired here.
-	 */
-	link->conf.Attributes = 0;
-
 	pcmcia_cur_dev = link;
 
 	dio24_config(link);
@@ -302,10 +292,10 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -353,14 +343,13 @@ static void dio24_config(struct pcmcia_device *link)
 	   the I/O windows and the interrupt mapping, and putting the
 	   card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq);
+	printk(", irq %d", link->irq);
 	if (link->resource[0])
 		printk(" & %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 2e27a30..255cf40 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -71,7 +71,6 @@ NI manuals:
 #include "comedi_fc.h"
 #include "ni_labpc.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -219,15 +218,6 @@ static int labpc_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/*
-	   General socket configuration defaults can go here.  In this
-	   client, we assume very little, and rely on the CIS for almost
-	   everything.  In most clients, many details (i.e., number, sizes,
-	   and attributes of IO windows) are fixed by the nature of the
-	   device, and can be hard-wired here.
-	 */
-	link->conf.Attributes = 0;
-
 	pcmcia_cur_dev = link;
 
 	labpc_config(link);
@@ -281,10 +271,10 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 
 	/* Does this card need audio output? */
 	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -331,14 +321,14 @@ static void labpc_config(struct pcmcia_device *link)
 	   the I/O windows and the interrupt mapping, and putting the
 	   card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq);
+	printk(", irq %d", link->irq);
 	if (link->resource[0])
 		printk(" & %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index be7e021..b88f52d 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -48,7 +48,6 @@ See the notes in the ni_atmio.o driver.
 #include "ni_stc.h"
 #include "8255.h"
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -265,7 +264,7 @@ static int cs_attach(struct pcmcia_device *link)
 {
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
 	link->resource[0]->end = 16;
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 
 	cur_dev = link;
 
@@ -336,7 +335,7 @@ static void mio_cs_config(struct pcmcia_device *link)
 	if (!link->irq)
 		dev_info(&link->dev, "no IRQ available\n");
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 }
 
 static int mio_cs_attach(struct comedi_device *dev, struct comedi_devconfig *it)
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index a2a32de..b8940d7 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -50,7 +50,6 @@ Devices: [Quatech] DAQP-208 (daqp), DAQP-308
 #include "../comedidev.h"
 #include <linux/semaphore.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -1031,15 +1030,6 @@ static int daqp_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/*
-	   General socket configuration defaults can go here.  In this
-	   client, we assume very little, and rely on the CIS for almost
-	   everything.  In most clients, many details (i.e., number, sizes,
-	   and attributes of IO windows) are fixed by the nature of the
-	   device, and can be hard-wired here.
-	 */
-	link->conf.Attributes = 0;
-
 	daqp_cs_config(link);
 
 	return 0;
@@ -1088,7 +1078,7 @@ static int daqp_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Do we need to allocate an interrupt? */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -1132,14 +1122,13 @@ static void daqp_cs_config(struct pcmcia_device *link)
 	   the I/O windows and the interrupt mapping, and putting the
 	   card and host interface into "Memory and IO" mode.
 	 */
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x", link->config_index);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %u", link->irq);
+	printk(", irq %u", link->irq);
 	if (link->resource[0])
 		printk(" & %pR", link->resource[0]);
 	if (link->resource[1])
diff --git a/drivers/staging/wlags49_h2/wl_cs.c b/drivers/staging/wlags49_h2/wl_cs.c
index 778800f..62a70af 100644
--- a/drivers/staging/wlags49_h2/wl_cs.c
+++ b/drivers/staging/wlags49_h2/wl_cs.c
@@ -83,7 +83,6 @@
 #include <linux/if_arp.h>
 #include <linux/ioport.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
@@ -147,7 +146,7 @@ static int wl_adapter_attach(struct pcmcia_device *link)
 
 	link->resource[0]->end  = HCF_NUM_IO_PORTS;
 	link->resource[0]->flags= IO_DATA_PATH_WIDTH_16;
-	link->conf.Attributes   = CONF_ENABLE_IRQ;
+	link->config_flags     |= CONF_ENABLE_IRQ;
 	link->config_index      = 5;
 	link->config_regs       = PRESENT_OPTION;
 
@@ -301,7 +300,7 @@ void wl_adapter_insert(struct pcmcia_device *link)
 	dev     = link->priv;
 
 	/* Do we need to allocate an interrupt? */
-	link->conf.Attributes |= CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 	link->io_lines = 6;
 
 	ret = pcmcia_request_io(link);
@@ -312,7 +311,7 @@ void wl_adapter_insert(struct pcmcia_device *link)
 	if (ret != 0)
 		goto failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret != 0)
 		goto failed;
 
diff --git a/drivers/staging/wlags49_h2/wl_internal.h b/drivers/staging/wlags49_h2/wl_internal.h
index 02f0a20..cd129b3 100644
--- a/drivers/staging/wlags49_h2/wl_internal.h
+++ b/drivers/staging/wlags49_h2/wl_internal.h
@@ -69,7 +69,6 @@
  ******************************************************************************/
 #include <linux/version.h>
 #ifdef BUS_PCMCIA
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index 5ccc6d0..e23270d 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -8,7 +8,6 @@
 #include <linux/errno.h>	/* error codes */
 #include <linux/slab.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
@@ -143,7 +142,7 @@ static int ixj_config(struct pcmcia_device * link)
 	if (pcmcia_loop_config(link, ixj_config_check, &dflt))
 		goto failed;
 
-	if (pcmcia_request_configuration(link, &link->conf))
+	if (pcmcia_enable_device(link))
 		goto failed;
 
 	/*
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 5904053..744c2cd 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -20,7 +20,6 @@
 #include <linux/ioport.h>
 #include <linux/platform_device.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
@@ -159,7 +158,7 @@ static int sl811_cs_config_check(struct pcmcia_device *p_dev,
 			dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
 	/* we need an interrupt */
-	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
@@ -195,7 +194,7 @@ static int sl811_cs_config(struct pcmcia_device *link)
 	if (!link->irq)
 		goto failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
@@ -227,8 +226,6 @@ static int sl811_cs_probe(struct pcmcia_device *link)
 	local->p_dev = link;
 	link->priv = local;
 
-	link->conf.Attributes = 0;
-
 	return sl811_cs_config(link);
 }
 
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
deleted file mode 100644
index 47b6092..0000000
--- a/include/pcmcia/cs.h
+++ /dev/null
@@ -1,35 +0,0 @@
-/*
- * cs.h
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * The initial developer of the original code is David A. Hinds
- * <dahinds@users.sourceforge.net>.  Portions created by David A. Hinds
- * are Copyright (C) 1999 David A. Hinds.  All Rights Reserved.
- *
- * (C) 1999             David A. Hinds
- */
-
-#ifndef _LINUX_CS_H
-#define _LINUX_CS_H
-
-#ifdef __KERNEL__
-#include <linux/interrupt.h>
-#endif
-
-/* For RequestConfiguration */
-typedef struct config_req_t {
-    u_int	Attributes;
-} config_req_t;
-
-/* Attributes for RequestConfiguration */
-#define CONF_ENABLE_IRQ		0x01
-#define CONF_ENABLE_DMA		0x02
-#define CONF_ENABLE_SPKR	0x04
-#define CONF_ENABLE_PULSE_IRQ	0x08
-#define CONF_ENABLE_ESR		0x10
-#define CONF_VALID_CLIENT	0x100
-
-#endif /* _LINUX_CS_H */
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index bc28f96..50b03fd 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -24,9 +24,11 @@
 
 #ifdef __KERNEL__
 #include <linux/device.h>
+#include <linux/interrupt.h>
 #include <pcmcia/ss.h>
 #include <asm/atomic.h>
 
+
 /*
  * PCMCIA device drivers (16-bit cards only; 32-bit cards require CardBus
  * a.k.a. PCI drivers
@@ -88,18 +90,16 @@ struct pcmcia_device {
 
 	struct list_head	socket_device_list;
 
-	/* deprecated, will be cleaned up soon */
-	config_req_t		conf;
-
 	/* device setup */
 	unsigned int		irq;
 	struct resource		*resource[PCMCIA_NUM_RESOURCES];
 	unsigned int		vpp;
 
-	unsigned int		io_lines; /* number of I/O lines */
+	unsigned int		config_flags;	/* CONF_ENABLE_ flags below */
 	unsigned int		config_base;
 	unsigned int		config_index;
 	unsigned int		config_regs;	/* PRESENT_ flags below */
+	unsigned int		io_lines;	/* number of I/O lines */
 
 	/* Is the device suspended? */
 	u16			suspended:1;
@@ -207,8 +207,7 @@ pcmcia_request_exclusive_irq(struct pcmcia_device *p_dev,
 int __must_check pcmcia_request_irq(struct pcmcia_device *p_dev,
 				irq_handler_t handler);
 
-int pcmcia_request_configuration(struct pcmcia_device *p_dev,
-				 config_req_t *req);
+int pcmcia_enable_device(struct pcmcia_device *p_dev);
 
 int pcmcia_request_window(struct pcmcia_device *p_dev, struct resource *res,
 			unsigned int speed);
@@ -265,6 +264,12 @@ static inline int pcmcia_io_cfg_data_width(unsigned int flags)
 #define PRESENT_IOBASE_3	0x100
 #define PRESENT_IOSIZE		0x200
 
+/* flags to be passed to pcmcia_enable_device() */
+#define CONF_ENABLE_IRQ         0x01
+#define CONF_ENABLE_SPKR        0x02
+#define CONF_ENABLE_PULSE_IRQ   0x04
+#define CONF_ENABLE_ESR         0x08
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_DS_H */
diff --git a/include/pcmcia/ss.h b/include/pcmcia/ss.h
index 626b63c..731cde0 100644
--- a/include/pcmcia/ss.h
+++ b/include/pcmcia/ss.h
@@ -19,7 +19,6 @@
 #include <linux/sched.h>	/* task_struct, completion */
 #include <linux/mutex.h>
 
-#include <pcmcia/cs.h>
 #ifdef CONFIG_CARDBUS
 #include <linux/pci.h>
 #endif
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 4df07fc..2476d5f 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -142,7 +142,7 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->resource[0]->end = 16;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
+	link->config_flags = CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 	link->config_index = 1;
 	link->config_regs = PRESENT_OPTION;
 
@@ -217,6 +217,7 @@ static int pdacf_config(struct pcmcia_device *link)
 
 	snd_printdd(KERN_DEBUG "pdacf_config called\n");
 	link->config_index = 0x5;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 
 	ret = pcmcia_request_io(link);
 	if (ret)
@@ -226,7 +227,7 @@ static int pdacf_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.h b/sound/pcmcia/pdaudiocf/pdaudiocf.h
index 5cc3e45..bd26e09 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.h
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.h
@@ -24,7 +24,6 @@
 #include <sound/pcm.h>
 #include <asm/io.h>
 #include <linux/interrupt.h>
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index 16186ad..017a8d6 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -2,7 +2,7 @@
  * Driver for Digigram VXpocket V2/440 soundcards
  *
  * Copyright (c) 2002 by Takashi Iwai <tiwai@suse.de>
- *
+
  *   This program is free software; you can redistribute it and/or modify
  *   it under the terms of the GNU General Public License as published by
  *   the Free Software Foundation; either version 2 of the License, or
@@ -162,7 +162,7 @@ static int snd_vxpocket_new(struct snd_card *card, int ibl,
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	link->resource[0]->end = 16;
 
-	link->conf.Attributes = CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ;
 	link->config_index = 1;
 	link->config_regs = PRESENT_OPTION;
 
@@ -233,7 +233,7 @@ static int vxpocket_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	ret = pcmcia_request_configuration(link, &link->conf);
+	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
 
diff --git a/sound/pcmcia/vx/vxpocket.h b/sound/pcmcia/vx/vxpocket.h
index d911066..13d658c 100644
--- a/sound/pcmcia/vx/vxpocket.h
+++ b/sound/pcmcia/vx/vxpocket.h
@@ -23,7 +23,6 @@
 
 #include <sound/vx_core.h>
 
-#include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
-- 
1.7.0.4

