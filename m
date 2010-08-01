From: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH 04/11] pcmcia: do not use io_req_t after call to pcmcia_request_io()
Date: Sun,  1 Aug 2010 14:59:03 +0200
Message-ID: <1280667550-3040-4-git-send-email-linux@dominikbrodowski.net>
References: <20100801125749.GA2564@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100801125749.GA2564-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

After pcmcia_request_io(), do not make use of the values stored in
io_req_t, but instead use those found in struct pcmcia_device->resource[].

CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org
CC: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
CC: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
CC: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
---
 drivers/ata/pata_pcmcia.c                        |    8 +++---
 drivers/bluetooth/bluecard_cs.c                  |   18 ++++++++--------
 drivers/bluetooth/bt3c_cs.c                      |    8 +++---
 drivers/bluetooth/btuart_cs.c                    |   12 +++++-----
 drivers/bluetooth/dtl1_cs.c                      |   13 ++++++-----
 drivers/char/pcmcia/cm4000_cs.c                  |   12 +++++-----
 drivers/char/pcmcia/cm4040_cs.c                  |   16 +++++++-------
 drivers/char/pcmcia/ipwireless/main.c            |   10 +++-----
 drivers/char/pcmcia/synclink_cs.c                |    7 ++---
 drivers/ide/ide-cs.c                             |    8 +++---
 drivers/isdn/hardware/avm/avm_cs.c               |    9 ++++---
 drivers/isdn/hisax/avma1_cs.c                    |    8 ++++--
 drivers/isdn/hisax/elsa_cs.c                     |   16 ++++++--------
 drivers/isdn/hisax/sedlbauer_cs.c                |   16 ++++++--------
 drivers/isdn/hisax/teles_cs.c                    |   14 +++++-------
 drivers/net/pcmcia/3c574_cs.c                    |    2 +-
 drivers/net/pcmcia/3c589_cs.c                    |    2 +-
 drivers/net/pcmcia/axnet_cs.c                    |    4 +-
 drivers/net/pcmcia/com20020_cs.c                 |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c                  |    6 ++--
 drivers/net/pcmcia/ibmtr_cs.c                    |    2 +-
 drivers/net/pcmcia/nmclan_cs.c                   |    2 +-
 drivers/net/pcmcia/pcnet_cs.c                    |    4 +-
 drivers/net/pcmcia/smc91c92_cs.c                 |   18 ++++++++--------
 drivers/net/pcmcia/xirc2ps_cs.c                  |   12 +++++-----
 drivers/net/wireless/airo_cs.c                   |   12 ++++------
 drivers/net/wireless/atmel_cs.c                  |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c          |   18 +++++++--------
 drivers/net/wireless/libertas/if_cs.c            |    7 ++---
 drivers/net/wireless/orinoco/orinoco_cs.c        |    5 ++-
 drivers/net/wireless/orinoco/spectrum_cs.c       |    5 ++-
 drivers/net/wireless/wl3501_cs.c                 |    2 +-
 drivers/parport/parport_cs.c                     |    6 +++-
 drivers/scsi/pcmcia/aha152x_stub.c               |    2 +-
 drivers/scsi/pcmcia/fdomain_stub.c               |    4 +-
 drivers/scsi/pcmcia/nsp_cs.c                     |   25 ++++++++++-----------
 drivers/scsi/pcmcia/qlogic_stub.c                |   18 ++++++++--------
 drivers/scsi/pcmcia/sym53c500_cs.c               |   16 +++++++-------
 drivers/serial/serial_cs.c                       |   22 +++++++++---------
 drivers/staging/comedi/drivers/cb_das16_cs.c     |   12 ++++------
 drivers/staging/comedi/drivers/das08_cs.c        |   12 ++++------
 drivers/staging/comedi/drivers/ni_daq_700.c      |   12 ++++------
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |   12 ++++------
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |   12 ++++------
 drivers/staging/comedi/drivers/ni_mio_cs.c       |    2 +-
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |   12 ++++------
 drivers/staging/wlags49_h2/wl_cs.c               |    2 +-
 drivers/telephony/ixj_pcmcia.c                   |    3 +-
 drivers/usb/host/sl811_cs.c                      |    7 ++---
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    3 +-
 sound/pcmcia/vx/vxpocket.c                       |    3 +-
 51 files changed, 224 insertions(+), 241 deletions(-)

diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 3dcb2b1..1fcd065 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -210,13 +210,13 @@ static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 			pdev->io.NumPorts2 = (stk->is_kme) ? 2 : 1;
 			if (pcmcia_request_io(pdev, &pdev->io) != 0)
 				return -ENODEV;
-			stk->ctl_base = pdev->io.BasePort2;
+			stk->ctl_base = pdev->resource[1]->start;
 		} else if ((io->nwin == 1) && (io->win[0].len >= 16)) {
 			pdev->io.NumPorts1 = io->win[0].len;
 			pdev->io.NumPorts2 = 0;
 			if (pcmcia_request_io(pdev, &pdev->io) != 0)
 				return -ENODEV;
-			stk->ctl_base = pdev->io.BasePort1 + 0x0e;
+			stk->ctl_base = pdev->resource[0]->start + 0x0e;
 		} else
 			return -ENODEV;
 		/* If we've got this far, we're done */
@@ -270,7 +270,7 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 		if (pcmcia_loop_config(pdev, pcmcia_check_one_config, stk))
 			goto failed; /* No suitable config found */
 	}
-	io_base = pdev->io.BasePort1;
+	io_base = pdev->resource[0]->start;
 	ctl_base = stk->ctl_base;
 	if (!pdev->irq)
 		goto failed;
@@ -293,7 +293,7 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 
 	/* FIXME: Could be more ports at base + 0x10 but we only deal with
 	   one right now */
-	if (pdev->io.NumPorts1 >= 0x20)
+	if (resource_size(pdev->resource[0]) >= 0x20)
 		n_ports = 2;
 
 	if (pdev->manf_id == 0x0097 && pdev->card_id == 0x1620)
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index eb085de..24d2007 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -159,7 +159,7 @@ static void bluecard_detach(struct pcmcia_device *p_dev);
 static void bluecard_activity_led_timeout(u_long arg)
 {
 	bluecard_info_t *info = (bluecard_info_t *)arg;
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 
 	if (!test_bit(CARD_HAS_PCCARD_ID, &(info->hw_state)))
 		return;
@@ -176,7 +176,7 @@ static void bluecard_activity_led_timeout(u_long arg)
 
 static void bluecard_enable_activity_led(bluecard_info_t *info)
 {
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 
 	if (!test_bit(CARD_HAS_PCCARD_ID, &(info->hw_state)))
 		return;
@@ -232,7 +232,7 @@ static void bluecard_write_wakeup(bluecard_info_t *info)
 	}
 
 	do {
-		register unsigned int iobase = info->p_dev->io.BasePort1;
+		register unsigned int iobase = info->p_dev->resource[0]->start;
 		register unsigned int offset;
 		register unsigned char command;
 		register unsigned long ready_bit;
@@ -379,7 +379,7 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 		return;
 	}
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	if (test_bit(XMIT_SENDING_READY, &(info->tx_state)))
 		bluecard_enable_activity_led(info);
@@ -508,7 +508,7 @@ static irqreturn_t bluecard_interrupt(int irq, void *dev_inst)
 	if (!test_bit(CARD_READY, &(info->hw_state)))
 		return IRQ_HANDLED;
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	spin_lock(&(info->lock));
 
@@ -622,7 +622,7 @@ static int bluecard_hci_flush(struct hci_dev *hdev)
 static int bluecard_hci_open(struct hci_dev *hdev)
 {
 	bluecard_info_t *info = (bluecard_info_t *)(hdev->driver_data);
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 
 	if (test_bit(CARD_HAS_PCCARD_ID, &(info->hw_state)))
 		bluecard_hci_set_baud_rate(hdev, DEFAULT_BAUD_RATE);
@@ -642,7 +642,7 @@ static int bluecard_hci_open(struct hci_dev *hdev)
 static int bluecard_hci_close(struct hci_dev *hdev)
 {
 	bluecard_info_t *info = (bluecard_info_t *)(hdev->driver_data);
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 
 	if (!test_and_clear_bit(HCI_RUNNING, &(hdev->flags)))
 		return 0;
@@ -709,7 +709,7 @@ static int bluecard_hci_ioctl(struct hci_dev *hdev, unsigned int cmd, unsigned l
 
 static int bluecard_open(bluecard_info_t *info)
 {
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 	struct hci_dev *hdev;
 	unsigned char id;
 
@@ -828,7 +828,7 @@ static int bluecard_open(bluecard_info_t *info)
 
 static int bluecard_close(bluecard_info_t *info)
 {
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 	struct hci_dev *hdev = info->hdev;
 
 	if (!hdev)
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 457b603..8ab494c 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -188,7 +188,7 @@ static void bt3c_write_wakeup(bt3c_info_t *info)
 		return;
 
 	do {
-		register unsigned int iobase = info->p_dev->io.BasePort1;
+		register unsigned int iobase = info->p_dev->resource[0]->start;
 		register struct sk_buff *skb;
 		register int len;
 
@@ -226,7 +226,7 @@ static void bt3c_receive(bt3c_info_t *info)
 		return;
 	}
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	avail = bt3c_read(iobase, 0x7006);
 	//printk("bt3c_cs: receiving %d bytes\n", avail);
@@ -347,7 +347,7 @@ static irqreturn_t bt3c_interrupt(int irq, void *dev_inst)
 		/* our irq handler is shared */
 		return IRQ_NONE;
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	spin_lock(&(info->lock));
 
@@ -480,7 +480,7 @@ static int bt3c_load_firmware(bt3c_info_t *info, const unsigned char *firmware,
 	unsigned int iobase, size, addr, fcs, tmp;
 	int i, err = 0;
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	/* Reset */
 	bt3c_io_write(iobase, 0x8040, 0x0404);
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index e7e0a17..7e770d4 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -142,7 +142,7 @@ static void btuart_write_wakeup(btuart_info_t *info)
 	}
 
 	do {
-		register unsigned int iobase = info->p_dev->io.BasePort1;
+		register unsigned int iobase = info->p_dev->resource[0]->start;
 		register struct sk_buff *skb;
 		register int len;
 
@@ -183,7 +183,7 @@ static void btuart_receive(btuart_info_t *info)
 		return;
 	}
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	do {
 		info->hdev->stat.byte_rx++;
@@ -297,7 +297,7 @@ static irqreturn_t btuart_interrupt(int irq, void *dev_inst)
 		/* our irq handler is shared */
 		return IRQ_NONE;
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	spin_lock(&(info->lock));
 
@@ -354,7 +354,7 @@ static void btuart_change_speed(btuart_info_t *info, unsigned int speed)
 		return;
 	}
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	spin_lock_irqsave(&(info->lock), flags);
 
@@ -478,7 +478,7 @@ static int btuart_hci_ioctl(struct hci_dev *hdev, unsigned int cmd, unsigned lon
 static int btuart_open(btuart_info_t *info)
 {
 	unsigned long flags;
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 	struct hci_dev *hdev;
 
 	spin_lock_init(&(info->lock));
@@ -548,7 +548,7 @@ static int btuart_open(btuart_info_t *info)
 static int btuart_close(btuart_info_t *info)
 {
 	unsigned long flags;
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 	struct hci_dev *hdev = info->hdev;
 
 	if (!hdev)
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 7c94aad..bfe9313 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -149,7 +149,7 @@ static void dtl1_write_wakeup(dtl1_info_t *info)
 	}
 
 	do {
-		register unsigned int iobase = info->p_dev->io.BasePort1;
+		register unsigned int iobase = info->p_dev->resource[0]->start;
 		register struct sk_buff *skb;
 		register int len;
 
@@ -214,7 +214,7 @@ static void dtl1_receive(dtl1_info_t *info)
 		return;
 	}
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	do {
 		info->hdev->stat.byte_rx++;
@@ -301,7 +301,7 @@ static irqreturn_t dtl1_interrupt(int irq, void *dev_inst)
 		/* our irq handler is shared */
 		return IRQ_NONE;
 
-	iobase = info->p_dev->io.BasePort1;
+	iobase = info->p_dev->resource[0]->start;
 
 	spin_lock(&(info->lock));
 
@@ -461,7 +461,7 @@ static int dtl1_hci_ioctl(struct hci_dev *hdev, unsigned int cmd,  unsigned long
 static int dtl1_open(dtl1_info_t *info)
 {
 	unsigned long flags;
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 	struct hci_dev *hdev;
 
 	spin_lock_init(&(info->lock));
@@ -508,7 +508,8 @@ static int dtl1_open(dtl1_info_t *info)
 	outb(UART_LCR_WLEN8, iobase + UART_LCR);	/* Reset DLAB */
 	outb((UART_MCR_DTR | UART_MCR_RTS | UART_MCR_OUT2), iobase + UART_MCR);
 
-	info->ri_latch = inb(info->p_dev->io.BasePort1 + UART_MSR) & UART_MSR_RI;
+	info->ri_latch = inb(info->p_dev->resource[0]->start + UART_MSR)
+				& UART_MSR_RI;
 
 	/* Turn on interrupts */
 	outb(UART_IER_RLSI | UART_IER_RDI | UART_IER_THRI, iobase + UART_IER);
@@ -533,7 +534,7 @@ static int dtl1_open(dtl1_info_t *info)
 static int dtl1_close(dtl1_info_t *info)
 {
 	unsigned long flags;
-	unsigned int iobase = info->p_dev->io.BasePort1;
+	unsigned int iobase = info->p_dev->resource[0]->start;
 	struct hci_dev *hdev = info->hdev;
 
 	if (!hdev)
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index a8be2a7..18484ed 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -421,7 +421,7 @@ static struct card_fixup card_fixups[] = {
 static void set_cardparameter(struct cm4000_dev *dev)
 {
 	int i;
-	unsigned int iobase = dev->p_dev->io.BasePort1;
+	unsigned int iobase = dev->p_dev->resource[0]->start;
 	u_int8_t stopbits = 0x02; /* ISO default */
 
 	DEBUGP(3, dev, "-> set_cardparameter\n");
@@ -454,7 +454,7 @@ static int set_protocol(struct cm4000_dev *dev, struct ptsreq *ptsreq)
 	unsigned short num_bytes_read;
 	unsigned char pts_reply[4];
 	ssize_t rc;
-	unsigned int iobase = dev->p_dev->io.BasePort1;
+	unsigned int iobase = dev->p_dev->resource[0]->start;
 
 	rc = 0;
 
@@ -663,7 +663,7 @@ static void terminate_monitor(struct cm4000_dev *dev)
 static void monitor_card(unsigned long p)
 {
 	struct cm4000_dev *dev = (struct cm4000_dev *) p;
-	unsigned int iobase = dev->p_dev->io.BasePort1;
+	unsigned int iobase = dev->p_dev->resource[0]->start;
 	unsigned short s;
 	struct ptsreq ptsreq;
 	int i, atrc;
@@ -924,7 +924,7 @@ static ssize_t cmm_read(struct file *filp, __user char *buf, size_t count,
 			loff_t *ppos)
 {
 	struct cm4000_dev *dev = filp->private_data;
-	unsigned int iobase = dev->p_dev->io.BasePort1;
+	unsigned int iobase = dev->p_dev->resource[0]->start;
 	ssize_t rc;
 	int i, j, k;
 
@@ -1047,7 +1047,7 @@ static ssize_t cmm_write(struct file *filp, const char __user *buf,
 			 size_t count, loff_t *ppos)
 {
 	struct cm4000_dev *dev = filp->private_data;
-	unsigned int iobase = dev->p_dev->io.BasePort1;
+	unsigned int iobase = dev->p_dev->resource[0]->start;
 	unsigned short s;
 	unsigned char tmp;
 	unsigned char infolen;
@@ -1400,7 +1400,7 @@ static void stop_monitor(struct cm4000_dev *dev)
 static long cmm_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 {
 	struct cm4000_dev *dev = filp->private_data;
-	unsigned int iobase = dev->p_dev->io.BasePort1;
+	unsigned int iobase = dev->p_dev->resource[0]->start;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	struct pcmcia_device *link;
 	int size;
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index 44adae9..a6bbf19 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -109,7 +109,7 @@ static inline unsigned char xinb(unsigned short port)
 static void cm4040_do_poll(unsigned long dummy)
 {
 	struct reader_dev *dev = (struct reader_dev *) dummy;
-	unsigned int obs = xinb(dev->p_dev->io.BasePort1
+	unsigned int obs = xinb(dev->p_dev->resource[0]->start
 				+ REG_OFFSET_BUFFER_STATUS);
 
 	if ((obs & BSR_BULK_IN_FULL)) {
@@ -140,7 +140,7 @@ static void cm4040_stop_poll(struct reader_dev *dev)
 static int wait_for_bulk_out_ready(struct reader_dev *dev)
 {
 	int i, rc;
-	int iobase = dev->p_dev->io.BasePort1;
+	int iobase = dev->p_dev->resource[0]->start;
 
 	for (i = 0; i < POLL_LOOP_COUNT; i++) {
 		if ((xinb(iobase + REG_OFFSET_BUFFER_STATUS)
@@ -170,7 +170,7 @@ static int wait_for_bulk_out_ready(struct reader_dev *dev)
 /* Write to Sync Control Register */
 static int write_sync_reg(unsigned char val, struct reader_dev *dev)
 {
-	int iobase = dev->p_dev->io.BasePort1;
+	int iobase = dev->p_dev->resource[0]->start;
 	int rc;
 
 	rc = wait_for_bulk_out_ready(dev);
@@ -188,7 +188,7 @@ static int write_sync_reg(unsigned char val, struct reader_dev *dev)
 static int wait_for_bulk_in_ready(struct reader_dev *dev)
 {
 	int i, rc;
-	int iobase = dev->p_dev->io.BasePort1;
+	int iobase = dev->p_dev->resource[0]->start;
 
 	for (i = 0; i < POLL_LOOP_COUNT; i++) {
 		if ((xinb(iobase + REG_OFFSET_BUFFER_STATUS)
@@ -218,7 +218,7 @@ static ssize_t cm4040_read(struct file *filp, char __user *buf,
 			size_t count, loff_t *ppos)
 {
 	struct reader_dev *dev = filp->private_data;
-	int iobase = dev->p_dev->io.BasePort1;
+	int iobase = dev->p_dev->resource[0]->start;
 	size_t bytes_to_read;
 	unsigned long i;
 	size_t min_bytes_to_read;
@@ -320,7 +320,7 @@ static ssize_t cm4040_write(struct file *filp, const char __user *buf,
 			 size_t count, loff_t *ppos)
 {
 	struct reader_dev *dev = filp->private_data;
-	int iobase = dev->p_dev->io.BasePort1;
+	int iobase = dev->p_dev->resource[0]->start;
 	ssize_t rc;
 	int i;
 	unsigned int bytes_to_write;
@@ -567,8 +567,8 @@ static int reader_config(struct pcmcia_device *link, int devno)
 
 	dev = link->priv;
 
-	DEBUGP(2, dev, "device " DEVICE_NAME "%d at 0x%.4x-0x%.4x\n", devno,
-	      link->io.BasePort1, link->io.BasePort1+link->io.NumPorts1);
+	DEBUGP(2, dev, "device " DEVICE_NAME "%d at %pR\n", devno,
+	      link->resource[0]);
 	DEBUGP(2, dev, "<- reader_config (succ)\n");
 
 	return 0;
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 63c32e3..9467994 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -100,7 +100,8 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	if (ret)
 		return ret;
 
-	io_resource = request_region(p_dev->io.BasePort1, p_dev->io.NumPorts1,
+	io_resource = request_region(p_dev->resource[0]->start,
+				resource_size(p_dev->resource[0]),
 				IPWIRELESS_PCCARD_NAME);
 
 	if (cfg->mem.nwin == 0)
@@ -197,7 +198,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 
 	INIT_WORK(&ipw->work_reboot, signalled_reboot_work);
 
-	ipwireless_init_hardware_v1(ipw->hardware, link->io.BasePort1,
+	ipwireless_init_hardware_v1(ipw->hardware, link->resource[0]->start,
 				    ipw->attr_memory, ipw->common_memory,
 				    ipw->is_v2_card, signalled_reboot_callback,
 				    ipw);
@@ -209,10 +210,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	printk(KERN_INFO IPWIRELESS_PCCARD_NAME ": Card type %s\n",
 			ipw->is_v2_card ? "V2/V3" : "V1");
 	printk(KERN_INFO IPWIRELESS_PCCARD_NAME
-			": I/O ports 0x%04x-0x%04x, irq %d\n",
-			(unsigned int) link->io.BasePort1,
-			(unsigned int) (link->io.BasePort1 +
-				link->io.NumPorts1 - 1),
+		": I/O ports %pR, irq %d\n", link->resource[0],
 			(unsigned int) link->irq);
 	if (ipw->attr_memory && ipw->common_memory)
 		printk(KERN_INFO IPWIRELESS_PCCARD_NAME
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 522992e..8ded9b0 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -609,16 +609,15 @@ static int mgslpc_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    info->io_base = link->io.BasePort1;
+    info->io_base = link->resource[0]->start;
     info->irq_level = link->irq;
 
     dev_info(&link->dev, "index 0x%02x:",
 	    link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	    printk(", irq %d", link->irq);
-    if (link->io.NumPorts1)
-	    printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		   link->io.BasePort1+link->io.NumPorts1-1);
+    if (link->resource[0])
+	    printk(", io %pR", link->resource[0]);
     printk("\n");
     return 0;
 
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 27dbab8..34eafaf 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -239,13 +239,13 @@ static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 			pdev->io.NumPorts2 = (stk->is_kme) ? 2 : 1;
 			if (pcmcia_request_io(pdev, &pdev->io) != 0)
 				return -ENODEV;
-			stk->ctl_base = pdev->io.BasePort2;
+			stk->ctl_base = pdev->resource[1]->start;
 		} else if ((io->nwin == 1) && (io->win[0].len >= 16)) {
 			pdev->io.NumPorts1 = io->win[0].len;
 			pdev->io.NumPorts2 = 0;
 			if (pcmcia_request_io(pdev, &pdev->io) != 0)
 				return -ENODEV;
-			stk->ctl_base = pdev->io.BasePort1 + 0x0e;
+			stk->ctl_base = pdev->resource[1]->start + 0x0e;
 		} else
 			return -ENODEV;
 		/* If we've got this far, we're done */
@@ -279,7 +279,7 @@ static int ide_config(struct pcmcia_device *link)
 	    if (pcmcia_loop_config(link, pcmcia_check_one_config, stk))
 		    goto failed; /* No suitable config found */
     }
-    io_base = link->io.BasePort1;
+    io_base = link->resource[0]->start;
     ctl_base = stk->ctl_base;
 
     if (!link->irq)
@@ -296,7 +296,7 @@ static int ide_config(struct pcmcia_device *link)
 	outb(0x81, ctl_base+1);
 
      host = idecs_register(io_base, ctl_base, link->irq, link);
-     if (host == NULL && link->io.NumPorts1 == 0x20) {
+     if (host == NULL && resource_size(link->resource[0]) == 0x20) {
 	    outb(0x02, ctl_base + 0x10);
 	    host = idecs_register(io_base + 0x10, ctl_base + 0x10,
 				  link->irq, link);
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index e804a01..7c8c51f 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -191,9 +191,10 @@ static int avmcs_config(struct pcmcia_device *link)
 	default:
         case AVM_CARDTYPE_B1: addcard = b1pcmcia_addcard_b1; break;
     }
-    if ((i = (*addcard)(link->io.BasePort1, link->irq)) < 0) {
-	    dev_err(&link->dev, "avm_cs: failed to add AVM-Controller at i/o %#x, irq %d\n",
-		    link->io.BasePort1, link->irq);
+    if ((i = (*addcard)(link->resource[0]->start, link->irq)) < 0) {
+	    dev_err(&link->dev,
+		    "avm_cs: failed to add AVM-Controller at i/o %#x, irq %d\n",
+		    (unsigned int) link->resource[0]->start, link->irq);
 	    avmcs_release(link);
 	    return -ENODEV;
     }
@@ -211,7 +212,7 @@ static int avmcs_config(struct pcmcia_device *link)
 
 static void avmcs_release(struct pcmcia_device *link)
 {
-	b1pcmcia_delcard(link->io.BasePort1, link->irq);
+	b1pcmcia_delcard(link->resource[0]->start, link->irq);
 	pcmcia_disable_device(link);
 } /* avmcs_release */
 
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 49e141e..8889963 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -180,16 +180,18 @@ static int __devinit avma1cs_config(struct pcmcia_device *link)
     }
 
     printk(KERN_NOTICE "avma1_cs: checking at i/o %#x, irq %d\n",
-				link->io.BasePort1, link->irq);
+		(unsigned int) link->resource[0]->start, link->irq);
 
     icard.para[0] = link->irq;
-    icard.para[1] = link->io.BasePort1;
+    icard.para[1] = link->resource[0]->start;
     icard.protocol = isdnprot;
     icard.typ = ISDN_CTYPE_A1_PCMCIA;
     
     i = hisax_init_pcmcia(link, &busy, &icard);
     if (i < 0) {
-    	printk(KERN_ERR "avma1_cs: failed to initialize AVM A1 PCMCIA %d at i/o %#x\n", i, link->io.BasePort1);
+	printk(KERN_ERR "avma1_cs: failed to initialize AVM A1 "
+			"PCMCIA %d at i/o %#x\n", i,
+			(unsigned int) link->resource[0]->start);
 	avma1cs_release(link);
 	return -ENODEV;
     }
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 425deea..c10bfd3 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -214,23 +214,21 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
 	    link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	printk(", irq %d", link->irq);
-    if (link->io.NumPorts1)
-        printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-               link->io.BasePort1+link->io.NumPorts1-1);
-    if (link->io.NumPorts2)
-        printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-               link->io.BasePort2+link->io.NumPorts2-1);
+    if (link->resource[0])
+	printk(" & %pR", link->resource[0]);
+    if (link->resource[1])
+	printk(" & %pR", link->resource[1]);
     printk("\n");
 
     icard.para[0] = link->irq;
-    icard.para[1] = link->io.BasePort1;
+    icard.para[1] = link->resource[0]->start;
     icard.protocol = protocol;
     icard.typ = ISDN_CTYPE_ELSA_PCMCIA;
     
     i = hisax_init_pcmcia(link, &(((local_info_t*)link->priv)->busy), &icard);
     if (i < 0) {
-    	printk(KERN_ERR "elsa_cs: failed to initialize Elsa PCMCIA %d at i/o %#x\n",
-    		i, link->io.BasePort1);
+	printk(KERN_ERR "elsa_cs: failed to initialize Elsa "
+		"PCMCIA %d with %pR\n", i, link->resource[0]);
     	elsa_cs_release(link);
     } else
     	((local_info_t*)link->priv)->cardnr = i;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 5dbad96..cecb35a 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -296,27 +296,25 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
 	printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	printk(", irq %d", link->irq);
-    if (link->io.NumPorts1)
-	printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-	       link->io.BasePort1+link->io.NumPorts1-1);
-    if (link->io.NumPorts2)
-	printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-	       link->io.BasePort2+link->io.NumPorts2-1);
+    if (link->resource[0])
+	printk(" & %pR", link->resource[0]);
+    if (link->resource[1])
+	printk(" & %pR", link->resource[1]);
     if (link->win)
 	printk(", mem 0x%06lx-0x%06lx", req->Base,
 	       req->Base+req->Size-1);
     printk("\n");
 
     icard.para[0] = link->irq;
-    icard.para[1] = link->io.BasePort1;
+    icard.para[1] = link->resource[0]->start;
     icard.protocol = protocol;
     icard.typ = ISDN_CTYPE_SEDLBAUER_PCMCIA;
     
     ret = hisax_init_pcmcia(link, 
 			    &(((local_info_t *)link->priv)->stop), &icard);
     if (ret < 0) {
-	printk(KERN_ERR "sedlbauer_cs: failed to initialize SEDLBAUER PCMCIA %d at i/o %#x\n",
-		ret, link->io.BasePort1);
+	printk(KERN_ERR "sedlbauer_cs: failed to initialize SEDLBAUER PCMCIA %d with %pR\n",
+		ret, link->resource[0]);
     	sedlbauer_release(link);
 	return -ENODEV;
     } else
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index d3fb1b7..3787fc7 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -194,23 +194,21 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
 	    link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	    printk(", irq %d", link->irq);
-    if (link->io.NumPorts1)
-        printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-               link->io.BasePort1+link->io.NumPorts1-1);
-    if (link->io.NumPorts2)
-        printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-               link->io.BasePort2+link->io.NumPorts2-1);
+    if (link->resource[0])
+	printk(" & %pR", link->resource[0]);
+    if (link->resource[1])
+	printk(" & %pR", link->resource[1]);
     printk("\n");
 
     icard.para[0] = link->irq;
-    icard.para[1] = link->io.BasePort1;
+    icard.para[1] = link->resource[0]->start;
     icard.protocol = protocol;
     icard.typ = ISDN_CTYPE_TELESPCMCIA;
     
     i = hisax_init_pcmcia(link, &(((local_info_t*)link->priv)->busy), &icard);
     if (i < 0) {
     	printk(KERN_ERR "teles_cs: failed to initialize Teles PCMCIA %d at i/o %#x\n",
-    		i, link->io.BasePort1);
+			i, (unsigned int) link->resource[0]->start);
     	teles_cs_release(link);
 	return -ENODEV;
     }
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index e249b89..b5ea9b8 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -356,7 +356,7 @@ static int tc574_config(struct pcmcia_device *link)
 		goto failed;
 
 	dev->irq = link->irq;
-	dev->base_addr = link->io.BasePort1;
+	dev->base_addr = link->resource[0]->start;
 
 	ioaddr = dev->base_addr;
 
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index b0772df..122ef4a 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -298,7 +298,7 @@ static int tc589_config(struct pcmcia_device *link)
 	    goto failed;
 
     dev->irq = link->irq;
-    dev->base_addr = link->io.BasePort1;
+    dev->base_addr = link->resource[0]->start;
     ioaddr = dev->base_addr;
     EL3WINDOW(0);
 
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index ee0a6d0..c52fdf3 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -332,7 +332,7 @@ static int axnet_config(struct pcmcia_device *link)
     if (!link->irq)
 	    goto failed;
     
-    if (link->io.NumPorts2 == 8) {
+    if (resource_size(link->resource[1]) == 8) {
 	link->conf.Attributes |= CONF_ENABLE_SPKR;
 	link->conf.Status = CCSR_AUDIO_ENA;
     }
@@ -342,7 +342,7 @@ static int axnet_config(struct pcmcia_device *link)
 	    goto failed;
 
     dev->irq = link->irq;
-    dev->base_addr = link->io.BasePort1;
+    dev->base_addr = link->resource[0]->start;
 
     if (!get_prom(link)) {
 	printk(KERN_NOTICE "axnet_cs: this is not an AX88190 card!\n");
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 99957af..3b53818 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -266,7 +266,7 @@ static int com20020_config(struct pcmcia_device *link)
 	goto failed;
     }
 	
-    ioaddr = dev->base_addr = link->io.BasePort1;
+    ioaddr = dev->base_addr = link->resource[0]->start;
     dev_dbg(&link->dev, "got ioaddr %Xh\n", ioaddr);
 
     dev_dbg(&link->dev, "request IRQ %d\n",
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 95a991b..bba6369 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -315,7 +315,7 @@ static int ungermann_try_io_port(struct pcmcia_device *link)
 	if (ret == 0) {
 	    /* calculate ConfigIndex value */
 	    link->conf.ConfigIndex = 
-		((link->io.BasePort1 & 0x0f0) >> 3) | 0x22;
+		((link->resource[0]->start & 0x0f0) >> 3) | 0x22;
 	    return ret;
 	}
     }
@@ -436,9 +436,9 @@ static int fmvj18x_config(struct pcmcia_device *link)
 	    goto failed;
 
     dev->irq = link->irq;
-    dev->base_addr = link->io.BasePort1;
+    dev->base_addr = link->resource[0]->start;
 
-    if (link->io.BasePort2 != 0) {
+    if (resource_size(link->resource[1]) != 0) {
 	ret = fmvj18x_setup_mfc(link);
 	if (ret != 0) goto failed;
     }
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index c36dcd1..e99abaa 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -231,7 +231,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
     }
-    dev->base_addr = link->io.BasePort1;
+    dev->base_addr = link->resource[0]->start;
 
     ret = pcmcia_request_exclusive_irq(link, ibmtr_interrupt);
     if (ret)
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index c0d85af..9980cbb 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -655,7 +655,7 @@ static int nmclan_config(struct pcmcia_device *link)
 	  goto failed;
 
   dev->irq = link->irq;
-  dev->base_addr = link->io.BasePort1;
+  dev->base_addr = link->resource[0]->start;
 
   ioaddr = dev->base_addr;
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index db6dbda..c9cd237 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -554,7 +554,7 @@ static int pcnet_config(struct pcmcia_device *link)
     if (!link->irq)
 	    goto failed;
 
-    if (link->io.NumPorts2 == 8) {
+    if (resource_size(link->resource[1]) == 8) {
 	link->conf.Attributes |= CONF_ENABLE_SPKR;
 	link->conf.Status = CCSR_AUDIO_ENA;
     }
@@ -566,7 +566,7 @@ static int pcnet_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
     dev->irq = link->irq;
-    dev->base_addr = link->io.BasePort1;
+    dev->base_addr = link->resource[0]->start;
     if (info->flags & HAS_MISC_REG) {
 	if ((if_port == 1) || (if_port == 2))
 	    dev->if_port = if_port;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 88f503a..1b0b323 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -457,7 +457,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     if (pcmcia_loop_config(link, mhz_mfc_config_check, NULL))
 	    return -ENODEV;
 
-    dev->base_addr = link->io.BasePort1;
+    dev->base_addr = link->resource[0]->start;
 
     /* Allocate a memory window, for accessing the ISR */
     req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
@@ -545,7 +545,7 @@ static void mot_config(struct pcmcia_device *link)
     struct net_device *dev = link->priv;
     struct smc_private *smc = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
-    unsigned int iouart = link->io.BasePort2;
+    unsigned int iouart = link->resource[1]->start;
 
     /* Set UART base address and force map with COR bit 1 */
     writeb(iouart & 0xff,        smc->base + MOT_UART + CISREG_IOBASE_0);
@@ -614,7 +614,7 @@ static int smc_config(struct pcmcia_device *link)
     link->io.NumPorts1 = 16;
     i = pcmcia_loop_config(link, smc_configcheck, NULL);
     if (!i)
-	    dev->base_addr = link->io.BasePort1;
+	    dev->base_addr = link->resource[0]->start;
 
     return i;
 }
@@ -666,7 +666,7 @@ static int osi_config(struct pcmcia_device *link)
 	link->io.NumPorts2 = 0;
 	i = pcmcia_request_io(link, &link->io);
     }
-    dev->base_addr = link->io.BasePort1 + 0x10;
+    dev->base_addr = link->resource[0]->start + 0x10;
     return i;
 }
 
@@ -683,7 +683,7 @@ static int osi_load_firmware(struct pcmcia_device *link)
 
 	/* Download the Seven of Diamonds firmware */
 	for (i = 0; i < fw->size; i++) {
-	    outb(fw->data[i], link->io.BasePort1 + 2);
+	    outb(fw->data[i], link->resource[0]->start + 2);
 	    udelay(50);
 	}
 	release_firmware(fw);
@@ -725,12 +725,12 @@ static int osi_setup(struct pcmcia_device *link, u_short manfid, u_short cardid)
 		return rc;
     } else if (manfid == MANFID_OSITECH) {
 	/* Make sure both functions are powered up */
-	set_bits(0x300, link->io.BasePort1 + OSITECH_AUI_PWR);
+	set_bits(0x300, link->resource[0]->start + OSITECH_AUI_PWR);
 	/* Now, turn on the interrupt for both card functions */
-	set_bits(0x300, link->io.BasePort1 + OSITECH_RESET_ISR);
+	set_bits(0x300, link->resource[0]->start + OSITECH_RESET_ISR);
 	dev_dbg(&link->dev, "AUI/PWR: %4.4x RESET/ISR: %4.4x\n",
-	      inw(link->io.BasePort1 + OSITECH_AUI_PWR),
-	      inw(link->io.BasePort1 + OSITECH_RESET_ISR));
+	      inw(link->resource[0]->start + OSITECH_AUI_PWR),
+	      inw(link->resource[0]->start + OSITECH_RESET_ISR));
     }
     return 0;
 }
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index add6c82..1577b00 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -877,13 +877,13 @@ xirc2ps_config(struct pcmcia_device * link)
 	 * the base address of the ethernet port (BasePort1) is written
 	 * to the BAR registers of the modem.
 	 */
-	err = pcmcia_write_config_byte(link, CISREG_IOBASE_0,
-				link->io.BasePort2 & 0xff);
+	err = pcmcia_write_config_byte(link, CISREG_IOBASE_0, (u8)
+				link->resource[1]->start & 0xff);
 	if (err)
 	    goto config_error;
 
-	err = pcmcia_write_config_byte(link, CISREG_IOBASE_1,
-				link->io.BasePort2 & 0xff);
+	err = pcmcia_write_config_byte(link, CISREG_IOBASE_1, (u8)
+				link->resource[1]->start & 0xff);
 	if (err)
 	    goto config_error;
 
@@ -907,7 +907,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	 * part.
 	 */
 	writeb(0x47, local->dingo_ccr + CISREG_COR);
-	ioaddr = link->io.BasePort1;
+	ioaddr = link->resource[0]->start;
 	writeb(ioaddr & 0xff	  , local->dingo_ccr + CISREG_IOBASE_0);
 	writeb((ioaddr >> 8)&0xff , local->dingo_ccr + CISREG_IOBASE_1);
 
@@ -954,7 +954,7 @@ xirc2ps_config(struct pcmcia_device * link)
 
     /* we can now register the device with the net subsystem */
     dev->irq = link->irq;
-    dev->base_addr = link->io.BasePort1;
+    dev->base_addr = link->resource[0]->start;
 
     if (local->dingo)
 	do_reset(dev, 1); /* a kludge to make the cem56 work */
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 9389ba0..b7e7f50 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -271,7 +271,7 @@ static int airo_config(struct pcmcia_device *link)
 		goto failed;
 	((local_info_t *)link->priv)->eth_dev =
 		init_airo_card(link->irq,
-			       link->io.BasePort1, 1, &link->dev);
+			       link->resource[0]->start, 1, &link->dev);
 	if (!((local_info_t *)link->priv)->eth_dev)
 		goto failed;
 
@@ -281,12 +281,10 @@ static int airo_config(struct pcmcia_device *link)
 	if (link->conf.Vpp)
 		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
 	printk(", irq %d", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1+link->io.NumPorts1-1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2+link->io.NumPorts2-1);
+	if (link->resource[0])
+		printk(" & %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	if (link->win)
 		printk(", mem 0x%06lx-0x%06lx", req->Base,
 		       req->Base+req->Size-1);
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 91ee74a..65b3aed 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -253,7 +253,7 @@ static int atmel_config(struct pcmcia_device *link)
 
 	((local_info_t*)link->priv)->eth_dev =
 		init_atmel_card(link->irq,
-				link->io.BasePort1,
+				link->resource[0]->start,
 				did ? did->driver_info : ATMEL_FW_TYPE_NONE,
 				&link->dev,
 				card_present,
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index def63bf..6db7fd1 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -227,7 +227,7 @@ static void sandisk_set_iobase(local_info_t *local)
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
 
 	res = pcmcia_write_config_byte(hw_priv->link, 0x10,
-				hw_priv->link->io.BasePort1 & 0x00ff);
+				hw_priv->link->resource[0]->start & 0x00ff);
 	if (res != 0) {
 		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 0 -"
 		       " res=%d\n", res);
@@ -235,7 +235,7 @@ static void sandisk_set_iobase(local_info_t *local)
 	udelay(10);
 
 	res = pcmcia_write_config_byte(hw_priv->link, 0x12,
-				hw_priv->link->io.BasePort1 & 0x00ff);
+				hw_priv->link->resource[0]->start & 0x00ff);
 	if (res != 0) {
 		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 1 -"
 		       " res=%d\n", res);
@@ -265,7 +265,7 @@ static int sandisk_enable_wireless(struct net_device *dev)
 	local_info_t *local = iface->local;
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
 
-	if (hw_priv->link->io.NumPorts1 < 0x42) {
+	if (resource_size(hw_priv->link->resource[0]) < 0x42) {
 		/* Not enough ports to be SanDisk multi-function card */
 		ret = -ENODEV;
 		goto done;
@@ -604,7 +604,7 @@ static int prism2_config(struct pcmcia_device *link)
 		goto failed_unlock;
 
 	dev->irq = link->irq;
-	dev->base_addr = link->io.BasePort1;
+	dev->base_addr = link->resource[0]->start;
 
 	spin_unlock_irqrestore(&local->irq_init_lock, flags);
 
@@ -616,12 +616,10 @@ static int prism2_config(struct pcmcia_device *link)
 		       link->conf.Vpp % 10);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1+link->io.NumPorts1-1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2+link->io.NumPorts2-1);
+	if (link->resource[0])
+		printk(" & %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	printk("\n");
 
 	local->shutdown = 0;
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 1d3a7e0..be4c475 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -853,7 +853,8 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 		goto out1;
 
 	/* Initialize io access */
-	card->iobase = ioport_map(p_dev->io.BasePort1, p_dev->io.NumPorts1);
+	card->iobase = ioport_map(p_dev->resource[0]->start,
+				resource_size(p_dev->resource[0]));
 	if (!card->iobase) {
 		lbs_pr_err("error in ioport_map\n");
 		ret = -EIO;
@@ -872,9 +873,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	}
 
 	/* Finally, report what we've done */
-	lbs_deb_cs("irq %d, io 0x%04x-0x%04x\n",
-	       p_dev->irq, p_dev->io.BasePort1,
-	       p_dev->io.BasePort1 + p_dev->io.NumPorts1 - 1);
+	lbs_deb_cs("irq %d, io %pR", p_dev->irq, p_dev->resource[0]);
 
 	/*
 	 * Most of the libertas cards can do unaligned register access, but some
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 41ca4f1..6d514b5 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -257,7 +257,8 @@ orinoco_cs_config(struct pcmcia_device *link)
 	/* We initialize the hermes structure before completing PCMCIA
 	 * configuration just in case the interrupt handler gets
 	 * called. */
-	mem = ioport_map(link->io.BasePort1, link->io.NumPorts1);
+	mem = ioport_map(link->resource[0]->start,
+			resource_size(link->resource[0]));
 	if (!mem)
 		goto failed;
 
@@ -279,7 +280,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 	}
 
 	/* Register an interface with the stack */
-	if (orinoco_if_add(priv, link->io.BasePort1,
+	if (orinoco_if_add(priv, link->resource[0]->start,
 			   link->irq, NULL) != 0) {
 		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
 		goto failed;
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 39399cd..4f8f55e 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -319,7 +319,8 @@ spectrum_cs_config(struct pcmcia_device *link)
 	/* We initialize the hermes structure before completing PCMCIA
 	 * configuration just in case the interrupt handler gets
 	 * called. */
-	mem = ioport_map(link->io.BasePort1, link->io.NumPorts1);
+	mem = ioport_map(link->resource[0]->start,
+			resource_size(link->resource[0]));
 	if (!mem)
 		goto failed;
 
@@ -346,7 +347,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 	}
 
 	/* Register an interface with the stack */
-	if (orinoco_if_add(priv, link->io.BasePort1,
+	if (orinoco_if_add(priv, link->resource[0]->start,
 			   link->irq, NULL) != 0) {
 		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
 		goto failed;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 35f431b..a32f220 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1960,7 +1960,7 @@ static int wl3501_config(struct pcmcia_device *link)
 		goto failed;
 
 	dev->irq = link->irq;
-	dev->base_addr = link->io.BasePort1;
+	dev->base_addr = link->resource[0]->start;
 	SET_NETDEV_DEV(dev, &link->dev);
 	if (register_netdev(dev)) {
 		printk(KERN_NOTICE "wl3501_cs: register_netdev() failed\n");
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index ee56fd6..fc1639c 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -177,12 +177,14 @@ static int parport_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    p = parport_pc_probe_port(link->io.BasePort1, link->io.BasePort2,
+    p = parport_pc_probe_port(link->resource[0]->start,
+			      link->resource[1]->start,
 			      link->irq, PARPORT_DMA_NONE,
 			      &link->dev, IRQF_SHARED);
     if (p == NULL) {
 	printk(KERN_NOTICE "parport_cs: parport_pc_probe_port() at "
-	       "0x%3x, irq %u failed\n", link->io.BasePort1,
+	       "0x%3x, irq %u failed\n",
+	       (unsigned int) link->resource[0]->start,
 	       link->irq);
 	goto failed;
     }
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index b07b53e..3e040f5 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -167,7 +167,7 @@ static int aha152x_config_cs(struct pcmcia_device *link)
     /* Set configuration options for the aha152x driver */
     memset(&s, 0, sizeof(s));
     s.conf        = "PCMCIA setup";
-    s.io_port     = link->io.BasePort1;
+    s.io_port     = link->resource[0]->start;
     s.irq         = link->irq;
     s.scsiid      = host_id;
     s.reconnect   = reconnect;
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index ee04897..49a9a0a 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -137,10 +137,10 @@ static int fdomain_config(struct pcmcia_device *link)
 	    goto failed;
 
     /* A bad hack... */
-    release_region(link->io.BasePort1, link->io.NumPorts1);
+    release_region(link->resource[0]->start, resource_size(link->resource[0]));
 
     /* Set configuration options for the fdomain driver */
-    sprintf(str, "%d,%d", link->io.BasePort1, link->irq);
+    sprintf(str, "%d,%d", (unsigned int) link->resource[0]->start, link->irq);
     fdomain_setup(str);
 
     host = __fdomain_16x0_detect(&fdomain_driver_template);
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index d414207..964c913 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1719,17 +1719,19 @@ static int nsp_cs_config(struct pcmcia_device *link)
 		goto cs_failed;
 
 	if (free_ports) {
-		if (link->io.BasePort1) {
-			release_region(link->io.BasePort1, link->io.NumPorts1);
+		if (link->resource[0]) {
+			release_region(link->resource[0]->start,
+					resource_size(link->resource[0]);
 		}
-		if (link->io.BasePort2) {
-			release_region(link->io.BasePort2, link->io.NumPorts2);
+		if (link->resource[1]) {
+			release_region(link->resource[1]->start,
+					resource_size(link->resource[1]);
 		}
 	}
 
 	/* Set port and IRQ */
-	data->BaseAddress = link->io.BasePort1;
-	data->NumAddress  = link->io.NumPorts1;
+	data->BaseAddress = link->resource[0]->start;
+	data->NumAddress  = resurce_size(link->resource[0]);
 	data->IrqNumber   = link->irq;
 
 	nsp_dbg(NSP_DEBUG_INIT, "I/O[0x%x+0x%x] IRQ %d",
@@ -1764,13 +1766,10 @@ static int nsp_cs_config(struct pcmcia_device *link)
 	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
 		printk(", irq %d", link->irq);
 	}
-	if (link->io.NumPorts1) {
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1+link->io.NumPorts1-1);
-	}
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2+link->io.NumPorts2-1);
+	if (link->resource[0])
+		printk(", io %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	if (link->win)
 		printk(", mem 0x%06lx-0x%06lx", cfg_mem->req.Base,
 		       cfg_mem->req.Base+cfg_mem->req.Size-1);
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index c1cf7f4..4e2b83f 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -215,18 +215,18 @@ static int qlogic_config(struct pcmcia_device * link)
 
 	if ((info->manf_id == MANFID_MACNICA) || (info->manf_id == MANFID_PIONEER) || (info->manf_id == 0x0098)) {
 		/* set ATAcmd */
-		outb(0xb4, link->io.BasePort1 + 0xd);
-		outb(0x24, link->io.BasePort1 + 0x9);
-		outb(0x04, link->io.BasePort1 + 0xd);
+		outb(0xb4, link->resource[0]->start + 0xd);
+		outb(0x24, link->resource[0]->start + 0x9);
+		outb(0x04, link->resource[0]->start + 0xd);
 	}
 
 	/* The KXL-810AN has a bigger IO port window */
-	if (link->io.NumPorts1 == 32)
+	if (resource_size(link->resource[0]) == 32)
 		host = qlogic_detect(&qlogicfas_driver_template, link,
-			link->io.BasePort1 + 16, link->irq);
+			link->resource[0]->start + 16, link->irq);
 	else
 		host = qlogic_detect(&qlogicfas_driver_template, link,
-			link->io.BasePort1, link->irq);
+			link->resource[0]->start, link->irq);
 	
 	if (!host) {
 		printk(KERN_INFO "%s: no SCSI devices found\n", qlogic_name);
@@ -268,9 +268,9 @@ static int qlogic_resume(struct pcmcia_device *link)
 	if ((info->manf_id == MANFID_MACNICA) ||
 	    (info->manf_id == MANFID_PIONEER) ||
 	    (info->manf_id == 0x0098)) {
-		outb(0x80, link->io.BasePort1 + 0xd);
-		outb(0x24, link->io.BasePort1 + 0x9);
-		outb(0x04, link->io.BasePort1 + 0xd);
+		outb(0x80, link->resource[0]->start + 0xd);
+		outb(0x24, link->resource[0]->start + 0x9);
+		outb(0x04, link->resource[0]->start + 0xd);
 	}
 	/* Ugggglllyyyy!!! */
 	qlogicfas408_bus_reset(NULL);
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index bd79e45..d99c0cb 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -733,9 +733,9 @@ SYM53C500_config(struct pcmcia_device *link)
 	    (info->manf_id == MANFID_PIONEER) ||
 	    (info->manf_id == 0x0098)) {
 		/* set ATAcmd */
-		outb(0xb4, link->io.BasePort1 + 0xd);
-		outb(0x24, link->io.BasePort1 + 0x9);
-		outb(0x04, link->io.BasePort1 + 0xd);
+		outb(0xb4, link->resource[0]->start + 0xd);
+		outb(0x24, link->resource[0]->start + 0x9);
+		outb(0x04, link->resource[0]->start + 0xd);
 	}
 
 	/*
@@ -748,7 +748,7 @@ SYM53C500_config(struct pcmcia_device *link)
 	*	0x130, 0x230, 0x280, 0x290,
 	*	0x320, 0x330, 0x340, 0x350
 	*/
-	port_base = link->io.BasePort1;
+	port_base = link->resource[0]->start;
 	irq_level = link->irq;
 
 	DEB(printk("SYM53C500: port_base=0x%x, irq=%d, fast_pio=%d\n",
@@ -821,15 +821,15 @@ static int sym53c500_resume(struct pcmcia_device *link)
 	if ((info->manf_id == MANFID_MACNICA) ||
 	    (info->manf_id == MANFID_PIONEER) ||
 	    (info->manf_id == 0x0098)) {
-		outb(0x80, link->io.BasePort1 + 0xd);
-		outb(0x24, link->io.BasePort1 + 0x9);
-		outb(0x04, link->io.BasePort1 + 0xd);
+		outb(0x80, link->resource[0]->start + 0xd);
+		outb(0x24, link->resource[0]->start + 0x9);
+		outb(0x04, link->resource[0]->start + 0xd);
 	}
 	/*
 	 *  If things don't work after a "resume",
 	 *  this is a good place to start looking.
 	 */
-	SYM53C500_int_host_reset(link->io.BasePort1);
+	SYM53C500_int_host_reset(link->resource[0]->start);
 
 	return 0;
 }
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 2be8b10..fe7adcd 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -463,13 +463,13 @@ static int simple_config(struct pcmcia_device *link)
 	/* If the card is already configured, look up the port and irq */
 	if (link->function_config) {
 		unsigned int port = 0;
-		if ((link->io.BasePort2 != 0) &&
-		    (link->io.NumPorts2 == 8)) {
-			port = link->io.BasePort2;
+		if ((link->resource[1]->end != 0) &&
+			(resource_size(link->resource[1]) == 8)) {
+			port = link->resource[1]->end;
 			info->slave = 1;
 		} else if ((info->manfid == MANFID_OSITECH) &&
-			   (link->io.NumPorts1 == 0x40)) {
-			port = link->io.BasePort1 + 0x28;
+			(resource_size(link->resource[0]) == 0x40)) {
+			port = link->resource[0]->start + 0x28;
 			info->slave = 1;
 		}
 		if (info->slave) {
@@ -507,7 +507,7 @@ found_port:
 	i = pcmcia_request_configuration(link, &link->conf);
 	if (i != 0)
 		return -1;
-	return setup_serial(link, info, link->io.BasePort1, link->irq);
+	return setup_serial(link, info, link->resource[0]->start, link->irq);
 }
 
 static int multi_config_check(struct pcmcia_device *p_dev,
@@ -524,7 +524,7 @@ static int multi_config_check(struct pcmcia_device *p_dev,
 		p_dev->io.BasePort1 = cf->io.win[0].base;
 		p_dev->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
 		if (!pcmcia_request_io(p_dev, &p_dev->io)) {
-			*base2 = p_dev->io.BasePort1 + 8;
+			*base2 = p_dev->resource[0]->start + 8;
 			return 0;
 		}
 	}
@@ -544,7 +544,7 @@ static int multi_config_check_notpicky(struct pcmcia_device *p_dev,
 		p_dev->io.BasePort2 = cf->io.win[1].base;
 		p_dev->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
 		if (!pcmcia_request_io(p_dev, &p_dev->io)) {
-			*base2 = p_dev->io.BasePort2;
+			*base2 = p_dev->resource[1]->start;
 			return 0;
 		}
 	}
@@ -596,9 +596,9 @@ static int multi_config(struct pcmcia_device *link)
 		    link->conf.ConfigIndex == 3) {
 			err = setup_serial(link, info, base2,
 					link->irq);
-			base2 = link->io.BasePort1;
+			base2 = link->resource[0]->start;;
 		} else {
-			err = setup_serial(link, info, link->io.BasePort1,
+			err = setup_serial(link, info, link->resource[0]->start,
 					link->irq);
 		}
 		info->c950ctrl = base2;
@@ -613,7 +613,7 @@ static int multi_config(struct pcmcia_device *link)
 		return 0;
 	}
 
-	setup_serial(link, info, link->io.BasePort1, link->irq);
+	setup_serial(link, info, link->resource[0]->start, link->irq);
 	for (i = 0; i < info->multi - 1; i++)
 		setup_serial(link, info, base2 + (8 * i),
 				link->irq);
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index acef29c..208f1b7 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -170,7 +170,7 @@ static int das16cs_attach(struct comedi_device *dev,
 	if (!link)
 		return -EIO;
 
-	dev->iobase = link->io.BasePort1;
+	dev->iobase = link->resource[0]->start;;
 	printk("I/O base=0x%04lx ", dev->iobase);
 
 	printk("fingerprint:\n");
@@ -787,12 +787,10 @@ static void das16cs_pcmcia_config(struct pcmcia_device *link)
 	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %u", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
+	if (link->resource[0])
+		printk(", io %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(", io %pR", link->resource[1]);
 	printk("\n");
 
 	return;
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index 3eddb7c..c4cfcff 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -88,7 +88,7 @@ static int das08_cs_attach(struct comedi_device *dev,
 			printk(" no pcmcia cards found\n");
 			return -EIO;
 		}
-		iobase = link->io.BasePort1;
+		iobase = link->resource[0]->start;
 	} else {
 		printk(" bug! board does not have PCMCIA bustype\n");
 		return -EINVAL;
@@ -283,12 +283,10 @@ static void das08_pcmcia_config(struct pcmcia_device *link)
 	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %u", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
+	if (link->resource[0])
+		printk(", io %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	printk("\n");
 
 	return;
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index f3c4d2f..6d56957 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -376,7 +376,7 @@ static int dio700_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 		link = pcmcia_cur_dev;	/* XXX hack */
 		if (!link)
 			return -EIO;
-		iobase = link->io.BasePort1;
+		iobase = link->resource[0]->start;
 #ifdef incomplete
 		irq = link->irq;
 #endif
@@ -644,12 +644,10 @@ static void dio700_config(struct pcmcia_device *link)
 	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
+	if (link->resource[0])
+		printk(", io %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	if (link->win)
 		printk(", mem 0x%06lx-0x%06lx", req.Base,
 		       req.Base + req.Size - 1);
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index f0c4367..29e1daf 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -128,7 +128,7 @@ static int dio24_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 		link = pcmcia_cur_dev;	/* XXX hack */
 		if (!link)
 			return -EIO;
-		iobase = link->io.BasePort1;
+		iobase = link->resource[0]->start;
 #ifdef incomplete
 		irq = link->irq;
 #endif
@@ -396,12 +396,10 @@ static void dio24_config(struct pcmcia_device *link)
 	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
+	if (link->resource[0])
+		printk(" & %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	if (link->win)
 		printk(", mem 0x%06lx-0x%06lx", req.Base,
 		       req.Base + req.Size - 1);
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 1ee78f8..fb10987 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -142,7 +142,7 @@ static int labpc_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 		link = pcmcia_cur_dev;	/* XXX hack */
 		if (!link)
 			return -EIO;
-		iobase = link->io.BasePort1;
+		iobase = link->resource[0]->start;
 		irq = link->irq;
 		break;
 	default:
@@ -373,12 +373,10 @@ static void labpc_config(struct pcmcia_device *link)
 	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
+	if (link->resource[0])
+		printk(" & %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	if (link->win)
 		printk(", mem 0x%06lx-0x%06lx", req.Base,
 		       req.Base + req.Size - 1);
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index 0bce220..f37dc22 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -355,7 +355,7 @@ static int mio_cs_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 		return -EIO;
 
 	dev->driver = &driver_ni_mio_cs;
-	dev->iobase = link->io.BasePort1;
+	dev->iobase = link->resource[0]->start;
 
 	irq = link->irq;
 
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index 67c0fa6..80b8d57 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -871,7 +871,7 @@ static int daqp_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 		}
 	}
 
-	dev->iobase = local->link->io.BasePort1;
+	dev->iobase = local->link->resource[0]->start;
 
 	ret = alloc_subdevices(dev, 4);
 	if (ret < 0)
@@ -1153,12 +1153,10 @@ static void daqp_cs_config(struct pcmcia_device *link)
 	dev_info(&link->dev, "index 0x%02x", link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %u", link->irq);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
+	if (link->resource[0])
+		printk(" & %pR", link->resource[0]);
+	if (link->resource[1])
+		printk(" & %pR", link->resource[1]);
 	printk("\n");
 
 	return;
diff --git a/drivers/staging/wlags49_h2/wl_cs.c b/drivers/staging/wlags49_h2/wl_cs.c
index afe4575..2361537 100644
--- a/drivers/staging/wlags49_h2/wl_cs.c
+++ b/drivers/staging/wlags49_h2/wl_cs.c
@@ -319,7 +319,7 @@ void wl_adapter_insert( struct pcmcia_device *link )
         goto failed;
 
     dev->irq        = link->irq;
-    dev->base_addr  = link->io.BasePort1;
+    dev->base_addr  = link->resource[0]->start;
 
     SET_NETDEV_DEV(dev, &link->dev);
     if (register_netdev(dev) != 0) {
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index f6c7e6f..a801036 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -150,7 +150,8 @@ static int ixj_config(struct pcmcia_device * link)
 	/*
  	 *	Register the card with the core.
 	 */
-	j = ixj_pcmcia_probe(link->io.BasePort1, link->io.BasePort1 + 0x10);
+	j = ixj_pcmcia_probe(link->resource[0]->start,
+			     link->resource[0]->start + 0x10);
 
 	info->ndev = 1;
 	ixj_get_serial(link, j);
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index acb7e25..22e04f2 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -189,7 +189,7 @@ static int sl811_cs_config(struct pcmcia_device *link)
 		goto failed;
 
 	/* require an IRQ and two registers */
-	if (!link->io.NumPorts1 || link->io.NumPorts1 < 2)
+	if (resource_size(link->resource[0]) < 2)
 		goto failed;
 
 	if (!link->irq)
@@ -204,11 +204,10 @@ static int sl811_cs_config(struct pcmcia_device *link)
 	if (link->conf.Vpp)
 		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
 	printk(", irq %d", link->irq);
-	printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-	       link->io.BasePort1+link->io.NumPorts1-1);
+	printk(", io %pR", link->resource[0]);
 	printk("\n");
 
-	if (sl811_hc_init(parent, link->io.BasePort1, link->irq)
+	if (sl811_hc_init(parent, link->resource[0]->start, link->irq)
 			< 0) {
 failed:
 		printk(KERN_WARNING "sl811_cs_config failed\n");
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index df110df..9f897bc 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -231,7 +231,8 @@ static int pdacf_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	if (snd_pdacf_assign_resources(pdacf, link->io.BasePort1, link->irq) < 0)
+	if (snd_pdacf_assign_resources(pdacf, link->resource[0]->start,
+					link->irq) < 0)
 		goto failed;
 
 	return 0;
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index 624b47a..f23c235 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -241,7 +241,8 @@ static int vxpocket_config(struct pcmcia_device *link)
 	chip->dev = &link->dev;
 	snd_card_set_dev(chip->card, chip->dev);
 
-	if (snd_vxpocket_assign_resources(chip, link->io.BasePort1, link->irq) < 0)
+	if (snd_vxpocket_assign_resources(chip, link->resource[0]->start,
+						link->irq) < 0)
 		goto failed;
 
 	return 0;
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
