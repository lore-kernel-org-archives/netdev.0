From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 07/29] pcmcia: dev_node removal (write-only drivers)
Date: Wed, 19 May 2010 08:42:43 +0200
Message-ID: <1274251385-6196-7-git-send-email-linux@dominikbrodowski.net>
References: <20100519064149.GA5755@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
	linux-bluetooth@vger.kernel.org, linux-mtd@lists.infradead.org,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-serial@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100519064149.GA5755@comet.dominikbrodowski.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

dev_node_t was only used to transport some minor/major numbers
from the PCMCIA device drivers to deprecated userspace helpers.
However, only a few drivers made use of it, and the userspace
helpers are deprecated anyways. Therefore, get rid of dev_node_t .

As a first step, remove any usage of dev_node_t from drivers which
only wrote to this typedef/struct, but did not make use of it.

CC: linux-bluetooth@vger.kernel.org
CC: Harald Welte <laforge@gnumonks.org>
CC: linux-mtd@lists.infradead.org
CC: linux-wireless@vger.kernel.org
CC: netdev@vger.kernel.org
CC: linux-serial@vger.kernel.org
CC: alsa-devel@alsa-project.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/bluetooth/bluecard_cs.c         |    4 ---
 drivers/bluetooth/bt3c_cs.c             |    4 ---
 drivers/bluetooth/btuart_cs.c           |    4 ---
 drivers/bluetooth/dtl1_cs.c             |    4 ---
 drivers/char/pcmcia/cm4040_cs.c         |    5 ---
 drivers/mtd/maps/pcmciamtd.c            |    3 --
 drivers/net/wireless/atmel_cs.c         |   42 -------------------------------
 drivers/net/wireless/hostap/hostap_cs.c |    9 +-----
 drivers/parport/parport_cs.c            |    5 ---
 drivers/scsi/pcmcia/aha152x_stub.c      |    3 --
 drivers/scsi/pcmcia/fdomain_stub.c      |    3 --
 drivers/scsi/pcmcia/nsp_cs.c            |    3 --
 drivers/scsi/pcmcia/nsp_cs.h            |    1 -
 drivers/scsi/pcmcia/qlogic_stub.c       |    3 --
 drivers/scsi/pcmcia/sym53c500_cs.c      |    3 --
 drivers/serial/serial_cs.c              |    9 ------
 drivers/telephony/ixj_pcmcia.c          |    3 --
 sound/pcmcia/pdaudiocf/pdaudiocf.c      |    1 -
 sound/pcmcia/pdaudiocf/pdaudiocf.h      |    1 -
 sound/pcmcia/vx/vxpocket.c              |    2 -
 sound/pcmcia/vx/vxpocket.h              |    1 -
 21 files changed, 2 insertions(+), 111 deletions(-)

diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index a34653d..6f907eb 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -65,7 +65,6 @@ MODULE_LICENSE("GPL");
 
 typedef struct bluecard_info_t {
 	struct pcmcia_device *p_dev;
-	dev_node_t node;
 
 	struct hci_dev *hdev;
 
@@ -916,9 +915,6 @@ static int bluecard_config(struct pcmcia_device *link)
 	if (bluecard_open(info) != 0)
 		goto failed;
 
-	strcpy(info->node.dev_name, info->hdev->name);
-	link->dev_node = &info->node;
-
 	return 0;
 
 failed:
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 1ad9694..21e05fd 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -72,7 +72,6 @@ MODULE_FIRMWARE("BT3CPCC.bin");
 
 typedef struct bt3c_info_t {
 	struct pcmcia_device *p_dev;
-	dev_node_t node;
 
 	struct hci_dev *hdev;
 
@@ -751,9 +750,6 @@ found_port:
 	if (bt3c_open(info) != 0)
 		goto failed;
 
-	strcpy(info->node.dev_name, info->hdev->name);
-	link->dev_node = &info->node;
-
 	return 0;
 
 failed:
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 1073d66..4ed7288 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -67,7 +67,6 @@ MODULE_LICENSE("GPL");
 
 typedef struct btuart_info_t {
 	struct pcmcia_device *p_dev;
-	dev_node_t node;
 
 	struct hci_dev *hdev;
 
@@ -680,9 +679,6 @@ found_port:
 	if (btuart_open(info) != 0)
 		goto failed;
 
-	strcpy(info->node.dev_name, info->hdev->name);
-	link->dev_node = &info->node;
-
 	return 0;
 
 failed:
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 3d72afd..ef044d5 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -67,7 +67,6 @@ MODULE_LICENSE("GPL");
 
 typedef struct dtl1_info_t {
 	struct pcmcia_device *p_dev;
-	dev_node_t node;
 
 	struct hci_dev *hdev;
 
@@ -629,9 +628,6 @@ static int dtl1_config(struct pcmcia_device *link)
 	if (dtl1_open(info) != 0)
 		goto failed;
 
-	strcpy(info->node.dev_name, info->hdev->name);
-	link->dev_node = &info->node;
-
 	return 0;
 
 failed:
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index a6a70e4..c0775c8 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -72,7 +72,6 @@ static struct class *cmx_class;
 
 struct reader_dev {
 	struct pcmcia_device	*p_dev;
-	dev_node_t		node;
 	wait_queue_head_t	devq;
 	wait_queue_head_t	poll_wait;
 	wait_queue_head_t	read_wait;
@@ -568,10 +567,6 @@ static int reader_config(struct pcmcia_device *link, int devno)
 	}
 
 	dev = link->priv;
-	sprintf(dev->node.dev_name, DEVICE_NAME "%d", devno);
-	dev->node.major = major;
-	dev->node.minor = devno;
-	dev->node.next = &dev->node;
 
 	DEBUGP(2, dev, "device " DEVICE_NAME "%d at 0x%.4x-0x%.4x\n", devno,
 	      link->io.BasePort1, link->io.BasePort1+link->io.NumPorts1);
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 689d6a7..87b2b8f 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -52,7 +52,6 @@ static const int debug = 0;
 
 struct pcmciamtd_dev {
 	struct pcmcia_device	*p_dev;
-	dev_node_t	node;		/* device node */
 	caddr_t		win_base;	/* ioremapped address of PCMCIA window */
 	unsigned int	win_size;	/* size of window */
 	unsigned int	offset;		/* offset into card the window currently points at */
@@ -647,9 +646,7 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 		pcmciamtd_release(link);
 		return -ENODEV;
 	}
-	snprintf(dev->node.dev_name, sizeof(dev->node.dev_name), "mtd%d", mtd->index);
 	info("mtd%d: %s", mtd->index, mtd->name);
-	link->dev_node = &dev->node;
 	return 0;
 
  failed:
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 759cdc4..c2746fc 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -85,41 +85,7 @@ static void atmel_release(struct pcmcia_device *link);
 
 static void atmel_detach(struct pcmcia_device *p_dev);
 
-/*
-   You'll also need to prototype all the functions that will actually
-   be used to talk to your device.  See 'pcmem_cs' for a good example
-   of a fully self-sufficient driver; the other drivers rely more or
-   less on other parts of the kernel.
-*/
-
-/*
-   A linked list of "instances" of the  atmelnet device.  Each actual
-   PCMCIA card corresponds to one device instance, and is described
-   by one struct pcmcia_device structure (defined in ds.h).
-
-   You may not want to use a linked list for this -- for example, the
-   memory card driver uses an array of struct pcmcia_device pointers, where minor
-   device numbers are used to derive the corresponding array index.
-*/
-
-/*
-   A driver needs to provide a dev_node_t structure for each device
-   on a card.  In some cases, there is only one device per card (for
-   example, ethernet cards, modems).  In other cases, there may be
-   many actual or logical devices (SCSI adapters, memory cards with
-   multiple partitions).  The dev_node_t structures need to be kept
-   in a linked list starting at the 'dev' field of a struct pcmcia_device
-   structure.  We allocate them in the card's private data structure,
-   because they generally shouldn't be allocated dynamically.
-
-   In this case, we also provide a flag to indicate if a device is
-   "stopped" due to a power management event, or card ejection.  The
-   device IO routines can use a flag like this to throttle IO to a
-   card that is not ready to accept it.
-*/
-
 typedef struct local_info_t {
-	dev_node_t	node;
 	struct net_device *eth_dev;
 } local_info_t;
 
@@ -297,14 +263,6 @@ static int atmel_config(struct pcmcia_device *link)
 			goto failed;
 
 
-	/*
-	  At this point, the dev_node_t structure(s) need to be
-	  initialized and arranged in a linked list at link->dev_node.
-	*/
-	strcpy(dev->node.dev_name, ((local_info_t*)link->priv)->eth_dev->name );
-	dev->node.major = dev->node.minor = 0;
-	link->dev_node = &dev->node;
-
 	return 0;
 
  failed:
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 5e2efbb..db72461 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -39,7 +39,6 @@ MODULE_PARM_DESC(ignore_cis_vcc, "Ignore broken CIS VCC entry");
 
 /* struct local_info::hw_priv */
 struct hostap_cs_priv {
-	dev_node_t node;
 	struct pcmcia_device *link;
 	int sandisk_connectplus;
 };
@@ -625,8 +624,6 @@ static int prism2_config(struct pcmcia_device *link)
 	local = iface->local;
 	local->hw_priv = hw_priv;
 	hw_priv->link = link;
-	strcpy(hw_priv->node.dev_name, dev->name);
-	link->dev_node = &hw_priv->node;
 
 	ret = pcmcia_request_irq(link, prism2_interrupt);
 	if (ret)
@@ -665,11 +662,9 @@ static int prism2_config(struct pcmcia_device *link)
 	sandisk_enable_wireless(dev);
 
 	ret = prism2_hw_config(dev, 1);
-	if (!ret) {
+	if (!ret)
 		ret = hostap_hw_ready(dev);
-		if (ret == 0 && local->ddev)
-			strcpy(hw_priv->node.dev_name, local->ddev->name);
-	}
+
 	return ret;
 
  failed:
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index 80c9052..fd8cfe9 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -75,7 +75,6 @@ INT_MODULE_PARM(epp_mode, 1);
 typedef struct parport_info_t {
 	struct pcmcia_device	*p_dev;
     int			ndev;
-    dev_node_t		node;
     struct parport	*port;
 } parport_info_t;
 
@@ -193,11 +192,7 @@ static int parport_config(struct pcmcia_device *link)
     if (epp_mode)
 	p->modes |= PARPORT_MODE_TRISTATE | PARPORT_MODE_EPP;
     info->ndev = 1;
-    info->node.major = LP_MAJOR;
-    info->node.minor = p->number;
     info->port = p;
-    strcpy(info->node.dev_name, p->name);
-    link->dev_node = &info->node;
 
     return 0;
 
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index c1de4ba..9d70aef 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -80,7 +80,6 @@ MODULE_LICENSE("Dual MPL/GPL");
 
 typedef struct scsi_info_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t		node;
     struct Scsi_Host	*host;
 } scsi_info_t;
 
@@ -185,8 +184,6 @@ static int aha152x_config_cs(struct pcmcia_device *link)
 	goto failed;
     }
 
-    sprintf(info->node.dev_name, "scsi%d", host->host_no);
-    link->dev_node = &info->node;
     info->host = host;
 
     return 0;
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 8cb6d71..21b1411 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -63,7 +63,6 @@ MODULE_LICENSE("Dual MPL/GPL");
 
 typedef struct scsi_info_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t		node;
     struct Scsi_Host	*host;
 } scsi_info_t;
 
@@ -155,8 +154,6 @@ static int fdomain_config(struct pcmcia_device *link)
 	    goto failed;
     scsi_scan_host(host);
 
-    sprintf(info->node.dev_name, "scsi%d", host->host_no);
-    link->dev_node = &info->node;
     info->host = host;
 
     return 0;
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 24c78ed..0f0e112 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1754,8 +1754,6 @@ static int nsp_cs_config(struct pcmcia_device *link)
 
 	scsi_scan_host(host);
 
-	snprintf(info->node.dev_name, sizeof(info->node.dev_name), "scsi%d", host->host_no);
-	link->dev_node  = &info->node;
 	info->host = host;
 
 	/* Finally, report what we've done */
@@ -1813,7 +1811,6 @@ static void nsp_cs_release(struct pcmcia_device *link)
 	if (info->host != NULL) {
 		scsi_remove_host(info->host);
 	}
-	link->dev_node = NULL;
 
 	if (link->win) {
 		if (data != NULL) {
diff --git a/drivers/scsi/pcmcia/nsp_cs.h b/drivers/scsi/pcmcia/nsp_cs.h
index 8c61a4f..d68c9f2 100644
--- a/drivers/scsi/pcmcia/nsp_cs.h
+++ b/drivers/scsi/pcmcia/nsp_cs.h
@@ -224,7 +224,6 @@
 typedef struct scsi_info_t {
 	struct pcmcia_device	*p_dev;
 	struct Scsi_Host      *host;
-	dev_node_t             node;
 	int                    stop;
 } scsi_info_t;
 
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index c3a4428..f0fc6ba 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -82,7 +82,6 @@ static struct scsi_host_template qlogicfas_driver_template = {
 
 typedef struct scsi_info_t {
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
 	struct Scsi_Host *host;
 	unsigned short manf_id;
 } scsi_info_t;
@@ -235,8 +234,6 @@ static int qlogic_config(struct pcmcia_device * link)
 		goto failed;
 	}
 
-	sprintf(info->node.dev_name, "scsi%d", host->host_no);
-	link->dev_node = &info->node;
 	info->host = host;
 
 	return 0;
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 6eacf4c..a511641 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -191,7 +191,6 @@
 
 struct scsi_info_t {
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
 	struct Scsi_Host *host;
 	unsigned short manf_id;
 };
@@ -792,8 +791,6 @@ SYM53C500_config(struct pcmcia_device *link)
 	*/
 	data->fast_pio = USE_FAST_PIO;
 
-	sprintf(info->node.dev_name, "scsi%d", host->host_no);
-	link->dev_node = &info->node;
 	info->host = host;
 
 	if (scsi_add_host(host, NULL))
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 6459252..dadd686 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -89,7 +89,6 @@ struct serial_info {
 	int			manfid;
 	int			prodid;
 	int			c950ctrl;
-	dev_node_t		node[4];
 	int			line[4];
 	const struct serial_quirk *quirk;
 };
@@ -289,8 +288,6 @@ static void serial_remove(struct pcmcia_device *link)
 	for (i = 0; i < info->ndev; i++)
 		serial8250_unregister_port(info->line[i]);
 
-	info->p_dev->dev_node = NULL;
-
 	if (!info->slave)
 		pcmcia_disable_device(link);
 }
@@ -410,11 +407,6 @@ static int setup_serial(struct pcmcia_device *handle, struct serial_info * info,
 	}
 
 	info->line[info->ndev] = line;
-	sprintf(info->node[info->ndev].dev_name, "ttyS%d", line);
-	info->node[info->ndev].major = TTY_MAJOR;
-	info->node[info->ndev].minor = 0x40 + line;
-	if (info->ndev > 0)
-		info->node[info->ndev - 1].next = &info->node[info->ndev];
 	info->ndev++;
 
 	return 0;
@@ -711,7 +703,6 @@ static int serial_config(struct pcmcia_device * link)
 		if (info->quirk->post(link))
 			goto failed;
 
-	link->dev_node = &info->node[0];
 	return 0;
 
 failed:
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index d442fd3..99cb224 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -22,7 +22,6 @@
 
 typedef struct ixj_info_t {
 	int ndev;
-	dev_node_t node;
 	struct ixj *port;
 } ixj_info_t;
 
@@ -155,8 +154,6 @@ static int ixj_config(struct pcmcia_device * link)
 	j = ixj_pcmcia_probe(link->io.BasePort1, link->io.BasePort1 + 0x10);
 
 	info->ndev = 1;
-	info->node.major = PHONE_MAJOR;
-	link->dev_node = &info->node;
 	ixj_get_serial(link, j);
 	return 0;
 
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 60fddf3..df110df 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -234,7 +234,6 @@ static int pdacf_config(struct pcmcia_device *link)
 	if (snd_pdacf_assign_resources(pdacf, link->io.BasePort1, link->irq) < 0)
 		goto failed;
 
-	link->dev_node = &pdacf->node;
 	return 0;
 
 failed:
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.h b/sound/pcmcia/pdaudiocf/pdaudiocf.h
index b060183..a0a7ec6 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.h
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.h
@@ -117,7 +117,6 @@ struct snd_pdacf {
 	
 	/* pcmcia stuff */
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
 };
 
 static inline void pdacf_reg_write(struct snd_pdacf *chip, unsigned char reg, unsigned short val)
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index 5eced7a..624b47a 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -211,7 +211,6 @@ static int snd_vxpocket_assign_resources(struct vx_core *chip, int port, int irq
 static int vxpocket_config(struct pcmcia_device *link)
 {
 	struct vx_core *chip = link->priv;
-	struct snd_vxpocket *vxp = (struct snd_vxpocket *)chip;
 	int ret;
 
 	snd_printdd(KERN_DEBUG "vxpocket_config called\n");
@@ -245,7 +244,6 @@ static int vxpocket_config(struct pcmcia_device *link)
 	if (snd_vxpocket_assign_resources(chip, link->io.BasePort1, link->irq) < 0)
 		goto failed;
 
-	link->dev_node = &vxp->node;
 	return 0;
 
 failed:
diff --git a/sound/pcmcia/vx/vxpocket.h b/sound/pcmcia/vx/vxpocket.h
index 27ea002..ea4df16 100644
--- a/sound/pcmcia/vx/vxpocket.h
+++ b/sound/pcmcia/vx/vxpocket.h
@@ -43,7 +43,6 @@ struct snd_vxpocket {
 
 	/* pcmcia stuff */
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
 };
 
 extern struct snd_vx_ops snd_vxpocket_ops;
-- 
1.6.3.3
