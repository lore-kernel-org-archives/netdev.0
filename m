From: Joe Perches <joe@perches.com>
Subject: [PATCH] irda: Convert IRDA_DEBUG to pr_debug
Date: Tue, 11 Nov 2014 14:44:57 -0800
Message-ID: <1415745897.16070.15.camel@perches.com>
References: <1415740421.16070.11.camel@perches.com>
	 <20141111.162257.701721486580745428.davem@davemloft.net>
	 <1415741850.16070.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0075.hostedemail.com ([216.40.44.75]:55786 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752156AbaKKWpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:45:12 -0500
In-Reply-To: <1415741850.16070.13.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the normal kernel debugging mechanism which also
enables dynamic_debug at the same time.

Other miscellanea:

o Remove sysctl for irda_debug
o Remove function tracing like uses (use ftrace instead)
o Coalesce formats
o Realign arguments
o Remove unnecessary OOM messages

Signed-off-by: Joe Perches <joe@perches.com>
---

donauboe does not have normal indentation, unchanged.

 drivers/net/irda/act200l-sir.c        |   8 --
 drivers/net/irda/actisys-sir.c        |   3 +-
 drivers/net/irda/ali-ircc.c           | 206 +++++++++++++------------------
 drivers/net/irda/donauboe.c           |  96 ++++++---------
 drivers/net/irda/girbil-sir.c         |   8 --
 drivers/net/irda/irda-usb.c           |  95 +++++++-------
 drivers/net/irda/irtty-sir.c          |   8 +-
 drivers/net/irda/litelink-sir.c       |   8 --
 drivers/net/irda/ma600-sir.c          |  14 +--
 drivers/net/irda/mcp2120-sir.c        |   8 --
 drivers/net/irda/mcs7780.c            |   8 +-
 drivers/net/irda/nsc-ircc.c           | 163 ++++++++++++------------
 drivers/net/irda/old_belkin-sir.c     |   8 --
 drivers/net/irda/sir_dev.c            |  44 ++++---
 drivers/net/irda/sir_dongle.c         |   4 +-
 drivers/net/irda/smsc-ircc2.c         | 125 ++++++++++---------
 drivers/net/irda/tekram-sir.c         |  12 +-
 drivers/net/irda/toim3232-sir.c       |  12 +-
 drivers/net/irda/via-ircc.c           | 154 ++++++++++-------------
 drivers/net/irda/vlsi_ir.c            |  27 ++--
 drivers/net/irda/w83977af_ir.c        |  68 ++++------
 include/net/irda/irda.h               |  11 --
 include/net/irda/irlap.h              |   2 +-
 net/irda/af_irda.c                    | 209 ++++++++++++++-----------------
 net/irda/discovery.c                  |  12 +-
 net/irda/ircomm/ircomm_core.c         |  50 ++------
 net/irda/ircomm/ircomm_event.c        |  24 ++--
 net/irda/ircomm/ircomm_lmp.c          |  28 +----
 net/irda/ircomm/ircomm_param.c        |  41 +++----
 net/irda/ircomm/ircomm_ttp.c          |  20 +--
 net/irda/ircomm/ircomm_tty.c          |  95 +++++---------
 net/irda/ircomm/ircomm_tty_attach.c   | 106 +++++++---------
 net/irda/ircomm/ircomm_tty_ioctl.c    |  18 +--
 net/irda/irda_device.c                |  16 +--
 net/irda/iriap.c                      |  91 +++++---------
 net/irda/iriap_event.c                |  38 +++---
 net/irda/irias_object.c               |  14 +--
 net/irda/irlan/irlan_client.c         |  64 ++++------
 net/irda/irlan/irlan_client_event.c   |  62 +++-------
 net/irda/irlan/irlan_common.c         |  77 +++---------
 net/irda/irlan/irlan_eth.c            |  24 ++--
 net/irda/irlan/irlan_event.c          |   4 +-
 net/irda/irlan/irlan_filter.c         |  23 ++--
 net/irda/irlan/irlan_provider.c       |  42 +++----
 net/irda/irlan/irlan_provider_event.c |  16 +--
 net/irda/irlap.c                      |  55 ++-------
 net/irda/irlap_event.c                | 225 ++++++++++++++++------------------
 net/irda/irlap_frame.c                |  87 +++++--------
 net/irda/irlmp.c                      | 167 ++++++++++---------------
 net/irda/irlmp_event.c                | 121 ++++++++----------
 net/irda/irlmp_frame.c                |  56 ++++-----
 net/irda/irmod.c                      |  12 --
 net/irda/irnetlink.c                  |   4 +-
 net/irda/irqueue.c                    |  14 +--
 net/irda/irsysctl.c                   |   9 --
 net/irda/irttp.c                      | 127 ++++++++-----------
 net/irda/parameters.c                 |  38 +++---
 net/irda/qos.c                        |  71 +++++------
 net/irda/wrapper.c                    |  22 ++--
 59 files changed, 1244 insertions(+), 1930 deletions(-)

diff --git a/drivers/net/irda/act200l-sir.c b/drivers/net/irda/act200l-sir.c
index a911645..e891751 100644
--- a/drivers/net/irda/act200l-sir.c
+++ b/drivers/net/irda/act200l-sir.c
@@ -107,8 +107,6 @@ static int act200l_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Power on the dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -124,8 +122,6 @@ static int act200l_open(struct sir_dev *dev)
 
 static int act200l_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Power off the dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
@@ -143,8 +139,6 @@ static int act200l_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 control[3];
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Clear DTR and set RTS to enter command mode */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
 
@@ -212,8 +206,6 @@ static int act200l_reset(struct sir_dev *dev)
 	};
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
 		/* Reset the dongle : set RTS low for 25 ms */
diff --git a/drivers/net/irda/actisys-sir.c b/drivers/net/irda/actisys-sir.c
index 50b2141..e224b8b 100644
--- a/drivers/net/irda/actisys-sir.c
+++ b/drivers/net/irda/actisys-sir.c
@@ -165,8 +165,7 @@ static int actisys_change_speed(struct sir_dev *dev, unsigned speed)
 	int ret = 0;
 	int i = 0;
 
-        IRDA_DEBUG(4, "%s(), speed=%d (was %d)\n", __func__,
-        	speed, dev->speed);
+	pr_debug("%s(), speed=%d (was %d)\n", __func__, speed, dev->speed);
 
 	/* dongle was already resetted from irda_request state machine,
 	 * we are in known state (dongle default)
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 7f23e5f..588680a 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -154,8 +154,6 @@ static int __init ali_ircc_init(void)
 	int reg, revision;
 	int i = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
-
 	ret = platform_driver_register(&ali_ircc_driver);
         if (ret) {
 		net_err_ratelimited("%s, Can't register driver!\n",
@@ -168,7 +166,7 @@ static int __init ali_ircc_init(void)
 	/* Probe for all the ALi chipsets we know about */
 	for (chip= chips; chip->name; chip++, i++) 
 	{
-		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __func__, chip->name);
+		pr_debug("%s(), Probing for %s ...\n", __func__, chip->name);
 				
 		/* Try all config registers for this chip */
 		for (cfg=0; cfg<2; cfg++)
@@ -198,12 +196,13 @@ static int __init ali_ircc_init(void)
 				
 			if (reg == chip->cid_value)
 			{
-				IRDA_DEBUG(2, "%s(), Chip found at 0x%03x\n", __func__, cfg_base);
+				pr_debug("%s(), Chip found at 0x%03x\n",
+					 __func__, cfg_base);
 					   
 				outb(0x1F, cfg_base);
 				revision = inb(cfg_base+1);
-				IRDA_DEBUG(2, "%s(), Found %s chip, revision=%d\n", __func__,
-					   chip->name, revision);					
+				pr_debug("%s(), Found %s chip, revision=%d\n",
+					 __func__, chip->name, revision);
 				
 				/* 
 				 * If the user supplies the base address, then
@@ -225,15 +224,14 @@ static int __init ali_ircc_init(void)
 			}
 			else
 			{
-				IRDA_DEBUG(2, "%s(), No %s chip at 0x%03x\n", __func__, chip->name, cfg_base);
+				pr_debug("%s(), No %s chip at 0x%03x\n",
+					 __func__, chip->name, cfg_base);
 			}
 			/* Exit configuration */
 			outb(0xbb, cfg_base);
 		}
 	}		
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
-
 	if (ret)
 		platform_driver_unregister(&ali_ircc_driver);
 
@@ -250,8 +248,6 @@ static void __exit ali_ircc_cleanup(void)
 {
 	int i;
 
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
-
 	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			ali_ircc_close(dev_self[i]);
@@ -259,7 +255,6 @@ static void __exit ali_ircc_cleanup(void)
 	
 	platform_driver_unregister(&ali_ircc_driver);
 
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 }
 
 static const struct net_device_ops ali_ircc_sir_ops = {
@@ -289,8 +284,6 @@ static int ali_ircc_open(int i, chipio_t *info)
 	int dongle_id;
 	int err;
 			
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
-
 	if (i >= ARRAY_SIZE(dev_self)) {
 		net_err_ratelimited("%s(), maximum number of supported chips reached!\n",
 				    __func__);
@@ -394,7 +387,6 @@ static int ali_ircc_open(int i, chipio_t *info)
 		
 	self->io.dongle_id = dongle_id;
 
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 	
 	return 0;
 
@@ -423,8 +415,6 @@ static int __exit ali_ircc_close(struct ali_ircc_cb *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
         iobase = self->io.fir_base;
@@ -433,7 +423,7 @@ static int __exit ali_ircc_close(struct ali_ircc_cb *self)
 	unregister_netdev(self->netdev);
 
 	/* Release the PORT that this driver is using */
-	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", __func__, self->io.fir_base);
+	pr_debug("%s(), Releasing Region %03x\n", __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -447,7 +437,6 @@ static int __exit ali_ircc_close(struct ali_ircc_cb *self)
 	dev_self[self->index] = NULL;
 	free_netdev(self->netdev);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 	
 	return 0;
 }
@@ -490,7 +479,6 @@ static int ali_ircc_probe_53(ali_chip_t *chip, chipio_t *info)
 	int cfg_base = info->cfg_base;
 	int hi, low, reg;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	/* Enter Configuration */
 	outb(chip->entr1, cfg_base);
@@ -509,13 +497,13 @@ static int ali_ircc_probe_53(ali_chip_t *chip, chipio_t *info)
 	
 	info->sir_base = info->fir_base;
 	
-	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __func__, info->fir_base);
+	pr_debug("%s(), probing fir_base=0x%03x\n", __func__, info->fir_base);
 		
 	/* Read IRQ control register */
 	outb(0x70, cfg_base);
 	reg = inb(cfg_base+1);
 	info->irq = reg & 0x0f;
-	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __func__, info->irq);
+	pr_debug("%s(), probing irq=%d\n", __func__, info->irq);
 	
 	/* Read DMA channel */
 	outb(0x74, cfg_base);
@@ -526,24 +514,23 @@ static int ali_ircc_probe_53(ali_chip_t *chip, chipio_t *info)
 		net_warn_ratelimited("%s(), No DMA channel assigned !\n",
 				     __func__);
 	else
-		IRDA_DEBUG(2, "%s(), probing dma=%d\n", __func__, info->dma);
+		pr_debug("%s(), probing dma=%d\n", __func__, info->dma);
 	
 	/* Read Enabled Status */
 	outb(0x30, cfg_base);
 	reg = inb(cfg_base+1);
 	info->enabled = (reg & 0x80) && (reg & 0x01);
-	IRDA_DEBUG(2, "%s(), probing enabled=%d\n", __func__, info->enabled);
+	pr_debug("%s(), probing enabled=%d\n", __func__, info->enabled);
 	
 	/* Read Power Status */
 	outb(0x22, cfg_base);
 	reg = inb(cfg_base+1);
 	info->suspended = (reg & 0x20);
-	IRDA_DEBUG(2, "%s(), probing suspended=%d\n", __func__, info->suspended);
+	pr_debug("%s(), probing suspended=%d\n", __func__, info->suspended);
 	
 	/* Exit configuration */
 	outb(0xbb, cfg_base);
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 	
 	return 0;	
 }
@@ -561,7 +548,6 @@ static int ali_ircc_setup(chipio_t *info)
 	int version;
 	int iobase = info->fir_base;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	/* Locking comments :
 	 * Most operations here need to be protected. We are called before
@@ -622,7 +608,6 @@ static int ali_ircc_setup(chipio_t *info)
 	// outb(UART_IER_RDI, iobase+UART_IER); //benjamin 2000/11/23 01:25PM
 	// Turn on the interrupts in ali_ircc_net_open
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 	
 	return 0;
 }
@@ -639,7 +624,6 @@ static int ali_ircc_read_dongle_id (int i, chipio_t *info)
 	int dongle_id, reg;
 	int cfg_base = info->cfg_base;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
 	/* Enter Configuration */
 	outb(chips[i].entr1, cfg_base);
@@ -653,13 +637,12 @@ static int ali_ircc_read_dongle_id (int i, chipio_t *info)
 	outb(0xf0, cfg_base);
 	reg = inb(cfg_base+1);	
 	dongle_id = ((reg>>6)&0x02) | ((reg>>5)&0x01);
-	IRDA_DEBUG(2, "%s(), probing dongle_id=%d, dongle_types=%s\n", __func__,
-		dongle_id, dongle_types[dongle_id]);
+	pr_debug("%s(), probing dongle_id=%d, dongle_types=%s\n",
+		 __func__, dongle_id, dongle_types[dongle_id]);
 	
 	/* Exit configuration */
 	outb(0xbb, cfg_base);
 			
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 	
 	return dongle_id;
 }
@@ -676,7 +659,6 @@ static irqreturn_t ali_ircc_interrupt(int irq, void *dev_id)
 	struct ali_ircc_cb *self;
 	int ret;
 		
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
 	self = netdev_priv(dev);
 	
@@ -690,7 +672,6 @@ static irqreturn_t ali_ircc_interrupt(int irq, void *dev_id)
 		
 	spin_unlock(&self->lock);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 	return ret;
 }
 /*
@@ -704,7 +685,6 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 	__u8 eir, OldMessageCount;
 	int iobase, tmp;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	iobase = self->io.fir_base;
 	
@@ -717,10 +697,10 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 	//self->ier = inb(iobase+FIR_IER); 		2000/12/1 04:32PM
 	eir = self->InterruptID & self->ier; /* Mask out the interesting ones */ 
 	
-	IRDA_DEBUG(1, "%s(), self->InterruptID = %x\n", __func__,self->InterruptID);
-	IRDA_DEBUG(1, "%s(), self->LineStatus = %x\n", __func__,self->LineStatus);
-	IRDA_DEBUG(1, "%s(), self->ier = %x\n", __func__,self->ier);
-	IRDA_DEBUG(1, "%s(), eir = %x\n", __func__,eir);
+	pr_debug("%s(), self->InterruptID = %x\n", __func__, self->InterruptID);
+	pr_debug("%s(), self->LineStatus = %x\n", __func__, self->LineStatus);
+	pr_debug("%s(), self->ier = %x\n", __func__, self->ier);
+	pr_debug("%s(), eir = %x\n", __func__, eir);
 	
 	/* Disable interrupts */
 	 SetCOMInterrupts(self, FALSE);
@@ -731,7 +711,8 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 	{		
 		if (self->io.direction == IO_XMIT) /* TX */
 		{
-			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Tx) *******\n", __func__);
+			pr_debug("%s(), ******* IIR_EOM (Tx) *******\n",
+				 __func__);
 			
 			if(ali_ircc_dma_xmit_complete(self))
 			{
@@ -750,23 +731,27 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 		}	
 		else /* RX */
 		{
-			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Rx) *******\n", __func__);
+			pr_debug("%s(), ******* IIR_EOM (Rx) *******\n",
+				 __func__);
 			
 			if(OldMessageCount > ((self->LineStatus+1) & 0x07))
 			{
 				self->rcvFramesOverflow = TRUE;	
-				IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ********\n", __func__);
+				pr_debug("%s(), ******* self->rcvFramesOverflow = TRUE ********\n",
+					 __func__);
 			}
 						
 			if (ali_ircc_dma_receive_complete(self))
 			{
-				IRDA_DEBUG(1, "%s(), ******* receive complete ********\n", __func__);
+				pr_debug("%s(), ******* receive complete ********\n",
+					 __func__);
 				
 				self->ier = IER_EOM;				
 			}
 			else
 			{
-				IRDA_DEBUG(1, "%s(), ******* Not receive complete ********\n", __func__);
+				pr_debug("%s(), ******* Not receive complete ********\n",
+					 __func__);
 				
 				self->ier = IER_EOM | IER_TIMER;								
 			}	
@@ -779,7 +764,8 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 		if(OldMessageCount > ((self->LineStatus+1) & 0x07))
 		{
 			self->rcvFramesOverflow = TRUE;	
-			IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE *******\n", __func__);
+			pr_debug("%s(), ******* self->rcvFramesOverflow = TRUE *******\n",
+				 __func__);
 		}
 		/* Disable Timer */
 		switch_bank(iobase, BANK1);
@@ -811,7 +797,6 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 	/* Restore Interrupt */	
 	SetCOMInterrupts(self, TRUE);	
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ---------------\n", __func__);
 	return IRQ_RETVAL(eir);
 }
 
@@ -826,7 +811,6 @@ static irqreturn_t ali_ircc_sir_interrupt(struct ali_ircc_cb *self)
 	int iobase;
 	int iir, lsr;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	iobase = self->io.sir_base;
 
@@ -835,13 +819,13 @@ static irqreturn_t ali_ircc_sir_interrupt(struct ali_ircc_cb *self)
 		/* Clear interrupt */
 		lsr = inb(iobase+UART_LSR);
 
-		IRDA_DEBUG(4, "%s(), iir=%02x, lsr=%02x, iobase=%#x\n", __func__,
-			   iir, lsr, iobase);
+		pr_debug("%s(), iir=%02x, lsr=%02x, iobase=%#x\n",
+			 __func__, iir, lsr, iobase);
 
 		switch (iir) 
 		{
 			case UART_IIR_RLSI:
-				IRDA_DEBUG(2, "%s(), RLSI\n", __func__);
+				pr_debug("%s(), RLSI\n", __func__);
 				break;
 			case UART_IIR_RDI:
 				/* Receive interrupt */
@@ -855,15 +839,14 @@ static irqreturn_t ali_ircc_sir_interrupt(struct ali_ircc_cb *self)
 				}				
 				break;
 			default:
-				IRDA_DEBUG(0, "%s(), unhandled IIR=%#x\n", __func__, iir);
+				pr_debug("%s(), unhandled IIR=%#x\n",
+					 __func__, iir);
 				break;
 		} 
 		
 	}
 	
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
-
 	return IRQ_RETVAL(iir);
 }
 
@@ -879,7 +862,6 @@ static void ali_ircc_sir_receive(struct ali_ircc_cb *self)
 	int boguscount = 0;
 	int iobase;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	IRDA_ASSERT(self != NULL, return;);
 
 	iobase = self->io.sir_base;
@@ -894,12 +876,11 @@ static void ali_ircc_sir_receive(struct ali_ircc_cb *self)
 
 		/* Make sure we don't stay here too long */
 		if (boguscount++ > 32) {
-			IRDA_DEBUG(2,"%s(), breaking!\n", __func__);
+			pr_debug("%s(), breaking!\n", __func__);
 			break;
 		}
 	} while (inb(iobase+UART_LSR) & UART_LSR_DR);	
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 /*
@@ -916,7 +897,6 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	iobase = self->io.sir_base;
 
@@ -935,16 +915,18 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
 		{
 			/* We must wait until all data are gone */
 			while(!(inb(iobase+UART_LSR) & UART_LSR_TEMT))
-				IRDA_DEBUG(1, "%s(), UART_LSR_THRE\n", __func__ );
+				pr_debug("%s(), UART_LSR_THRE\n", __func__);
 			
-			IRDA_DEBUG(1, "%s(), Changing speed! self->new_speed = %d\n", __func__ , self->new_speed);
+			pr_debug("%s(), Changing speed! self->new_speed = %d\n",
+				 __func__, self->new_speed);
 			ali_ircc_change_speed(self, self->new_speed);
 			self->new_speed = 0;			
 			
 			// benjamin 2000/11/10 06:32PM
 			if (self->io.speed > 115200)
 			{
-				IRDA_DEBUG(2, "%s(), ali_ircc_change_speed from UART_LSR_TEMT\n", __func__ );
+				pr_debug("%s(), ali_ircc_change_speed from UART_LSR_TEMT\n",
+					 __func__);
 					
 				self->ier = IER_EOM;
 				// SetCOMInterrupts(self, TRUE);							
@@ -962,7 +944,6 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
 		outb(UART_IER_RDI, iobase+UART_IER);
 	}
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
@@ -970,9 +951,8 @@ static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
 	struct net_device *dev = self->netdev;
 	int iobase;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_DEBUG(2, "%s(), setting speed = %d\n", __func__ , baud);
+	pr_debug("%s(), setting speed = %d\n", __func__, baud);
 	
 	/* This function *must* be called with irq off and spin-lock.
 	 * - Jean II */
@@ -1011,7 +991,6 @@ static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
 		
 	netif_wake_queue(self->netdev);	
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
@@ -1021,14 +1000,14 @@ static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
 	struct ali_ircc_cb *self = priv;
 	struct net_device *dev;
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 		
 	IRDA_ASSERT(self != NULL, return;);
 
 	dev = self->netdev;
 	iobase = self->io.fir_base;
 	
-	IRDA_DEBUG(1, "%s(), self->io.speed = %d, change to speed = %d\n", __func__ ,self->io.speed,baud);
+	pr_debug("%s(), self->io.speed = %d, change to speed = %d\n",
+		 __func__, self->io.speed, baud);
 	
 	/* Come from SIR speed */
 	if(self->io.speed <=115200)
@@ -1042,7 +1021,6 @@ static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
 	// Set Dongle Speed mode
 	ali_ircc_change_dongle_speed(self, baud);
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 /*
@@ -1060,9 +1038,8 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 	int lcr;    /* Line control reg */
 	int divisor;
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_DEBUG(1, "%s(), Setting speed to: %d\n", __func__ , speed);
+	pr_debug("%s(), Setting speed to: %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -1116,7 +1093,6 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 	
 	spin_unlock_irqrestore(&self->lock, flags);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
@@ -1126,14 +1102,14 @@ static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
 	int iobase,dongle_id;
 	int tmp = 0;
 			
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	iobase = self->io.fir_base; 	/* or iobase = self->io.sir_base; */
 	dongle_id = self->io.dongle_id;
 	
 	/* We are already locked, no need to do it again */
 		
-	IRDA_DEBUG(1, "%s(), Set Speed for %s , Speed = %d\n", __func__ , dongle_types[dongle_id], speed);
+	pr_debug("%s(), Set Speed for %s , Speed = %d\n",
+		 __func__, dongle_types[dongle_id], speed);
 	
 	switch_bank(iobase, BANK2);
 	tmp = inb(iobase+FIR_IRDA_CR);
@@ -1297,7 +1273,6 @@ static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
 			
 	switch_bank(iobase, BANK0);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 /*
@@ -1310,11 +1285,10 @@ static int ali_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len)
 {
 	int actual = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 		
 	/* Tx FIFO should be empty! */
 	if (!(inb(iobase+UART_LSR) & UART_LSR_THRE)) {
-		IRDA_DEBUG(0, "%s(), failed, fifo not empty!\n", __func__ );
+		pr_debug("%s(), failed, fifo not empty!\n", __func__);
 		return 0;
 	}
         
@@ -1326,7 +1300,6 @@ static int ali_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len)
 		actual++;
 	}
 	
-        IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	return actual;
 }
 
@@ -1342,7 +1315,6 @@ static int ali_ircc_net_open(struct net_device *dev)
 	int iobase;
 	char hwname[32];
 		
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
@@ -1386,7 +1358,6 @@ static int ali_ircc_net_open(struct net_device *dev)
 	 */
 	self->irlap = irlap_open(dev, &self->qos, hwname);
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return 0;
 }
@@ -1403,7 +1374,6 @@ static int ali_ircc_net_close(struct net_device *dev)
 	struct ali_ircc_cb *self;
 	//int iobase;
 			
-	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __func__ );
 		
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -1426,7 +1396,6 @@ static int ali_ircc_net_close(struct net_device *dev)
 	free_irq(self->io.irq, dev);
 	free_dma(self->io.dma);
 
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return 0;
 }
@@ -1446,7 +1415,6 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 	__u32 speed;
 	int mtt, diff;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	self = netdev_priv(dev);
 	iobase = self->io.fir_base;
@@ -1500,7 +1468,8 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 			diff = self->now.tv_usec - self->stamp.tv_usec;
 			/* self->stamp is set from ali_ircc_dma_receive_complete() */
 							
-			IRDA_DEBUG(1, "%s(), ******* diff = %d *******\n", __func__ , diff);
+			pr_debug("%s(), ******* diff = %d *******\n",
+				 __func__, diff);
 			
 			if (diff < 0) 
 				diff += 1000000;
@@ -1522,7 +1491,8 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 					/* Adjust for timer resolution */
 					mtt = (mtt+250) / 500; 	/* 4 discard, 5 get advanced, Let's round off */
 					
-					IRDA_DEBUG(1, "%s(), ************** mtt = %d ***********\n", __func__ , mtt);
+					pr_debug("%s(), ************** mtt = %d ***********\n",
+						 __func__, mtt);
 					
 					/* Setup timer */
 					if (mtt == 1) /* 500 us */
@@ -1579,7 +1549,6 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return NETDEV_TX_OK;	
 }
 
@@ -1590,7 +1559,6 @@ static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 	unsigned char FIFO_OPTI, Hi, Lo;
 	
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	iobase = self->io.fir_base;
 	
@@ -1641,7 +1609,8 @@ static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 	tmp = inb(iobase+FIR_LCR_B);
 	tmp &= ~0x20; // Disable SIP
 	outb(((unsigned char)(tmp & 0x3f) | LCR_B_TX_MODE) & ~LCR_B_BW, iobase+FIR_LCR_B);
-	IRDA_DEBUG(1, "%s(), *** Change to TX mode: FIR_LCR_B = 0x%x ***\n", __func__ , inb(iobase+FIR_LCR_B));
+	pr_debug("%s(), *** Change to TX mode: FIR_LCR_B = 0x%x ***\n",
+		 __func__, inb(iobase + FIR_LCR_B));
 	
 	outb(0, iobase+FIR_LSR);
 			
@@ -1651,7 +1620,6 @@ static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 	
 	switch_bank(iobase, BANK0); 
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
@@ -1659,7 +1627,6 @@ static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
 	int iobase;
 	int ret = TRUE;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	iobase = self->io.fir_base;
 	
@@ -1716,7 +1683,6 @@ static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
 		
 	switch_bank(iobase, BANK0); 
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return ret;
 }
 
@@ -1731,7 +1697,6 @@ static int ali_ircc_dma_receive(struct ali_ircc_cb *self)
 {
 	int iobase, tmp;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	iobase = self->io.fir_base;
 	
@@ -1769,7 +1734,8 @@ static int ali_ircc_dma_receive(struct ali_ircc_cb *self)
 	//switch_bank(iobase, BANK0);
 	tmp = inb(iobase+FIR_LCR_B);
 	outb((unsigned char)(tmp &0x3f) | LCR_B_RX_MODE | LCR_B_BW , iobase + FIR_LCR_B); // 2000/12/1 05:16PM
-	IRDA_DEBUG(1, "%s(), *** Change To RX mode: FIR_LCR_B = 0x%x ***\n", __func__ , inb(iobase+FIR_LCR_B));
+	pr_debug("%s(), *** Change To RX mode: FIR_LCR_B = 0x%x ***\n",
+		 __func__, inb(iobase + FIR_LCR_B));
 			
 	/* Set Rx Threshold */
 	switch_bank(iobase, BANK1);
@@ -1781,7 +1747,6 @@ static int ali_ircc_dma_receive(struct ali_ircc_cb *self)
 	outb(CR_DMA_EN | CR_DMA_BURST, iobase+FIR_CR);
 				
 	switch_bank(iobase, BANK0); 
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return 0;
 }
 
@@ -1792,8 +1757,6 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 	__u8 status, MessageCount;
 	int len, i, iobase, val;	
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
-
 	st_fifo = &self->st_fifo;		
 	iobase = self->io.fir_base;	
 		
@@ -1801,7 +1764,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 	MessageCount = inb(iobase+ FIR_LSR)&0x07;
 	
 	if (MessageCount > 0)	
-		IRDA_DEBUG(0, "%s(), Message count = %d,\n", __func__ , MessageCount);
+		pr_debug("%s(), Message count = %d\n", __func__, MessageCount);
 		
 	for (i=0; i<=MessageCount; i++)
 	{
@@ -1814,11 +1777,11 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 		len = len << 8; 
 		len |= inb(iobase+FIR_RX_DSR_LO);
 		
-		IRDA_DEBUG(1, "%s(), RX Length = 0x%.2x,\n", __func__ , len);
-		IRDA_DEBUG(1, "%s(), RX Status = 0x%.2x,\n", __func__ , status);
+		pr_debug("%s(), RX Length = 0x%.2x,\n", __func__ , len);
+		pr_debug("%s(), RX Status = 0x%.2x,\n", __func__ , status);
 		
 		if (st_fifo->tail >= MAX_RX_WINDOW) {
-			IRDA_DEBUG(0, "%s(), window is full!\n", __func__ );
+			pr_debug("%s(), window is full!\n", __func__);
 			continue;
 		}
 			
@@ -1841,7 +1804,8 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 		/* Check for errors */
 		if ((status & 0xd8) || self->rcvFramesOverflow || (len==0)) 		
 		{
-			IRDA_DEBUG(0,"%s(), ************* RX Errors ************\n", __func__ );
+			pr_debug("%s(), ************* RX Errors ************\n",
+				 __func__);
 			
 			/* Skip frame */
 			self->netdev->stats.rx_errors++;
@@ -1851,29 +1815,34 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			if (status & LSR_FIFO_UR) 
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* FIFO Errors ************\n", __func__ );
+				pr_debug("%s(), ************* FIFO Errors ************\n",
+					 __func__);
 			}	
 			if (status & LSR_FRAME_ERROR)
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* FRAME Errors ************\n", __func__ );
+				pr_debug("%s(), ************* FRAME Errors ************\n",
+					 __func__);
 			}
 							
 			if (status & LSR_CRC_ERROR) 
 			{
 				self->netdev->stats.rx_crc_errors++;
-				IRDA_DEBUG(0,"%s(), ************* CRC Errors ************\n", __func__ );
+				pr_debug("%s(), ************* CRC Errors ************\n",
+					 __func__);
 			}
 			
 			if(self->rcvFramesOverflow)
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* Overran DMA buffer ************\n", __func__ );
+				pr_debug("%s(), ************* Overran DMA buffer ************\n",
+					 __func__);
 			}
 			if(len == 0)
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ********** Receive Frame Size = 0 *********\n", __func__ );
+				pr_debug("%s(), ********** Receive Frame Size = 0 *********\n",
+					 __func__);
 			}
 		}	 
 		else 
@@ -1885,7 +1854,8 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 				val = inb(iobase+FIR_BSR);	
 				if ((val& BSR_FIFO_NOT_EMPTY)== 0x80) 
 				{
-					IRDA_DEBUG(0, "%s(), ************* BSR_FIFO_NOT_EMPTY ************\n", __func__ );
+					pr_debug("%s(), ************* BSR_FIFO_NOT_EMPTY ************\n",
+						 __func__);
 					
 					/* Put this entry back in fifo */
 					st_fifo->head--;
@@ -1946,7 +1916,6 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 	
 	switch_bank(iobase, BANK0);	
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return TRUE;
 }
 
@@ -1966,7 +1935,6 @@ static netdev_tx_t ali_ircc_sir_hard_xmit(struct sk_buff *skb,
 	int iobase;
 	__u32 speed;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return NETDEV_TX_OK;);
 	
@@ -2015,7 +1983,6 @@ static netdev_tx_t ali_ircc_sir_hard_xmit(struct sk_buff *skb,
 
 	dev_kfree_skb(skb);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return NETDEV_TX_OK;	
 }
@@ -2034,7 +2001,6 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	unsigned long flags;
 	int ret = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -2042,11 +2008,11 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
-		IRDA_DEBUG(1, "%s(), SIOCSBANDWIDTH\n", __func__ );
+		pr_debug("%s(), SIOCSBANDWIDTH\n", __func__);
 		/*
 		 * This function will also be used by IrLAP to change the
 		 * speed, so we still must allow for speed change within
@@ -2060,13 +2026,13 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		spin_unlock_irqrestore(&self->lock, flags);
 		break;
 	case SIOCSMEDIABUSY: /* Set media busy */
-		IRDA_DEBUG(1, "%s(), SIOCSMEDIABUSY\n", __func__ );
+		pr_debug("%s(), SIOCSMEDIABUSY\n", __func__);
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		irda_device_set_media_busy(self->netdev, TRUE);
 		break;
 	case SIOCGRECEIVING: /* Check if we are receiving right now */
-		IRDA_DEBUG(2, "%s(), SIOCGRECEIVING\n", __func__ );
+		pr_debug("%s(), SIOCGRECEIVING\n", __func__);
 		/* This is protected */
 		irq->ifr_receiving = ali_ircc_is_receiving(self);
 		break;
@@ -2074,7 +2040,6 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		ret = -EOPNOTSUPP;
 	}
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return ret;
 }
@@ -2091,7 +2056,6 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 	int status = FALSE;
 	int iobase;		
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	IRDA_ASSERT(self != NULL, return FALSE;);
 
@@ -2105,7 +2069,8 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 		if((inb(iobase+FIR_FIFO_FR) & 0x3f) != 0) 		
 		{
 			/* We are receiving something */
-			IRDA_DEBUG(1, "%s(), We are receiving something\n", __func__ );
+			pr_debug("%s(), We are receiving something\n",
+				 __func__);
 			status = TRUE;
 		}
 		switch_bank(iobase, BANK0);		
@@ -2117,7 +2082,6 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 	
 	spin_unlock_irqrestore(&self->lock, flags);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return status;
 }
@@ -2163,7 +2127,8 @@ static void SetCOMInterrupts(struct ali_ircc_cb *self , unsigned char enable)
 	
 	int iobase = self->io.fir_base; /* or sir_base */
 
-	IRDA_DEBUG(2, "%s(), -------- Start -------- ( Enable = %d )\n", __func__ , enable);
+	pr_debug("%s(), -------- Start -------- ( Enable = %d )\n",
+		 __func__, enable);
 	
 	/* Enable the interrupt which we wish to */
 	if (enable){
@@ -2204,14 +2169,12 @@ static void SetCOMInterrupts(struct ali_ircc_cb *self , unsigned char enable)
 	else
 		outb(newMask, iobase+UART_IER);
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void SIR2FIR(int iobase)
 {
 	//unsigned char tmp;
 		
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	/* Already protected (change_speed() or setup()), no need to lock.
 	 * Jean II */
@@ -2227,14 +2190,12 @@ static void SIR2FIR(int iobase)
 	//tmp |= 0x20;
 	//outb(tmp, iobase+FIR_LCR_B);	
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void FIR2SIR(int iobase)
 {
 	unsigned char val;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	/* Already protected (change_speed() or setup()), no need to lock.
 	 * Jean II */
@@ -2250,7 +2211,6 @@ static void FIR2SIR(int iobase)
 	val = inb(iobase+UART_LSR);
 	val = inb(iobase+UART_MSR);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 MODULE_AUTHOR("Benjamin Kong <benjamin_kong@ali.com.tw>");
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index a87a82c..b337e6d 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -232,7 +232,7 @@ char head=tete;
 for (i=0;i<len;i+=16) {
     for (j=0;j<16 && i+j<len;j++) { sprintf(&dump[3*j],"%02x.",data[i+j]); }
     dump [3*j]=0;
-    IRDA_DEBUG (2, "%c%s\n",head , dump);
+    pr_debug("%c%s\n", head, dump);
     head='+';
     }
 }
@@ -245,8 +245,6 @@ toshoboe_dumpregs (struct toshoboe_cb *self)
 {
   __u32 ringbase;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   ringbase = INB (OBOE_RING_BASE0) << 10;
   ringbase |= INB (OBOE_RING_BASE1) << 18;
   ringbase |= INB (OBOE_RING_BASE2) << 26;
@@ -293,8 +291,6 @@ static void
 toshoboe_disablebm (struct toshoboe_cb *self)
 {
   __u8 command;
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   pci_read_config_byte (self->pdev, PCI_COMMAND, &command);
   command &= ~PCI_COMMAND_MASTER;
   pci_write_config_byte (self->pdev, PCI_COMMAND, command);
@@ -305,8 +301,6 @@ toshoboe_disablebm (struct toshoboe_cb *self)
 static void
 toshoboe_stopchip (struct toshoboe_cb *self)
 {
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   /*Disable interrupts */
   OUTB (0x0, OBOE_IER);
   /*Disable DMA, Disable Rx, Disable Tx */
@@ -350,7 +344,7 @@ toshoboe_setbaud (struct toshoboe_cb *self)
   __u16 pconfig = 0;
   __u8 config0l = 0;
 
-  IRDA_DEBUG (2, "%s(%d/%d)\n", __func__, self->speed, self->io.speed);
+  pr_debug("%s(%d/%d)\n", __func__, self->speed, self->io.speed);
 
   switch (self->speed)
     {
@@ -482,7 +476,6 @@ toshoboe_setbaud (struct toshoboe_cb *self)
 static void
 toshoboe_enablebm (struct toshoboe_cb *self)
 {
-  IRDA_DEBUG (4, "%s()\n", __func__);
   pci_set_master (self->pdev);
 }
 
@@ -492,8 +485,6 @@ toshoboe_initring (struct toshoboe_cb *self)
 {
   int i;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   for (i = 0; i < TX_SLOTS; ++i)
     {
       self->ring->tx[i].len = 0;
@@ -550,8 +541,6 @@ toshoboe_startchip (struct toshoboe_cb *self)
 {
   __u32 physaddr;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   toshoboe_initring (self);
   toshoboe_enablebm (self);
   OUTBP (OBOE_CONFIG1_RESET, OBOE_CONFIG1);
@@ -636,9 +625,8 @@ toshoboe_makemttpacket (struct toshoboe_cb *self, void *buf, int mtt)
   xbofs=xbofs/80000; /*Eight bits per byte, and mtt is in us*/
   xbofs++;
 
-  IRDA_DEBUG (2, DRIVER_NAME
-      ": generated mtt of %d bytes for %d us at %d baud\n"
-	  , xbofs,mtt,self->speed);
+  pr_debug(DRIVER_NAME ": generated mtt of %d bytes for %d us at %d baud\n",
+	   xbofs, mtt, self->speed);
 
   if (xbofs > TX_LEN)
     {
@@ -824,8 +812,6 @@ toshoboe_probe (struct toshoboe_cb *self)
 #endif
   unsigned long flags;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   if (request_irq (self->io.irq, toshoboe_probeinterrupt,
                    self->io.irqflags, "toshoboe", (void *) self))
     {
@@ -983,10 +969,10 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
 
   IRDA_ASSERT (self != NULL, return NETDEV_TX_OK; );
 
-  IRDA_DEBUG (1, "%s.tx:%x(%x)%x\n", __func__
-      ,skb->len,self->txpending,INB (OBOE_ENABLEH));
+  pr_debug("%s.tx:%x(%x)%x\n",
+	   __func__, skb->len, self->txpending, INB(OBOE_ENABLEH));
   if (!cb->magic) {
-      IRDA_DEBUG (2, "%s.Not IrLAP:%x\n", __func__, cb->magic);
+	  pr_debug("%s.Not IrLAP:%x\n", __func__, cb->magic);
 #ifdef DUMP_PACKETS
       _dumpbufs(skb->data,skb->len,'>');
 #endif
@@ -1012,8 +998,8 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
       if (self->txpending || skb->len)
         {
           self->new_speed = speed;
-          IRDA_DEBUG (1, "%s: Queued TxDone scheduled speed change %d\n" ,
-		      __func__, speed);
+	  pr_debug("%s: Queued TxDone scheduled speed change %d\n" ,
+		   __func__, speed);
           /* if no data, that's all! */
           if (!skb->len)
             {
@@ -1055,8 +1041,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
       /* which we will add a wrong checksum to */
 
       mtt = toshoboe_makemttpacket (self, self->tx_bufs[self->txs], mtt);
-      IRDA_DEBUG (1, "%s.mtt:%x(%x)%d\n", __func__
-          ,skb->len,mtt,self->txpending);
+      pr_debug("%s.mtt:%x(%x)%d\n", __func__, skb->len, mtt, self->txpending);
       if (mtt)
         {
           self->ring->tx[self->txs].len = mtt & 0xfff;
@@ -1099,8 +1084,9 @@ dumpbufs(skb->data,skb->len,'>');
 
   if (self->ring->tx[self->txs].control & OBOE_CTL_TX_HW_OWNS)
     {
-      IRDA_DEBUG (0, "%s.ful:%x(%x)%x\n", __func__
-          ,skb->len, self->ring->tx[self->txs].control, self->txpending);
+	    pr_debug("%s.ful:%x(%x)%x\n",
+		     __func__, skb->len, self->ring->tx[self->txs].control,
+		     self->txpending);
       toshoboe_start_DMA(self, OBOE_CONFIG0H_ENTX);
       spin_unlock_irqrestore(&self->spinlock, flags);
       return NETDEV_TX_BUSY;
@@ -1177,8 +1163,7 @@ toshoboe_interrupt (int irq, void *dev_id)
           if (self->ring->tx[i].control & OBOE_CTL_TX_HW_OWNS)
               self->txpending++;
         }
-      IRDA_DEBUG (1, "%s.txd(%x)%x/%x\n", __func__
-          ,irqstat,txp,self->txpending);
+      pr_debug("%s.txd(%x)%x/%x\n", __func__, irqstat, txp, self->txpending);
 
       txp = INB (OBOE_TXSLOT) & OBOE_SLOT_MASK;
 
@@ -1206,8 +1191,8 @@ toshoboe_interrupt (int irq, void *dev_id)
       if ((!self->txpending) && (self->new_speed))
         {
           self->speed = self->new_speed;
-          IRDA_DEBUG (1, "%s: Executed TxDone scheduled speed change %d\n",
-		      __func__, self->speed);
+	  pr_debug("%s: Executed TxDone scheduled speed change %d\n",
+		   __func__, self->speed);
           toshoboe_setbaud (self);
         }
 
@@ -1222,8 +1207,8 @@ toshoboe_interrupt (int irq, void *dev_id)
         {
           int len = self->ring->rx[self->rxs].len;
           skb = NULL;
-          IRDA_DEBUG (3, "%s.rcv:%x(%x)\n", __func__
-		      ,len,self->ring->rx[self->rxs].control);
+	  pr_debug("%s.rcv:%x(%x)\n", __func__
+		   , len, self->ring->rx[self->rxs].control);
 
 #ifdef DUMP_PACKETS
 dumpbufs(self->rx_bufs[self->rxs],len,'<');
@@ -1244,7 +1229,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                       len -= 2;
                   else
                       len = 0;
-                  IRDA_DEBUG (1, "%s.SIR:%x(%x)\n", __func__, len,enable);
+                  pr_debug("%s.SIR:%x(%x)\n", __func__, len, enable);
                 }
 
 #ifdef USE_MIR
@@ -1254,7 +1239,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                       len -= 2;
                   else
                       len = 0;
-                  IRDA_DEBUG (2, "%s.MIR:%x(%x)\n", __func__, len,enable);
+                  pr_debug("%s.MIR:%x(%x)\n", __func__, len, enable);
                 }
 #endif
               else if (enable & OBOE_ENABLEH_FIRON)
@@ -1263,10 +1248,10 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                       len -= 4;   /*FIXME: check this */
                   else
                       len = 0;
-                  IRDA_DEBUG (1, "%s.FIR:%x(%x)\n", __func__, len,enable);
+                  pr_debug("%s.FIR:%x(%x)\n", __func__, len, enable);
                 }
               else
-                  IRDA_DEBUG (0, "%s.?IR:%x(%x)\n", __func__, len,enable);
+		      pr_debug("%s.?IR:%x(%x)\n", __func__, len, enable);
 
               if (len)
                 {
@@ -1299,8 +1284,8 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
             /* (SIR) data is splitted in several slots. */
             /* we have to join all the received buffers received */
             /*in a large buffer before checking CRC. */
-            IRDA_DEBUG (0, "%s.err:%x(%x)\n", __func__
-                ,len,self->ring->rx[self->rxs].control);
+		    pr_debug("%s.err:%x(%x)\n", __func__
+			     , len, self->ring->rx[self->rxs].control);
             }
 
           self->ring->rx[self->rxs].len = 0x0;
@@ -1327,8 +1312,8 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
   if (irqstat & OBOE_INT_SIP)
     {
       self->int_sip++;
-      IRDA_DEBUG (1, "%s.sip:%x(%x)%x\n", __func__
-	      ,self->int_sip,irqstat,self->txpending);
+      pr_debug("%s.sip:%x(%x)%x\n",
+	       __func__, self->int_sip, irqstat, self->txpending);
     }
   return IRQ_HANDLED;
 }
@@ -1341,8 +1326,6 @@ toshoboe_net_open (struct net_device *dev)
   unsigned long flags;
   int rc;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   self = netdev_priv(dev);
 
   if (self->async)
@@ -1379,8 +1362,6 @@ toshoboe_net_close (struct net_device *dev)
 {
   struct toshoboe_cb *self;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   IRDA_ASSERT (dev != NULL, return -1; );
   self = netdev_priv(dev);
 
@@ -1424,7 +1405,7 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 
   IRDA_ASSERT (self != NULL, return -1; );
 
-  IRDA_DEBUG (5, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
+  pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
   /* Disable interrupts & save flags */
   spin_lock_irqsave(&self->spinlock, flags);
@@ -1436,8 +1417,8 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
        * speed, so we still must allow for speed change within
        * interrupt context.
        */
-      IRDA_DEBUG (1, "%s(BANDWIDTH), %s, (%X/%ld\n", __func__
-          ,dev->name, INB (OBOE_STATUS), irq->ifr_baudrate );
+	    pr_debug("%s(BANDWIDTH), %s, (%X/%ld\n",
+		     __func__, dev->name, INB(OBOE_STATUS), irq->ifr_baudrate);
       if (!in_interrupt () && !capable (CAP_NET_ADMIN)) {
 	ret = -EPERM;
 	goto out;
@@ -1449,8 +1430,9 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
       self->new_speed = irq->ifr_baudrate;
       break;
     case SIOCSMEDIABUSY:       /* Set media busy */
-      IRDA_DEBUG (1, "%s(MEDIABUSY), %s, (%X/%x)\n", __func__
-          ,dev->name, INB (OBOE_STATUS), capable (CAP_NET_ADMIN) );
+	    pr_debug("%s(MEDIABUSY), %s, (%X/%x)\n",
+		     __func__, dev->name,
+		     INB(OBOE_STATUS), capable(CAP_NET_ADMIN));
       if (!capable (CAP_NET_ADMIN)) {
 	ret = -EPERM;
 	goto out;
@@ -1459,11 +1441,11 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
       break;
     case SIOCGRECEIVING:       /* Check if we are receiving right now */
       irq->ifr_receiving = (INB (OBOE_STATUS) & OBOE_STATUS_RXBUSY) ? 1 : 0;
-      IRDA_DEBUG (3, "%s(RECEIVING), %s, (%X/%x)\n", __func__
-          ,dev->name, INB (OBOE_STATUS), irq->ifr_receiving );
+	    pr_debug("%s(RECEIVING), %s, (%X/%x)\n",
+		     __func__, dev->name, INB(OBOE_STATUS), irq->ifr_receiving);
       break;
     default:
-      IRDA_DEBUG (1, "%s(?), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
+	    pr_debug("%s(?), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
       ret = -EOPNOTSUPP;
     }
 out:
@@ -1490,8 +1472,6 @@ toshoboe_close (struct pci_dev *pci_dev)
   int i;
   struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   IRDA_ASSERT (self != NULL, return; );
 
   if (!self->stopped)
@@ -1538,8 +1518,6 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
   int ok = 0;
   int err;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   if ((err=pci_enable_device(pci_dev)))
     return err;
 
@@ -1700,8 +1678,6 @@ toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
   unsigned long flags;
   int i = 10;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   if (!self || self->stopped)
     return 0;
 
@@ -1728,8 +1704,6 @@ toshoboe_wakeup (struct pci_dev *pci_dev)
   struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
   unsigned long flags;
 
-  IRDA_DEBUG (4, "%s()\n", __func__);
-
   if (!self || !self->stopped)
     return 0;
 
diff --git a/drivers/net/irda/girbil-sir.c b/drivers/net/irda/girbil-sir.c
index f0512ad..7e0a5b8 100644
--- a/drivers/net/irda/girbil-sir.c
+++ b/drivers/net/irda/girbil-sir.c
@@ -86,8 +86,6 @@ static int girbil_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power on dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -102,8 +100,6 @@ static int girbil_open(struct sir_dev *dev)
 
 static int girbil_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
@@ -126,8 +122,6 @@ static int girbil_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 control[2];
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* dongle alread reset - port and dongle at default speed */
 
 	switch(state) {
@@ -210,8 +204,6 @@ static int girbil_reset(struct sir_dev *dev)
 	u8 control = GIRBIL_TXEN | GIRBIL_RXEN;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
 		/* Reset dongle */
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index e9aedbe..48b2f9a 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -176,12 +176,13 @@ static void irda_usb_build_header(struct irda_usb_cb *self,
 		    (!force) && (self->speed != -1)) {
 			/* No speed and xbofs change here
 			 * (we'll do it later in the write callback) */
-			IRDA_DEBUG(2, "%s(), not changing speed yet\n", __func__);
+			pr_debug("%s(), not changing speed yet\n", __func__);
 			*header = 0;
 			return;
 		}
 
-		IRDA_DEBUG(2, "%s(), changing speed to %d\n", __func__, self->new_speed);
+		pr_debug("%s(), changing speed to %d\n",
+			 __func__, self->new_speed);
 		self->speed = self->new_speed;
 		/* We will do ` self->new_speed = -1; ' in the completion
 		 * handler just in case the current URB fail - Jean II */
@@ -227,7 +228,8 @@ static void irda_usb_build_header(struct irda_usb_cb *self,
 	
 	/* Set the negotiated additional XBOFS */
 	if (self->new_xbofs != -1) {
-		IRDA_DEBUG(2, "%s(), changing xbofs to %d\n", __func__, self->new_xbofs);
+		pr_debug("%s(), changing xbofs to %d\n",
+			 __func__, self->new_xbofs);
 		self->xbofs = self->new_xbofs;
 		/* We will do ` self->new_xbofs = -1; ' in the completion
 		 * handler just in case the current URB fail - Jean II */
@@ -301,8 +303,8 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
 	struct urb *urb;
 	int ret;
 
-	IRDA_DEBUG(2, "%s(), speed=%d, xbofs=%d\n", __func__,
-		   self->new_speed, self->new_xbofs);
+	pr_debug("%s(), speed=%d, xbofs=%d\n", __func__,
+		 self->new_speed, self->new_xbofs);
 
 	/* Grab the speed URB */
 	urb = self->speed_urb;
@@ -346,8 +348,6 @@ static void speed_bulk_callback(struct urb *urb)
 {
 	struct irda_usb_cb *self = urb->context;
 	
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* We should always have a context */
 	IRDA_ASSERT(self != NULL, return;);
 	/* We should always be called for the speed URB */
@@ -356,7 +356,8 @@ static void speed_bulk_callback(struct urb *urb)
 	/* Check for timeout and other USB nasties */
 	if (urb->status != 0) {
 		/* I get a lot of -ECONNABORTED = -103 here - Jean II */
-		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
+		pr_debug("%s(), URB complete status %d, transfer_flags 0x%04X\n",
+			 __func__, urb->status, urb->transfer_flags);
 
 		/* Don't do anything here, that might confuse the USB layer.
 		 * Instead, we will wait for irda_usb_net_timeout(), the
@@ -391,7 +392,7 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 	s16 xbofs;
 	int res, mtt;
 
-	IRDA_DEBUG(4, "%s() on %s\n", __func__, netdev->name);
+	pr_debug("%s() on %s\n", __func__, netdev->name);
 
 	netif_stop_queue(netdev);
 
@@ -402,7 +403,7 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 	 * We need to check self->present under the spinlock because
 	 * of irda_usb_disconnect() is synchronous - Jean II */
 	if (!self->present) {
-		IRDA_DEBUG(0, "%s(), Device is gone...\n", __func__);
+		pr_debug("%s(), Device is gone...\n", __func__);
 		goto drop;
 	}
 
@@ -554,8 +555,6 @@ static void write_bulk_callback(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct irda_usb_cb *self = ((struct irda_skb_cb *) skb->cb)->context;
 	
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* We should always have a context */
 	IRDA_ASSERT(self != NULL, return;);
 	/* We should always be called for the speed URB */
@@ -568,7 +567,8 @@ static void write_bulk_callback(struct urb *urb)
 	/* Check for timeout and other USB nasties */
 	if (urb->status != 0) {
 		/* I get a lot of -ECONNABORTED = -103 here - Jean II */
-		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
+		pr_debug("%s(), URB complete status %d, transfer_flags 0x%04X\n",
+			 __func__, urb->status, urb->transfer_flags);
 
 		/* Don't do anything here, that might confuse the USB layer,
 		 * and we could go in recursion and blow the kernel stack...
@@ -587,7 +587,7 @@ static void write_bulk_callback(struct urb *urb)
 
 	/* If the network is closed, stop everything */
 	if ((!self->netopen) || (!self->present)) {
-		IRDA_DEBUG(0, "%s(), Network is gone...\n", __func__);
+		pr_debug("%s(), Network is gone...\n", __func__);
 		spin_unlock_irqrestore(&self->lock, flags);
 		return;
 	}
@@ -598,7 +598,7 @@ static void write_bulk_callback(struct urb *urb)
 		    (self->new_xbofs != self->xbofs)) {
 			/* We haven't changed speed yet (because of
 			 * IUC_SPEED_BUG), so do it now - Jean II */
-			IRDA_DEBUG(1, "%s(), Changing speed now...\n", __func__);
+			pr_debug("%s(), Changing speed now...\n", __func__);
 			irda_usb_change_speed_xbofs(self);
 		} else {
 			/* New speed and xbof is now committed in hardware */
@@ -630,7 +630,7 @@ static void irda_usb_net_timeout(struct net_device *netdev)
 	struct urb *urb;
 	int	done = 0;	/* If we have made any progress */
 
-	IRDA_DEBUG(0, "%s(), Network layer thinks we timed out!\n", __func__);
+	pr_debug("%s(), Network layer thinks we timed out!\n", __func__);
 	IRDA_ASSERT(self != NULL, return;);
 
 	/* Protect us from USB callbacks, net Tx and else. */
@@ -647,7 +647,8 @@ static void irda_usb_net_timeout(struct net_device *netdev)
 	/* Check speed URB */
 	urb = self->speed_urb;
 	if (urb->status != 0) {
-		IRDA_DEBUG(0, "%s: Speed change timed out, urb->status=%d, urb->transfer_flags=0x%04X\n", netdev->name, urb->status, urb->transfer_flags);
+		pr_debug("%s: Speed change timed out, urb->status=%d, urb->transfer_flags=0x%04X\n",
+			 netdev->name, urb->status, urb->transfer_flags);
 
 		switch (urb->status) {
 		case -EINPROGRESS:
@@ -672,7 +673,8 @@ static void irda_usb_net_timeout(struct net_device *netdev)
 	if (urb->status != 0) {
 		struct sk_buff *skb = urb->context;
 
-		IRDA_DEBUG(0, "%s: Tx timed out, urb->status=%d, urb->transfer_flags=0x%04X\n", netdev->name, urb->status, urb->transfer_flags);
+		pr_debug("%s: Tx timed out, urb->status=%d, urb->transfer_flags=0x%04X\n",
+			 netdev->name, urb->status, urb->transfer_flags);
 
 		/* Increase error count */
 		netdev->stats.tx_errors++;
@@ -761,8 +763,6 @@ static void irda_usb_submit(struct irda_usb_cb *self, struct sk_buff *skb, struc
 	struct irda_skb_cb *cb;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* This should never happen */
 	IRDA_ASSERT(skb != NULL, return;);
 	IRDA_ASSERT(urb != NULL, return;);
@@ -805,7 +805,7 @@ static void irda_usb_receive(struct urb *urb)
 	struct urb *next_urb;
 	unsigned int len, docopy;
 
-	IRDA_DEBUG(2, "%s(), len=%d\n", __func__, urb->actual_length);
+	pr_debug("%s(), len=%d\n", __func__, urb->actual_length);
 	
 	/* Find ourselves */
 	cb = (struct irda_skb_cb *) skb->cb;
@@ -815,7 +815,7 @@ static void irda_usb_receive(struct urb *urb)
 
 	/* If the network is closed or the device gone, stop everything */
 	if ((!self->netopen) || (!self->present)) {
-		IRDA_DEBUG(0, "%s(), Network is gone!\n", __func__);
+		pr_debug("%s(), Network is gone!\n", __func__);
 		/* Don't re-submit the URB : will stall the Rx path */
 		return;
 	}
@@ -838,7 +838,8 @@ static void irda_usb_receive(struct urb *urb)
 			/* Usually precursor to a hot-unplug on OHCI. */
 		default:
 			self->netdev->stats.rx_errors++;
-			IRDA_DEBUG(0, "%s(), RX status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
+			pr_debug("%s(), RX status %d, transfer_flags 0x%04X\n",
+				 __func__, urb->status, urb->transfer_flags);
 			break;
 		}
 		/* If we received an error, we don't want to resubmit the
@@ -964,8 +965,6 @@ static void irda_usb_rx_defer_expired(unsigned long data)
 	struct irda_skb_cb *cb;
 	struct urb *next_urb;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Find ourselves */
 	cb = (struct irda_skb_cb *) skb->cb;
 	IRDA_ASSERT(cb != NULL, return;);
@@ -1049,8 +1048,8 @@ static int stir421x_fw_upload(struct irda_usb_cb *self,
 						   self->bulk_out_ep),
 				   patch_block, block_size,
 				   &actual_len, msecs_to_jiffies(500));
-		IRDA_DEBUG(3,"%s(): Bulk send %u bytes, ret=%d\n",
-			   __func__, actual_len, ret);
+		pr_debug("%s(): Bulk send %u bytes, ret=%d\n",
+			 __func__, actual_len, ret);
 
 		if (ret < 0)
 			break;
@@ -1112,8 +1111,8 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
 				+ ((build / 10) << 4)
 				+ (build % 10);
 
-			IRDA_DEBUG(3, "%s(): Firmware Product version %ld\n",
-                                   __func__, fw_version);
+			pr_debug("%s(): Firmware Product version %ld\n",
+				 __func__, fw_version);
                 }
         }
 
@@ -1169,8 +1168,6 @@ static int irda_usb_net_open(struct net_device *netdev)
 	char	hwname[16];
 	int i;
 	
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	IRDA_ASSERT(netdev != NULL, return -1;);
 	self = netdev_priv(netdev);
 	IRDA_ASSERT(self != NULL, return -1;);
@@ -1249,8 +1246,6 @@ static int irda_usb_net_close(struct net_device *netdev)
 	struct irda_usb_cb *self;
 	int	i;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	IRDA_ASSERT(netdev != NULL, return -1;);
 	self = netdev_priv(netdev);
 	IRDA_ASSERT(self != NULL, return -1;);
@@ -1304,7 +1299,7 @@ static int irda_usb_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -1354,7 +1349,6 @@ static inline void irda_usb_init_qos(struct irda_usb_cb *self)
 {
 	struct irda_class_desc *desc;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
 	
 	desc = self->irda_desc;
 	
@@ -1370,8 +1364,10 @@ static inline void irda_usb_init_qos(struct irda_usb_cb *self)
 	self->qos.window_size.bits     = desc->bmWindowSize;
 	self->qos.data_size.bits       = desc->bmDataSize;
 
-	IRDA_DEBUG(0, "%s(), dongle says speed=0x%X, size=0x%X, window=0x%X, bofs=0x%X, turn=0x%X\n", 
-		__func__, self->qos.baud_rate.bits, self->qos.data_size.bits, self->qos.window_size.bits, self->qos.additional_bofs.bits, self->qos.min_turn_time.bits);
+	pr_debug("%s(), dongle says speed=0x%X, size=0x%X, window=0x%X, bofs=0x%X, turn=0x%X\n",
+		 __func__, self->qos.baud_rate.bits, self->qos.data_size.bits,
+		 self->qos.window_size.bits, self->qos.additional_bofs.bits,
+		 self->qos.min_turn_time.bits);
 
 	/* Don't always trust what the dongle tell us */
 	if(self->capability & IUC_SIR_ONLY)
@@ -1414,8 +1410,6 @@ static inline int irda_usb_open(struct irda_usb_cb *self)
 {
 	struct net_device *netdev = self->netdev;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	netdev->netdev_ops = &irda_usb_netdev_ops;
 
 	irda_usb_init_qos(self);
@@ -1430,8 +1424,6 @@ static inline int irda_usb_open(struct irda_usb_cb *self)
  */
 static inline void irda_usb_close(struct irda_usb_cb *self)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	/* Remove netdevice */
 	unregister_netdev(self->netdev);
 
@@ -1509,8 +1501,9 @@ static inline int irda_usb_parse_endpoints(struct irda_usb_cb *self, struct usb_
 		}
 	}
 
-	IRDA_DEBUG(0, "%s(), And our endpoints are : in=%02X, out=%02X (%d), int=%02X\n",
-		__func__, self->bulk_in_ep, self->bulk_out_ep, self->bulk_out_mtu, self->bulk_int_ep);
+	pr_debug("%s(), And our endpoints are : in=%02X, out=%02X (%d), int=%02X\n",
+		 __func__, self->bulk_in_ep, self->bulk_out_ep,
+		 self->bulk_out_mtu, self->bulk_int_ep);
 
 	return (self->bulk_in_ep != 0) && (self->bulk_out_ep != 0);
 }
@@ -1572,7 +1565,7 @@ static inline struct irda_class_desc *irda_usb_find_class_desc(struct usb_interf
 		0, intf->altsetting->desc.bInterfaceNumber, desc,
 		sizeof(*desc), 500);
 	
-	IRDA_DEBUG(1, "%s(), ret=%d\n", __func__, ret);
+	pr_debug("%s(), ret=%d\n", __func__, ret);
 	if (ret < sizeof(*desc)) {
 		net_warn_ratelimited("usb-irda: class_descriptor read %s (%d)\n",
 				     ret < 0 ? "failed" : "too short", ret);
@@ -1679,7 +1672,8 @@ static int irda_usb_probe(struct usb_interface *intf,
 	 * specify an alternate, but very few driver do like this.
 	 * Jean II */
 	ret = usb_set_interface(dev, intf->altsetting->desc.bInterfaceNumber, 0);
-	IRDA_DEBUG(1, "usb-irda: set interface %d result %d\n", intf->altsetting->desc.bInterfaceNumber, ret);
+	pr_debug("usb-irda: set interface %d result %d\n",
+		 intf->altsetting->desc.bInterfaceNumber, ret);
 	switch (ret) {
 		case 0:
 			break;
@@ -1687,10 +1681,11 @@ static int irda_usb_probe(struct usb_interface *intf,
 			/* Martin Diehl says if we get a -EPIPE we should
 			 * be fine and we don't need to do a usb_clear_halt().
 			 * - Jean II */
-			IRDA_DEBUG(0, "%s(), Received -EPIPE, ignoring...\n", __func__);
+			pr_debug("%s(), Received -EPIPE, ignoring...\n",
+				 __func__);
 			break;
 		default:
-			IRDA_DEBUG(0, "%s(), Unknown error %d\n", __func__, ret);
+			pr_debug("%s(), Unknown error %d\n", __func__, ret);
 			ret = -EIO;
 			goto err_out_3;
 	}
@@ -1716,7 +1711,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 		ret = usb_control_msg (self->usbdev, usb_sndctrlpipe (self->usbdev, 0),
 				       0x02, 0x40, 0, 0, NULL, 0, 500);
 		if (ret < 0) {
-			IRDA_DEBUG (0, "usb_control_msg failed %d\n", ret);
+			pr_debug("usb_control_msg failed %d\n", ret);
 			goto err_out_3;
 		} else {
 			mdelay(10);
@@ -1808,8 +1803,6 @@ static void irda_usb_disconnect(struct usb_interface *intf)
 	struct irda_usb_cb *self = usb_get_intfdata(intf);
 	int i;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	usb_set_intfdata(intf, NULL);
 	if (!self)
 		return;
@@ -1858,7 +1851,7 @@ static void irda_usb_disconnect(struct usb_interface *intf)
 
 	/* Free self and network device */
 	free_netdev(self->netdev);
-	IRDA_DEBUG(0, "%s(), USB IrDA Disconnected\n", __func__);
+	pr_debug("%s(), USB IrDA Disconnected\n", __func__);
 }
 
 #ifdef CONFIG_PM
diff --git a/drivers/net/irda/irtty-sir.c b/drivers/net/irda/irtty-sir.c
index abbb654..696852e 100644
--- a/drivers/net/irda/irtty-sir.c
+++ b/drivers/net/irda/irtty-sir.c
@@ -240,7 +240,7 @@ static void irtty_receive_buf(struct tty_struct *tty, const unsigned char *cp,
 		 *  Characters received with a parity error, etc?
 		 */
  		if (fp && *fp++) { 
-			IRDA_DEBUG(0, "Framing or parity error!\n");
+			pr_debug("Framing or parity error!\n");
 			sirdev_receive(dev, NULL, 0);	/* notify sir_dev (updating stats) */
 			return;
  		}
@@ -387,7 +387,7 @@ static int irtty_ioctl(struct tty_struct *tty, struct file *file, unsigned int c
 	IRDA_ASSERT(priv != NULL, return -ENODEV;);
 	IRDA_ASSERT(priv->magic == IRTTY_MAGIC, return -EBADR;);
 
-	IRDA_DEBUG(3, "%s(cmd=0x%X)\n", __func__, cmd);
+	pr_debug("%s(cmd=0x%X)\n", __func__, cmd);
 
 	dev = priv->dev;
 	IRDA_ASSERT(dev != NULL, return -1;);
@@ -477,7 +477,7 @@ static int irtty_open(struct tty_struct *tty)
 
 	mutex_unlock(&irtty_mutex);
 
-	IRDA_DEBUG(0, "%s - %s: irda line discipline opened\n", __func__, tty->name);
+	pr_debug("%s - %s: irda line discipline opened\n", __func__, tty->name);
 
 	return 0;
 
@@ -528,7 +528,7 @@ static void irtty_close(struct tty_struct *tty)
 
 	kfree(priv);
 
-	IRDA_DEBUG(0, "%s - %s: irda line discipline closed\n", __func__, tty->name);
+	pr_debug("%s - %s: irda line discipline closed\n", __func__, tty->name);
 }
 
 /* ------------------------------------------------------- */
diff --git a/drivers/net/irda/litelink-sir.c b/drivers/net/irda/litelink-sir.c
index 6827777..8eefcb4 100644
--- a/drivers/net/irda/litelink-sir.c
+++ b/drivers/net/irda/litelink-sir.c
@@ -76,8 +76,6 @@ static int litelink_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power up dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -93,8 +91,6 @@ static int litelink_open(struct sir_dev *dev)
 
 static int litelink_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
@@ -111,8 +107,6 @@ static int litelink_change_speed(struct sir_dev *dev, unsigned speed)
 {
         int i;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* dongle already reset by irda-thread - current speed (dongle and
 	 * port) is the default speed (115200 for litelink!)
 	 */
@@ -154,8 +148,6 @@ static int litelink_change_speed(struct sir_dev *dev, unsigned speed)
  */
 static int litelink_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* probably the power-up can be dropped here, but with only
 	 * 15 usec delay it's not worth the risk unless somebody with
 	 * the hardware confirms it doesn't break anything...
diff --git a/drivers/net/irda/ma600-sir.c b/drivers/net/irda/ma600-sir.c
index 944d044..a764817 100644
--- a/drivers/net/irda/ma600-sir.c
+++ b/drivers/net/irda/ma600-sir.c
@@ -65,13 +65,11 @@ static struct dongle_driver ma600 = {
 
 static int __init ma600_sir_init(void)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
 	return irda_register_dongle(&ma600);
 }
 
 static void __exit ma600_sir_cleanup(void)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
 	irda_unregister_dongle(&ma600);
 }
 
@@ -86,8 +84,6 @@ static int ma600_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
 	/* Explicitly set the speeds we can accept */
@@ -104,8 +100,6 @@ static int ma600_open(struct sir_dev *dev)
 
 static int ma600_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
@@ -174,8 +168,8 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
 {
 	u8	byte;
 	
-	IRDA_DEBUG(2, "%s(), speed=%d (was %d)\n", __func__,
-		speed, dev->speed);
+	pr_debug("%s(), speed=%d (was %d)\n", __func__,
+		 speed, dev->speed);
 
 	/* dongle already reset, dongle and port at default speed (9600) */
 
@@ -204,7 +198,7 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
 		return -1;
 	}
 	else
-		IRDA_DEBUG(2, "%s() control byte write read OK\n", __func__);
+		pr_debug("%s() control byte write read OK\n", __func__);
 #endif
 
 	/* Set DTR, Set RTS */
@@ -236,8 +230,6 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
 
 static int ma600_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Reset the dongle : set DTR low for 10 ms */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
 	msleep(10);
diff --git a/drivers/net/irda/mcp2120-sir.c b/drivers/net/irda/mcp2120-sir.c
index 9767469..2e33f91 100644
--- a/drivers/net/irda/mcp2120-sir.c
+++ b/drivers/net/irda/mcp2120-sir.c
@@ -63,8 +63,6 @@ static int mcp2120_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* seems no explicit power-on required here and reset switching it on anyway */
 
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
@@ -76,8 +74,6 @@ static int mcp2120_open(struct sir_dev *dev)
 
 static int mcp2120_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power off dongle */
         /* reset and inhibit mcp2120 */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -102,8 +98,6 @@ static int mcp2120_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 control[2];
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
 		/* Set DTR to enter command mode */
@@ -188,8 +182,6 @@ static int mcp2120_reset(struct sir_dev *dev)
 	unsigned delay = 0;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
                 //printk("mcp2120_reset: dongle_reset\n");
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 6cbd29d..e4d678f 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -894,7 +894,7 @@ static int mcs_probe(struct usb_interface *intf,
 	if (!ndev)
 		goto error1;
 
-	IRDA_DEBUG(1, "MCS7780 USB-IrDA bridge found at %d.\n", udev->devnum);
+	pr_debug("MCS7780 USB-IrDA bridge found at %d.\n", udev->devnum);
 
 	SET_NETDEV_DEV(ndev, &intf->dev);
 
@@ -942,8 +942,8 @@ static int mcs_probe(struct usb_interface *intf,
 	if (ret != 0)
 		goto error2;
 
-	IRDA_DEBUG(1, "IrDA: Registered MosChip MCS7780 device as %s\n",
-		   ndev->name);
+	pr_debug("IrDA: Registered MosChip MCS7780 device as %s\n",
+		 ndev->name);
 
 	mcs->transceiver_type = transceiver_type;
 	mcs->sir_tweak = sir_tweak;
@@ -973,7 +973,7 @@ static void mcs_disconnect(struct usb_interface *intf)
 	free_netdev(mcs->netdev);
 
 	usb_set_intfdata(intf, NULL);
-	IRDA_DEBUG(0, "MCS7780 now disconnected.\n");
+	pr_debug("MCS7780 now disconnected.\n");
 }
 
 module_usb_driver(mcs_driver);
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index c0a1790..e7317b1 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -226,8 +226,8 @@ static int __init nsc_ircc_init(void)
 
 	/* Probe for all the NSC chipsets we know about */
 	for (chip = chips; chip->name ; chip++) {
-		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __func__,
-			   chip->name);
+		pr_debug("%s(), Probing for %s ...\n", __func__,
+			 chip->name);
 		
 		/* Try all config registers for this chip */
 		for (cfg = 0; cfg < ARRAY_SIZE(chip->cfg); cfg++) {
@@ -238,7 +238,8 @@ static int __init nsc_ircc_init(void)
 			/* Read index register */
 			reg = inb(cfg_base);
 			if (reg == 0xff) {
-				IRDA_DEBUG(2, "%s() no chip at 0x%03x\n", __func__, cfg_base);
+				pr_debug("%s() no chip at 0x%03x\n",
+					 __func__, cfg_base);
 				continue;
 			}
 			
@@ -246,8 +247,9 @@ static int __init nsc_ircc_init(void)
 			outb(chip->cid_index, cfg_base);
 			id = inb(cfg_base+1);
 			if ((id & chip->cid_mask) == chip->cid_value) {
-				IRDA_DEBUG(2, "%s() Found %s chip, revision=%d\n",
-					   __func__, chip->name, id & ~chip->cid_mask);
+				pr_debug("%s() Found %s chip, revision=%d\n",
+					 __func__, chip->name,
+					 id & ~chip->cid_mask);
 
 				/*
 				 * If we found a correct PnP setting,
@@ -277,7 +279,8 @@ static int __init nsc_ircc_init(void)
 				 * the chip.
 				 */
 				if (ret) {
-					IRDA_DEBUG(2, "%s, PnP init failed\n", driver_name);
+					pr_debug("%s, PnP init failed\n",
+						 driver_name);
 					memset(&info, 0, sizeof(chipio_t));
 					info.cfg_base = cfg_base;
 					info.fir_base = io[i];
@@ -299,7 +302,8 @@ static int __init nsc_ircc_init(void)
 				}
 				i++;
 			} else {
-				IRDA_DEBUG(2, "%s(), Wrong chip id=0x%02x\n", __func__, id);
+				pr_debug("%s(), Wrong chip id=0x%02x\n",
+					 __func__, id);
 			}
 		} 
 	}
@@ -363,9 +367,6 @@ static int __init nsc_ircc_open(chipio_t *info)
 	void *ret;
 	int err, chip_index;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
-
  	for (chip_index = 0; chip_index < ARRAY_SIZE(dev_self); chip_index++) {
 		if (!dev_self[chip_index])
 			break;
@@ -520,8 +521,6 @@ static int __exit nsc_ircc_close(struct nsc_ircc_cb *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
         iobase = self->io.fir_base;
@@ -532,8 +531,8 @@ static int __exit nsc_ircc_close(struct nsc_ircc_cb *self)
 	unregister_netdev(self->netdev);
 
 	/* Release the PORT that this driver is using */
-	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", 
-		   __func__, self->io.fir_base);
+	pr_debug("%s(), Releasing Region %03x\n",
+		 __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -630,8 +629,8 @@ static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info)
 		break;
 	}
 	info->sir_base = info->fir_base;
-	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __func__,
-		   info->fir_base);
+	pr_debug("%s(), probing fir_base=0x%03x\n", __func__,
+		 info->fir_base);
 
 	/* Read control signals routing register (CSRT) */
 	outb(CFG_108_CSRT, cfg_base);
@@ -663,7 +662,7 @@ static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info)
 		info->irq = 15;
 		break;
 	}
-	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __func__, info->irq);
+	pr_debug("%s(), probing irq=%d\n", __func__, info->irq);
 
 	/* Currently we only read Rx DMA but it will also be used for Tx */
 	switch ((reg >> 3) & 0x03) {
@@ -680,7 +679,7 @@ static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info)
 		info->dma = 3;
 		break;
 	}
-	IRDA_DEBUG(2, "%s(), probing dma=%d\n", __func__, info->dma);
+	pr_debug("%s(), probing dma=%d\n", __func__, info->dma);
 
 	/* Read mode control register (MCTL) */
 	outb(CFG_108_MCTL, cfg_base);
@@ -731,7 +730,7 @@ static int nsc_ircc_probe_338(nsc_chip_t *chip, chipio_t *info)
 	
 	pnp = (reg >> 3) & 0x01;
 	if (pnp) {
-		IRDA_DEBUG(2, "(), Chip is in PnP mode\n");
+		pr_debug("(), Chip is in PnP mode\n");
 		outb(0x46, cfg_base);
 		reg = (inb(cfg_base+1) & 0xfe) << 2;
 
@@ -835,9 +834,8 @@ static int nsc_ircc_init_39x(nsc_chip_t *chip, chipio_t *info)
 	int enabled;
 
 	/* User is sure about his config... accept it. */
-	IRDA_DEBUG(2, "%s(): nsc_ircc_init_39x (user settings): "
-		   "io=0x%04x, irq=%d, dma=%d\n", 
-		   __func__, info->fir_base, info->irq, info->dma);
+	pr_debug("%s(): nsc_ircc_init_39x (user settings): io=0x%04x, irq=%d, dma=%d\n",
+		 __func__, info->fir_base, info->irq, info->dma);
 
 	/* Access bank for SP2 */
 	outb(CFG_39X_LDN, cfg_base);
@@ -877,8 +875,8 @@ static int nsc_ircc_probe_39x(nsc_chip_t *chip, chipio_t *info)
 	int reg1, reg2, irq, irqt, dma1, dma2;
 	int enabled, susp;
 
-	IRDA_DEBUG(2, "%s(), nsc_ircc_probe_39x, base=%d\n",
-		   __func__, cfg_base);
+	pr_debug("%s(), nsc_ircc_probe_39x, base=%d\n",
+		 __func__, cfg_base);
 
 	/* This function should be executed with irq off to avoid
 	 * another driver messing with the Super I/O bank - Jean II */
@@ -912,7 +910,8 @@ static int nsc_ircc_probe_39x(nsc_chip_t *chip, chipio_t *info)
 	outb(CFG_39X_SPC, cfg_base);
 	susp = 1 - ((inb(cfg_base+1) & 0x02) >> 1);
 
-	IRDA_DEBUG(2, "%s(): io=0x%02x%02x, irq=%d (type %d), rxdma=%d, txdma=%d, enabled=%d (suspended=%d)\n", __func__, reg1,reg2,irq,irqt,dma1,dma2,enabled,susp);
+	pr_debug("%s(): io=0x%02x%02x, irq=%d (type %d), rxdma=%d, txdma=%d, enabled=%d (suspended=%d)\n",
+		 __func__, reg1, reg2, irq, irqt, dma1, dma2, enabled, susp);
 
 	/* Configure SP2 */
 
@@ -963,8 +962,8 @@ static int nsc_ircc_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *i
 		!(pnp_dma_flags(dev, 0) & IORESOURCE_DISABLED))
 		pnp_info.dma = pnp_dma(dev, 0);
 
-	IRDA_DEBUG(0, "%s() : From PnP, found firbase 0x%03X ; irq %d ; dma %d.\n",
-		   __func__, pnp_info.fir_base, pnp_info.irq, pnp_info.dma);
+	pr_debug("%s() : From PnP, found firbase 0x%03X ; irq %d ; dma %d.\n",
+		 __func__, pnp_info.fir_base, pnp_info.irq, pnp_info.dma);
 
 	if((pnp_info.fir_base == 0) ||
 	   (pnp_info.irq == -1) || (pnp_info.dma == -1)) {
@@ -992,8 +991,8 @@ static int nsc_ircc_setup(chipio_t *info)
 	switch_bank(iobase, BANK3);
 	version = inb(iobase+MID);
 
-	IRDA_DEBUG(2, "%s() Driver %s Found chip version %02x\n",
-		   __func__, driver_name, version);
+	pr_debug("%s() Driver %s Found chip version %02x\n",
+		 __func__, driver_name, version);
 
 	/* Should be 0x2? */
 	if (0x20 != (version & 0xf0)) {
@@ -1096,39 +1095,39 @@ static void nsc_ircc_init_dongle_interface (int iobase, int dongle_id)
 	switch (dongle_id) {
 	case 0x00: /* same as */
 	case 0x01: /* Differential serial interface */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x02: /* same as */
 	case 0x03: /* Reserved */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x04: /* Sharp RY5HD01 */
 		break;
 	case 0x05: /* Reserved, but this is what the Thinkpad reports */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x06: /* Single-ended serial interface */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x07: /* Consumer-IR only */
-		IRDA_DEBUG(0, "%s(), %s is not for IrDA mode\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s is not for IrDA mode\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x08: /* HP HSDL-2300, HP HSDL-3600/HSDL-3610 */
-		IRDA_DEBUG(0, "%s(), %s\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x09: /* IBM31T1100 or Temic TFDS6000/TFDS6500 */
 		outb(0x28, iobase+7); /* Set irsl[0-2] as output */
 		break;
 	case 0x0A: /* same as */
 	case 0x0B: /* Reserved */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x0C: /* same as */
 	case 0x0D: /* HP HSDL-1100/HSDL-2100 */
@@ -1142,15 +1141,15 @@ static void nsc_ircc_init_dongle_interface (int iobase, int dongle_id)
 		outb(0x28, iobase+7); /* Set irsl[0-2] as output */
 		break;
 	case 0x0F: /* No dongle connected */
-		IRDA_DEBUG(0, "%s(), %s\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s\n",
+			 __func__, dongle_types[dongle_id]);
 
 		switch_bank(iobase, BANK0);
 		outb(0x62, iobase+MCR);
 		break;
 	default: 
-		IRDA_DEBUG(0, "%s(), invalid dongle_id %#x", 
-			   __func__, dongle_id);
+		pr_debug("%s(), invalid dongle_id %#x",
+			 __func__, dongle_id);
 	}
 	
 	/* IRCFG1: IRSL1 and 2 are set to IrDA mode */
@@ -1181,31 +1180,31 @@ static void nsc_ircc_change_dongle_speed(int iobase, int speed, int dongle_id)
 	switch (dongle_id) {
 	case 0x00: /* same as */
 	case 0x01: /* Differential serial interface */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x02: /* same as */
 	case 0x03: /* Reserved */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x04: /* Sharp RY5HD01 */
 		break;
 	case 0x05: /* Reserved */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x06: /* Single-ended serial interface */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x07: /* Consumer-IR only */
-		IRDA_DEBUG(0, "%s(), %s is not for IrDA mode\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s is not for IrDA mode\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x08: /* HP HSDL-2300, HP HSDL-3600/HSDL-3610 */
-		IRDA_DEBUG(0, "%s(), %s\n", 
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s\n",
+			 __func__, dongle_types[dongle_id]);
 		outb(0x00, iobase+4);
 		if (speed > 115200)
 			outb(0x01, iobase+4);
@@ -1223,8 +1222,8 @@ static void nsc_ircc_change_dongle_speed(int iobase, int speed, int dongle_id)
 		break;
 	case 0x0A: /* same as */
 	case 0x0B: /* Reserved */
-		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s not defined by irda yet\n",
+			 __func__, dongle_types[dongle_id]);
 		break;
 	case 0x0C: /* same as */
 	case 0x0D: /* HP HSDL-1100/HSDL-2100 */
@@ -1232,14 +1231,14 @@ static void nsc_ircc_change_dongle_speed(int iobase, int speed, int dongle_id)
 	case 0x0E: /* Supports SIR Mode only */
 		break;
 	case 0x0F: /* No dongle connected */
-		IRDA_DEBUG(0, "%s(), %s is not for IrDA mode\n",
-			   __func__, dongle_types[dongle_id]);
+		pr_debug("%s(), %s is not for IrDA mode\n",
+			 __func__, dongle_types[dongle_id]);
 
 		switch_bank(iobase, BANK0); 
 		outb(0x62, iobase+MCR);
 		break;
 	default: 
-		IRDA_DEBUG(0, "%s(), invalid data_rate\n", __func__);
+		pr_debug("%s(), invalid data_rate\n", __func__);
 	}
 	/* Restore bank register */
 	outb(bank, iobase+BSR);
@@ -1260,7 +1259,7 @@ static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
 	__u8 bank;
 	__u8 ier;                  /* Interrupt enable register */
 
-	IRDA_DEBUG(2, "%s(), speed=%d\n", __func__, speed);
+	pr_debug("%s(), speed=%d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return 0;);
 
@@ -1293,20 +1292,20 @@ static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
 		outb(inb(iobase+4) | 0x04, iobase+4);
 	       
 		mcr = MCR_MIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __func__);
+		pr_debug("%s(), handling baud of 576000\n", __func__);
 		break;
 	case 1152000:
 		mcr = MCR_MIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n", __func__);
+		pr_debug("%s(), handling baud of 1152000\n", __func__);
 		break;
 	case 4000000:
 		mcr = MCR_FIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n", __func__);
+		pr_debug("%s(), handling baud of 4000000\n", __func__);
 		break;
 	default:
 		mcr = MCR_FIR;
-		IRDA_DEBUG(0, "%s(), unknown baud rate of %d\n", 
-			   __func__, speed);
+		pr_debug("%s(), unknown baud rate of %d\n",
+			 __func__, speed);
 		break;
 	}
 
@@ -1613,15 +1612,13 @@ static int nsc_ircc_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	int actual = 0;
 	__u8 bank;
 	
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	/* Save current bank */
 	bank = inb(iobase+BSR);
 
 	switch_bank(iobase, BANK0);
 	if (!(inb_p(iobase+LSR) & LSR_TXEMP)) {
-		IRDA_DEBUG(4, "%s(), warning, FIFO not empty yet!\n",
-			   __func__);
+		pr_debug("%s(), warning, FIFO not empty yet!\n",
+			 __func__);
 
 		/* FIFO may still be filled to the Tx interrupt threshold */
 		fifo_size -= 17;
@@ -1633,8 +1630,8 @@ static int nsc_ircc_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 		outb(buf[actual++], iobase+TXD);
 	}
         
-	IRDA_DEBUG(4, "%s(), fifo_size %d ; %d sent of %d\n", 
-		   __func__, fifo_size, actual, len);
+	pr_debug("%s(), fifo_size %d ; %d sent of %d\n",
+		 __func__, fifo_size, actual, len);
 	
 	/* Restore bank */
 	outb(bank, iobase+BSR);
@@ -1655,8 +1652,6 @@ static int nsc_ircc_dma_xmit_complete(struct nsc_ircc_cb *self)
 	__u8 bank;
 	int ret = TRUE;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	iobase = self->io.fir_base;
 
 	/* Save current bank */
@@ -1786,7 +1781,7 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 		len = inb(iobase+RFLFL) | ((inb(iobase+RFLFH) & 0x1f) << 8);
 
 		if (st_fifo->tail >= MAX_RX_WINDOW) {
-			IRDA_DEBUG(0, "%s(), window is full!\n", __func__);
+			pr_debug("%s(), window is full!\n", __func__);
 			continue;
 		}
 			
@@ -1980,7 +1975,7 @@ static void nsc_ircc_sir_interrupt(struct nsc_ircc_cb *self, int eir)
 		 * Need to be after self->io.direction to avoid race with
 		 * nsc_ircc_hard_xmit_sir() - Jean II */
 		if (self->new_speed) {
-			IRDA_DEBUG(2, "%s(), Changing speed!\n", __func__);
+			pr_debug("%s(), Changing speed!\n", __func__);
 			self->ier = nsc_ircc_change_speed(self,
 							  self->new_speed);
 			self->new_speed = 0;
@@ -2174,7 +2169,6 @@ static int nsc_ircc_net_open(struct net_device *dev)
 	char hwname[32];
 	__u8 bank;
 	
-	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
@@ -2236,7 +2230,6 @@ static int nsc_ircc_net_close(struct net_device *dev)
 	int iobase;
 	__u8 bank;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -2290,7 +2283,7 @@ static int nsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -2329,7 +2322,7 @@ static int nsc_ircc_suspend(struct platform_device *dev, pm_message_t state)
 	if (self->io.suspended)
 		return 0;
 
-	IRDA_DEBUG(1, "%s, Suspending\n", driver_name);
+	pr_debug("%s, Suspending\n", driver_name);
 
 	rtnl_lock();
 	if (netif_running(self->netdev)) {
@@ -2363,7 +2356,7 @@ static int nsc_ircc_resume(struct platform_device *dev)
 	if (!self->io.suspended)
 		return 0;
 
-	IRDA_DEBUG(1, "%s, Waking up\n", driver_name);
+	pr_debug("%s, Waking up\n", driver_name);
 
 	rtnl_lock();
 	nsc_ircc_setup(&self->io);
diff --git a/drivers/net/irda/old_belkin-sir.c b/drivers/net/irda/old_belkin-sir.c
index f237136..a7c2e99 100644
--- a/drivers/net/irda/old_belkin-sir.c
+++ b/drivers/net/irda/old_belkin-sir.c
@@ -90,8 +90,6 @@ static int old_belkin_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power on dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -108,8 +106,6 @@ static int old_belkin_open(struct sir_dev *dev)
 
 static int old_belkin_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
@@ -123,8 +119,6 @@ static int old_belkin_close(struct sir_dev *dev)
  */
 static int old_belkin_change_speed(struct sir_dev *dev, unsigned speed)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	dev->speed = 9600;
 	return (speed==dev->speed) ? 0 : -EINVAL;
 }
@@ -137,8 +131,6 @@ static int old_belkin_change_speed(struct sir_dev *dev, unsigned speed)
  */
 static int old_belkin_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* This dongles speed "defaults" to 9600 bps ;-) */
 	dev->speed = 9600;
 
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 5bfcd25..6af26a7 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -109,11 +109,11 @@ static void sirdev_config_fsm(struct work_struct *work)
 	int ret = -1;
 	unsigned delay;
 
-	IRDA_DEBUG(2, "%s(), <%ld>\n", __func__, jiffies);
+	pr_debug("%s(), <%ld>\n", __func__, jiffies);
 
 	do {
-		IRDA_DEBUG(3, "%s - state=0x%04x / substate=0x%04x\n",
-			__func__, fsm->state, fsm->substate);
+		pr_debug("%s - state=0x%04x / substate=0x%04x\n",
+			 __func__, fsm->state, fsm->substate);
 
 		next_state = fsm->state;
 		delay = 0;
@@ -287,12 +287,12 @@ int sirdev_schedule_request(struct sir_dev *dev, int initial_state, unsigned par
 {
 	struct sir_fsm *fsm = &dev->fsm;
 
-	IRDA_DEBUG(2, "%s - state=0x%04x / param=%u\n", __func__,
-			initial_state, param);
+	pr_debug("%s - state=0x%04x / param=%u\n", __func__,
+		 initial_state, param);
 
 	if (down_trylock(&fsm->sem)) {
 		if (in_interrupt()  ||  in_atomic()  ||  irqs_disabled()) {
-			IRDA_DEBUG(1, "%s(), state machine busy!\n", __func__);
+			pr_debug("%s(), state machine busy!\n", __func__);
 			return -EWOULDBLOCK;
 		} else
 			down(&fsm->sem);
@@ -345,7 +345,7 @@ int sirdev_set_dongle(struct sir_dev *dev, IRDA_DONGLE type)
 {
 	int err;
 
-	IRDA_DEBUG(3, "%s : requesting dongle %d.\n", __func__, type);
+	pr_debug("%s : requesting dongle %d.\n", __func__, type);
 
 	err = sirdev_schedule_dongle_open(dev, type);
 	if (unlikely(err))
@@ -380,7 +380,7 @@ int sirdev_raw_write(struct sir_dev *dev, const char *buf, int len)
 
 	ret = dev->drv->do_write(dev, dev->tx_buff.data, dev->tx_buff.len);
 	if (ret > 0) {
-		IRDA_DEBUG(3, "%s(), raw-tx started\n", __func__);
+		pr_debug("%s(), raw-tx started\n", __func__);
 
 		dev->tx_buff.data += ret;
 		dev->tx_buff.len -= ret;
@@ -440,8 +440,8 @@ void sirdev_write_complete(struct sir_dev *dev)
 	
 	spin_lock_irqsave(&dev->tx_lock, flags);
 
-	IRDA_DEBUG(3, "%s() - dev->tx_buff.len = %d\n",
-		   __func__, dev->tx_buff.len);
+	pr_debug("%s() - dev->tx_buff.len = %d\n",
+		 __func__, dev->tx_buff.len);
 
 	if (likely(dev->tx_buff.len > 0))  {
 		/* Write data left in transmit buffer */
@@ -475,7 +475,7 @@ void sirdev_write_complete(struct sir_dev *dev)
 		 * restarted when the irda-thread has completed the request.
 		 */
 
-		IRDA_DEBUG(3, "%s(), raw-tx done\n", __func__);
+		pr_debug("%s(), raw-tx done\n", __func__);
 		dev->raw_tx = 0;
 		goto done;	/* no post-frame handling in raw mode */
 	}
@@ -492,7 +492,7 @@ void sirdev_write_complete(struct sir_dev *dev)
 	 * re-activated.
 	 */
 
-	IRDA_DEBUG(5, "%s(), finished with frame!\n", __func__);
+	pr_debug("%s(), finished with frame!\n", __func__);
 		
 	if ((skb=dev->tx_skb) != NULL) {
 		dev->tx_skb = NULL;
@@ -502,7 +502,7 @@ void sirdev_write_complete(struct sir_dev *dev)
 	}
 
 	if (unlikely(dev->new_speed > 0)) {
-		IRDA_DEBUG(5, "%s(), Changing speed!\n", __func__);
+		pr_debug("%s(), Changing speed!\n", __func__);
 		err = sirdev_schedule_speed(dev, dev->new_speed);
 		if (unlikely(err)) {
 			/* should never happen
@@ -552,7 +552,7 @@ int sirdev_receive(struct sir_dev *dev, const unsigned char *cp, size_t count)
 		 */
 		irda_device_set_media_busy(dev->netdev, TRUE);
 		dev->netdev->stats.rx_dropped++;
-		IRDA_DEBUG(0, "%s; rx-drop: %zd\n", __func__, count);
+		pr_debug("%s; rx-drop: %zd\n", __func__, count);
 		return 0;
 	}
 
@@ -598,7 +598,7 @@ static netdev_tx_t sirdev_hard_xmit(struct sk_buff *skb,
 
 	netif_stop_queue(ndev);
 
-	IRDA_DEBUG(3, "%s(), skb->len = %d\n", __func__, skb->len);
+	pr_debug("%s(), skb->len = %d\n", __func__, skb->len);
 
 	speed = irda_get_next_speed(skb);
 	if ((speed != dev->speed) && (speed != -1)) {
@@ -635,7 +635,7 @@ static netdev_tx_t sirdev_hard_xmit(struct sk_buff *skb,
 
 	/* Check problems */
 	if(spin_is_locked(&dev->tx_lock)) {
-		IRDA_DEBUG(3, "%s(), write not completed\n", __func__);
+		pr_debug("%s(), write not completed\n", __func__);
 	}
 
 	/* serialize with write completion */
@@ -684,7 +684,7 @@ static int sirdev_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	IRDA_DEBUG(3, "%s(), %s, (cmd=0x%X)\n", __func__, ndev->name, cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, ndev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -801,8 +801,6 @@ static int sirdev_open(struct net_device *ndev)
 	if (!try_module_get(drv->owner))
 		return -ESTALE;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	if (sirdev_alloc_buffers(dev))
 		goto errout_dec;
 
@@ -819,7 +817,7 @@ static int sirdev_open(struct net_device *ndev)
 
 	netif_wake_queue(ndev);
 
-	IRDA_DEBUG(2, "%s - done, speed = %d\n", __func__, dev->speed);
+	pr_debug("%s - done, speed = %d\n", __func__, dev->speed);
 
 	return 0;
 
@@ -839,7 +837,7 @@ static int sirdev_close(struct net_device *ndev)
 	struct sir_dev *dev = netdev_priv(ndev);
 	const struct sir_driver *drv;
 
-//	IRDA_DEBUG(0, "%s\n", __func__);
+/* pr_debug("%s\n", __func__); */
 
 	netif_stop_queue(ndev);
 
@@ -881,7 +879,7 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	struct net_device *ndev;
 	struct sir_dev *dev;
 
-	IRDA_DEBUG(0, "%s - %s\n", __func__, name);
+	pr_debug("%s - %s\n", __func__, name);
 
 	/* instead of adding tests to protect against drv->do_write==NULL
 	 * at several places we refuse to create a sir_dev instance for
@@ -939,7 +937,7 @@ int sirdev_put_instance(struct sir_dev *dev)
 {
 	int err = 0;
 
-	IRDA_DEBUG(0, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	atomic_set(&dev->enable_rx, 0);
 
diff --git a/drivers/net/irda/sir_dongle.c b/drivers/net/irda/sir_dongle.c
index cfbabb6..7436f73 100644
--- a/drivers/net/irda/sir_dongle.c
+++ b/drivers/net/irda/sir_dongle.c
@@ -34,8 +34,8 @@ int irda_register_dongle(struct dongle_driver *new)
 	struct list_head *entry;
 	struct dongle_driver *drv;
 
-	IRDA_DEBUG(0, "%s : registering dongle \"%s\" (%d).\n",
-		   __func__, new->driver_name, new->type);
+	pr_debug("%s : registering dongle \"%s\" (%d).\n",
+		 __func__, new->driver_name, new->type);
 
 	mutex_lock(&dongle_list_lock);
 	list_for_each(entry, &dongle_list) {
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index a7f0f52..b455ffe 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -461,7 +461,7 @@ static int __init smsc_ircc_init(void)
 {
 	int ret;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	ret = platform_driver_register(&smsc_ircc_driver);
 	if (ret) {
@@ -523,7 +523,7 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 	struct net_device *dev;
 	int err;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	err = smsc_ircc_present(fir_base, sir_base);
 	if (err)
@@ -803,7 +803,7 @@ static int smsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -882,7 +882,7 @@ static netdev_tx_t smsc_ircc_hard_xmit_sir(struct sk_buff *skb,
 	unsigned long flags;
 	s32 speed;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return NETDEV_TX_OK;);
 
@@ -957,21 +957,21 @@ static void smsc_ircc_set_fir_speed(struct smsc_ircc_cb *self, u32 speed)
 		ir_mode = IRCC_CFGA_IRDA_HDLC;
 		ctrl = IRCC_CRC;
 		fast = 0;
-		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __func__);
+		pr_debug("%s(), handling baud of 576000\n", __func__);
 		break;
 	case 1152000:
 		ir_mode = IRCC_CFGA_IRDA_HDLC;
 		ctrl = IRCC_1152 | IRCC_CRC;
 		fast = IRCC_LCR_A_FAST | IRCC_LCR_A_GP_DATA;
-		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n",
-			   __func__);
+		pr_debug("%s(), handling baud of 1152000\n",
+			 __func__);
 		break;
 	case 4000000:
 		ir_mode = IRCC_CFGA_IRDA_4PPM;
 		ctrl = IRCC_CRC;
 		fast = IRCC_LCR_A_FAST;
-		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n",
-			   __func__);
+		pr_debug("%s(), handling baud of 4000000\n",
+			 __func__);
 		break;
 	}
 	#if 0
@@ -999,7 +999,7 @@ static void smsc_ircc_fir_start(struct smsc_ircc_cb *self)
 	struct net_device *dev;
 	int fir_base;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1044,7 +1044,7 @@ static void smsc_ircc_fir_stop(struct smsc_ircc_cb *self)
 {
 	int fir_base;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -1068,7 +1068,7 @@ static void smsc_ircc_change_speed(struct smsc_ircc_cb *self, u32 speed)
 	struct net_device *dev;
 	int last_speed_was_sir;
 
-	IRDA_DEBUG(0, "%s() changing speed to: %d\n", __func__, speed);
+	pr_debug("%s() changing speed to: %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1136,7 +1136,7 @@ static void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
 	int lcr;    /* Line control reg */
 	int divisor;
 
-	IRDA_DEBUG(0, "%s(), Setting speed to: %d\n", __func__, speed);
+	pr_debug("%s(), Setting speed to: %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	iobase = self->io.sir_base;
@@ -1171,7 +1171,7 @@ static void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
 	/* Turn on interrups */
 	outb(UART_IER_RLSI | UART_IER_RDI | UART_IER_THRI, iobase + UART_IER);
 
-	IRDA_DEBUG(2, "%s() speed changed to: %d\n", __func__, speed);
+	pr_debug("%s() speed changed to: %d\n", __func__, speed);
 }
 
 
@@ -1255,7 +1255,7 @@ static void smsc_ircc_dma_xmit(struct smsc_ircc_cb *self, int bofs)
 	int iobase = self->io.fir_base;
 	u8 ctrl;
 
-	IRDA_DEBUG(3, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 #if 1
 	/* Disable Rx */
 	register_bank(iobase, 0);
@@ -1309,7 +1309,7 @@ static void smsc_ircc_dma_xmit_complete(struct smsc_ircc_cb *self)
 {
 	int iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 #if 0
 	/* Disable Tx */
 	register_bank(iobase, 0);
@@ -1413,7 +1413,7 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
 
 	register_bank(iobase, 0);
 
-	IRDA_DEBUG(3, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 #if 0
 	/* Disable Rx */
 	register_bank(iobase, 0);
@@ -1424,8 +1424,8 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
 	lsr= inb(iobase + IRCC_LSR);
 	msgcnt = inb(iobase + IRCC_LCR_B) & 0x08;
 
-	IRDA_DEBUG(2, "%s: dma count = %d\n", __func__,
-		   get_dma_residue(self->io.dma));
+	pr_debug("%s: dma count = %d\n", __func__,
+		 get_dma_residue(self->io.dma));
 
 	len = self->rx_buff.truesize - get_dma_residue(self->io.dma);
 
@@ -1450,7 +1450,7 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
 		net_warn_ratelimited("%s(), bogus len=%d\n", __func__, len);
 		return;
 	}
-	IRDA_DEBUG(2, "%s: msgcnt = %d, len=%d\n", __func__, msgcnt, len);
+	pr_debug("%s: msgcnt = %d, len=%d\n", __func__, msgcnt, len);
 
 	skb = dev_alloc_skb(len + 1);
 	if (!skb)
@@ -1494,7 +1494,7 @@ static void smsc_ircc_sir_receive(struct smsc_ircc_cb *self)
 
 		/* Make sure we don't stay here to long */
 		if (boguscount++ > 32) {
-			IRDA_DEBUG(2, "%s(), breaking!\n", __func__);
+			pr_debug("%s(), breaking!\n", __func__);
 			break;
 		}
 	} while (inb(iobase + UART_LSR) & UART_LSR_DR);
@@ -1536,7 +1536,7 @@ static irqreturn_t smsc_ircc_interrupt(int dummy, void *dev_id)
 	lcra = inb(iobase + IRCC_LCR_A);
 	lsr = inb(iobase + IRCC_LSR);
 
-	IRDA_DEBUG(2, "%s(), iir = 0x%02x\n", __func__, iir);
+	pr_debug("%s(), iir = 0x%02x\n", __func__, iir);
 
 	if (iir & IRCC_IIR_EOM) {
 		if (self->io.direction == IO_RECV)
@@ -1586,12 +1586,12 @@ static irqreturn_t smsc_ircc_interrupt_sir(struct net_device *dev)
 		/* Clear interrupt */
 		lsr = inb(iobase + UART_LSR);
 
-		IRDA_DEBUG(4, "%s(), iir=%02x, lsr=%02x, iobase=%#x\n",
-			    __func__, iir, lsr, iobase);
+		pr_debug("%s(), iir=%02x, lsr=%02x, iobase=%#x\n",
+			 __func__, iir, lsr, iobase);
 
 		switch (iir) {
 		case UART_IIR_RLSI:
-			IRDA_DEBUG(2, "%s(), RLSI\n", __func__);
+			pr_debug("%s(), RLSI\n", __func__);
 			break;
 		case UART_IIR_RDI:
 			/* Receive interrupt */
@@ -1603,8 +1603,8 @@ static irqreturn_t smsc_ircc_interrupt_sir(struct net_device *dev)
 				smsc_ircc_sir_write_wakeup(self);
 			break;
 		default:
-			IRDA_DEBUG(0, "%s(), unhandled IIR=%#x\n",
-				   __func__, iir);
+			pr_debug("%s(), unhandled IIR=%#x\n",
+				 __func__, iir);
 			break;
 		}
 
@@ -1631,12 +1631,12 @@ static int ircc_is_receiving(struct smsc_ircc_cb *self)
 	int status = FALSE;
 	/* int iobase; */
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return FALSE;);
 
-	IRDA_DEBUG(0, "%s: dma count = %d\n", __func__,
-		   get_dma_residue(self->io.dma));
+	pr_debug("%s: dma count = %d\n", __func__,
+		 get_dma_residue(self->io.dma));
 
 	status = (self->rx_buff.state != OUTSIDE_FRAME);
 
@@ -1651,8 +1651,8 @@ static int smsc_ircc_request_irq(struct smsc_ircc_cb *self)
 	error = request_irq(self->io.irq, smsc_ircc_interrupt, 0,
 			    self->netdev->name, self->netdev);
 	if (error)
-		IRDA_DEBUG(0, "%s(), unable to allocate irq=%d, err=%d\n",
-			   __func__, self->io.irq, error);
+		pr_debug("%s(), unable to allocate irq=%d, err=%d\n",
+			 __func__, self->io.irq, error);
 
 	return error;
 }
@@ -1696,21 +1696,21 @@ static int smsc_ircc_net_open(struct net_device *dev)
 	struct smsc_ircc_cb *self;
 	char hwname[16];
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	if (self->io.suspended) {
-		IRDA_DEBUG(0, "%s(), device is suspended\n", __func__);
+		pr_debug("%s(), device is suspended\n", __func__);
 		return -EAGAIN;
 	}
 
 	if (request_irq(self->io.irq, smsc_ircc_interrupt, 0, dev->name,
 			(void *) dev)) {
-		IRDA_DEBUG(0, "%s(), unable to allocate irq=%d\n",
-			   __func__, self->io.irq);
+		pr_debug("%s(), unable to allocate irq=%d\n",
+			 __func__, self->io.irq);
 		return -EAGAIN;
 	}
 
@@ -1753,7 +1753,7 @@ static int smsc_ircc_net_close(struct net_device *dev)
 {
 	struct smsc_ircc_cb *self;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
@@ -1784,7 +1784,7 @@ static int smsc_ircc_suspend(struct platform_device *dev, pm_message_t state)
 	struct smsc_ircc_cb *self = platform_get_drvdata(dev);
 
 	if (!self->io.suspended) {
-		IRDA_DEBUG(1, "%s, Suspending\n", driver_name);
+		pr_debug("%s, Suspending\n", driver_name);
 
 		rtnl_lock();
 		if (netif_running(self->netdev)) {
@@ -1805,7 +1805,7 @@ static int smsc_ircc_resume(struct platform_device *dev)
 	struct smsc_ircc_cb *self = platform_get_drvdata(dev);
 
 	if (self->io.suspended) {
-		IRDA_DEBUG(1, "%s, Waking up\n", driver_name);
+		pr_debug("%s, Waking up\n", driver_name);
 
 		rtnl_lock();
 		smsc_ircc_init_chip(self);
@@ -1836,7 +1836,7 @@ static int smsc_ircc_resume(struct platform_device *dev)
  */
 static int __exit smsc_ircc_close(struct smsc_ircc_cb *self)
 {
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -1848,13 +1848,13 @@ static int __exit smsc_ircc_close(struct smsc_ircc_cb *self)
 	smsc_ircc_stop_interrupts(self);
 
 	/* Release the PORTS that this driver is using */
-	IRDA_DEBUG(0, "%s(), releasing 0x%03x\n",  __func__,
-		   self->io.fir_base);
+	pr_debug("%s(), releasing 0x%03x\n",  __func__,
+		 self->io.fir_base);
 
 	release_region(self->io.fir_base, self->io.fir_ext);
 
-	IRDA_DEBUG(0, "%s(), releasing 0x%03x\n", __func__,
-		   self->io.sir_base);
+	pr_debug("%s(), releasing 0x%03x\n", __func__,
+		 self->io.sir_base);
 
 	release_region(self->io.sir_base, self->io.sir_ext);
 
@@ -1875,7 +1875,7 @@ static void __exit smsc_ircc_cleanup(void)
 {
 	int i;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	for (i = 0; i < 2; i++) {
 		if (dev_self[i])
@@ -1899,7 +1899,7 @@ static void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
 	struct net_device *dev;
 	int fir_base, sir_base;
 
-	IRDA_DEBUG(3, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1925,7 +1925,7 @@ static void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
 	/* Turn on interrups */
 	outb(UART_IER_RLSI | UART_IER_RDI |UART_IER_THRI, sir_base + UART_IER);
 
-	IRDA_DEBUG(3, "%s() - exit\n", __func__);
+	pr_debug("%s() - exit\n", __func__);
 
 	outb(0x00, fir_base + IRCC_MASTER);
 }
@@ -1935,7 +1935,7 @@ void smsc_ircc_sir_stop(struct smsc_ircc_cb *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(3, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 	iobase = self->io.sir_base;
 
 	/* Reset UART */
@@ -1961,7 +1961,7 @@ static void smsc_ircc_sir_write_wakeup(struct smsc_ircc_cb *self)
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	IRDA_DEBUG(4, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	iobase = self->io.sir_base;
 
@@ -1982,8 +1982,8 @@ static void smsc_ircc_sir_write_wakeup(struct smsc_ircc_cb *self)
 		 *  if we need to change the speed of the hardware
 		 */
 		if (self->new_speed) {
-			IRDA_DEBUG(5, "%s(), Changing speed to %d.\n",
-				   __func__, self->new_speed);
+			pr_debug("%s(), Changing speed to %d.\n",
+				 __func__, self->new_speed);
 			smsc_ircc_sir_wait_hw_transmitter_finish(self);
 			smsc_ircc_change_speed(self, self->new_speed);
 			self->new_speed = 0;
@@ -2123,7 +2123,7 @@ static void smsc_ircc_sir_wait_hw_transmitter_finish(struct smsc_ircc_cb *self)
 		udelay(1);
 
 	if (count < 0)
-		IRDA_DEBUG(0, "%s(): stuck transmitter\n", __func__);
+		pr_debug("%s(): stuck transmitter\n", __func__);
 }
 
 
@@ -2184,7 +2184,7 @@ static int __init smsc_superio_flat(const struct smsc_chip *chips, unsigned shor
 	u8 mode, dma, irq;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	if (smsc_ircc_probe(cfgbase, SMSCSIOFLAT_DEVICEID_REG, chips, type) == NULL)
 		return ret;
@@ -2235,7 +2235,7 @@ static int __init smsc_superio_paged(const struct smsc_chip *chips, unsigned sho
 	unsigned short fir_io, sir_io;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	if (smsc_ircc_probe(cfg_base, 0x20, chips, type) == NULL)
 		return ret;
@@ -2269,7 +2269,7 @@ static int __init smsc_superio_paged(const struct smsc_chip *chips, unsigned sho
 
 static int __init smsc_access(unsigned short cfg_base, unsigned char reg)
 {
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	outb(reg, cfg_base);
 	return inb(cfg_base) != reg ? -1 : 0;
@@ -2279,7 +2279,7 @@ static const struct smsc_chip * __init smsc_ircc_probe(unsigned short cfg_base,
 {
 	u8 devid, xdevid, rev;
 
-	IRDA_DEBUG(1, "%s\n", __func__);
+	pr_debug("%s\n", __func__);
 
 	/* Leave configuration */
 
@@ -2534,9 +2534,8 @@ static int __init preconfigure_smsc_chip(struct
 	outb(LPC47N227_CFGACCESSKEY, iobase); // enter configuration state
 	outb(SMSCSIOFLAT_DEVICEID_REG, iobase); // set for device ID
 	tmpbyte = inb(iobase +1); // Read device ID
-	IRDA_DEBUG(0,
-		   "Detected Chip id: 0x%02x, setting up registers...\n",
-		   tmpbyte);
+	pr_debug("Detected Chip id: 0x%02x, setting up registers...\n",
+		 tmpbyte);
 
 	/* Disable UART1 and set up SIR I/O port */
 	outb(0x24, iobase);  // select CR24 - UART1 base addr
@@ -2682,7 +2681,7 @@ static int __init preconfigure_through_82801(struct pci_dev *dev,
 	default:
 		tmpbyte |= 0x01; /* COM2 default */
 	}
-	IRDA_DEBUG(1, "COM_DEC (write): 0x%02x\n", tmpbyte);
+	pr_debug("COM_DEC (write): 0x%02x\n", tmpbyte);
 	pci_write_config_byte(dev, COM_DEC, tmpbyte);
 
 	/* Enable Low Pin Count interface */
@@ -2710,7 +2709,7 @@ static int __init preconfigure_through_82801(struct pci_dev *dev,
 	}
 	tmpword &= 0xfffd; /* disable LPC COMB */
 	tmpword |= 0x0001; /* set bit 0 : enable LPC COMA addr range (GEN2) */
-	IRDA_DEBUG(1, "LPC_EN (write): 0x%04x\n", tmpword);
+	pr_debug("LPC_EN (write): 0x%04x\n", tmpword);
 	pci_write_config_word(dev, LPC_EN, tmpword);
 
 	/*
@@ -2755,7 +2754,7 @@ static int __init preconfigure_through_82801(struct pci_dev *dev,
 	default:
 		break; /* do not change settings */
 	}
-	IRDA_DEBUG(1, "PCI_DMA_C (write): 0x%04x\n", tmpword);
+	pr_debug("PCI_DMA_C (write): 0x%04x\n", tmpword);
 	pci_write_config_word(dev, PCI_DMA_C, tmpword);
 
 	/*
@@ -2766,7 +2765,7 @@ static int __init preconfigure_through_82801(struct pci_dev *dev,
 	 */
 	tmpword = conf->fir_io & 0xfff8;
 	tmpword |= 0x0001;
-	IRDA_DEBUG(1, "GEN2_DEC (write): 0x%04x\n", tmpword);
+	pr_debug("GEN2_DEC (write): 0x%04x\n", tmpword);
 	pci_write_config_word(dev, GEN2_DEC, tmpword);
 
 	/* Pre-configure chip */
diff --git a/drivers/net/irda/tekram-sir.c b/drivers/net/irda/tekram-sir.c
index 04db4ea..9dcf0c1 100644
--- a/drivers/net/irda/tekram-sir.c
+++ b/drivers/net/irda/tekram-sir.c
@@ -63,8 +63,8 @@ static int __init tekram_sir_init(void)
 {
 	if (tekram_delay < 1  ||  tekram_delay > 500)
 		tekram_delay = 200;
-	IRDA_DEBUG(1, "%s - using %d ms delay\n",
-		tekram.driver_name, tekram_delay);
+	pr_debug("%s - using %d ms delay\n",
+		 tekram.driver_name, tekram_delay);
 	return irda_register_dongle(&tekram);
 }
 
@@ -77,8 +77,6 @@ static int tekram_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
@@ -92,8 +90,6 @@ static int tekram_open(struct sir_dev *dev)
 
 static int tekram_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
@@ -130,8 +126,6 @@ static int tekram_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 byte;
 	static int ret = 0;
 	
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	switch(state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
 
@@ -205,8 +199,6 @@ static int tekram_change_speed(struct sir_dev *dev, unsigned speed)
 
 static int tekram_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Clear DTR, Set RTS */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE); 
 
diff --git a/drivers/net/irda/toim3232-sir.c b/drivers/net/irda/toim3232-sir.c
index 19ad460..6d2f559 100644
--- a/drivers/net/irda/toim3232-sir.c
+++ b/drivers/net/irda/toim3232-sir.c
@@ -168,8 +168,8 @@ static int __init toim3232_sir_init(void)
 {
 	if (toim3232delay < 1  ||  toim3232delay > 500)
 		toim3232delay = 200;
-	IRDA_DEBUG(1, "%s - using %d ms delay\n",
-		toim3232.driver_name, toim3232delay);
+	pr_debug("%s - using %d ms delay\n",
+		 toim3232.driver_name, toim3232delay);
 	return irda_register_dongle(&toim3232);
 }
 
@@ -182,8 +182,6 @@ static int toim3232_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Pull the lines high to start with.
 	 *
 	 * For the IR320ST-2, we need to charge the main supply capacitor to
@@ -210,8 +208,6 @@ static int toim3232_open(struct sir_dev *dev)
 
 static int toim3232_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
@@ -242,8 +238,6 @@ static int toim3232_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 byte;
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	switch(state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
 
@@ -345,8 +339,6 @@ static int toim3232_change_speed(struct sir_dev *dev, unsigned speed)
 
 static int toim3232_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Switch off both DTR and RTS to switch off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
 
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index b07b4cc..6960d4c 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -144,12 +144,10 @@ static int __init via_ircc_init(void)
 {
 	int rc;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	rc = pci_register_driver(&via_driver);
 	if (rc < 0) {
-		IRDA_DEBUG(0, "%s(): error rc = %d, returning  -ENODEV...\n",
-			   __func__, rc);
+		pr_debug("%s(): error rc = %d, returning  -ENODEV...\n",
+			 __func__, rc);
 		return -ENODEV;
 	}
 	return 0;
@@ -162,11 +160,11 @@ static int via_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 	u16 Chipset,FirDRQ1,FirDRQ0,FirIRQ,FirIOBase;
 	chipio_t info;
 
-	IRDA_DEBUG(2, "%s(): Device ID=(0X%X)\n", __func__, id->device);
+	pr_debug("%s(): Device ID=(0X%X)\n", __func__, id->device);
 
 	rc = pci_enable_device (pcidev);
 	if (rc) {
-		IRDA_DEBUG(0, "%s(): error rc = %d\n", __func__, rc);
+		pr_debug("%s(): error rc = %d\n", __func__, rc);
 		return -ENODEV;
 	}
 
@@ -177,7 +175,7 @@ static int via_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 		Chipset=0x3076;
 
 	if (Chipset==0x3076) {
-		IRDA_DEBUG(2, "%s(): Chipset = 3076\n", __func__);
+		pr_debug("%s(): Chipset = 3076\n", __func__);
 
 		WriteLPCReg(7,0x0c );
 		temp=ReadLPCReg(0x30);//check if BIOS Enable Fir
@@ -213,7 +211,7 @@ static int via_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 		} else
 			rc = -ENODEV; //IR not turn on	 
 	} else { //Not VT1211
-		IRDA_DEBUG(2, "%s(): Chipset = 3096\n", __func__);
+		pr_debug("%s(): Chipset = 3096\n", __func__);
 
 		pci_read_config_byte(pcidev,0x67,&bTmp);//check if BIOS Enable Fir
 		if((bTmp&0x01)==1) {  // BIOS enable FIR
@@ -252,14 +250,12 @@ static int via_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 			rc = -ENODEV; //IR not turn on !!!!!
 	}//Not VT1211
 
-	IRDA_DEBUG(2, "%s(): End - rc = %d\n", __func__, rc);
+	pr_debug("%s(): End - rc = %d\n", __func__, rc);
 	return rc;
 }
 
 static void __exit via_ircc_cleanup(void)
 {
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	/* Cleanup all instances of the driver */
 	pci_unregister_driver (&via_driver); 
 }
@@ -289,8 +285,6 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
 	struct via_ircc_cb *self;
 	int err;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	/* Allocate new instance of the driver */
 	dev = alloc_irdadev(sizeof(struct via_ircc_cb));
 	if (dev == NULL) 
@@ -316,8 +310,8 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
 
 	/* Reserve the ioports that we need */
 	if (!request_region(self->io.fir_base, self->io.fir_ext, driver_name)) {
-		IRDA_DEBUG(0, "%s(), can't get iobase of 0x%03x\n",
-			   __func__, self->io.fir_base);
+		pr_debug("%s(), can't get iobase of 0x%03x\n",
+			 __func__, self->io.fir_base);
 		err = -ENODEV;
 		goto err_out1;
 	}
@@ -423,8 +417,6 @@ static void via_remove_one(struct pci_dev *pdev)
 	struct via_ircc_cb *self = pci_get_drvdata(pdev);
 	int iobase;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	iobase = self->io.fir_base;
 
 	ResetChip(iobase, 5);	//hardware reset.
@@ -432,8 +424,8 @@ static void via_remove_one(struct pci_dev *pdev)
 	unregister_netdev(self->netdev);
 
 	/* Release the PORT that this driver is using */
-	IRDA_DEBUG(2, "%s(), Releasing Region %03x\n",
-		   __func__, self->io.fir_base);
+	pr_debug("%s(), Releasing Region %03x\n",
+		 __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 	if (self->tx_buff.head)
 		dma_free_coherent(&pdev->dev, self->tx_buff.truesize,
@@ -458,8 +450,6 @@ static void via_hw_init(struct via_ircc_cb *self)
 {
 	int iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	SetMaxRxPacketSize(iobase, 0x0fff);	//set to max:4095
 	// FIFO Init
 	EnRXFIFOReadyInt(iobase, OFF);
@@ -528,8 +518,8 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 	/* speed is unused, as we use IsSIROn()/IsMIROn() */
 	speed = speed;
 
-	IRDA_DEBUG(1, "%s(): change_dongle_speed to %d for 0x%x, %d\n",
-		   __func__, speed, iobase, dongle_id);
+	pr_debug("%s(): change_dongle_speed to %d for 0x%x, %d\n",
+		 __func__, speed, iobase, dongle_id);
 
 	switch (dongle_id) {
 
@@ -618,7 +608,8 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 
 	case 0x11:		/* Temic TFDS4500 */
 
-		IRDA_DEBUG(2, "%s: Temic TFDS4500: One RX pin, TX normal, RX inverted.\n", __func__);
+		pr_debug("%s: Temic TFDS4500: One RX pin, TX normal, RX inverted\n",
+			 __func__);
 
 		UseOneRX(iobase, ON);	//use ONE RX....RX1
 		InvertTX(iobase, OFF);
@@ -636,7 +627,8 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 			SlowIRRXLowActive(iobase, OFF);
 
 		} else{
-			IRDA_DEBUG(0, "%s: Warning: TFDS4500 not running in SIR mode !\n", __func__);
+			pr_debug("%s: Warning: TFDS4500 not running in SIR mode !\n",
+				 __func__);
 		}
 		break;
 
@@ -673,7 +665,7 @@ static void via_ircc_change_speed(struct via_ircc_cb *self, __u32 speed)
 	iobase = self->io.fir_base;
 	/* Update accounting for new speed */
 	self->io.speed = speed;
-	IRDA_DEBUG(1, "%s: change_speed to %d bps.\n", __func__, speed);
+	pr_debug("%s: change_speed to %d bps.\n", __func__, speed);
 
 	WriteReg(iobase, I_ST_CT_0, 0x0);
 
@@ -903,10 +895,10 @@ static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase)
 		       ((u8 *)self->tx_fifo.queue[self->tx_fifo.ptr].start -
 			self->tx_buff.head) + self->tx_buff_dma,
 		       self->tx_fifo.queue[self->tx_fifo.ptr].len, DMA_TX_MODE);
-	IRDA_DEBUG(1, "%s: tx_fifo.ptr=%x,len=%x,tx_fifo.len=%x..\n",
-		   __func__, self->tx_fifo.ptr,
-		   self->tx_fifo.queue[self->tx_fifo.ptr].len,
-		   self->tx_fifo.len);
+	pr_debug("%s: tx_fifo.ptr=%x,len=%x,tx_fifo.len=%x..\n",
+		 __func__, self->tx_fifo.ptr,
+		 self->tx_fifo.queue[self->tx_fifo.ptr].len,
+		 self->tx_fifo.len);
 
 	SetSendByte(iobase, self->tx_fifo.queue[self->tx_fifo.ptr].len);
 	RXStart(iobase, OFF);
@@ -927,8 +919,6 @@ static int via_ircc_dma_xmit_complete(struct via_ircc_cb *self)
 	int iobase;
 	u8 Tx_status;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	iobase = self->io.fir_base;
 	/* Disable DMA */
 //      DisableDmaChannel(self->io.dma);
@@ -958,10 +948,9 @@ static int via_ircc_dma_xmit_complete(struct via_ircc_cb *self)
 			self->tx_fifo.ptr++;
 		}
 	}
-	IRDA_DEBUG(1,
-		   "%s: tx_fifo.len=%x ,tx_fifo.ptr=%x,tx_fifo.free=%x...\n",
-		   __func__,
-		   self->tx_fifo.len, self->tx_fifo.ptr, self->tx_fifo.free);
+	pr_debug("%s: tx_fifo.len=%x ,tx_fifo.ptr=%x,tx_fifo.free=%x...\n",
+		 __func__,
+		 self->tx_fifo.len, self->tx_fifo.ptr, self->tx_fifo.free);
 /* F01_S
 	// Any frames to be sent back-to-back? 
 	if (self->tx_fifo.len) {
@@ -996,8 +985,6 @@ static int via_ircc_dma_receive(struct via_ircc_cb *self)
 
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	self->tx_fifo.len = self->tx_fifo.ptr = self->tx_fifo.free = 0;
 	self->tx_fifo.tail = self->tx_buff.head;
 	self->RxDataReady = 0;
@@ -1079,15 +1066,15 @@ static int via_ircc_dma_receive_complete(struct via_ircc_cb *self,
 		if (len == 0)
 			return TRUE;	//interrupt only, data maybe move by RxT  
 		if (((len - 4) < 2) || ((len - 4) > 2048)) {
-			IRDA_DEBUG(1, "%s(): Trouble:len=%x,CurCount=%x,LastCount=%x..\n",
-				   __func__, len, RxCurCount(iobase, self),
-				   self->RxLastCount);
+			pr_debug("%s(): Trouble:len=%x,CurCount=%x,LastCount=%x\n",
+				 __func__, len, RxCurCount(iobase, self),
+				 self->RxLastCount);
 			hwreset(self);
 			return FALSE;
 		}
-		IRDA_DEBUG(2, "%s(): fifo.len=%x,len=%x,CurCount=%x..\n",
-			   __func__,
-			   st_fifo->len, len - 4, RxCurCount(iobase, self));
+		pr_debug("%s(): fifo.len=%x,len=%x,CurCount=%x..\n",
+			 __func__,
+			 st_fifo->len, len - 4, RxCurCount(iobase, self));
 
 		st_fifo->entries[st_fifo->tail].status = status;
 		st_fifo->entries[st_fifo->tail].len = len;
@@ -1134,8 +1121,8 @@ F01_E */
 		skb_put(skb, len - 4);
 
 		skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4);
-		IRDA_DEBUG(2, "%s(): len=%x.rx_buff=%p\n", __func__,
-			   len - 4, self->rx_buff.data);
+		pr_debug("%s(): len=%x.rx_buff=%p\n", __func__,
+			 len - 4, self->rx_buff.data);
 
 		// Move to next frame 
 		self->rx_buff.data += len;
@@ -1164,7 +1151,7 @@ static int upload_rxdata(struct via_ircc_cb *self, int iobase)
 
 	len = GetRecvByte(iobase, self);
 
-	IRDA_DEBUG(2, "%s(): len=%x\n", __func__, len);
+	pr_debug("%s(): len=%x\n", __func__, len);
 
 	if ((len - 4) < 2) {
 		self->netdev->stats.rx_dropped++;
@@ -1249,8 +1236,8 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 			skb_put(skb, len - 4);
 			skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4);
 
-			IRDA_DEBUG(2, "%s(): len=%x.head=%x\n", __func__,
-				   len - 4, st_fifo->head);
+			pr_debug("%s(): len=%x.head=%x\n", __func__,
+				 len - 4, st_fifo->head);
 
 			// Move to next frame 
 			self->rx_buff.data += len;
@@ -1263,10 +1250,8 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 		}		//while
 		self->RetryCount = 0;
 
-		IRDA_DEBUG(2,
-			   "%s(): End of upload HostStatus=%x,RxStatus=%x\n",
-			   __func__,
-			   GetHostStatus(iobase), GetRXStatus(iobase));
+		pr_debug("%s(): End of upload HostStatus=%x,RxStatus=%x\n",
+			 __func__, GetHostStatus(iobase), GetRXStatus(iobase));
 
 		/*
 		 * if frame is receive complete at this routine ,then upload
@@ -1304,12 +1289,12 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 	spin_lock(&self->lock);
 	iHostIntType = GetHostStatus(iobase);
 
-	IRDA_DEBUG(4, "%s(): iHostIntType %02x:  %s %s %s  %02x\n",
-		   __func__, iHostIntType,
-		   (iHostIntType & 0x40) ? "Timer" : "",
-		   (iHostIntType & 0x20) ? "Tx" : "",
-		   (iHostIntType & 0x10) ? "Rx" : "",
-		   (iHostIntType & 0x0e) >> 1);
+	pr_debug("%s(): iHostIntType %02x:  %s %s %s  %02x\n",
+		 __func__, iHostIntType,
+		 (iHostIntType & 0x40) ? "Timer" : "",
+		 (iHostIntType & 0x20) ? "Tx" : "",
+		 (iHostIntType & 0x10) ? "Rx" : "",
+		 (iHostIntType & 0x0e) >> 1);
 
 	if ((iHostIntType & 0x40) != 0) {	//Timer Event
 		self->EventFlag.TimeOut++;
@@ -1334,12 +1319,12 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 	if ((iHostIntType & 0x20) != 0) {	//Tx Event
 		iTxIntType = GetTXStatus(iobase);
 
-		IRDA_DEBUG(4, "%s(): iTxIntType %02x:  %s %s %s %s\n",
-			   __func__, iTxIntType,
-			   (iTxIntType & 0x08) ? "FIFO underr." : "",
-			   (iTxIntType & 0x04) ? "EOM" : "",
-			   (iTxIntType & 0x02) ? "FIFO ready" : "",
-			   (iTxIntType & 0x01) ? "Early EOM" : "");
+		pr_debug("%s(): iTxIntType %02x:  %s %s %s %s\n",
+			 __func__, iTxIntType,
+			 (iTxIntType & 0x08) ? "FIFO underr." : "",
+			 (iTxIntType & 0x04) ? "EOM" : "",
+			 (iTxIntType & 0x02) ? "FIFO ready" : "",
+			 (iTxIntType & 0x01) ? "Early EOM" : "");
 
 		if (iTxIntType & 0x4) {
 			self->EventFlag.EOMessage++;	// read and will auto clean
@@ -1358,17 +1343,17 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 		/* Check if DMA has finished */
 		iRxIntType = GetRXStatus(iobase);
 
-		IRDA_DEBUG(4, "%s(): iRxIntType %02x:  %s %s %s %s %s %s %s\n",
-			   __func__, iRxIntType,
-			   (iRxIntType & 0x80) ? "PHY err."	: "",
-			   (iRxIntType & 0x40) ? "CRC err"	: "",
-			   (iRxIntType & 0x20) ? "FIFO overr."	: "",
-			   (iRxIntType & 0x10) ? "EOF"		: "",
-			   (iRxIntType & 0x08) ? "RxData"	: "",
-			   (iRxIntType & 0x02) ? "RxMaxLen"	: "",
-			   (iRxIntType & 0x01) ? "SIR bad"	: "");
+		pr_debug("%s(): iRxIntType %02x:  %s %s %s %s %s %s %s\n",
+			 __func__, iRxIntType,
+			 (iRxIntType & 0x80) ? "PHY err."	: "",
+			 (iRxIntType & 0x40) ? "CRC err"	: "",
+			 (iRxIntType & 0x20) ? "FIFO overr."	: "",
+			 (iRxIntType & 0x10) ? "EOF"		: "",
+			 (iRxIntType & 0x08) ? "RxData"		: "",
+			 (iRxIntType & 0x02) ? "RxMaxLen"	: "",
+			 (iRxIntType & 0x01) ? "SIR bad"	: "");
 		if (!iRxIntType)
-			IRDA_DEBUG(3, "%s(): RxIRQ =0\n", __func__);
+			pr_debug("%s(): RxIRQ =0\n", __func__);
 
 		if (iRxIntType & 0x10) {
 			if (via_ircc_dma_receive_complete(self, iobase)) {
@@ -1377,10 +1362,9 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 			}
 		}		// No ERR     
 		else {		//ERR
-			IRDA_DEBUG(4, "%s(): RxIRQ ERR:iRxIntType=%x,HostIntType=%x,CurCount=%x,RxLastCount=%x_____\n",
-				   __func__, iRxIntType, iHostIntType,
-				   RxCurCount(iobase, self),
-				   self->RxLastCount);
+			pr_debug("%s(): RxIRQ ERR:iRxIntType=%x,HostIntType=%x,CurCount=%x,RxLastCount=%x_____\n",
+				 __func__, iRxIntType, iHostIntType,
+				 RxCurCount(iobase, self), self->RxLastCount);
 
 			if (iRxIntType & 0x20) {	//FIFO OverRun ERR
 				ResetChip(iobase, 0);
@@ -1403,8 +1387,6 @@ static void hwreset(struct via_ircc_cb *self)
 	int iobase;
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	ResetChip(iobase, 5);
 	EnableDMA(iobase, OFF);
 	EnableTX(iobase, OFF);
@@ -1448,7 +1430,7 @@ static int via_ircc_is_receiving(struct via_ircc_cb *self)
 	if (CkRxRecv(iobase, self))
 		status = TRUE;
 
-	IRDA_DEBUG(2, "%s(): status=%x....\n", __func__, status);
+	pr_debug("%s(): status=%x....\n", __func__, status);
 
 	return status;
 }
@@ -1466,8 +1448,6 @@ static int via_ircc_net_open(struct net_device *dev)
 	int iobase;
 	char hwname[32];
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
 	dev->stats.rx_packets = 0;
@@ -1533,8 +1513,6 @@ static int via_ircc_net_close(struct net_device *dev)
 	struct via_ircc_cb *self;
 	int iobase;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
@@ -1577,8 +1555,8 @@ static int via_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq,
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return -1;);
-	IRDA_DEBUG(1, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name,
-		   cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name,
+		 cmd);
 	/* Disable interrupts & save flags */
 	spin_lock_irqsave(&self->lock, flags);
 	switch (cmd) {
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index fd4dede..ac39d9f 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -556,7 +556,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 	crclen = (idev->mode==IFF_FIR) ? sizeof(u32) : sizeof(u16);
 	len -= crclen;		/* remove trailing CRC */
 	if (len <= 0) {
-		IRDA_DEBUG(0, "%s: strange frame (len=%d)\n", __func__, len);
+		pr_debug("%s: strange frame (len=%d)\n", __func__, len);
 		ret |= VLSI_RX_DROP;
 		goto done;
 	}
@@ -571,7 +571,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 		 */
 		le16_to_cpus(rd->buf+len);
 		if (irda_calc_crc16(INIT_FCS,rd->buf,len+crclen) != GOOD_FCS) {
-			IRDA_DEBUG(0, "%s: crc error\n", __func__);
+			pr_debug("%s: crc error\n", __func__);
 			ret |= VLSI_RX_CRC;
 			goto done;
 		}
@@ -689,7 +689,7 @@ static void vlsi_unarm_rx(vlsi_irda_dev_t *idev)
 		if (rd_is_active(rd)) {
 			rd_set_status(rd, 0);
 			if (rd_get_count(rd)) {
-				IRDA_DEBUG(0, "%s - dropping rx packet\n", __func__);
+				pr_debug("%s - dropping rx packet\n", __func__);
 				ret = -VLSI_RX_DROP;
 			}
 			rd_set_count(rd, 0);
@@ -764,7 +764,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 	int	fifocnt;
 
 	baudrate = idev->new_baud;
-	IRDA_DEBUG(2, "%s: %d -> %d\n", __func__, idev->baud, idev->new_baud);
+	pr_debug("%s: %d -> %d\n", __func__, idev->baud, idev->new_baud);
 	if (baudrate == 4000000) {
 		mode = IFF_FIR;
 		config = IRCFG_FIR;
@@ -798,7 +798,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 
 	fifocnt = inw(iobase+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 	if (fifocnt != 0) {
-		IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __func__, fifocnt);
+		pr_debug("%s: rx fifo not empty(%d)\n", __func__, fifocnt);
 	}
 
 	outw(0, iobase+VLSI_PIO_IRENABLE);
@@ -1022,7 +1022,8 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 
 		fifocnt = inw(ndev->base_addr+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 		if (fifocnt != 0) {
-			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __func__, fifocnt);
+			pr_debug("%s: rx fifo not empty(%d)\n",
+				 __func__, fifocnt);
 		}
 
 		config = inw(iobase+VLSI_PIO_IRCFG);
@@ -1034,7 +1035,7 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 
 	if (ring_put(r) == NULL) {
 		netif_stop_queue(ndev);
-		IRDA_DEBUG(3, "%s: tx ring full - queue stopped\n", __func__);
+		pr_debug("%s: tx ring full - queue stopped\n", __func__);
 	}
 	spin_unlock_irqrestore(&idev->lock, flags);
 
@@ -1099,8 +1100,8 @@ static void vlsi_tx_interrupt(struct net_device *ndev)
 
 		fifocnt = inw(iobase+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 		if (fifocnt != 0) {
-			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n",
-				__func__, fifocnt);
+			pr_debug("%s: rx fifo not empty(%d)\n",
+				 __func__, fifocnt);
 		}
 		outw(config | IRCFG_ENTX, iobase+VLSI_PIO_IRCFG);
 	}
@@ -1109,7 +1110,7 @@ static void vlsi_tx_interrupt(struct net_device *ndev)
 
 	if (netif_queue_stopped(ndev)  &&  !idev->new_baud) {
 		netif_wake_queue(ndev);
-		IRDA_DEBUG(3, "%s: queue awoken\n", __func__);
+		pr_debug("%s: queue awoken\n", __func__);
 	}
 }
 
@@ -1133,7 +1134,7 @@ static void vlsi_unarm_tx(vlsi_irda_dev_t *idev)
 				dev_kfree_skb_any(rd->skb);
 				rd->skb = NULL;
 			}
-			IRDA_DEBUG(0, "%s - dropping tx packet\n", __func__);
+			pr_debug("%s - dropping tx packet\n", __func__);
 			ret = -VLSI_TX_DROP;
 		}
 		else
@@ -1191,8 +1192,8 @@ static int vlsi_start_clock(struct pci_dev *pdev)
 			else			/* was: clksrc=0(auto) */
 				clksrc = 3;	/* fallback to 40MHz XCLK (OB800) */
 
-			IRDA_DEBUG(0, "%s: PLL not locked, fallback to clksrc=%d\n",
-				__func__, clksrc);
+			pr_debug("%s: PLL not locked, fallback to clksrc=%d\n",
+				 __func__, clksrc);
 		}
 		else
 			clksrc = 1;	/* got successful PLL lock */
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 86ca123..4e3d2e7 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -110,8 +110,6 @@ static int __init w83977af_init(void)
 {
         int i;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	for (i=0; i < ARRAY_SIZE(dev_self) && io[i] < 2000; i++) {
 		if (w83977af_open(i, io[i], irq[i], dma[i]) == 0)
 			return 0;
@@ -129,8 +127,6 @@ static void __exit w83977af_cleanup(void)
 {
 	int i;
 
-        IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			w83977af_close(dev_self[i]);
@@ -157,12 +153,10 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
         struct w83977af_ir *self;
 	int err;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	/* Lock the port that we need */
 	if (!request_region(iobase, CHIP_IO_EXTENT, driver_name)) {
-		IRDA_DEBUG(0, "%s(), can't get iobase of 0x%03x\n",
-		      __func__ , iobase);
+		pr_debug("%s(), can't get iobase of 0x%03x\n",
+			 __func__ , iobase);
 		return -ENODEV;
 	}
 
@@ -269,8 +263,6 @@ static int w83977af_close(struct w83977af_ir *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
         iobase = self->io.fir_base;
 
 #ifdef CONFIG_USE_W977_PNP
@@ -289,8 +281,8 @@ static int w83977af_close(struct w83977af_ir *self)
 	unregister_netdev(self->netdev);
 
 	/* Release the PORT that this driver is using */
-	IRDA_DEBUG(0 , "%s(), Releasing Region %03x\n", 
-	      __func__ , self->io.fir_base);
+	pr_debug("%s(), Releasing Region %03x\n",
+		 __func__ , self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -312,7 +304,6 @@ static int w83977af_probe(int iobase, int irq, int dma)
 	int i;
   	
  	for (i=0; i < 2; i++) {
-		IRDA_DEBUG( 0, "%s()\n", __func__ );
 #ifdef CONFIG_USE_W977_PNP
  		/* Enter PnP configuration mode */
 		w977_efm_enter(efbase[i]);
@@ -399,7 +390,7 @@ static int w83977af_probe(int iobase, int irq, int dma)
 			return 0;
 		} else {
 			/* Try next extented function register address */
-			IRDA_DEBUG( 0, "%s(), Wrong chip version", __func__ );
+			pr_debug("%s(), Wrong chip version", __func__);
 		}
   	}   	
 	return -1;
@@ -435,19 +426,19 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 	case 115200: outb(0x01, iobase+ABLL); break;
 	case 576000:
 		ir_mode = HCR_MIR_576;
-		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __func__ );
+		pr_debug("%s(), handling baud of 576000\n", __func__);
 		break;
 	case 1152000:
 		ir_mode = HCR_MIR_1152;
-		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n", __func__ );
+		pr_debug("%s(), handling baud of 1152000\n", __func__);
 		break;
 	case 4000000:
 		ir_mode = HCR_FIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n", __func__ );
+		pr_debug("%s(), handling baud of 4000000\n", __func__);
 		break;
 	default:
 		ir_mode = HCR_FIR;
-		IRDA_DEBUG(0, "%s(), unknown baud rate of %d\n", __func__ , speed);
+		pr_debug("%s(), unknown baud rate of %d\n", __func__ , speed);
 		break;
 	}
 
@@ -498,8 +489,8 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(4, "%s(%ld), skb->len=%d\n", __func__ , jiffies,
-		   (int) skb->len);
+	pr_debug("%s(%ld), skb->len=%d\n", __func__ , jiffies,
+		 (int)skb->len);
 	
 	/* Lock transmit buffer */
 	netif_stop_queue(dev);
@@ -526,7 +517,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 		self->tx_buff.len = skb->len;
 		
 		mtt = irda_get_mtt(skb);
-			IRDA_DEBUG(4, "%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
+		pr_debug("%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
 			if (mtt)
 				udelay(mtt);
 
@@ -560,7 +551,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 {
 	__u8 set;
-        IRDA_DEBUG(4, "%s(), len=%d\n", __func__ , self->tx_buff.len);
+	pr_debug("%s(), len=%d\n", __func__ , self->tx_buff.len);
 
 	/* Save current set */
 	set = inb(iobase+SSR);
@@ -595,19 +586,16 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	int actual = 0;
 	__u8 set;
 	
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	/* Save current bank */
 	set = inb(iobase+SSR);
 
 	switch_bank(iobase, SET0);
 	if (!(inb_p(iobase+USR) & USR_TSRE)) {
-		IRDA_DEBUG(4,
-			   "%s(), warning, FIFO not empty yet!\n", __func__  );
+		pr_debug("%s(), warning, FIFO not empty yet!\n", __func__);
 
 		fifo_size -= 17;
-		IRDA_DEBUG(4, "%s(), %d bytes left in tx fifo\n", 
-			   __func__ , fifo_size);
+		pr_debug("%s(), %d bytes left in tx fifo\n",
+			 __func__ , fifo_size);
 	}
 
 	/* Fill FIFO with current frame */
@@ -616,8 +604,8 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 		outb(buf[actual++], iobase+TBR);
 	}
         
-	IRDA_DEBUG(4, "%s(), fifo_size %d ; %d sent of %d\n", 
-		   __func__ , fifo_size, actual, len);
+	pr_debug("%s(), fifo_size %d ; %d sent of %d\n",
+		 __func__ , fifo_size, actual, len);
 
 	/* Restore bank */
 	outb(set, iobase+SSR);
@@ -637,7 +625,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	int iobase;
 	__u8 set;
 
-	IRDA_DEBUG(4, "%s(%ld)\n", __func__ , jiffies);
+	pr_debug("%s(%ld)\n", __func__ , jiffies);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -652,7 +640,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	
 	/* Check for underrun! */
 	if (inb(iobase+AUDR) & AUDR_UNDR) {
-		IRDA_DEBUG(0, "%s(), Transmit underrun!\n", __func__ );
+		pr_debug("%s(), Transmit underrun!\n", __func__);
 		
 		self->netdev->stats.tx_errors++;
 		self->netdev->stats.tx_fifo_errors++;
@@ -693,7 +681,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 #endif
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(4, "%s\n", __func__ );
+	pr_debug("%s\n", __func__);
 
 	iobase= self->io.fir_base;
 
@@ -764,7 +752,7 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 	__u8 set;
 	__u8 status;
 
-	IRDA_DEBUG(4, "%s\n", __func__ );
+	pr_debug("%s\n", __func__);
 
 	st_fifo = &self->st_fifo;
 
@@ -881,8 +869,6 @@ static void w83977af_pio_receive(struct w83977af_ir *self)
 	__u8 byte = 0x00;
 	int iobase;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	
 	iobase = self->io.fir_base;
@@ -908,7 +894,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 	__u8 set;
 	int iobase;
 
-	IRDA_DEBUG(4, "%s(), isr=%#x\n", __func__ , isr);
+	pr_debug("%s(), isr=%#x\n", __func__ , isr);
 	
 	iobase = self->io.fir_base;
 	/* Transmit FIFO low on data */
@@ -944,8 +930,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 	if (isr & ISR_TXEMP_I) {		
 		/* Check if we need to change the speed? */
 		if (self->new_speed) {
-			IRDA_DEBUG(2,
-				   "%s(), Changing speed!\n", __func__ );
+			pr_debug("%s(), Changing speed!\n", __func__);
 			w83977af_change_speed(self, self->new_speed);
 			self->new_speed = 0;
 		}
@@ -1127,7 +1112,6 @@ static int w83977af_net_open(struct net_device *dev)
 	char hwname[32];
 	__u8 set;
 	
-	IRDA_DEBUG(0, "%s()\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
@@ -1190,8 +1174,6 @@ static int w83977af_net_close(struct net_device *dev)
 	int iobase;
 	__u8 set;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
 	self = netdev_priv(dev);
@@ -1245,7 +1227,7 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
 	
 	spin_lock_irqsave(&self->lock, flags);
 
diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index 4ff18bd..92c8fb5 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -55,16 +55,6 @@ typedef __u32 magic_t;
 #endif
 
 #ifdef CONFIG_IRDA_DEBUG
-
-extern unsigned int irda_debug;
-
-/* use 0 for production, 1 for verification, >2 for debug */
-#define IRDA_DEBUG_LEVEL 0
-
-#define IRDA_DEBUG(n, args...) \
-do {	if (irda_debug >= (n)) \
-		printk(KERN_DEBUG args); \
-} while (0)
 #define IRDA_ASSERT(expr, func) \
 do { if(!(expr)) { \
 	printk( "Assertion failed! %s:%s:%d %s\n", \
@@ -72,7 +62,6 @@ do { if(!(expr)) { \
 	func } } while (0)
 #define IRDA_ASSERT_LABEL(label)	label
 #else
-#define IRDA_DEBUG(n, args...) do { } while (0)
 #define IRDA_ASSERT(expr, func) do { (void)(expr); } while (0)
 #define IRDA_ASSERT_LABEL(label)
 #endif /* CONFIG_IRDA_DEBUG */
diff --git a/include/net/irda/irlap.h b/include/net/irda/irlap.h
index fb4b76d..6f23e82 100644
--- a/include/net/irda/irlap.h
+++ b/include/net/irda/irlap.h
@@ -303,7 +303,7 @@ static inline void irlap_next_state(struct irlap_cb *self, IRLAP_STATE state)
 	if (!self || self->magic != LAP_MAGIC)
 		return;
 
-	IRDA_DEBUG(4, "next LAP state = %s\n", irlap_state[state]);
+		pr_debug("next LAP state = %s\n", irlap_state[state]);
 	*/
 	self->state = state;
 }
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 4b04ae0..31f70a8 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -84,14 +84,12 @@ static int irda_data_indication(void *instance, void *sap, struct sk_buff *skb)
 	struct sock *sk;
 	int err;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	self = instance;
 	sk = instance;
 
 	err = sock_queue_rcv_skb(sk, skb);
 	if (err) {
-		IRDA_DEBUG(1, "%s(), error: no more mem!\n", __func__);
+		pr_debug("%s(), error: no more mem!\n", __func__);
 		self->rx_flow = FLOW_STOP;
 
 		/* When we return error, TTP will need to requeue the skb */
@@ -115,7 +113,7 @@ static void irda_disconnect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	/* Don't care about it, but let's not leak it */
 	if(skb)
@@ -123,8 +121,8 @@ static void irda_disconnect_indication(void *instance, void *sap,
 
 	sk = instance;
 	if (sk == NULL) {
-		IRDA_DEBUG(0, "%s(%p) : BUG : sk is NULL\n",
-			   __func__, self);
+		pr_debug("%s(%p) : BUG : sk is NULL\n",
+			 __func__, self);
 		return;
 	}
 
@@ -180,7 +178,7 @@ static void irda_connect_confirm(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	sk = instance;
 	if (sk == NULL) {
@@ -219,8 +217,8 @@ static void irda_connect_confirm(void *instance, void *sap,
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
 	}
 
-	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __func__,
-		   self->max_data_size);
+	pr_debug("%s(), max_data_size=%d\n", __func__,
+		 self->max_data_size);
 
 	memcpy(&self->qos_tx, qos, sizeof(struct qos_info));
 
@@ -244,7 +242,7 @@ static void irda_connect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	sk = instance;
 	if (sk == NULL) {
@@ -282,8 +280,8 @@ static void irda_connect_indication(void *instance, void *sap,
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
 	}
 
-	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __func__,
-		   self->max_data_size);
+	pr_debug("%s(), max_data_size=%d\n", __func__,
+		 self->max_data_size);
 
 	memcpy(&self->qos_tx, qos, sizeof(struct qos_info));
 
@@ -301,12 +299,10 @@ static void irda_connect_response(struct irda_sock *self)
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER, GFP_KERNEL);
 	if (skb == NULL) {
-		IRDA_DEBUG(0, "%s() Unable to allocate sk_buff!\n",
-			   __func__);
+		pr_debug("%s() Unable to allocate sk_buff!\n",
+			 __func__);
 		return;
 	}
 
@@ -327,26 +323,24 @@ static void irda_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 	struct irda_sock *self;
 	struct sock *sk;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	self = instance;
 	sk = instance;
 	BUG_ON(sk == NULL);
 
 	switch (flow) {
 	case FLOW_STOP:
-		IRDA_DEBUG(1, "%s(), IrTTP wants us to slow down\n",
-			   __func__);
+		pr_debug("%s(), IrTTP wants us to slow down\n",
+			 __func__);
 		self->tx_flow = flow;
 		break;
 	case FLOW_START:
 		self->tx_flow = flow;
-		IRDA_DEBUG(1, "%s(), IrTTP wants us to start again\n",
-			   __func__);
+		pr_debug("%s(), IrTTP wants us to start again\n",
+			 __func__);
 		wake_up_interruptible(sk_sleep(sk));
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown flow command!\n", __func__);
+		pr_debug("%s(), Unknown flow command!\n", __func__);
 		/* Unknown flow command, better stop */
 		self->tx_flow = flow;
 		break;
@@ -372,7 +366,7 @@ static void irda_getvalue_confirm(int result, __u16 obj_id,
 		return;
 	}
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	/* We probably don't need to make any more queries */
 	iriap_close(self->iriap);
@@ -380,8 +374,8 @@ static void irda_getvalue_confirm(int result, __u16 obj_id,
 
 	/* Check if request succeeded */
 	if (result != IAS_SUCCESS) {
-		IRDA_DEBUG(1, "%s(), IAS query failed! (%d)\n", __func__,
-			   result);
+		pr_debug("%s(), IAS query failed! (%d)\n", __func__,
+			 result);
 
 		self->errno = result;	/* We really need it later */
 
@@ -413,8 +407,6 @@ static void irda_selective_discovery_indication(discinfo_t *discovery,
 {
 	struct irda_sock *self;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	self = priv;
 	if (!self) {
 		net_warn_ratelimited("%s: lost myself!\n", __func__);
@@ -440,8 +432,6 @@ static void irda_discovery_timeout(u_long priv)
 {
 	struct irda_sock *self;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	self = (struct irda_sock *) priv;
 	BUG_ON(self == NULL);
 
@@ -465,7 +455,7 @@ static int irda_open_tsap(struct irda_sock *self, __u8 tsap_sel, char *name)
 	notify_t notify;
 
 	if (self->tsap) {
-		IRDA_DEBUG(0, "%s: busy!\n", __func__);
+		pr_debug("%s: busy!\n", __func__);
 		return -EBUSY;
 	}
 
@@ -483,8 +473,8 @@ static int irda_open_tsap(struct irda_sock *self, __u8 tsap_sel, char *name)
 	self->tsap = irttp_open_tsap(tsap_sel, DEFAULT_INITIAL_CREDIT,
 				     &notify);
 	if (self->tsap == NULL) {
-		IRDA_DEBUG(0, "%s(), Unable to allocate TSAP!\n",
-			   __func__);
+		pr_debug("%s(), Unable to allocate TSAP!\n",
+			 __func__);
 		return -ENOMEM;
 	}
 	/* Remember which TSAP selector we actually got */
@@ -517,7 +507,7 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
 
 	self->lsap = irlmp_open_lsap(LSAP_CONNLESS, &notify, pid);
 	if (self->lsap == NULL) {
-		IRDA_DEBUG( 0, "%s(), Unable to allocate LSAP!\n", __func__);
+		pr_debug("%s(), Unable to allocate LSAP!\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -538,7 +528,7 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
  */
 static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 {
-	IRDA_DEBUG(2, "%s(%p, %s)\n", __func__, self, name);
+	pr_debug("%s(%p, %s)\n", __func__, self, name);
 
 	if (self->iriap) {
 		net_warn_ratelimited("%s(): busy with a previous query\n",
@@ -577,8 +567,8 @@ static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 	/* Get the remote TSAP selector */
 	switch (self->ias_result->type) {
 	case IAS_INTEGER:
-		IRDA_DEBUG(4, "%s() int=%d\n",
-			   __func__, self->ias_result->t.integer);
+		pr_debug("%s() int=%d\n",
+			 __func__, self->ias_result->t.integer);
 
 		if (self->ias_result->t.integer != -1)
 			self->dtsap_sel = self->ias_result->t.integer;
@@ -587,7 +577,7 @@ static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 		break;
 	default:
 		self->dtsap_sel = 0;
-		IRDA_DEBUG(0, "%s(), bad type!\n", __func__);
+		pr_debug("%s(), bad type!\n", __func__);
 		break;
 	}
 	if (self->ias_result)
@@ -625,7 +615,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 	__u32	daddr = DEV_ADDR_ANY;	/* Address we found the service on */
 	__u8	dtsap_sel = 0x0;	/* TSAP associated with it */
 
-	IRDA_DEBUG(2, "%s(), name=%s\n", __func__, name);
+	pr_debug("%s(), name=%s\n", __func__, name);
 
 	/* Ask lmp for the current discovery log
 	 * Note : we have to use irlmp_get_discoveries(), as opposed
@@ -646,8 +636,8 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 		/* Try the address in the log */
 		self->daddr = discoveries[i].daddr;
 		self->saddr = 0x0;
-		IRDA_DEBUG(1, "%s(), trying daddr = %08x\n",
-			   __func__, self->daddr);
+		pr_debug("%s(), trying daddr = %08x\n",
+			 __func__, self->daddr);
 
 		/* Query remote LM-IAS for this service */
 		err = irda_find_lsap_sel(self, name);
@@ -655,8 +645,8 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 		case 0:
 			/* We found the requested service */
 			if(daddr != DEV_ADDR_ANY) {
-				IRDA_DEBUG(1, "%s(), discovered service ''%s'' in two different devices !!!\n",
-					   __func__, name);
+				pr_debug("%s(), discovered service ''%s'' in two different devices !!!\n",
+					 __func__, name);
 				self->daddr = DEV_ADDR_ANY;
 				kfree(discoveries);
 				return -ENOTUNIQ;
@@ -670,7 +660,8 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 			break;
 		default:
 			/* Something bad did happen :-( */
-			IRDA_DEBUG(0, "%s(), unexpected IAS query failure\n", __func__);
+			pr_debug("%s(), unexpected IAS query failure\n",
+				 __func__);
 			self->daddr = DEV_ADDR_ANY;
 			kfree(discoveries);
 			return -EHOSTUNREACH;
@@ -681,8 +672,8 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 
 	/* Check out what we found */
 	if(daddr == DEV_ADDR_ANY) {
-		IRDA_DEBUG(1, "%s(), cannot discover service ''%s'' in any device !!!\n",
-			   __func__, name);
+		pr_debug("%s(), cannot discover service ''%s'' in any device !!!\n",
+			 __func__, name);
 		self->daddr = DEV_ADDR_ANY;
 		return -EADDRNOTAVAIL;
 	}
@@ -692,8 +683,8 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 	self->saddr = 0x0;
 	self->dtsap_sel = dtsap_sel;
 
-	IRDA_DEBUG(1, "%s(), discovered requested service ''%s'' at address %08x\n",
-		   __func__, name, self->daddr);
+	pr_debug("%s(), discovered requested service ''%s'' at address %08x\n",
+		 __func__, name, self->daddr);
 
 	return 0;
 }
@@ -725,8 +716,8 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 		saddr.sir_addr = self->saddr;
 	}
 
-	IRDA_DEBUG(1, "%s(), tsap_sel = %#x\n", __func__, saddr.sir_lsap_sel);
-	IRDA_DEBUG(1, "%s(), addr = %08x\n", __func__, saddr.sir_addr);
+	pr_debug("%s(), tsap_sel = %#x\n", __func__, saddr.sir_lsap_sel);
+	pr_debug("%s(), addr = %08x\n", __func__, saddr.sir_addr);
 
 	/* uaddr_len come to us uninitialised */
 	*uaddr_len = sizeof (struct sockaddr_irda);
@@ -746,8 +737,6 @@ static int irda_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	int err = -EOPNOTSUPP;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	lock_sock(sk);
 
 	if ((sk->sk_type != SOCK_STREAM) && (sk->sk_type != SOCK_SEQPACKET) &&
@@ -779,7 +768,7 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct irda_sock *self = irda_sk(sk);
 	int err;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	if (addr_len != sizeof(struct sockaddr_irda))
 		return -EINVAL;
@@ -792,7 +781,8 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		self->pid = addr->sir_lsap_sel;
 		err = -EOPNOTSUPP;
 		if (self->pid & 0x80) {
-			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __func__);
+			pr_debug("%s(), extension in PID not supp!\n",
+				 __func__);
 			goto out;
 		}
 		err = irda_open_lsap(self, self->pid);
@@ -845,8 +835,6 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sk_buff *skb;
 	int err;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	err = irda_create(sock_net(sk), newsock, sk->sk_protocol, 0);
 	if (err)
 		return err;
@@ -911,7 +899,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	new->tsap = irttp_dup(self->tsap, new);
 	err = -EPERM; /* value does not seem to make sense. -arnd */
 	if (!new->tsap) {
-		IRDA_DEBUG(0, "%s(), dup failed!\n", __func__);
+		pr_debug("%s(), dup failed!\n", __func__);
 		kfree_skb(skb);
 		goto out;
 	}
@@ -971,7 +959,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct irda_sock *self = irda_sk(sk);
 	int err;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	lock_sock(sk);
 	/* Don't allow connect for Ultra sockets */
@@ -1007,13 +995,13 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 		/* Try to find one suitable */
 		err = irda_discover_daddr_and_lsap_sel(self, addr->sir_name);
 		if (err) {
-			IRDA_DEBUG(0, "%s(), auto-connect failed!\n", __func__);
+			pr_debug("%s(), auto-connect failed!\n", __func__);
 			goto out;
 		}
 	} else {
 		/* Use the one provided by the user */
 		self->daddr = addr->sir_addr;
-		IRDA_DEBUG(1, "%s(), daddr = %08x\n", __func__, self->daddr);
+		pr_debug("%s(), daddr = %08x\n", __func__, self->daddr);
 
 		/* If we don't have a valid service name, we assume the
 		 * user want to connect on a specific LSAP. Prevent
@@ -1023,7 +1011,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 			/* Query remote LM-IAS using service name */
 			err = irda_find_lsap_sel(self, addr->sir_name);
 			if (err) {
-				IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
+				pr_debug("%s(), connect failed!\n", __func__);
 				goto out;
 			}
 		} else {
@@ -1048,7 +1036,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 				    self->saddr, self->daddr, NULL,
 				    self->max_sdu_size_rx, NULL);
 	if (err) {
-		IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
+		pr_debug("%s(), connect failed!\n", __func__);
 		goto out;
 	}
 
@@ -1100,8 +1088,6 @@ static int irda_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	struct irda_sock *self;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
 
@@ -1121,7 +1107,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol,
 		return -ENOMEM;
 
 	self = irda_sk(sk);
-	IRDA_DEBUG(2, "%s() : self is %p\n", __func__, self);
+	pr_debug("%s() : self is %p\n", __func__, self);
 
 	init_waitqueue_head(&self->query_wait);
 
@@ -1183,7 +1169,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol,
  */
 static void irda_destroy_socket(struct irda_sock *self)
 {
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	/* Unregister with IrLMP */
 	irlmp_unregister_client(self->ckey);
@@ -1220,8 +1206,6 @@ static int irda_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	if (sk == NULL)
 		return 0;
 
@@ -1288,7 +1272,7 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err = -EPIPE;
 
-	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
+	pr_debug("%s(), len=%zd\n", __func__, len);
 
 	/* Note : socket.c set MSG_EOR on SEQPACKET sockets */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_EOR | MSG_CMSG_COMPAT |
@@ -1324,8 +1308,8 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	/* Check that we don't send out too big frames */
 	if (len > self->max_data_size) {
-		IRDA_DEBUG(2, "%s(), Chopping frame from %zd to %d bytes!\n",
-			   __func__, len, self->max_data_size);
+		pr_debug("%s(), Chopping frame from %zd to %d bytes!\n",
+			 __func__, len, self->max_data_size);
 		len = self->max_data_size;
 	}
 
@@ -1349,7 +1333,7 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 	 */
 	err = irttp_data_request(self->tsap, skb);
 	if (err) {
-		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
+		pr_debug("%s(), err=%d\n", __func__, err);
 		goto out_err;
 	}
 
@@ -1380,8 +1364,6 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	size_t copied;
 	int err;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &err);
 	if (!skb)
@@ -1391,8 +1373,8 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	copied = skb->len;
 
 	if (copied > size) {
-		IRDA_DEBUG(2, "%s(), Received truncated frame (%zd < %zd)!\n",
-			   __func__, copied, size);
+		pr_debug("%s(), Received truncated frame (%zd < %zd)!\n",
+			 __func__, copied, size);
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
 	}
@@ -1408,7 +1390,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	 */
 	if (self->rx_flow == FLOW_STOP) {
 		if ((atomic_read(&sk->sk_rmem_alloc) << 2) <= sk->sk_rcvbuf) {
-			IRDA_DEBUG(2, "%s(), Starting IrTTP\n", __func__);
+			pr_debug("%s(), Starting IrTTP\n", __func__);
 			self->rx_flow = FLOW_START;
 			irttp_flow_request(self->tsap, FLOW_START);
 		}
@@ -1430,8 +1412,6 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 	int target, err;
 	long timeo;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	if ((err = sock_error(sk)) < 0)
 		return err;
 
@@ -1503,15 +1483,15 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 
 			/* put the skb back if we didn't use it up.. */
 			if (skb->len) {
-				IRDA_DEBUG(1, "%s(), back on q!\n",
-					   __func__);
+				pr_debug("%s(), back on q!\n",
+					 __func__);
 				skb_queue_head(&sk->sk_receive_queue, skb);
 				break;
 			}
 
 			kfree_skb(skb);
 		} else {
-			IRDA_DEBUG(0, "%s() questionable!?\n", __func__);
+			pr_debug("%s() questionable!?\n", __func__);
 
 			/* put message back and return */
 			skb_queue_head(&sk->sk_receive_queue, skb);
@@ -1527,7 +1507,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 	 */
 	if (self->rx_flow == FLOW_STOP) {
 		if ((atomic_read(&sk->sk_rmem_alloc) << 2) <= sk->sk_rcvbuf) {
-			IRDA_DEBUG(2, "%s(), Starting IrTTP\n", __func__);
+			pr_debug("%s(), Starting IrTTP\n", __func__);
 			self->rx_flow = FLOW_START;
 			irttp_flow_request(self->tsap, FLOW_START);
 		}
@@ -1551,7 +1531,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
-	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
+	pr_debug("%s(), len=%zd\n", __func__, len);
 
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
 		return -EINVAL;
@@ -1575,9 +1555,8 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	 * service, so we have no fragmentation and no coalescence
 	 */
 	if (len > self->max_data_size) {
-		IRDA_DEBUG(0, "%s(), Warning to much data! "
-			   "Chopping frame from %zd to %d bytes!\n",
-			   __func__, len, self->max_data_size);
+		pr_debug("%s(), Warning too much data! Chopping frame from %zd to %d bytes!\n",
+			 __func__, len, self->max_data_size);
 		len = self->max_data_size;
 	}
 
@@ -1590,7 +1569,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	skb_reserve(skb, self->max_header_size);
 	skb_reset_transport_header(skb);
 
-	IRDA_DEBUG(4, "%s(), appending user data\n", __func__);
+	pr_debug("%s(), appending user data\n", __func__);
 	skb_put(skb, len);
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
 	if (err) {
@@ -1604,7 +1583,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	 */
 	err = irttp_udata_request(self->tsap, skb);
 	if (err) {
-		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
+		pr_debug("%s(), err=%d\n", __func__, err);
 		goto out;
 	}
 
@@ -1633,7 +1612,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
-	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
+	pr_debug("%s(), len=%zd\n", __func__, len);
 
 	err = -EINVAL;
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
@@ -1661,7 +1640,8 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 
 		pid = addr->sir_lsap_sel;
 		if (pid & 0x80) {
-			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __func__);
+			pr_debug("%s(), extension in PID not supp!\n",
+				 __func__);
 			err = -EOPNOTSUPP;
 			goto out;
 		}
@@ -1670,8 +1650,8 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 		 * port. Jean II */
 		if ((self->lsap == NULL) ||
 		    (sk->sk_state != TCP_ESTABLISHED)) {
-			IRDA_DEBUG(0, "%s(), socket not bound to Ultra PID.\n",
-				   __func__);
+			pr_debug("%s(), socket not bound to Ultra PID.\n",
+				 __func__);
 			err = -ENOTCONN;
 			goto out;
 		}
@@ -1684,9 +1664,8 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	 * service, so we have no fragmentation and no coalescence
 	 */
 	if (len > self->max_data_size) {
-		IRDA_DEBUG(0, "%s(), Warning to much data! "
-			   "Chopping frame from %zd to %d bytes!\n",
-			   __func__, len, self->max_data_size);
+		pr_debug("%s(), Warning too much data! Chopping frame from %zd to %d bytes!\n",
+			 __func__, len, self->max_data_size);
 		len = self->max_data_size;
 	}
 
@@ -1699,7 +1678,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	skb_reserve(skb, self->max_header_size);
 	skb_reset_transport_header(skb);
 
-	IRDA_DEBUG(4, "%s(), appending user data\n", __func__);
+	pr_debug("%s(), appending user data\n", __func__);
 	skb_put(skb, len);
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
 	if (err) {
@@ -1710,7 +1689,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	err = irlmp_connless_data_request((bound ? self->lsap : NULL),
 					  skb, pid);
 	if (err)
-		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
+		pr_debug("%s(), err=%d\n", __func__, err);
 out:
 	release_sock(sk);
 	return err ? : len;
@@ -1725,7 +1704,7 @@ static int irda_shutdown(struct socket *sock, int how)
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
 
-	IRDA_DEBUG(1, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	lock_sock(sk);
 
@@ -1764,8 +1743,6 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	struct irda_sock *self = irda_sk(sk);
 	unsigned int mask;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
 
@@ -1773,13 +1750,13 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	if (sk->sk_err)
 		mask |= POLLERR;
 	if (sk->sk_shutdown & RCV_SHUTDOWN) {
-		IRDA_DEBUG(0, "%s(), POLLHUP\n", __func__);
+		pr_debug("%s(), POLLHUP\n", __func__);
 		mask |= POLLHUP;
 	}
 
 	/* Readable? */
 	if (!skb_queue_empty(&sk->sk_receive_queue)) {
-		IRDA_DEBUG(4, "Socket is readable\n");
+		pr_debug("Socket is readable\n");
 		mask |= POLLIN | POLLRDNORM;
 	}
 
@@ -1787,7 +1764,7 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	switch (sk->sk_type) {
 	case SOCK_STREAM:
 		if (sk->sk_state == TCP_CLOSE) {
-			IRDA_DEBUG(0, "%s(), POLLHUP\n", __func__);
+			pr_debug("%s(), POLLHUP\n", __func__);
 			mask |= POLLHUP;
 		}
 
@@ -1825,7 +1802,7 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	struct sock *sk = sock->sk;
 	int err;
 
-	IRDA_DEBUG(4, "%s(), cmd=%#x\n", __func__, cmd);
+	pr_debug("%s(), cmd=%#x\n", __func__, cmd);
 
 	err = -EINVAL;
 	switch (cmd) {
@@ -1866,7 +1843,7 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCSIFMETRIC:
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), doing device ioctl!\n", __func__);
+		pr_debug("%s(), doing device ioctl!\n", __func__);
 		err = -ENOIOCTLCMD;
 	}
 
@@ -1902,7 +1879,7 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 	struct ias_attrib *	ias_attr;	/* Attribute in IAS object */
 	int opt, free_ias = 0, err = 0;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	if (level != SOL_IRLMP)
 		return -ENOPROTOOPT;
@@ -2102,7 +2079,8 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 
 		/* Check is the user space own the object */
 		if(ias_attr->value->owner != IAS_USER_ATTR) {
-			IRDA_DEBUG(1, "%s(), attempting to delete a kernel attribute\n", __func__);
+			pr_debug("%s(), attempting to delete a kernel attribute\n",
+				 __func__);
 			kfree(ias_opt);
 			err = -EPERM;
 			goto out;
@@ -2125,8 +2103,8 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 
 		/* Only possible for a seqpacket service (TTP with SAR) */
 		if (sk->sk_type != SOCK_SEQPACKET) {
-			IRDA_DEBUG(2, "%s(), setting max_sdu_size = %d\n",
-				   __func__, opt);
+			pr_debug("%s(), setting max_sdu_size = %d\n",
+				 __func__, opt);
 			self->max_sdu_size_rx = opt;
 		} else {
 			net_warn_ratelimited("%s: not allowed to set MAXSDUSIZE for this socket type!\n",
@@ -2258,7 +2236,7 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 	int err = 0;
 	int offset, total;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
+	pr_debug("%s(%p)\n", __func__, self);
 
 	if (level != SOL_IRLMP)
 		return -ENOPROTOOPT;
@@ -2546,7 +2524,8 @@ bed:
 
 		/* Wait until a node is discovered */
 		if (!self->cachedaddr) {
-			IRDA_DEBUG(1, "%s(), nothing discovered yet, going to sleep...\n", __func__);
+			pr_debug("%s(), nothing discovered yet, going to sleep...\n",
+				 __func__);
 
 			/* Set watchdog timer to expire in <val> ms. */
 			self->errno = 0;
@@ -2562,14 +2541,14 @@ bed:
 			/* If watchdog is still activated, kill it! */
 			del_timer(&(self->watchdog));
 
-			IRDA_DEBUG(1, "%s(), ...waking up !\n", __func__);
+			pr_debug("%s(), ...waking up !\n", __func__);
 
 			if (err != 0)
 				goto out;
 		}
 		else
-			IRDA_DEBUG(1, "%s(), found immediately !\n",
-				   __func__);
+			pr_debug("%s(), found immediately !\n",
+				 __func__);
 
 		/* Tell IrLMP that we have been notified */
 		irlmp_update_client(self->ckey, self->mask.word,
diff --git a/net/irda/discovery.c b/net/irda/discovery.c
index 6786e7f..364d70a 100644
--- a/net/irda/discovery.c
+++ b/net/irda/discovery.c
@@ -112,8 +112,6 @@ void irlmp_add_discovery_log(hashbin_t *cachelog, hashbin_t *log)
 {
 	discovery_t *discovery;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	/*
 	 *  If log is missing this means that IrLAP was unable to perform the
 	 *  discovery, so restart discovery again with just the half timeout
@@ -159,8 +157,6 @@ void irlmp_expire_discoveries(hashbin_t *log, __u32 saddr, int force)
 	int			i = 0;		/* How many we expired */
 
 	IRDA_ASSERT(log != NULL, return;);
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	spin_lock_irqsave(&log->hb_spinlock, flags);
 
 	discovery = (discovery_t *) hashbin_get_first(log);
@@ -232,10 +228,10 @@ void irlmp_dump_discoveries(hashbin_t *log)
 
 	discovery = (discovery_t *) hashbin_get_first(log);
 	while (discovery != NULL) {
-		IRDA_DEBUG(0, "Discovery:\n");
-		IRDA_DEBUG(0, "  daddr=%08x\n", discovery->data.daddr);
-		IRDA_DEBUG(0, "  saddr=%08x\n", discovery->data.saddr);
-		IRDA_DEBUG(0, "  nickname=%s\n", discovery->data.info);
+		pr_debug("Discovery:\n");
+		pr_debug("  daddr=%08x\n", discovery->data.daddr);
+		pr_debug("  saddr=%08x\n", discovery->data.saddr);
+		pr_debug("  nickname=%s\n", discovery->data.info);
 
 		discovery = (discovery_t *) hashbin_get_next(log);
 	}
diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index b77fe8c..3af2195 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -91,8 +91,6 @@ static int __init ircomm_init(void)
 
 static void __exit ircomm_cleanup(void)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	hashbin_delete(ircomm, (FREE_FUNC) __ircomm_close);
 
 #ifdef CONFIG_PROC_FS
@@ -111,8 +109,8 @@ struct ircomm_cb *ircomm_open(notify_t *notify, __u8 service_type, int line)
 	struct ircomm_cb *self = NULL;
 	int ret;
 
-	IRDA_DEBUG(2, "%s(), service_type=0x%02x\n", __func__ ,
-		   service_type);
+	pr_debug("%s(), service_type=0x%02x\n", __func__ ,
+		 service_type);
 
 	IRDA_ASSERT(ircomm != NULL, return NULL;);
 
@@ -155,8 +153,6 @@ EXPORT_SYMBOL(ircomm_open);
  */
 static int __ircomm_close(struct ircomm_cb *self)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Disconnect link if any */
 	ircomm_do_event(self, IRCOMM_DISCONNECT_REQUEST, NULL, NULL);
 
@@ -191,8 +187,6 @@ int ircomm_close(struct ircomm_cb *self)
 	IRDA_ASSERT(self != NULL, return -EIO;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -EIO;);
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	entry = hashbin_remove(ircomm, self->line, NULL);
 
 	IRDA_ASSERT(entry == self, return -1;);
@@ -216,8 +210,6 @@ int ircomm_connect_request(struct ircomm_cb *self, __u8 dlsap_sel,
 	struct ircomm_info info;
 	int ret;
 
-	IRDA_DEBUG(2 , "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
 
@@ -243,8 +235,6 @@ EXPORT_SYMBOL(ircomm_connect_request);
 void ircomm_connect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 			       struct ircomm_info *info)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/*
 	 * If there are any data hiding in the control channel, we must
 	 * deliver it first. The side effect is that the control channel
@@ -255,7 +245,7 @@ void ircomm_connect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 						info->qos, info->max_data_size,
 						info->max_header_size, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
+		pr_debug("%s(), missing handler\n", __func__);
 	}
 }
 
@@ -272,8 +262,6 @@ int ircomm_connect_response(struct ircomm_cb *self, struct sk_buff *userdata)
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	ret = ircomm_do_event(self, IRCOMM_CONNECT_RESPONSE, userdata, NULL);
 
 	return ret;
@@ -290,15 +278,13 @@ EXPORT_SYMBOL(ircomm_connect_response);
 void ircomm_connect_confirm(struct ircomm_cb *self, struct sk_buff *skb,
 			    struct ircomm_info *info)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	if (self->notify.connect_confirm )
 		self->notify.connect_confirm(self->notify.instance,
 					     self, info->qos,
 					     info->max_data_size,
 					     info->max_header_size, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
+		pr_debug("%s(), missing handler\n", __func__);
 	}
 }
 
@@ -312,8 +298,6 @@ int ircomm_data_request(struct ircomm_cb *self, struct sk_buff *skb)
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -EFAULT;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -EFAULT;);
 	IRDA_ASSERT(skb != NULL, return -EFAULT;);
@@ -333,14 +317,12 @@ EXPORT_SYMBOL(ircomm_data_request);
  */
 void ircomm_data_indication(struct ircomm_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(skb->len > 0, return;);
 
 	if (self->notify.data_indication)
 		self->notify.data_indication(self->notify.instance, self, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
+		pr_debug("%s(), missing handler\n", __func__);
 	}
 }
 
@@ -365,8 +347,8 @@ void ircomm_process_data(struct ircomm_cb *self, struct sk_buff *skb)
 	 * fine
 	 */
 	if (unlikely(skb->len < (clen + 1))) {
-		IRDA_DEBUG(2, "%s() throwing away illegal frame\n",
-			   __func__ );
+		pr_debug("%s() throwing away illegal frame\n",
+			 __func__);
 		return;
 	}
 
@@ -384,8 +366,8 @@ void ircomm_process_data(struct ircomm_cb *self, struct sk_buff *skb)
 	if (skb->len)
 		ircomm_data_indication(self, skb);
 	else {
-		IRDA_DEBUG(4, "%s(), data was control info only!\n",
-			   __func__ );
+		pr_debug("%s(), data was control info only!\n",
+			 __func__);
 	}
 }
 
@@ -399,8 +381,6 @@ int ircomm_control_request(struct ircomm_cb *self, struct sk_buff *skb)
 {
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -EFAULT;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -EFAULT;);
 	IRDA_ASSERT(skb != NULL, return -EFAULT;);
@@ -421,8 +401,6 @@ EXPORT_SYMBOL(ircomm_control_request);
 static void ircomm_control_indication(struct ircomm_cb *self,
 				      struct sk_buff *skb, int clen)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Use udata for delivering data on the control channel */
 	if (self->notify.udata_indication) {
 		struct sk_buff *ctrl_skb;
@@ -442,7 +420,7 @@ static void ircomm_control_indication(struct ircomm_cb *self,
 		 * see ircomm_tty_control_indication(). */
 		dev_kfree_skb(ctrl_skb);
 	} else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
+		pr_debug("%s(), missing handler\n", __func__);
 	}
 }
 
@@ -457,8 +435,6 @@ int ircomm_disconnect_request(struct ircomm_cb *self, struct sk_buff *userdata)
 	struct ircomm_info info;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
 
@@ -478,15 +454,13 @@ EXPORT_SYMBOL(ircomm_disconnect_request);
 void ircomm_disconnect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 				  struct ircomm_info *info)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(info != NULL, return;);
 
 	if (self->notify.disconnect_indication) {
 		self->notify.disconnect_indication(self->notify.instance, self,
 						   info->reason, skb);
 	} else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
+		pr_debug("%s(), missing handler\n", __func__);
 	}
 }
 
@@ -498,8 +472,6 @@ void ircomm_disconnect_indication(struct ircomm_cb *self, struct sk_buff *skb,
  */
 void ircomm_flow_request(struct ircomm_cb *self, LOCAL_FLOW flow)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 
diff --git a/net/irda/ircomm/ircomm_event.c b/net/irda/ircomm/ircomm_event.c
index b172c65..0476da2 100644
--- a/net/irda/ircomm/ircomm_event.c
+++ b/net/irda/ircomm/ircomm_event.c
@@ -106,8 +106,8 @@ static int ircomm_state_idle(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ircomm_connect_indication(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(4, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -136,8 +136,8 @@ static int ircomm_state_waiti(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ircomm_disconnect_indication(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -169,8 +169,8 @@ static int ircomm_state_waitr(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ircomm_disconnect_indication(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event = %s\n", __func__ ,
-			   ircomm_event[event]);
+		pr_debug("%s(), unknown event = %s\n", __func__ ,
+			 ircomm_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -211,8 +211,8 @@ static int ircomm_state_conn(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ret = self->issue.disconnect_request(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event = %s\n", __func__ ,
-			   ircomm_event[event]);
+		pr_debug("%s(), unknown event = %s\n", __func__ ,
+			 ircomm_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -227,8 +227,8 @@ static int ircomm_state_conn(struct ircomm_cb *self, IRCOMM_EVENT event,
 int ircomm_do_event(struct ircomm_cb *self, IRCOMM_EVENT event,
 		    struct sk_buff *skb, struct ircomm_info *info)
 {
-	IRDA_DEBUG(4, "%s: state=%s, event=%s\n", __func__ ,
-		   ircomm_state[self->state], ircomm_event[event]);
+	pr_debug("%s: state=%s, event=%s\n", __func__ ,
+		 ircomm_state[self->state], ircomm_event[event]);
 
 	return (*state[self->state])(self, event, skb, info);
 }
@@ -243,6 +243,6 @@ void ircomm_next_state(struct ircomm_cb *self, IRCOMM_STATE state)
 {
 	self->state = state;
 
-	IRDA_DEBUG(4, "%s: next state=%s, service type=%d\n", __func__ ,
-		   ircomm_state[self->state], self->service_type);
+	pr_debug("%s: next state=%s, service type=%d\n", __func__ ,
+		 ircomm_state[self->state], self->service_type);
 }
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 05767e3..e4cc847 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -52,8 +52,6 @@ static int ircomm_lmp_connect_request(struct ircomm_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	/* Don't forget to refcount it - should be NULL anyway */
 	if(userdata)
 		skb_get(userdata);
@@ -74,8 +72,6 @@ static int ircomm_lmp_connect_response(struct ircomm_cb *self,
 {
 	struct sk_buff *tx_skb;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
 		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
@@ -107,8 +103,6 @@ static int ircomm_lmp_disconnect_request(struct ircomm_cb *self,
 	struct sk_buff *tx_skb;
 	int ret;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	if (!userdata) {
 		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
@@ -144,13 +138,11 @@ static void ircomm_lmp_flow_control(struct sk_buff *skb)
 
 	cb = (struct irda_skb_cb *) skb->cb;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	line = cb->line;
 
 	self = (struct ircomm_cb *) hashbin_lock_find(ircomm, line, NULL);
 	if (!self) {
-		IRDA_DEBUG(2, "%s(), didn't find myself\n", __func__ );
+		pr_debug("%s(), didn't find myself\n", __func__);
 		return;
 	}
 
@@ -160,7 +152,7 @@ static void ircomm_lmp_flow_control(struct sk_buff *skb)
 	self->pkt_count--;
 
 	if ((self->pkt_count < 2) && (self->flow_status == FLOW_STOP)) {
-		IRDA_DEBUG(2, "%s(), asking TTY to start again!\n", __func__ );
+		pr_debug("%s(), asking TTY to start again!\n", __func__);
 		self->flow_status = FLOW_START;
 		if (self->notify.flow_indication)
 			self->notify.flow_indication(self->notify.instance,
@@ -187,7 +179,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 
 	cb->line = self->line;
 
-	IRDA_DEBUG(4, "%s(), sending frame\n", __func__ );
+	pr_debug("%s(), sending frame\n", __func__);
 
 	/* Don't forget to refcount it - see ircomm_tty_do_softint() */
 	skb_get(skb);
@@ -196,7 +188,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 	skb->destructor = ircomm_lmp_flow_control;
 
 	if ((self->pkt_count++ > 7) && (self->flow_status == FLOW_START)) {
-		IRDA_DEBUG(2, "%s(), asking TTY to slow down!\n", __func__ );
+		pr_debug("%s(), asking TTY to slow down!\n", __func__);
 		self->flow_status = FLOW_STOP;
 		if (self->notify.flow_indication)
 			self->notify.flow_indication(self->notify.instance,
@@ -222,8 +214,6 @@ static int ircomm_lmp_data_indication(void *instance, void *sap,
 {
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
@@ -252,8 +242,6 @@ static void ircomm_lmp_connect_confirm(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -285,8 +273,6 @@ static void ircomm_lmp_connect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *)instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -315,8 +301,6 @@ static void ircomm_lmp_disconnect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 
@@ -338,8 +322,6 @@ int ircomm_open_lsap(struct ircomm_cb *self)
 {
 	notify_t notify;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	/* Register callbacks */
 	irda_notify_init(&notify);
 	notify.data_indication       = ircomm_lmp_data_indication;
@@ -351,7 +333,7 @@ int ircomm_open_lsap(struct ircomm_cb *self)
 
 	self->lsap = irlmp_open_lsap(LSAP_ANY, &notify, 0);
 	if (!self->lsap) {
-		IRDA_DEBUG(0,"%sfailed to allocate tsap\n", __func__ );
+		pr_debug("%sfailed to allocate tsap\n", __func__);
 		return -1;
 	}
 	self->slsap_sel = self->lsap->slsap_sel;
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index c203fbb..27be782 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -101,8 +101,6 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 	struct sk_buff *skb;
 	int count;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
@@ -139,7 +137,7 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 
 	spin_unlock_irqrestore(&self->spinlock, flags);
 
-	IRDA_DEBUG(2, "%s(), skb->len=%d\n", __func__ , skb->len);
+	pr_debug("%s(), skb->len=%d\n", __func__ , skb->len);
 
 	if (flush) {
 		/* ircomm_tty_do_softint will take care of the rest */
@@ -173,12 +171,11 @@ static int ircomm_param_service_type(void *instance, irda_param_t *param,
 	/* Find all common service types */
 	service_type &= self->service_type;
 	if (!service_type) {
-		IRDA_DEBUG(2,
-			   "%s(), No common service type to use!\n", __func__ );
+		pr_debug("%s(), No common service type to use!\n", __func__);
 		return -1;
 	}
-	IRDA_DEBUG(0, "%s(), services in common=%02x\n", __func__ ,
-		   service_type);
+	pr_debug("%s(), services in common=%02x\n", __func__ ,
+		 service_type);
 
 	/*
 	 * Now choose a preferred service type of those available
@@ -192,8 +189,8 @@ static int ircomm_param_service_type(void *instance, irda_param_t *param,
 	else if (service_type & IRCOMM_3_WIRE_RAW)
 		self->settings.service_type = IRCOMM_3_WIRE_RAW;
 
-	IRDA_DEBUG(0, "%s(), resulting service type=0x%02x\n", __func__ ,
-		   self->settings.service_type);
+	pr_debug("%s(), resulting service type=0x%02x\n", __func__ ,
+		 self->settings.service_type);
 
 	/*
 	 * Now the line is ready for some communication. Check if we are a
@@ -235,8 +232,8 @@ static int ircomm_param_port_type(void *instance, irda_param_t *param, int get)
 	else {
 		self->settings.port_type = (__u8) param->pv.i;
 
-		IRDA_DEBUG(0, "%s(), port type=%d\n", __func__ ,
-			   self->settings.port_type);
+		pr_debug("%s(), port type=%d\n", __func__ ,
+			 self->settings.port_type);
 	}
 	return 0;
 }
@@ -255,9 +252,9 @@ static int ircomm_param_port_name(void *instance, irda_param_t *param, int get)
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
 	if (get) {
-		IRDA_DEBUG(0, "%s(), not imp!\n", __func__ );
+		pr_debug("%s(), not imp!\n", __func__);
 	} else {
-		IRDA_DEBUG(0, "%s(), port-name=%s\n", __func__ , param->pv.c);
+		pr_debug("%s(), port-name=%s\n", __func__ , param->pv.c);
 		strncpy(self->settings.port_name, param->pv.c, 32);
 	}
 
@@ -282,7 +279,7 @@ static int ircomm_param_data_rate(void *instance, irda_param_t *param, int get)
 	else
 		self->settings.data_rate = param->pv.i;
 
-	IRDA_DEBUG(2, "%s(), data rate = %d\n", __func__ , param->pv.i);
+	pr_debug("%s(), data rate = %d\n", __func__ , param->pv.i);
 
 	return 0;
 }
@@ -328,7 +325,7 @@ static int ircomm_param_flow_control(void *instance, irda_param_t *param,
 	else
 		self->settings.flow_control = (__u8) param->pv.i;
 
-	IRDA_DEBUG(1, "%s(), flow control = 0x%02x\n", __func__ , (__u8) param->pv.i);
+	pr_debug("%s(), flow control = 0x%02x\n", __func__ , (__u8)param->pv.i);
 
 	return 0;
 }
@@ -354,8 +351,8 @@ static int ircomm_param_xon_xoff(void *instance, irda_param_t *param, int get)
 		self->settings.xonxoff[1] = (__u16) param->pv.i >> 8;
 	}
 
-	IRDA_DEBUG(0, "%s(), XON/XOFF = 0x%02x,0x%02x\n", __func__ ,
-		   param->pv.i & 0xff, param->pv.i >> 8);
+	pr_debug("%s(), XON/XOFF = 0x%02x,0x%02x\n", __func__ ,
+		 param->pv.i & 0xff, param->pv.i >> 8);
 
 	return 0;
 }
@@ -381,8 +378,8 @@ static int ircomm_param_enq_ack(void *instance, irda_param_t *param, int get)
 		self->settings.enqack[1] = (__u16) param->pv.i >> 8;
 	}
 
-	IRDA_DEBUG(0, "%s(), ENQ/ACK = 0x%02x,0x%02x\n", __func__ ,
-		   param->pv.i & 0xff, param->pv.i >> 8);
+	pr_debug("%s(), ENQ/ACK = 0x%02x,0x%02x\n", __func__ ,
+		 param->pv.i & 0xff, param->pv.i >> 8);
 
 	return 0;
 }
@@ -396,7 +393,7 @@ static int ircomm_param_enq_ack(void *instance, irda_param_t *param, int get)
 static int ircomm_param_line_status(void *instance, irda_param_t *param,
 				    int get)
 {
-	IRDA_DEBUG(2, "%s(), not impl.\n", __func__ );
+	pr_debug("%s(), not impl.\n", __func__);
 
 	return 0;
 }
@@ -457,7 +454,7 @@ static int ircomm_param_dce(void *instance, irda_param_t *param, int get)
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	__u8 dce;
 
-	IRDA_DEBUG(1, "%s(), dce = 0x%02x\n", __func__ , (__u8) param->pv.i);
+	pr_debug("%s(), dce = 0x%02x\n", __func__ , (__u8)param->pv.i);
 
 	dce = (__u8) param->pv.i;
 
@@ -469,7 +466,7 @@ static int ircomm_param_dce(void *instance, irda_param_t *param, int get)
 	/* Check if any of the settings have changed */
 	if (dce & 0x0f) {
 		if (dce & IRCOMM_DELTA_CTS) {
-			IRDA_DEBUG(2, "%s(), CTS\n", __func__ );
+			pr_debug("%s(), CTS\n", __func__);
 		}
 	}
 
diff --git a/net/irda/ircomm/ircomm_ttp.c b/net/irda/ircomm/ircomm_ttp.c
index abe9a5a..4b81e09 100644
--- a/net/irda/ircomm/ircomm_ttp.c
+++ b/net/irda/ircomm/ircomm_ttp.c
@@ -76,8 +76,6 @@ int ircomm_open_tsap(struct ircomm_cb *self)
 {
 	notify_t notify;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	/* Register callbacks */
 	irda_notify_init(&notify);
 	notify.data_indication       = ircomm_ttp_data_indication;
@@ -91,7 +89,7 @@ int ircomm_open_tsap(struct ircomm_cb *self)
 	self->tsap = irttp_open_tsap(LSAP_ANY, DEFAULT_INITIAL_CREDIT,
 				     &notify);
 	if (!self->tsap) {
-		IRDA_DEBUG(0, "%sfailed to allocate tsap\n", __func__ );
+		pr_debug("%sfailed to allocate tsap\n", __func__);
 		return -1;
 	}
 	self->slsap_sel = self->tsap->stsap_sel;
@@ -119,8 +117,6 @@ static int ircomm_ttp_connect_request(struct ircomm_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	/* Don't forget to refcount it - should be NULL anyway */
 	if(userdata)
 		skb_get(userdata);
@@ -143,8 +139,6 @@ static int ircomm_ttp_connect_response(struct ircomm_cb *self,
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	/* Don't forget to refcount it - should be NULL anyway */
 	if(userdata)
 		skb_get(userdata);
@@ -171,7 +165,7 @@ static int ircomm_ttp_data_request(struct ircomm_cb *self,
 
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), clen=%d\n", __func__ , clen);
+	pr_debug("%s(), clen=%d\n", __func__ , clen);
 
 	/*
 	 * Insert clen field, currently we either send data only, or control
@@ -206,8 +200,6 @@ static int ircomm_ttp_data_indication(void *instance, void *sap,
 {
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
@@ -229,8 +221,6 @@ static void ircomm_ttp_connect_confirm(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -270,8 +260,6 @@ static void ircomm_ttp_connect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *)instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -329,8 +317,6 @@ static void ircomm_ttp_disconnect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 
@@ -354,8 +340,6 @@ static void ircomm_ttp_flow_indication(void *instance, void *sap,
 {
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
 
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 11b0a5e..40695b9 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -174,8 +174,6 @@ static int __init ircomm_tty_init(void)
 
 static void __exit __ircomm_tty_cleanup(struct ircomm_tty_cb *self)
 {
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -196,8 +194,6 @@ static void __exit ircomm_tty_cleanup(void)
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	ret = tty_unregister_driver(driver);
 	if (ret) {
 		net_err_ratelimited("%s(), failed to unregister driver\n",
@@ -220,14 +216,12 @@ static int ircomm_tty_startup(struct ircomm_tty_cb *self)
 	notify_t notify;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
 	/* Check if already open */
 	if (test_and_set_bit(ASYNCB_INITIALIZED, &self->port.flags)) {
-		IRDA_DEBUG(2, "%s(), already open so break out!\n", __func__ );
+		pr_debug("%s(), already open so break out!\n", __func__);
 		return 0;
 	}
 
@@ -282,8 +276,6 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	int		do_clocal = 0;
 	unsigned long	flags;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/*
 	 * If non-blocking mode is set, or the port is not enabled,
 	 * then make the check up front and then exit.
@@ -298,12 +290,12 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		if (tty->termios.c_cflag & CBAUD)
 			tty_port_raise_dtr_rts(port);
 		port->flags |= ASYNC_NORMAL_ACTIVE;
-		IRDA_DEBUG(1, "%s(), O_NONBLOCK requested!\n", __func__ );
+		pr_debug("%s(), O_NONBLOCK requested!\n", __func__);
 		return 0;
 	}
 
 	if (tty->termios.c_cflag & CLOCAL) {
-		IRDA_DEBUG(1, "%s(), doing CLOCAL!\n", __func__ );
+		pr_debug("%s(), doing CLOCAL!\n", __func__);
 		do_clocal = 1;
 	}
 
@@ -317,8 +309,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	retval = 0;
 	add_wait_queue(&port->open_wait, &wait);
 
-	IRDA_DEBUG(2, "%s(%d):block_til_ready before block on %s open_count=%d\n",
-	      __FILE__, __LINE__, tty->driver->name, port->count);
+	pr_debug("%s(%d):block_til_ready before block on %s open_count=%d\n",
+		 __FILE__, __LINE__, tty->driver->name, port->count);
 
 	spin_lock_irqsave(&port->lock, flags);
 	port->count--;
@@ -355,8 +347,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 			break;
 		}
 
-		IRDA_DEBUG(1, "%s(%d):block_til_ready blocking on %s open_count=%d\n",
-		      __FILE__, __LINE__, tty->driver->name, port->count);
+		pr_debug("%s(%d):block_til_ready blocking on %s open_count=%d\n",
+			 __FILE__, __LINE__, tty->driver->name, port->count);
 
 		schedule();
 	}
@@ -370,8 +362,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	port->blocked_open--;
 	spin_unlock_irqrestore(&port->lock, flags);
 
-	IRDA_DEBUG(1, "%s(%d):block_til_ready after blocking on %s open_count=%d\n",
-	      __FILE__, __LINE__, tty->driver->name, port->count);
+	pr_debug("%s(%d):block_til_ready after blocking on %s open_count=%d\n",
+		 __FILE__, __LINE__, tty->driver->name, port->count);
 
 	if (!retval)
 		port->flags |= ASYNC_NORMAL_ACTIVE;
@@ -439,16 +431,14 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	unsigned long	flags;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* ++ is not atomic, so this should be protected - Jean II */
 	spin_lock_irqsave(&self->port.lock, flags);
 	self->port.count++;
 	spin_unlock_irqrestore(&self->port.lock, flags);
 	tty_port_tty_set(&self->port, tty);
 
-	IRDA_DEBUG(1, "%s(), %s%d, count = %d\n", __func__ , tty->driver->name,
-		   self->line, self->port.count);
+	pr_debug("%s(), %s%d, count = %d\n", __func__ , tty->driver->name,
+		 self->line, self->port.count);
 
 	/* Not really used by us, but lets do it anyway */
 	self->port.low_latency = (self->port.flags & ASYNC_LOW_LATENCY) ? 1 : 0;
@@ -487,9 +477,9 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		self->settings.service_type = IRCOMM_9_WIRE; /* 9 wire as default */
 		/* Jan Kiszka -> add DSR/RI -> Conform to IrCOMM spec */
 		self->settings.dce = IRCOMM_CTS | IRCOMM_CD | IRCOMM_DSR | IRCOMM_RI; /* Default line settings */
-		IRDA_DEBUG(2, "%s(), IrCOMM device\n", __func__ );
+		pr_debug("%s(), IrCOMM device\n", __func__);
 	} else {
-		IRDA_DEBUG(2, "%s(), IrLPT device\n", __func__ );
+		pr_debug("%s(), IrLPT device\n", __func__);
 		self->service_type = IRCOMM_3_WIRE_RAW;
 		self->settings.service_type = IRCOMM_3_WIRE_RAW; /* Default */
 	}
@@ -500,9 +490,8 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 
 	ret = ircomm_tty_block_til_ready(self, tty, filp);
 	if (ret) {
-		IRDA_DEBUG(2,
-		      "%s(), returning after block_til_ready with %d\n", __func__ ,
-		      ret);
+		pr_debug("%s(), returning after block_til_ready with %d\n",
+			 __func__, ret);
 
 		return ret;
 	}
@@ -520,8 +509,6 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	struct tty_port *port = &self->port;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -571,8 +558,6 @@ static void ircomm_tty_do_softint(struct work_struct *work)
 	unsigned long flags;
 	struct sk_buff *skb, *ctrl_skb;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if (!self || self->magic != IRCOMM_TTY_MAGIC)
 		return;
 
@@ -638,8 +623,8 @@ static int ircomm_tty_write(struct tty_struct *tty,
 	int len = 0;
 	int size;
 
-	IRDA_DEBUG(2, "%s(), count=%d, hw_stopped=%d\n", __func__ , count,
-		   tty->hw_stopped);
+	pr_debug("%s(), count=%d, hw_stopped=%d\n", __func__ , count,
+		 tty->hw_stopped);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
@@ -661,7 +646,7 @@ static int ircomm_tty_write(struct tty_struct *tty,
 	 * we don't mess up the original "safe skb" (see tx_data_size).
 	 * Jean II */
 	if (self->max_header_size == IRCOMM_TTY_HDR_UNINITIALISED) {
-		IRDA_DEBUG(1, "%s() : not initialised\n", __func__);
+		pr_debug("%s() : not initialised\n", __func__);
 #ifdef IRCOMM_NO_TX_BEFORE_INIT
 		/* We didn't consume anything, TTY will retry */
 		return 0;
@@ -790,7 +775,7 @@ static int ircomm_tty_write_room(struct tty_struct *tty)
 			ret = self->max_data_size;
 		spin_unlock_irqrestore(&self->spinlock, flags);
 	}
-	IRDA_DEBUG(2, "%s(), ret=%d\n", __func__ , ret);
+	pr_debug("%s(), ret=%d\n", __func__ , ret);
 
 	return ret;
 }
@@ -807,8 +792,6 @@ static void ircomm_tty_wait_until_sent(struct tty_struct *tty, int timeout)
 	unsigned long orig_jiffies, poll_time;
 	unsigned long flags;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -842,8 +825,6 @@ static void ircomm_tty_throttle(struct tty_struct *tty)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -873,8 +854,6 @@ static void ircomm_tty_unthrottle(struct tty_struct *tty)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -888,7 +867,7 @@ static void ircomm_tty_unthrottle(struct tty_struct *tty)
 		self->settings.dte |= (IRCOMM_RTS|IRCOMM_DELTA_RTS);
 
 		ircomm_param_request(self, IRCOMM_DTE, TRUE);
-		IRDA_DEBUG(1, "%s(), FLOW_START\n", __func__ );
+		pr_debug("%s(), FLOW_START\n", __func__);
 	}
 	ircomm_flow_request(self->ircomm, FLOW_START);
 }
@@ -925,8 +904,6 @@ static void ircomm_tty_shutdown(struct ircomm_tty_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	if (!test_and_clear_bit(ASYNCB_INITIALIZED, &self->port.flags))
 		return;
 
@@ -969,8 +946,6 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 	struct tty_port *port = &self->port;
 	unsigned long	flags;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -998,7 +973,7 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
  */
 static void ircomm_tty_send_xchar(struct tty_struct *tty, char ch)
 {
-	IRDA_DEBUG(0, "%s(), not impl\n", __func__ );
+	pr_debug("%s(), not impl\n", __func__);
 }
 
 /*
@@ -1042,8 +1017,6 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 	struct tty_struct *tty;
 	int status;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -1055,15 +1028,13 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 		/*wake_up_interruptible(&self->delta_msr_wait);*/
 	}
 	if ((self->port.flags & ASYNC_CHECK_CD) && (status & IRCOMM_DELTA_CD)) {
-		IRDA_DEBUG(2,
-			   "%s(), ircomm%d CD now %s...\n", __func__ , self->line,
-			   (status & IRCOMM_CD) ? "on" : "off");
+		pr_debug("%s(), ircomm%d CD now %s...\n", __func__ , self->line,
+			 (status & IRCOMM_CD) ? "on" : "off");
 
 		if (status & IRCOMM_CD) {
 			wake_up_interruptible(&self->port.open_wait);
 		} else {
-			IRDA_DEBUG(2,
-				   "%s(), Doing serial hangup..\n", __func__ );
+			pr_debug("%s(), Doing serial hangup..\n", __func__);
 			if (tty)
 				tty_hangup(tty);
 
@@ -1074,8 +1045,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 	if (tty && tty_port_cts_enabled(&self->port)) {
 		if (tty->hw_stopped) {
 			if (status & IRCOMM_CTS) {
-				IRDA_DEBUG(2,
-					   "%s(), CTS tx start...\n", __func__ );
+				pr_debug("%s(), CTS tx start...\n", __func__);
 				tty->hw_stopped = 0;
 
 				/* Wake up processes blocked on open */
@@ -1086,8 +1056,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 			}
 		} else {
 			if (!(status & IRCOMM_CTS)) {
-				IRDA_DEBUG(2,
-					   "%s(), CTS tx stop...\n", __func__ );
+				pr_debug("%s(), CTS tx stop...\n", __func__);
 				tty->hw_stopped = 1;
 			}
 		}
@@ -1108,15 +1077,13 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	struct tty_struct *tty;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
 	tty = tty_port_tty_get(&self->port);
 	if (!tty) {
-		IRDA_DEBUG(0, "%s(), no tty!\n", __func__ );
+		pr_debug("%s(), no tty!\n", __func__);
 		return 0;
 	}
 
@@ -1127,7 +1094,7 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 	 * params, we can just as well declare the hardware for running.
 	 */
 	if (tty->hw_stopped && (self->flow == FLOW_START)) {
-		IRDA_DEBUG(0, "%s(), polling for line settings!\n", __func__ );
+		pr_debug("%s(), polling for line settings!\n", __func__);
 		ircomm_param_request(self, IRCOMM_POLL, TRUE);
 
 		/* We can just as well declare the hardware for running */
@@ -1160,8 +1127,6 @@ static int ircomm_tty_control_indication(void *instance, void *sap,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	int clen;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
@@ -1196,7 +1161,7 @@ static void ircomm_tty_flow_indication(void *instance, void *sap,
 
 	switch (cmd) {
 	case FLOW_START:
-		IRDA_DEBUG(2, "%s(), hw start!\n", __func__ );
+		pr_debug("%s(), hw start!\n", __func__);
 		if (tty)
 			tty->hw_stopped = 0;
 
@@ -1205,7 +1170,7 @@ static void ircomm_tty_flow_indication(void *instance, void *sap,
 		break;
 	default:  /* If we get here, something is very wrong, better stop */
 	case FLOW_STOP:
-		IRDA_DEBUG(2, "%s(), hw stopped!\n", __func__ );
+		pr_debug("%s(), hw stopped!\n", __func__);
 		if (tty)
 			tty->hw_stopped = 1;
 		break;
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index 2119044..549ca14 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -130,14 +130,12 @@ int ircomm_tty_attach_cable(struct ircomm_tty_cb *self)
 {
 	struct tty_struct *tty;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
 	/* Check if somebody has already connected to us */
 	if (ircomm_is_connected(self->ircomm)) {
-		IRDA_DEBUG(0, "%s(), already connected!\n", __func__ );
+		pr_debug("%s(), already connected!\n", __func__);
 		return 0;
 	}
 
@@ -163,8 +161,6 @@ int ircomm_tty_attach_cable(struct ircomm_tty_cb *self)
  */
 void ircomm_tty_detach_cable(struct ircomm_tty_cb *self)
 {
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -212,8 +208,6 @@ static void ircomm_tty_ias_register(struct ircomm_tty_cb *self)
 	__u8 oct_seq[6];
 	__u16 hints;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -313,17 +307,17 @@ int ircomm_tty_send_initial_parameters(struct ircomm_tty_cb *self)
 	 * Set default values, but only if the application for some reason
 	 * haven't set them already
 	 */
-	IRDA_DEBUG(2, "%s(), data-rate = %d\n", __func__ ,
-		   self->settings.data_rate);
+	pr_debug("%s(), data-rate = %d\n", __func__ ,
+		 self->settings.data_rate);
 	if (!self->settings.data_rate)
 		self->settings.data_rate = 9600;
-	IRDA_DEBUG(2, "%s(), data-format = %d\n", __func__ ,
-		   self->settings.data_format);
+	pr_debug("%s(), data-format = %d\n", __func__ ,
+		 self->settings.data_format);
 	if (!self->settings.data_format)
 		self->settings.data_format = IRCOMM_WSIZE_8;  /* 8N1 */
 
-	IRDA_DEBUG(2, "%s(), flow-control = %d\n", __func__ ,
-		   self->settings.flow_control);
+	pr_debug("%s(), flow-control = %d\n", __func__ ,
+		 self->settings.flow_control);
 	/*self->settings.flow_control = IRCOMM_RTS_CTS_IN|IRCOMM_RTS_CTS_OUT;*/
 
 	/* Do not set delta values for the initial parameters */
@@ -367,8 +361,6 @@ static void ircomm_tty_discovery_indication(discinfo_t *discovery,
 	struct ircomm_tty_cb *self;
 	struct ircomm_tty_info info;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Important note :
 	 * We need to drop all passive discoveries.
 	 * The LSAP management of IrComm is deficient and doesn't deal
@@ -404,8 +396,6 @@ void ircomm_tty_disconnect_indication(void *instance, void *sap,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	struct tty_struct *tty;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -436,8 +426,6 @@ static void ircomm_tty_getvalue_confirm(int result, __u16 obj_id,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) priv;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -447,13 +435,13 @@ static void ircomm_tty_getvalue_confirm(int result, __u16 obj_id,
 
 	/* Check if request succeeded */
 	if (result != IAS_SUCCESS) {
-		IRDA_DEBUG(4, "%s(), got NULL value!\n", __func__ );
+		pr_debug("%s(), got NULL value!\n", __func__);
 		return;
 	}
 
 	switch (value->type) {
 	case IAS_OCT_SEQ:
-		IRDA_DEBUG(2, "%s(), got octet sequence\n", __func__ );
+		pr_debug("%s(), got octet sequence\n", __func__);
 
 		irda_param_extract_all(self, value->t.oct_seq, value->len,
 				       &ircomm_param_info);
@@ -463,21 +451,21 @@ static void ircomm_tty_getvalue_confirm(int result, __u16 obj_id,
 		break;
 	case IAS_INTEGER:
 		/* Got LSAP selector */
-		IRDA_DEBUG(2, "%s(), got lsapsel = %d\n", __func__ ,
-			   value->t.integer);
+		pr_debug("%s(), got lsapsel = %d\n", __func__ ,
+			 value->t.integer);
 
 		if (value->t.integer == -1) {
-			IRDA_DEBUG(0, "%s(), invalid value!\n", __func__ );
+			pr_debug("%s(), invalid value!\n", __func__);
 		} else
 			self->dlsap_sel = value->t.integer;
 
 		ircomm_tty_do_event(self, IRCOMM_TTY_GOT_LSAPSEL, NULL, NULL);
 		break;
 	case IAS_MISSING:
-		IRDA_DEBUG(0, "%s(), got IAS_MISSING\n", __func__ );
+		pr_debug("%s(), got IAS_MISSING\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), got unknown type!\n", __func__ );
+		pr_debug("%s(), got unknown type!\n", __func__);
 		break;
 	}
 	irias_delete_value(value);
@@ -497,8 +485,6 @@ void ircomm_tty_connect_confirm(void *instance, void *sap,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -528,8 +514,6 @@ void ircomm_tty_connect_indication(void *instance, void *sap,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	int clen;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -559,8 +543,6 @@ void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 {
 	struct tty_struct *tty;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -578,10 +560,10 @@ void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 	 */
 	if (tty_port_cts_enabled(&self->port) &&
 			((self->settings.dce & IRCOMM_CTS) == 0)) {
-		IRDA_DEBUG(0, "%s(), waiting for CTS ...\n", __func__ );
+		pr_debug("%s(), waiting for CTS ...\n", __func__);
 		goto put;
 	} else {
-		IRDA_DEBUG(1, "%s(), starting hardware!\n", __func__ );
+		pr_debug("%s(), starting hardware!\n", __func__);
 
 		tty->hw_stopped = 0;
 
@@ -621,8 +603,6 @@ static void ircomm_tty_watchdog_timer_expired(void *data)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -642,8 +622,8 @@ int ircomm_tty_do_event(struct ircomm_tty_cb *self, IRCOMM_TTY_EVENT event,
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
-		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
+	pr_debug("%s: state=%s, event=%s\n", __func__ ,
+		 ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	return (*state[self->state])(self, event, skb, info);
 }
@@ -660,8 +640,8 @@ static inline void ircomm_tty_next_state(struct ircomm_tty_cb *self, IRCOMM_TTY_
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	IRDA_DEBUG(2, "%s: next state=%s, service type=%d\n", __func__ ,
-		   ircomm_tty_state[self->state], self->service_type);
+	pr_debug("%s: next state=%s, service type=%d\n", __func__ ,
+	ircomm_tty_state[self->state], self->service_type);
 	*/
 	self->state = state;
 }
@@ -679,8 +659,8 @@ static int ircomm_tty_state_idle(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
-		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
+	pr_debug("%s: state=%s, event=%s\n", __func__ ,
+		 ircomm_tty_state[self->state], ircomm_tty_event[event]);
 	switch (event) {
 	case IRCOMM_TTY_ATTACH_CABLE:
 		/* Try to discover any remote devices */
@@ -723,8 +703,8 @@ static int ircomm_tty_state_idle(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_tty_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -743,8 +723,8 @@ static int ircomm_tty_state_search(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
-		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
+	pr_debug("%s: state=%s, event=%s\n", __func__ ,
+		 ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
 	case IRCOMM_TTY_DISCOVERY_INDICATION:
@@ -796,8 +776,8 @@ static int ircomm_tty_state_search(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_tty_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -816,8 +796,8 @@ static int ircomm_tty_state_query_parameters(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
-		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
+	pr_debug("%s: state=%s, event=%s\n", __func__ ,
+		 ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
 	case IRCOMM_TTY_GOT_PARAMETERS:
@@ -854,8 +834,8 @@ static int ircomm_tty_state_query_parameters(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_tty_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -874,8 +854,8 @@ static int ircomm_tty_state_query_lsap_sel(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
-		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
+	pr_debug("%s: state=%s, event=%s\n", __func__ ,
+		 ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
 	case IRCOMM_TTY_GOT_LSAPSEL:
@@ -903,8 +883,8 @@ static int ircomm_tty_state_query_lsap_sel(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_tty_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -923,8 +903,8 @@ static int ircomm_tty_state_setup(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
-		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
+	pr_debug("%s: state=%s, event=%s\n", __func__ ,
+		 ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
 	case IRCOMM_TTY_CONNECT_CONFIRM:
@@ -957,8 +937,8 @@ static int ircomm_tty_state_setup(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_tty_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
@@ -995,13 +975,13 @@ static int ircomm_tty_state_ready(struct ircomm_tty_cb *self,
 			self->settings.dce = IRCOMM_DELTA_CD;
 			ircomm_tty_check_modem_status(self);
 		} else {
-			IRDA_DEBUG(0, "%s(), hanging up!\n", __func__ );
+			pr_debug("%s(), hanging up!\n", __func__);
 			tty_port_tty_hangup(&self->port, false);
 		}
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
-			   ircomm_tty_event[event]);
+		pr_debug("%s(), unknown event: %s\n", __func__ ,
+			 ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
 	return ret;
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index 7eb06e0..75ccdbd 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -56,8 +56,6 @@ static void ircomm_tty_change_speed(struct ircomm_tty_cb *self,
 	unsigned int cflag, cval;
 	int baud;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if (!self->ircomm)
 		return;
 
@@ -150,8 +148,6 @@ void ircomm_tty_set_termios(struct tty_struct *tty,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	unsigned int cflag = tty->termios.c_cflag;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if ((cflag == old_termios->c_cflag) &&
 	    (RELEVANT_IFLAG(tty->termios.c_iflag) ==
 	     RELEVANT_IFLAG(old_termios->c_iflag)))
@@ -199,8 +195,6 @@ int ircomm_tty_tiocmget(struct tty_struct *tty)
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	unsigned int result;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if (tty->flags & (1 << TTY_IO_ERROR))
 		return -EIO;
 
@@ -224,8 +218,6 @@ int ircomm_tty_tiocmset(struct tty_struct *tty,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if (tty->flags & (1 << TTY_IO_ERROR))
 		return -EIO;
 
@@ -266,8 +258,6 @@ static int ircomm_tty_get_serial_info(struct ircomm_tty_cb *self,
 	if (!retinfo)
 		return -EFAULT;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	memset(&info, 0, sizeof(info));
 	info.line = self->line;
 	info.flags = self->port.flags;
@@ -302,8 +292,6 @@ static int ircomm_tty_set_serial_info(struct ircomm_tty_cb *self,
 	struct serial_struct new_serial;
 	struct ircomm_tty_cb old_state, *state;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	if (copy_from_user(&new_serial,new_info,sizeof(new_serial)))
 		return -EFAULT;
 
@@ -376,8 +364,6 @@ int ircomm_tty_ioctl(struct tty_struct *tty,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if ((cmd != TIOCGSERIAL) && (cmd != TIOCSSERIAL) &&
 	    (cmd != TIOCSERCONFIG) && (cmd != TIOCSERGSTRUCT) &&
 	    (cmd != TIOCMIWAIT) && (cmd != TIOCGICOUNT)) {
@@ -393,11 +379,11 @@ int ircomm_tty_ioctl(struct tty_struct *tty,
 		ret = ircomm_tty_set_serial_info(self, (struct serial_struct __user *) arg);
 		break;
 	case TIOCMIWAIT:
-		IRDA_DEBUG(0, "(), TIOCMIWAIT, not impl!\n");
+		pr_debug("(), TIOCMIWAIT, not impl!\n");
 		break;
 
 	case TIOCGICOUNT:
-		IRDA_DEBUG(0, "%s(), TIOCGICOUNT not impl!\n", __func__ );
+		pr_debug("%s(), TIOCGICOUNT not impl!\n", __func__);
 #if 0
 		save_flags(flags); cli();
 		cnow = driver->icount;
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 96788db..8567366 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -90,8 +90,6 @@ static void leftover_dongle(void *arg)
 
 void irda_device_cleanup(void)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	hashbin_delete(tasks, (FREE_FUNC) __irda_task_delete);
 
 	hashbin_delete(dongles, leftover_dongle);
@@ -107,7 +105,7 @@ void irda_device_set_media_busy(struct net_device *dev, int status)
 {
 	struct irlap_cb *self;
 
-	IRDA_DEBUG(4, "%s(%s)\n", __func__, status ? "TRUE" : "FALSE");
+	pr_debug("%s(%s)\n", __func__, status ? "TRUE" : "FALSE");
 
 	self = (struct irlap_cb *) dev->atalk_ptr;
 
@@ -127,7 +125,7 @@ void irda_device_set_media_busy(struct net_device *dev, int status)
 			irlap_start_mbusy_timer(self, SMALLBUSY_TIMEOUT);
 		else
 			irlap_start_mbusy_timer(self, MEDIABUSY_TIMEOUT);
-		IRDA_DEBUG( 4, "Media busy!\n");
+		pr_debug("Media busy!\n");
 	} else {
 		self->media_busy = FALSE;
 		irlap_stop_mbusy_timer(self);
@@ -147,8 +145,6 @@ int irda_device_is_receiving(struct net_device *dev)
 	struct if_irda_req req;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	if (!dev->netdev_ops->ndo_do_ioctl) {
 		net_err_ratelimited("%s: do_ioctl not impl. by device driver\n",
 				    __func__);
@@ -192,8 +188,6 @@ static int irda_task_kick(struct irda_task *task)
 	int count = 0;
 	int timeout;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(task != NULL, return -1;);
 	IRDA_ASSERT(task->magic == IRDA_TASK_MAGIC, return -1;);
 
@@ -241,8 +235,8 @@ static int irda_task_kick(struct irda_task *task)
 				 irda_task_timer_expired);
 		finished = FALSE;
 	} else {
-		IRDA_DEBUG(0, "%s(), not finished, and no timeout!\n",
-			   __func__);
+		pr_debug("%s(), not finished, and no timeout!\n",
+			 __func__);
 		finished = FALSE;
 	}
 
@@ -259,8 +253,6 @@ static void irda_task_timer_expired(void *data)
 {
 	struct irda_task *task;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	task = data;
 
 	irda_task_kick(task);
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index c2ea344..7a93cdd 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -145,7 +145,7 @@ int __init iriap_init(void)
 	 */
 	server = iriap_open(LSAP_IAS, IAS_SERVER, NULL, NULL);
 	if (!server) {
-		IRDA_DEBUG(0, "%s(), unable to open server\n", __func__);
+		pr_debug("%s(), unable to open server\n", __func__);
 		return -1;
 	}
 	iriap_register_lsap(server, LSAP_IAS, IAS_SERVER);
@@ -177,8 +177,6 @@ struct iriap_cb *iriap_open(__u8 slsap_sel, int mode, void *priv,
 {
 	struct iriap_cb *self;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	self = kzalloc(sizeof(*self), GFP_ATOMIC);
 	if (!self)
 		return NULL;
@@ -221,8 +219,6 @@ EXPORT_SYMBOL(iriap_open);
  */
 static void __iriap_close(struct iriap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
@@ -245,8 +241,6 @@ void iriap_close(struct iriap_cb *self)
 {
 	struct iriap_cb *entry;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
@@ -266,8 +260,6 @@ static int iriap_register_lsap(struct iriap_cb *self, __u8 slsap_sel, int mode)
 {
 	notify_t notify;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	irda_notify_init(&notify);
 	notify.connect_confirm       = iriap_connect_confirm;
 	notify.connect_indication    = iriap_connect_indication;
@@ -302,8 +294,8 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 {
 	struct iriap_cb *self;
 
-	IRDA_DEBUG(4, "%s(), reason=%s [%d]\n", __func__,
-		   irlmp_reason_str(reason), reason);
+	pr_debug("%s(), reason=%s [%d]\n", __func__,
+		 irlmp_reason_str(reason), reason);
 
 	self = instance;
 
@@ -319,7 +311,7 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 		dev_kfree_skb(skb);
 
 	if (self->mode == IAS_CLIENT) {
-		IRDA_DEBUG(4, "%s(), disconnect as client\n", __func__);
+		pr_debug("%s(), disconnect as client\n", __func__);
 
 
 		iriap_do_client_event(self, IAP_LM_DISCONNECT_INDICATION,
@@ -332,7 +324,7 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 		if (self->confirm)
 			self->confirm(IAS_DISCONNECT, 0, NULL, self->priv);
 	} else {
-		IRDA_DEBUG(4, "%s(), disconnect as server\n", __func__);
+		pr_debug("%s(), disconnect as server\n", __func__);
 		iriap_do_server_event(self, IAP_LM_DISCONNECT_INDICATION,
 				      NULL);
 		iriap_close(self);
@@ -346,16 +338,13 @@ static void iriap_disconnect_request(struct iriap_cb *self)
 {
 	struct sk_buff *tx_skb;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 	if (tx_skb == NULL) {
-		IRDA_DEBUG(0,
-			   "%s(), Could not allocate an sk_buff of length %d\n",
-			   __func__, LMP_MAX_HEADER);
+		pr_debug("%s(), Could not allocate an sk_buff of length %d\n",
+			 __func__, LMP_MAX_HEADER);
 		return;
 	}
 
@@ -460,14 +449,14 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 	len = get_unaligned_be16(fp + n);
 	n += 2;
 
-	IRDA_DEBUG(4, "%s(), len=%d\n", __func__, len);
+	pr_debug("%s(), len=%d\n", __func__, len);
 
 	/* Get object ID, MSB first */
 	obj_id = get_unaligned_be16(fp + n);
 	n += 2;
 
 	type = fp[n++];
-	IRDA_DEBUG(4, "%s(), Value type = %d\n", __func__, type);
+	pr_debug("%s(), Value type = %d\n", __func__, type);
 
 	switch (type) {
 	case IAS_INTEGER:
@@ -476,7 +465,7 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 		value = irias_new_integer_value(tmp_cpu32);
 
 		/*  Legal values restricted to 0x01-0x6f, page 15 irttp */
-		IRDA_DEBUG(4, "%s(), lsap=%d\n", __func__, value->t.integer);
+		pr_debug("%s(), lsap=%d\n", __func__, value->t.integer);
 		break;
 	case IAS_STRING:
 		charset = fp[n++];
@@ -495,11 +484,11 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 /*		case CS_ISO_8859_9: */
 /*		case CS_UNICODE: */
 		default:
-			IRDA_DEBUG(0, "%s(), charset [%d] %s, not supported\n",
-				   __func__, charset,
-				   charset < ARRAY_SIZE(ias_charset_types) ?
-					ias_charset_types[charset] :
-					"(unknown)");
+			pr_debug("%s(), charset [%d] %s, not supported\n",
+				 __func__, charset,
+				 charset < ARRAY_SIZE(ias_charset_types) ?
+				 ias_charset_types[charset] :
+				 "(unknown)");
 
 			/* Aborting, close connection! */
 			iriap_disconnect_request(self);
@@ -507,12 +496,12 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 			/* break; */
 		}
 		value_len = fp[n++];
-		IRDA_DEBUG(4, "%s(), strlen=%d\n", __func__, value_len);
+		pr_debug("%s(), strlen=%d\n", __func__, value_len);
 
 		/* Make sure the string is null-terminated */
 		if (n + value_len < skb->len)
 			fp[n + value_len] = 0x00;
-		IRDA_DEBUG(4, "Got string %s\n", fp+n);
+		pr_debug("Got string %s\n", fp+n);
 
 		/* Will truncate to IAS_MAX_STRING bytes */
 		value = irias_new_string_value(fp+n);
@@ -538,7 +527,7 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 	if (self->confirm)
 		self->confirm(IAS_SUCCESS, obj_id, value, self->priv);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler!\n", __func__);
+		pr_debug("%s(), missing handler!\n", __func__);
 		irias_delete_value(value);
 	}
 }
@@ -560,8 +549,6 @@ static void iriap_getvaluebyclass_response(struct iriap_cb *self,
 	__be16 tmp_be16;
 	__u8 *fp;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 	IRDA_ASSERT(value != NULL, return;);
@@ -622,12 +609,12 @@ static void iriap_getvaluebyclass_response(struct iriap_cb *self,
 		memcpy(fp+n, value->t.oct_seq, value->len); n+=value->len;
 		break;
 	case IAS_MISSING:
-		IRDA_DEBUG( 3, "%s: sending IAS_MISSING\n", __func__);
+		pr_debug("%s: sending IAS_MISSING\n", __func__);
 		skb_put(tx_skb, 1);
 		fp[n++] = value->type;
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), type not implemented!\n", __func__);
+		pr_debug("%s(), type not implemented!\n", __func__);
 		break;
 	}
 	iriap_do_r_connect_event(self, IAP_CALL_RESPONSE, tx_skb);
@@ -654,8 +641,6 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
 	__u8 *fp;
 	int n;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -677,20 +662,20 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
 	memcpy(attr, fp+n, attr_len); n+=attr_len;
 	attr[attr_len] = '\0';
 
-	IRDA_DEBUG(4, "LM-IAS: Looking up %s: %s\n", name, attr);
+	pr_debug("LM-IAS: Looking up %s: %s\n", name, attr);
 	obj = irias_find_object(name);
 
 	if (obj == NULL) {
-		IRDA_DEBUG(2, "LM-IAS: Object %s not found\n", name);
+		pr_debug("LM-IAS: Object %s not found\n", name);
 		iriap_getvaluebyclass_response(self, 0x1235, IAS_CLASS_UNKNOWN,
 					       &irias_missing);
 		return;
 	}
-	IRDA_DEBUG(4, "LM-IAS: found %s, id=%d\n", obj->name, obj->id);
+	pr_debug("LM-IAS: found %s, id=%d\n", obj->name, obj->id);
 
 	attrib = irias_find_attrib(obj, attr);
 	if (attrib == NULL) {
-		IRDA_DEBUG(2, "LM-IAS: Attribute %s not found\n", attr);
+		pr_debug("LM-IAS: Attribute %s not found\n", attr);
 		iriap_getvaluebyclass_response(self, obj->id,
 					       IAS_ATTRIB_UNKNOWN,
 					       &irias_missing);
@@ -713,8 +698,6 @@ void iriap_send_ack(struct iriap_cb *self)
 	struct sk_buff *tx_skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
@@ -744,7 +727,7 @@ void iriap_connect_request(struct iriap_cb *self)
 				    self->saddr, self->daddr,
 				    NULL, NULL);
 	if (ret < 0) {
-		IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
+		pr_debug("%s(), connect failed!\n", __func__);
 		self->confirm(IAS_DISCONNECT, 0, NULL, self->priv);
 	}
 }
@@ -792,8 +775,6 @@ static void iriap_connect_indication(void *instance, void *sap,
 {
 	struct iriap_cb *self, *new;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	self = instance;
 
 	IRDA_ASSERT(skb != NULL, return;);
@@ -803,14 +784,14 @@ static void iriap_connect_indication(void *instance, void *sap,
 	/* Start new server */
 	new = iriap_open(LSAP_IAS, IAS_SERVER, NULL, NULL);
 	if (!new) {
-		IRDA_DEBUG(0, "%s(), open failed\n", __func__);
+		pr_debug("%s(), open failed\n", __func__);
 		goto out;
 	}
 
 	/* Now attach up the new "socket" */
 	new->lsap = irlmp_dup(self->lsap, new);
 	if (!new->lsap) {
-		IRDA_DEBUG(0, "%s(), dup failed!\n", __func__);
+		pr_debug("%s(), dup failed!\n", __func__);
 		goto out;
 	}
 
@@ -840,8 +821,6 @@ static int iriap_data_indication(void *instance, void *sap,
 	__u8  *frame;
 	__u8  opcode;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	self = instance;
 
 	IRDA_ASSERT(skb != NULL, return 0;);
@@ -852,7 +831,7 @@ static int iriap_data_indication(void *instance, void *sap,
 
 	if (self->mode == IAS_SERVER) {
 		/* Call server */
-		IRDA_DEBUG(4, "%s(), Calling server!\n", __func__);
+		pr_debug("%s(), Calling server!\n", __func__);
 		iriap_do_r_connect_event(self, IAP_RECV_F_LST, skb);
 		goto out;
 	}
@@ -865,7 +844,7 @@ static int iriap_data_indication(void *instance, void *sap,
 
 	/* Check for ack frames since they don't contain any data */
 	if (opcode & IAP_ACK) {
-		IRDA_DEBUG(0, "%s() Got ack frame!\n", __func__);
+		pr_debug("%s() Got ack frame!\n", __func__);
 		goto out;
 	}
 
@@ -873,7 +852,7 @@ static int iriap_data_indication(void *instance, void *sap,
 
 	switch (opcode) {
 	case GET_INFO_BASE:
-		IRDA_DEBUG(0, "IrLMP GetInfoBaseDetails not implemented!\n");
+		pr_debug("IrLMP GetInfoBaseDetails not implemented!\n");
 		break;
 	case GET_VALUE_BY_CLASS:
 		iriap_do_call_event(self, IAP_RECV_F_LST, NULL);
@@ -883,7 +862,7 @@ static int iriap_data_indication(void *instance, void *sap,
 			iriap_getvaluebyclass_confirm(self, skb);
 			break;
 		case IAS_CLASS_UNKNOWN:
-			IRDA_DEBUG(1, "%s(), No such class!\n", __func__);
+			pr_debug("%s(), No such class!\n", __func__);
 			/* Finished, close connection! */
 			iriap_disconnect_request(self);
 
@@ -896,7 +875,7 @@ static int iriap_data_indication(void *instance, void *sap,
 					      self->priv);
 			break;
 		case IAS_ATTRIB_UNKNOWN:
-			IRDA_DEBUG(1, "%s(), No such attribute!\n", __func__);
+			pr_debug("%s(), No such attribute!\n", __func__);
 			/* Finished, close connection! */
 			iriap_disconnect_request(self);
 
@@ -911,8 +890,8 @@ static int iriap_data_indication(void *instance, void *sap,
 		}
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown op-code: %02x\n", __func__,
-			   opcode);
+		pr_debug("%s(), Unknown op-code: %02x\n", __func__,
+			 opcode);
 		break;
 	}
 
@@ -933,8 +912,6 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
 	__u8 *fp;
 	__u8 opcode;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
diff --git a/net/irda/iriap_event.c b/net/irda/iriap_event.c
index 09de4ef..e6098b2 100644
--- a/net/irda/iriap_event.c
+++ b/net/irda/iriap_event.c
@@ -187,7 +187,7 @@ static void state_s_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 	case IAP_LM_DISCONNECT_INDICATION:
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
+		pr_debug("%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -219,7 +219,7 @@ static void state_s_connecting(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_client_state(self, S_DISCONNECT);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
+		pr_debug("%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -243,7 +243,7 @@ static void state_s_call(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_client_state(self, S_DISCONNECT);
 		break;
 	default:
-		IRDA_DEBUG(0, "state_s_call: Unknown event %d\n", event);
+		pr_debug("state_s_call: Unknown event %d\n", event);
 		break;
 	}
 }
@@ -271,7 +271,7 @@ static void state_s_make_call(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_call_state(self, S_OUTSTANDING);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
+		pr_debug("%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -285,7 +285,7 @@ static void state_s_make_call(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_calling(struct iriap_cb *self, IRIAP_EVENT event,
 			    struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
+	pr_debug("%s(), Not implemented\n", __func__);
 }
 
 /*
@@ -307,7 +307,7 @@ static void state_s_outstanding(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_call_state(self, S_WAIT_FOR_CALL);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
+		pr_debug("%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -320,7 +320,7 @@ static void state_s_outstanding(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_replying(struct iriap_cb *self, IRIAP_EVENT event,
 			     struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
+	pr_debug("%s(), Not implemented\n", __func__);
 }
 
 /*
@@ -332,7 +332,7 @@ static void state_s_replying(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_wait_for_call(struct iriap_cb *self, IRIAP_EVENT event,
 				  struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
+	pr_debug("%s(), Not implemented\n", __func__);
 }
 
 
@@ -345,7 +345,7 @@ static void state_s_wait_for_call(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_wait_active(struct iriap_cb *self, IRIAP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
+	pr_debug("%s(), Not implemented\n", __func__);
 }
 
 /**************************************************************************
@@ -386,7 +386,7 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_r_connect_state(self, R_RECEIVING);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event %d\n", __func__, event);
+		pr_debug("%s(), unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -397,8 +397,6 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_call(struct iriap_cb *self, IRIAP_EVENT event,
 			 struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	switch (event) {
 	case IAP_LM_DISCONNECT_INDICATION:
 		/* Abort call */
@@ -406,7 +404,7 @@ static void state_r_call(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_r_connect_state(self, R_WAITING);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event!\n", __func__);
+		pr_debug("%s(), unknown event!\n", __func__);
 		break;
 	}
 }
@@ -421,13 +419,13 @@ static void state_r_call(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_waiting(struct iriap_cb *self, IRIAP_EVENT event,
 			    struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
+	pr_debug("%s(), Not implemented\n", __func__);
 }
 
 static void state_r_wait_active(struct iriap_cb *self, IRIAP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
+	pr_debug("%s(), Not implemented\n", __func__);
 }
 
 /*
@@ -439,8 +437,6 @@ static void state_r_wait_active(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_receiving(struct iriap_cb *self, IRIAP_EVENT event,
 			      struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	switch (event) {
 	case IAP_RECV_F_LST:
 		iriap_next_r_connect_state(self, R_EXECUTE);
@@ -448,7 +444,7 @@ static void state_r_receiving(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_call_indication(self, skb);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event!\n", __func__);
+		pr_debug("%s(), unknown event!\n", __func__);
 		break;
 	}
 }
@@ -462,8 +458,6 @@ static void state_r_receiving(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_execute(struct iriap_cb *self, IRIAP_EVENT event,
 			    struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(skb != NULL, return;);
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -483,7 +477,7 @@ static void state_r_execute(struct iriap_cb *self, IRIAP_EVENT event,
 		irlmp_data_request(self->lsap, skb);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event!\n", __func__);
+		pr_debug("%s(), unknown event!\n", __func__);
 		break;
 	}
 }
@@ -491,7 +485,7 @@ static void state_r_execute(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_returning(struct iriap_cb *self, IRIAP_EVENT event,
 			      struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), event=%d\n", __func__, event);
+	pr_debug("%s(), event=%d\n", __func__, event);
 
 	switch (event) {
 	case IAP_RECV_F_LST:
diff --git a/net/irda/irias_object.c b/net/irda/irias_object.c
index cd53692..53b86d0 100644
--- a/net/irda/irias_object.c
+++ b/net/irda/irias_object.c
@@ -48,8 +48,6 @@ struct ias_object *irias_new_object( char *name, int id)
 {
 	struct ias_object *obj;
 
-	IRDA_DEBUG( 4, "%s()\n", __func__);
-
 	obj = kzalloc(sizeof(struct ias_object), GFP_ATOMIC);
 	if (obj == NULL) {
 		net_warn_ratelimited("%s(), Unable to allocate object!\n",
@@ -134,8 +132,8 @@ int irias_delete_object(struct ias_object *obj)
 	/* Remove from list */
 	node = hashbin_remove_this(irias_objects, (irda_queue_t *) obj);
 	if (!node)
-		IRDA_DEBUG( 0, "%s(), object already removed!\n",
-			    __func__);
+		pr_debug("%s(), object already removed!\n",
+			 __func__);
 
 	/* Destroy */
 	__irias_delete_object(obj);
@@ -287,8 +285,8 @@ int irias_object_change_attribute(char *obj_name, char *attrib_name,
 	}
 
 	if ( attrib->value->type != new_value->type) {
-		IRDA_DEBUG( 0, "%s(), changing value type not allowed!\n",
-			    __func__);
+		pr_debug("%s(), changing value type not allowed!\n",
+			 __func__);
 		spin_unlock_irqrestore(&obj->attribs->hb_spinlock, flags);
 		return -1;
 	}
@@ -533,8 +531,6 @@ struct ias_value *irias_new_missing_value(void)
  */
 void irias_delete_value(struct ias_value *value)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(value != NULL, return;);
 
 	switch (value->type) {
@@ -551,7 +547,7 @@ void irias_delete_value(struct ias_value *value)
 		 kfree(value->t.oct_seq);
 		 break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown value type!\n", __func__);
+		pr_debug("%s(), Unknown value type!\n", __func__);
 		break;
 	}
 	kfree(value);
diff --git a/net/irda/irlan/irlan_client.c b/net/irda/irlan/irlan_client.c
index f8eea02..c5837a4 100644
--- a/net/irda/irlan/irlan_client.c
+++ b/net/irda/irlan/irlan_client.c
@@ -72,8 +72,6 @@ static void irlan_client_kick_timer_expired(void *data)
 {
 	struct irlan_cb *self = (struct irlan_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -91,8 +89,6 @@ static void irlan_client_kick_timer_expired(void *data)
 
 static void irlan_client_start_kick_timer(struct irlan_cb *self, int timeout)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	irda_start_timer(&self->client.kick_timer, timeout, (void *) self,
 			 irlan_client_kick_timer_expired);
 }
@@ -105,8 +101,6 @@ static void irlan_client_start_kick_timer(struct irlan_cb *self, int timeout)
  */
 void irlan_client_wakeup(struct irlan_cb *self, __u32 saddr, __u32 daddr)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -117,7 +111,7 @@ void irlan_client_wakeup(struct irlan_cb *self, __u32 saddr, __u32 daddr)
 	if ((self->client.state != IRLAN_IDLE) ||
 	    (self->provider.access_type == ACCESS_DIRECT))
 	{
-			IRDA_DEBUG(0, "%s(), already awake!\n", __func__ );
+		pr_debug("%s(), already awake!\n", __func__);
 			return;
 	}
 
@@ -126,7 +120,7 @@ void irlan_client_wakeup(struct irlan_cb *self, __u32 saddr, __u32 daddr)
 	self->daddr = daddr;
 
 	if (self->disconnect_reason == LM_USER_REQUEST) {
-			IRDA_DEBUG(0, "%s(), still stopped by user\n", __func__ );
+		pr_debug("%s(), still stopped by user\n", __func__);
 			return;
 	}
 
@@ -153,8 +147,6 @@ void irlan_client_discovery_indication(discinfo_t *discovery,
 	struct irlan_cb *self;
 	__u32 saddr, daddr;
 
-	IRDA_DEBUG(1, "%s()\n", __func__ );
-
 	IRDA_ASSERT(discovery != NULL, return;);
 
 	/*
@@ -175,8 +167,8 @@ void irlan_client_discovery_indication(discinfo_t *discovery,
 	if (self) {
 		IRDA_ASSERT(self->magic == IRLAN_MAGIC, goto out;);
 
-		IRDA_DEBUG(1, "%s(), Found instance (%08x)!\n", __func__ ,
-		      daddr);
+		pr_debug("%s(), Found instance (%08x)!\n", __func__ ,
+			 daddr);
 
 		irlan_client_wakeup(self, saddr, daddr);
 	}
@@ -195,8 +187,6 @@ static int irlan_client_ctrl_data_indication(void *instance, void *sap,
 {
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	self = instance;
 
 	IRDA_ASSERT(self != NULL, return -1;);
@@ -206,7 +196,7 @@ static int irlan_client_ctrl_data_indication(void *instance, void *sap,
 	irlan_do_client_event(self, IRLAN_DATA_INDICATION, skb);
 
 	/* Ready for a new command */
-	IRDA_DEBUG(2, "%s(), clearing tx_busy\n", __func__ );
+	pr_debug("%s(), clearing tx_busy\n", __func__);
 	self->client.tx_busy = FALSE;
 
 	/* Check if we have some queued commands waiting to be sent */
@@ -223,7 +213,7 @@ static void irlan_client_ctrl_disconnect_indication(void *instance, void *sap,
 	struct tsap_cb *tsap;
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(4, "%s(), reason=%d\n", __func__ , reason);
+	pr_debug("%s(), reason=%d\n", __func__ , reason);
 
 	self = instance;
 	tsap = sap;
@@ -255,8 +245,6 @@ static void irlan_client_open_ctrl_tsap(struct irlan_cb *self)
 	struct tsap_cb *tsap;
 	notify_t notify;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -275,7 +263,7 @@ static void irlan_client_open_ctrl_tsap(struct irlan_cb *self)
 
 	tsap = irttp_open_tsap(LSAP_ANY, DEFAULT_INITIAL_CREDIT, &notify);
 	if (!tsap) {
-		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __func__ );
+		pr_debug("%s(), Got no tsap!\n", __func__);
 		return;
 	}
 	self->client.tsap_ctrl = tsap;
@@ -295,8 +283,6 @@ static void irlan_client_ctrl_connect_confirm(void *instance, void *sap,
 {
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
@@ -374,7 +360,7 @@ void irlan_client_parse_response(struct irlan_cb *self, struct sk_buff *skb)
 
 	IRDA_ASSERT(skb != NULL, return;);
 
-	IRDA_DEBUG(4, "%s() skb->len=%d\n", __func__ , (int) skb->len);
+	pr_debug("%s() skb->len=%d\n", __func__ , (int)skb->len);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -405,7 +391,7 @@ void irlan_client_parse_response(struct irlan_cb *self, struct sk_buff *skb)
 	/* How many parameters? */
 	count = frame[1];
 
-	IRDA_DEBUG(4, "%s(), got %d parameters\n", __func__ , count);
+	pr_debug("%s(), got %d parameters\n", __func__ , count);
 
 	ptr = frame+2;
 
@@ -413,7 +399,7 @@ void irlan_client_parse_response(struct irlan_cb *self, struct sk_buff *skb)
 	for (i=0; i<count;i++) {
 		ret = irlan_extract_param(ptr, name, value, &val_len);
 		if (ret < 0) {
-			IRDA_DEBUG(2, "%s(), IrLAN, Error!\n", __func__ );
+			pr_debug("%s(), IrLAN, Error!\n", __func__);
 			break;
 		}
 		ptr += ret;
@@ -437,7 +423,7 @@ static void irlan_check_response_param(struct irlan_cb *self, char *param,
 	__u8 *bytes;
 	int i;
 
-	IRDA_DEBUG(4, "%s(), parm=%s\n", __func__ , param);
+	pr_debug("%s(), parm=%s\n", __func__ , param);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -475,13 +461,13 @@ static void irlan_check_response_param(struct irlan_cb *self, char *param,
 		else if (strcmp(value, "HOSTED") == 0)
 			self->client.access_type = ACCESS_HOSTED;
 		else {
-			IRDA_DEBUG(2, "%s(), unknown access type!\n", __func__ );
+			pr_debug("%s(), unknown access type!\n", __func__);
 		}
 	}
 	/* IRLAN version */
 	if (strcmp(param, "IRLAN_VER") == 0) {
-		IRDA_DEBUG(4, "IrLAN version %d.%d\n", (__u8) value[0],
-		      (__u8) value[1]);
+		pr_debug("IrLAN version %d.%d\n", (__u8)value[0],
+			 (__u8)value[1]);
 
 		self->version[0] = value[0];
 		self->version[1] = value[1];
@@ -490,37 +476,37 @@ static void irlan_check_response_param(struct irlan_cb *self, char *param,
 	/* Which remote TSAP to use for data channel */
 	if (strcmp(param, "DATA_CHAN") == 0) {
 		self->dtsap_sel_data = value[0];
-		IRDA_DEBUG(4, "Data TSAP = %02x\n", self->dtsap_sel_data);
+		pr_debug("Data TSAP = %02x\n", self->dtsap_sel_data);
 		return;
 	}
 	if (strcmp(param, "CON_ARB") == 0) {
 		memcpy(&tmp_cpu, value, 2); /* Align value */
 		le16_to_cpus(&tmp_cpu);     /* Convert to host order */
 		self->client.recv_arb_val = tmp_cpu;
-		IRDA_DEBUG(2, "%s(), receive arb val=%d\n", __func__ ,
-			   self->client.recv_arb_val);
+		pr_debug("%s(), receive arb val=%d\n", __func__ ,
+			 self->client.recv_arb_val);
 	}
 	if (strcmp(param, "MAX_FRAME") == 0) {
 		memcpy(&tmp_cpu, value, 2); /* Align value */
 		le16_to_cpus(&tmp_cpu);     /* Convert to host order */
 		self->client.max_frame = tmp_cpu;
-		IRDA_DEBUG(4, "%s(), max frame=%d\n", __func__ ,
-			   self->client.max_frame);
+		pr_debug("%s(), max frame=%d\n", __func__ ,
+			 self->client.max_frame);
 	}
 
 	/* RECONNECT_KEY, in case the link goes down! */
 	if (strcmp(param, "RECONNECT_KEY") == 0) {
-		IRDA_DEBUG(4, "Got reconnect key: ");
+		pr_debug("Got reconnect key: ");
 		/* for (i = 0; i < val_len; i++) */
 /* 			printk("%02x", value[i]); */
 		memcpy(self->client.reconnect_key, value, val_len);
 		self->client.key_len = val_len;
-		IRDA_DEBUG(4, "\n");
+		pr_debug("\n");
 	}
 	/* FILTER_ENTRY, have we got an ethernet address? */
 	if (strcmp(param, "FILTER_ENTRY") == 0) {
 		bytes = value;
-		IRDA_DEBUG(4, "Ethernet address = %pM\n", bytes);
+		pr_debug("Ethernet address = %pM\n", bytes);
 		for (i = 0; i < 6; i++)
 			self->dev->dev_addr[i] = bytes[i];
 	}
@@ -537,8 +523,6 @@ void irlan_client_get_value_confirm(int result, __u16 obj_id,
 {
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(priv != NULL, return;);
 
 	self = priv;
@@ -550,7 +534,7 @@ void irlan_client_get_value_confirm(int result, __u16 obj_id,
 
 	/* Check if request succeeded */
 	if (result != IAS_SUCCESS) {
-		IRDA_DEBUG(2, "%s(), got NULL value!\n", __func__ );
+		pr_debug("%s(), got NULL value!\n", __func__);
 		irlan_do_client_event(self, IRLAN_IAS_PROVIDER_NOT_AVAIL,
 				      NULL);
 		return;
@@ -568,7 +552,7 @@ void irlan_client_get_value_confirm(int result, __u16 obj_id,
 		irias_delete_value(value);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown type!\n", __func__ );
+		pr_debug("%s(), unknown type!\n", __func__);
 		break;
 	}
 	irlan_do_client_event(self, IRLAN_IAS_PROVIDER_NOT_AVAIL, NULL);
diff --git a/net/irda/irlan/irlan_client_event.c b/net/irda/irlan/irlan_client_event.c
index f9d11bf..cc93fab 100644
--- a/net/irda/irlan/irlan_client_event.c
+++ b/net/irda/irlan/irlan_client_event.c
@@ -92,8 +92,6 @@ void irlan_do_client_event(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
 
@@ -114,10 +112,10 @@ static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 					      "IrLAN", "IrDA:TinyTP:LsapSel");
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(4, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -136,8 +134,6 @@ static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 				    struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
 
@@ -154,7 +150,7 @@ static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_CONN);
 		break;
 	case IRLAN_IAS_PROVIDER_NOT_AVAIL:
-		IRDA_DEBUG(2, "%s(), IAS_PROVIDER_NOT_AVAIL\n", __func__ );
+		pr_debug("%s(), IAS_PROVIDER_NOT_AVAIL\n", __func__);
 		irlan_next_client_state(self, IRLAN_IDLE);
 
 		/* Give the client a kick! */
@@ -167,10 +163,10 @@ static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -189,8 +185,6 @@ static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_conn(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch (event) {
@@ -204,10 +198,10 @@ static int irlan_client_state_conn(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -224,8 +218,6 @@ static int irlan_client_state_conn(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch (event) {
@@ -244,10 +236,10 @@ static int irlan_client_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -266,8 +258,6 @@ static int irlan_client_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_media(struct irlan_cb *self, IRLAN_EVENT event,
 				    struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch(event) {
@@ -281,10 +271,10 @@ static int irlan_client_state_media(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -305,8 +295,6 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 {
 	struct qos_info qos;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch(event) {
@@ -344,7 +332,7 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 			irlan_next_client_state(self, IRLAN_DATA);
 			break;
 		default:
-			IRDA_DEBUG(2, "%s(), unknown access type!\n", __func__ );
+			pr_debug("%s(), unknown access type!\n", __func__);
 			break;
 		}
 		break;
@@ -353,10 +341,10 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 
@@ -376,8 +364,6 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_wait(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch(event) {
@@ -390,10 +376,10 @@ static int irlan_client_state_wait(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -407,8 +393,6 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 {
 	struct qos_info qos;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch(event) {
@@ -429,7 +413,7 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 		} else if (self->client.recv_arb_val >
 			   self->provider.send_arb_val)
 		{
-			IRDA_DEBUG(2, "%s(), lost the battle :-(\n", __func__ );
+			pr_debug("%s(), lost the battle :-(\n", __func__);
 		}
 		break;
 	case IRLAN_DATA_CONNECT_INDICATION:
@@ -440,10 +424,10 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
+		pr_debug("%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -462,8 +446,6 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
 
@@ -476,7 +458,7 @@ static int irlan_client_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -494,8 +476,6 @@ static int irlan_client_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_close(struct irlan_cb *self, IRLAN_EVENT event,
 				    struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if (skb)
 		dev_kfree_skb(skb);
 
@@ -511,8 +491,6 @@ static int irlan_client_state_close(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_sync(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if (skb)
 		dev_kfree_skb(skb);
 
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index cc60b4a..481bbc2 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -118,8 +118,6 @@ static int __init irlan_init(void)
 	struct irlan_cb *new;
 	__u16 hints;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 #ifdef CONFIG_PROC_FS
 	{ struct proc_dir_entry *proc;
 	proc = proc_create("irlan", 0, proc_irda, &irlan_fops);
@@ -130,7 +128,6 @@ static int __init irlan_init(void)
 	}
 #endif /* CONFIG_PROC_FS */
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
 	hints = irlmp_service_to_hint(S_LAN);
 
 	/* Register with IrLMP as a client */
@@ -173,8 +170,6 @@ static void __exit irlan_cleanup(void)
 {
 	struct irlan_cb *self, *next;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	irlmp_unregister_client(ckey);
 	irlmp_unregister_service(skey);
 
@@ -201,8 +196,6 @@ static struct irlan_cb __init *irlan_open(__u32 saddr, __u32 daddr)
 	struct net_device *dev;
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Create network device with irlan */
 	dev = alloc_irlandev(eth ? "eth%d" : "irlan%d");
 	if (!dev)
@@ -245,8 +238,8 @@ static struct irlan_cb __init *irlan_open(__u32 saddr, __u32 daddr)
 	irlan_next_provider_state(self, IRLAN_IDLE);
 
 	if (register_netdev(dev)) {
-		IRDA_DEBUG(2, "%s(), register_netdev() failed!\n",
-			   __func__ );
+		pr_debug("%s(), register_netdev() failed!\n",
+			 __func__);
 		self = NULL;
 		free_netdev(dev);
 	} else {
@@ -266,8 +259,6 @@ static struct irlan_cb __init *irlan_open(__u32 saddr, __u32 daddr)
  */
 static void __irlan_close(struct irlan_cb *self)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	ASSERT_RTNL();
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -314,8 +305,6 @@ static void irlan_connect_indication(void *instance, void *sap,
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	self = instance;
 	tsap = sap;
 
@@ -326,7 +315,7 @@ static void irlan_connect_indication(void *instance, void *sap,
 	self->max_sdu_size = max_sdu_size;
 	self->max_header_size = max_header_size;
 
-	IRDA_DEBUG(0, "%s: We are now connected!\n", __func__);
+	pr_debug("%s: We are now connected!\n", __func__);
 
 	del_timer(&self->watchdog_timer);
 
@@ -370,7 +359,7 @@ static void irlan_connect_confirm(void *instance, void *sap,
 
 	/* TODO: we could set the MTU depending on the max_sdu_size */
 
-	IRDA_DEBUG(0, "%s: We are now connected!\n", __func__);
+	pr_debug("%s: We are now connected!\n", __func__);
 	del_timer(&self->watchdog_timer);
 
 	/*
@@ -403,7 +392,7 @@ static void irlan_disconnect_indication(void *instance,
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(0, "%s(), reason=%d\n", __func__ , reason);
+	pr_debug("%s(), reason=%d\n", __func__ , reason);
 
 	self = instance;
 	tsap = sap;
@@ -415,26 +404,26 @@ static void irlan_disconnect_indication(void *instance,
 
 	IRDA_ASSERT(tsap == self->tsap_data, return;);
 
-	IRDA_DEBUG(2, "IrLAN, data channel disconnected by peer!\n");
+	pr_debug("IrLAN, data channel disconnected by peer!\n");
 
 	/* Save reason so we know if we should try to reconnect or not */
 	self->disconnect_reason = reason;
 
 	switch (reason) {
 	case LM_USER_REQUEST: /* User request */
-		IRDA_DEBUG(2, "%s(), User requested\n", __func__ );
+		pr_debug("%s(), User requested\n", __func__);
 		break;
 	case LM_LAP_DISCONNECT: /* Unexpected IrLAP disconnect */
-		IRDA_DEBUG(2, "%s(), Unexpected IrLAP disconnect\n", __func__ );
+		pr_debug("%s(), Unexpected IrLAP disconnect\n", __func__);
 		break;
 	case LM_CONNECT_FAILURE: /* Failed to establish IrLAP connection */
-		IRDA_DEBUG(2, "%s(), IrLAP connect failed\n", __func__ );
+		pr_debug("%s(), IrLAP connect failed\n", __func__);
 		break;
 	case LM_LAP_RESET:  /* IrLAP reset */
-		IRDA_DEBUG(2, "%s(), IrLAP reset\n", __func__ );
+		pr_debug("%s(), IrLAP reset\n", __func__);
 		break;
 	case LM_INIT_DISCONNECT:
-		IRDA_DEBUG(2, "%s(), IrLMP connect failed\n", __func__ );
+		pr_debug("%s(), IrLMP connect failed\n", __func__);
 		break;
 	default:
 		net_err_ratelimited("%s(), Unknown disconnect reason\n",
@@ -460,8 +449,6 @@ void irlan_open_data_tsap(struct irlan_cb *self)
 	struct tsap_cb *tsap;
 	notify_t notify;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -482,7 +469,7 @@ void irlan_open_data_tsap(struct irlan_cb *self)
 
 	tsap = irttp_open_tsap(LSAP_ANY, DEFAULT_INITIAL_CREDIT, &notify);
 	if (!tsap) {
-		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __func__ );
+		pr_debug("%s(), Got no tsap!\n", __func__);
 		return;
 	}
 	self->tsap_data = tsap;
@@ -496,8 +483,6 @@ void irlan_open_data_tsap(struct irlan_cb *self)
 
 void irlan_close_tsaps(struct irlan_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -586,8 +571,6 @@ int irlan_run_ctrl_tx_queue(struct irlan_cb *self)
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	if (irda_lock(&self->client.tx_busy) == FALSE)
 		return -EBUSY;
 
@@ -605,7 +588,7 @@ int irlan_run_ctrl_tx_queue(struct irlan_cb *self)
 		dev_kfree_skb(skb);
 		return -1;
 	}
-	IRDA_DEBUG(2, "%s(), sending ...\n", __func__ );
+	pr_debug("%s(), sending ...\n", __func__);
 
 	return irttp_data_request(self->client.tsap_ctrl, skb);
 }
@@ -618,8 +601,6 @@ int irlan_run_ctrl_tx_queue(struct irlan_cb *self)
  */
 static void irlan_ctrl_data_request(struct irlan_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	/* Queue command */
 	skb_queue_tail(&self->client.txq, skb);
 
@@ -638,8 +619,6 @@ void irlan_get_provider_info(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -671,8 +650,6 @@ void irlan_open_data_channel(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -706,8 +683,6 @@ void irlan_close_data_channel(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -747,8 +722,6 @@ static void irlan_open_unicast_addr(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -789,8 +762,6 @@ void irlan_set_broadcast_filter(struct irlan_cb *self, int status)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -833,8 +804,6 @@ void irlan_set_multicast_filter(struct irlan_cb *self, int status)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -878,8 +847,6 @@ static void irlan_get_unicast_addr(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -918,8 +885,6 @@ void irlan_get_media_char(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -1006,7 +971,7 @@ static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 	int n=0;
 
 	if (skb == NULL) {
-		IRDA_DEBUG(2, "%s(), Got NULL skb\n", __func__ );
+		pr_debug("%s(), Got NULL skb\n", __func__);
 		return 0;
 	}
 
@@ -1023,7 +988,7 @@ static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 		IRDA_ASSERT(value_len > 0, return 0;);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown parameter type!\n", __func__ );
+		pr_debug("%s(), Unknown parameter type!\n", __func__);
 		return 0;
 	}
 
@@ -1032,7 +997,7 @@ static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 
 	/* Make space for data */
 	if (skb_tailroom(skb) < (param_len+value_len+3)) {
-		IRDA_DEBUG(2, "%s(), No more space at end of skb\n", __func__ );
+		pr_debug("%s(), No more space at end of skb\n", __func__);
 		return 0;
 	}
 	skb_put(skb, param_len+value_len+3);
@@ -1079,13 +1044,11 @@ int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len)
 	__u16 val_len;
 	int n=0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	/* get length of parameter name (1 byte) */
 	name_len = buf[n++];
 
 	if (name_len > 254) {
-		IRDA_DEBUG(2, "%s(), name_len > 254\n", __func__ );
+		pr_debug("%s(), name_len > 254\n", __func__);
 		return -RSP_INVALID_COMMAND_FORMAT;
 	}
 
@@ -1102,7 +1065,7 @@ int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len)
 	le16_to_cpus(&val_len); n+=2;
 
 	if (val_len >= 1016) {
-		IRDA_DEBUG(2, "%s(), parameter length to long\n", __func__ );
+		pr_debug("%s(), parameter length to long\n", __func__);
 		return -RSP_INVALID_COMMAND_FORMAT;
 	}
 	*len = val_len;
@@ -1112,8 +1075,8 @@ int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len)
 	value[val_len] = '\0';
 	n+=val_len;
 
-	IRDA_DEBUG(4, "Parameter: %s ", name);
-	IRDA_DEBUG(4, "Value: %s\n", value);
+	pr_debug("Parameter: %s ", name);
+	pr_debug("Value: %s\n", value);
 
 	return n;
 }
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 94b948e..fcfbe57 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -110,8 +110,6 @@ static int irlan_eth_open(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Ready to play! */
 	netif_stop_queue(dev); /* Wait until data link is ready */
 
@@ -137,8 +135,6 @@ static int irlan_eth_close(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Stop device */
 	netif_stop_queue(dev);
 
@@ -231,8 +227,8 @@ int irlan_eth_receive(void *instance, void *sap, struct sk_buff *skb)
 		return 0;
 	}
 	if (skb->len < ETH_HLEN) {
-		IRDA_DEBUG(0, "%s() : IrLAN frame too short (%d)\n",
-			   __func__, skb->len);
+		pr_debug("%s() : IrLAN frame too short (%d)\n",
+			 __func__, skb->len);
 		dev->stats.rx_dropped++;
 		dev_kfree_skb(skb);
 		return 0;
@@ -281,9 +277,9 @@ void irlan_eth_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 
 	IRDA_ASSERT(dev != NULL, return;);
 
-	IRDA_DEBUG(0, "%s() : flow %s ; running %d\n", __func__,
-		   flow == FLOW_STOP ? "FLOW_STOP" : "FLOW_START",
-		   netif_running(dev));
+	pr_debug("%s() : flow %s ; running %d\n", __func__,
+		 flow == FLOW_STOP ? "FLOW_STOP" : "FLOW_START",
+		 netif_running(dev));
 
 	switch (flow) {
 	case FLOW_STOP:
@@ -310,11 +306,9 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Check if data channel has been connected yet */
 	if (self->client.state != IRLAN_DATA) {
-		IRDA_DEBUG(1, "%s(), delaying!\n", __func__);
+		pr_debug("%s(), delaying!\n", __func__);
 		return;
 	}
 
@@ -324,18 +318,18 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 	} else if ((dev->flags & IFF_ALLMULTI) ||
 		 netdev_mc_count(dev) > HW_MAX_ADDRS) {
 		/* Disable promiscuous mode, use normal mode. */
-		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__);
+		pr_debug("%s(), Setting multicast filter\n", __func__);
 		/* hardware_set_filter(NULL); */
 
 		irlan_set_multicast_filter(self, TRUE);
 	} else if (!netdev_mc_empty(dev)) {
-		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__);
+		pr_debug("%s(), Setting multicast filter\n", __func__);
 		/* Walk the address list, and load the filter */
 		/* hardware_set_filter(dev->mc_list); */
 
 		irlan_set_multicast_filter(self, TRUE);
 	} else {
-		IRDA_DEBUG(4, "%s(), Clearing multicast filter\n", __func__);
+		pr_debug("%s(), Clearing multicast filter\n", __func__);
 		irlan_set_multicast_filter(self, FALSE);
 	}
 
diff --git a/net/irda/irlan/irlan_event.c b/net/irda/irlan/irlan_event.c
index 43f1604..9a1cc11 100644
--- a/net/irda/irlan/irlan_event.c
+++ b/net/irda/irlan/irlan_event.c
@@ -40,7 +40,7 @@ const char * const irlan_state[] = {
 
 void irlan_next_client_state(struct irlan_cb *self, IRLAN_STATE state)
 {
-	IRDA_DEBUG(2, "%s(), %s\n", __func__ , irlan_state[state]);
+	pr_debug("%s(), %s\n", __func__ , irlan_state[state]);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -50,7 +50,7 @@ void irlan_next_client_state(struct irlan_cb *self, IRLAN_STATE state)
 
 void irlan_next_provider_state(struct irlan_cb *self, IRLAN_STATE state)
 {
-	IRDA_DEBUG(2, "%s(), %s\n", __func__ , irlan_state[state]);
+	pr_debug("%s(), %s\n", __func__ , irlan_state[state]);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
diff --git a/net/irda/irlan/irlan_filter.c b/net/irda/irlan/irlan_filter.c
index 7977be7..e755e90 100644
--- a/net/irda/irlan/irlan_filter.c
+++ b/net/irda/irlan/irlan_filter.c
@@ -43,7 +43,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_DIRECTED) &&
 	    (self->provider.filter_operation == DYNAMIC))
 	{
-		IRDA_DEBUG(0, "Giving peer a dynamic Ethernet address\n");
+		pr_debug("Giving peer a dynamic Ethernet address\n");
 		self->provider.mac_address[0] = 0x40;
 		self->provider.mac_address[1] = 0x00;
 		self->provider.mac_address[2] = 0x00;
@@ -73,7 +73,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_DIRECTED) &&
 	    (self->provider.filter_mode == FILTER))
 	{
-		IRDA_DEBUG(0, "Directed filter on\n");
+		pr_debug("Directed filter on\n");
 		skb->data[0] = 0x00; /* Success */
 		skb->data[1] = 0x00;
 		return;
@@ -81,7 +81,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_DIRECTED) &&
 	    (self->provider.filter_mode == NONE))
 	{
-		IRDA_DEBUG(0, "Directed filter off\n");
+		pr_debug("Directed filter off\n");
 		skb->data[0] = 0x00; /* Success */
 		skb->data[1] = 0x00;
 		return;
@@ -90,7 +90,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_BROADCAST) &&
 	    (self->provider.filter_mode == FILTER))
 	{
-		IRDA_DEBUG(0, "Broadcast filter on\n");
+		pr_debug("Broadcast filter on\n");
 		skb->data[0] = 0x00; /* Success */
 		skb->data[1] = 0x00;
 		return;
@@ -98,7 +98,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_BROADCAST) &&
 	    (self->provider.filter_mode == NONE))
 	{
-		IRDA_DEBUG(0, "Broadcast filter off\n");
+		pr_debug("Broadcast filter off\n");
 		skb->data[0] = 0x00; /* Success */
 		skb->data[1] = 0x00;
 		return;
@@ -106,7 +106,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_MULTICAST) &&
 	    (self->provider.filter_mode == FILTER))
 	{
-		IRDA_DEBUG(0, "Multicast filter on\n");
+		pr_debug("Multicast filter on\n");
 		skb->data[0] = 0x00; /* Success */
 		skb->data[1] = 0x00;
 		return;
@@ -114,7 +114,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_MULTICAST) &&
 	    (self->provider.filter_mode == NONE))
 	{
-		IRDA_DEBUG(0, "Multicast filter off\n");
+		pr_debug("Multicast filter off\n");
 		skb->data[0] = 0x00; /* Success */
 		skb->data[1] = 0x00;
 		return;
@@ -122,7 +122,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	if ((self->provider.filter_type == IRLAN_MULTICAST) &&
 	    (self->provider.filter_operation == GET))
 	{
-		IRDA_DEBUG(0, "Multicast filter get\n");
+		pr_debug("Multicast filter get\n");
 		skb->data[0] = 0x00; /* Success? */
 		skb->data[1] = 0x02;
 		irlan_insert_string_param(skb, "FILTER_MODE", "NONE");
@@ -132,7 +132,7 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
 	skb->data[0] = 0x00; /* Command not supported */
 	skb->data[1] = 0x00;
 
-	IRDA_DEBUG(0, "Not implemented!\n");
+	pr_debug("Not implemented!\n");
 }
 
 /*
@@ -143,18 +143,15 @@ void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb)
  */
 void irlan_check_command_param(struct irlan_cb *self, char *param, char *value)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	IRDA_DEBUG(4, "%s, %s\n", param, value);
+	pr_debug("%s, %s\n", param, value);
 
 	/*
 	 *  This is experimental!! DB.
 	 */
 	 if (strcmp(param, "MODE") == 0) {
-		IRDA_DEBUG(0, "%s()\n", __func__ );
 		self->use_udata = TRUE;
 		return;
 	}
diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index 4664855..15c292c 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -70,8 +70,6 @@ static int irlan_provider_data_indication(void *instance, void *sap,
 	struct irlan_cb *self;
 	__u8 code;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	self = instance;
 
 	IRDA_ASSERT(self != NULL, return -1;);
@@ -82,32 +80,32 @@ static int irlan_provider_data_indication(void *instance, void *sap,
 	code = skb->data[0];
 	switch(code) {
 	case CMD_GET_PROVIDER_INFO:
-		IRDA_DEBUG(4, "Got GET_PROVIDER_INFO command!\n");
+		pr_debug("Got GET_PROVIDER_INFO command!\n");
 		irlan_do_provider_event(self, IRLAN_GET_INFO_CMD, skb);
 		break;
 
 	case CMD_GET_MEDIA_CHAR:
-		IRDA_DEBUG(4, "Got GET_MEDIA_CHAR command!\n");
+		pr_debug("Got GET_MEDIA_CHAR command!\n");
 		irlan_do_provider_event(self, IRLAN_GET_MEDIA_CMD, skb);
 		break;
 	case CMD_OPEN_DATA_CHANNEL:
-		IRDA_DEBUG(4, "Got OPEN_DATA_CHANNEL command!\n");
+		pr_debug("Got OPEN_DATA_CHANNEL command!\n");
 		irlan_do_provider_event(self, IRLAN_OPEN_DATA_CMD, skb);
 		break;
 	case CMD_FILTER_OPERATION:
-		IRDA_DEBUG(4, "Got FILTER_OPERATION command!\n");
+		pr_debug("Got FILTER_OPERATION command!\n");
 		irlan_do_provider_event(self, IRLAN_FILTER_CONFIG_CMD, skb);
 		break;
 	case CMD_RECONNECT_DATA_CHAN:
-		IRDA_DEBUG(2, "%s(), Got RECONNECT_DATA_CHAN command\n", __func__ );
-		IRDA_DEBUG(2, "%s(), NOT IMPLEMENTED\n", __func__ );
+		pr_debug("%s(), Got RECONNECT_DATA_CHAN command\n", __func__);
+		pr_debug("%s(), NOT IMPLEMENTED\n", __func__);
 		break;
 	case CMD_CLOSE_DATA_CHAN:
-		IRDA_DEBUG(2, "Got CLOSE_DATA_CHAN command!\n");
-		IRDA_DEBUG(2, "%s(), NOT IMPLEMENTED\n", __func__ );
+		pr_debug("Got CLOSE_DATA_CHAN command!\n");
+		pr_debug("%s(), NOT IMPLEMENTED\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown command!\n", __func__ );
+		pr_debug("%s(), Unknown command!\n", __func__);
 		break;
 	}
 	return 0;
@@ -128,8 +126,6 @@ static void irlan_provider_connect_indication(void *instance, void *sap,
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(0, "%s()\n", __func__ );
-
 	self = instance;
 	tsap = sap;
 
@@ -179,7 +175,7 @@ static void irlan_provider_disconnect_indication(void *instance, void *sap,
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(4, "%s(), reason=%d\n", __func__ , reason);
+	pr_debug("%s(), reason=%d\n", __func__ , reason);
 
 	self = instance;
 	tsap = sap;
@@ -233,7 +229,7 @@ int irlan_provider_parse_command(struct irlan_cb *self, int cmd,
 
 	IRDA_ASSERT(skb != NULL, return -RSP_PROTOCOL_ERROR;);
 
-	IRDA_DEBUG(4, "%s(), skb->len=%d\n", __func__ , (int)skb->len);
+	pr_debug("%s(), skb->len=%d\n", __func__ , (int)skb->len);
 
 	IRDA_ASSERT(self != NULL, return -RSP_PROTOCOL_ERROR;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -RSP_PROTOCOL_ERROR;);
@@ -255,7 +251,7 @@ int irlan_provider_parse_command(struct irlan_cb *self, int cmd,
 	/* How many parameters? */
 	count = frame[1];
 
-	IRDA_DEBUG(4, "Got %d parameters\n", count);
+	pr_debug("Got %d parameters\n", count);
 
 	ptr = frame+2;
 
@@ -263,7 +259,7 @@ int irlan_provider_parse_command(struct irlan_cb *self, int cmd,
 	for (i=0; i<count;i++) {
 		ret = irlan_extract_param(ptr, name, value, &val_len);
 		if (ret < 0) {
-			IRDA_DEBUG(2, "%s(), IrLAN, Error!\n", __func__ );
+			pr_debug("%s(), IrLAN, Error!\n", __func__);
 			break;
 		}
 		ptr+=ret;
@@ -288,8 +284,6 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -320,7 +314,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 			irlan_insert_string_param(skb, "MEDIA", "802.5");
 			break;
 		default:
-			IRDA_DEBUG(2, "%s(), unknown media type!\n", __func__ );
+			pr_debug("%s(), unknown media type!\n", __func__);
 			break;
 		}
 		irlan_insert_short_param(skb, "IRLAN_VER", 0x0101);
@@ -344,7 +338,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 			irlan_insert_string_param(skb, "ACCESS_TYPE", "HOSTED");
 			break;
 		default:
-			IRDA_DEBUG(2, "%s(), Unknown access type\n", __func__ );
+			pr_debug("%s(), Unknown access type\n", __func__);
 			break;
 		}
 		irlan_insert_short_param(skb, "MAX_FRAME", 0x05ee);
@@ -364,7 +358,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 		irlan_filter_request(self, skb);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown command!\n", __func__ );
+		pr_debug("%s(), Unknown command!\n", __func__);
 		break;
 	}
 
@@ -382,8 +376,6 @@ int irlan_provider_open_ctrl_tsap(struct irlan_cb *self)
 	struct tsap_cb *tsap;
 	notify_t notify;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
 
@@ -403,7 +395,7 @@ int irlan_provider_open_ctrl_tsap(struct irlan_cb *self)
 
 	tsap = irttp_open_tsap(LSAP_ANY, 1, &notify);
 	if (!tsap) {
-		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __func__ );
+		pr_debug("%s(), Got no tsap!\n", __func__);
 		return -1;
 	}
 	self->provider.tsap_ctrl = tsap;
diff --git a/net/irda/irlan/irlan_provider_event.c b/net/irda/irlan/irlan_provider_event.c
index 01a9d7c..9c4f7f5 100644
--- a/net/irda/irlan/irlan_provider_event.c
+++ b/net/irda/irlan/irlan_provider_event.c
@@ -72,8 +72,6 @@ void irlan_do_provider_event(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_provider_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 				     struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch(event) {
@@ -82,7 +80,7 @@ static int irlan_provider_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 	     irlan_next_provider_state( self, IRLAN_INFO);
 	     break;
 	default:
-		IRDA_DEBUG(4, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -101,8 +99,6 @@ static int irlan_provider_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch(event) {
@@ -147,7 +143,7 @@ static int irlan_provider_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_provider_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG( 0, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -166,8 +162,6 @@ static int irlan_provider_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_provider_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 				     struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	switch(event) {
@@ -186,7 +180,7 @@ static int irlan_provider_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_provider_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -205,8 +199,6 @@ static int irlan_provider_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_provider_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 				     struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__ );
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
 
@@ -221,7 +213,7 @@ static int irlan_provider_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_provider_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG( 0, "%s(), Unknown event %d\n", __func__ , event);
+		pr_debug("%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 2e3bc6c..4b011b7a 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -111,8 +111,6 @@ struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
 {
 	struct irlap_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	/* Initialize the irlap structure. */
 	self = kzalloc(sizeof(struct irlap_cb), GFP_KERNEL);
 	if (self == NULL)
@@ -213,8 +211,6 @@ void irlap_close(struct irlap_cb *self)
 {
 	struct irlap_cb *lap;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -229,7 +225,7 @@ void irlap_close(struct irlap_cb *self)
 	/* Be sure that we manage to remove ourself from the hash */
 	lap = hashbin_remove(irlap, self->saddr, NULL);
 	if (!lap) {
-		IRDA_DEBUG(1, "%s(), Didn't find myself!\n", __func__);
+		pr_debug("%s(), Didn't find myself!\n", __func__);
 		return;
 	}
 	__irlap_close(lap);
@@ -244,8 +240,6 @@ EXPORT_SYMBOL(irlap_close);
  */
 void irlap_connect_indication(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -263,8 +257,6 @@ void irlap_connect_indication(struct irlap_cb *self, struct sk_buff *skb)
  */
 void irlap_connect_response(struct irlap_cb *self, struct sk_buff *userdata)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	irlap_do_event(self, CONNECT_RESPONSE, userdata, NULL);
 }
 
@@ -278,7 +270,7 @@ void irlap_connect_response(struct irlap_cb *self, struct sk_buff *userdata)
 void irlap_connect_request(struct irlap_cb *self, __u32 daddr,
 			   struct qos_info *qos_user, int sniff)
 {
-	IRDA_DEBUG(3, "%s(), daddr=0x%08x\n", __func__, daddr);
+	pr_debug("%s(), daddr=0x%08x\n", __func__, daddr);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -305,8 +297,6 @@ void irlap_connect_request(struct irlap_cb *self, __u32 daddr,
  */
 void irlap_connect_confirm(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -342,8 +332,6 @@ void irlap_data_request(struct irlap_cb *self, struct sk_buff *skb,
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(skb_headroom(skb) >= (LAP_ADDR_HEADER+LAP_CTRL_HEADER),
 		    return;);
 	skb_push(skb, LAP_ADDR_HEADER+LAP_CTRL_HEADER);
@@ -389,8 +377,6 @@ void irlap_unitdata_request(struct irlap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(skb_headroom(skb) >= (LAP_ADDR_HEADER+LAP_CTRL_HEADER),
 	       return;);
 	skb_push(skb, LAP_ADDR_HEADER+LAP_CTRL_HEADER);
@@ -415,8 +401,6 @@ void irlap_unitdata_request(struct irlap_cb *self, struct sk_buff *skb)
 #ifdef CONFIG_IRDA_ULTRA
 void irlap_unitdata_indication(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -435,8 +419,6 @@ void irlap_unitdata_indication(struct irlap_cb *self, struct sk_buff *skb)
  */
 void irlap_disconnect_request(struct irlap_cb *self)
 {
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -456,7 +438,7 @@ void irlap_disconnect_request(struct irlap_cb *self)
 		irlap_do_event(self, DISCONNECT_REQUEST, NULL, NULL);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), disconnect pending!\n", __func__);
+		pr_debug("%s(), disconnect pending!\n", __func__);
 		self->disconnect_pending = TRUE;
 		break;
 	}
@@ -470,7 +452,7 @@ void irlap_disconnect_request(struct irlap_cb *self)
  */
 void irlap_disconnect_indication(struct irlap_cb *self, LAP_REASON reason)
 {
-	IRDA_DEBUG(1, "%s(), reason=%s\n", __func__, lap_reasons[reason]);
+	pr_debug("%s(), reason=%s\n", __func__, lap_reasons[reason]);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -480,7 +462,7 @@ void irlap_disconnect_indication(struct irlap_cb *self, LAP_REASON reason)
 
 	switch (reason) {
 	case LAP_RESET_INDICATION:
-		IRDA_DEBUG(1, "%s(), Sending reset request!\n", __func__);
+		pr_debug("%s(), Sending reset request!\n", __func__);
 		irlap_do_event(self, RESET_REQUEST, NULL, NULL);
 		break;
 	case LAP_NO_RESPONSE:	   /* FALLTHROUGH */
@@ -510,7 +492,7 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(discovery != NULL, return;);
 
-	IRDA_DEBUG(4, "%s(), nslots = %d\n", __func__, discovery->nslots);
+	pr_debug("%s(), nslots = %d\n", __func__, discovery->nslots);
 
 	IRDA_ASSERT((discovery->nslots == 1) || (discovery->nslots == 6) ||
 		    (discovery->nslots == 8) || (discovery->nslots == 16),
@@ -518,8 +500,8 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 
 	/* Discovery is only possible in NDM mode */
 	if (self->state != LAP_NDM) {
-		IRDA_DEBUG(4, "%s(), discovery only possible in NDM mode\n",
-			   __func__);
+		pr_debug("%s(), discovery only possible in NDM mode\n",
+			 __func__);
 		irlap_discovery_confirm(self, NULL);
 		/* Note : in theory, if we are not in NDM, we could postpone
 		 * the discovery like we do for connection request.
@@ -597,8 +579,6 @@ void irlap_discovery_confirm(struct irlap_cb *self, hashbin_t *discovery_log)
  */
 void irlap_discovery_indication(struct irlap_cb *self, discovery_t *discovery)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(discovery != NULL, return;);
@@ -643,8 +623,6 @@ void irlap_status_indication(struct irlap_cb *self, int quality_of_link)
  */
 void irlap_reset_indication(struct irlap_cb *self)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -659,7 +637,6 @@ void irlap_reset_indication(struct irlap_cb *self)
  */
 void irlap_reset_confirm(void)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__);
 }
 
 /*
@@ -759,7 +736,7 @@ int irlap_validate_nr_received(struct irlap_cb *self, int nr)
 {
 	/*  nr as expected?  */
 	if (nr == self->vs) {
-		IRDA_DEBUG(4, "%s(), expected!\n", __func__);
+		pr_debug("%s(), expected!\n", __func__);
 		return NR_EXPECTED;
 	}
 
@@ -787,8 +764,6 @@ int irlap_validate_nr_received(struct irlap_cb *self, int nr)
  */
 void irlap_initiate_connection_state(struct irlap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -870,7 +845,7 @@ static void irlap_change_speed(struct irlap_cb *self, __u32 speed, int now)
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(0, "%s(), setting speed to %d\n", __func__, speed);
+	pr_debug("%s(), setting speed to %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -913,7 +888,7 @@ static void irlap_init_qos_capabilities(struct irlap_cb *self,
 	 *  user may not have set all of them.
 	 */
 	if (qos_user) {
-		IRDA_DEBUG(1, "%s(), Found user specified QoS!\n", __func__);
+		pr_debug("%s(), Found user specified QoS!\n", __func__);
 
 		if (qos_user->baud_rate.bits)
 			self->qos_rx.baud_rate.bits &= qos_user->baud_rate.bits;
@@ -943,8 +918,6 @@ static void irlap_init_qos_capabilities(struct irlap_cb *self,
  */
 void irlap_apply_default_connection_parameters(struct irlap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -1006,8 +979,6 @@ void irlap_apply_default_connection_parameters(struct irlap_cb *self)
  */
 void irlap_apply_connection_parameters(struct irlap_cb *self, int now)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -1086,12 +1057,12 @@ void irlap_apply_connection_parameters(struct irlap_cb *self, int now)
 		self->N1 = sysctl_warn_noreply_time * 1000 /
 		  self->qos_rx.max_turn_time.value;
 
-	IRDA_DEBUG(4, "Setting N1 = %d\n", self->N1);
+	pr_debug("Setting N1 = %d\n", self->N1);
 
 	/* Set N2 to match our own disconnect time */
 	self->N2 = self->qos_tx.link_disc_time.value * 1000 /
 		self->qos_rx.max_turn_time.value;
-	IRDA_DEBUG(4, "Setting N2 = %d\n", self->N2);
+	pr_debug("Setting N2 = %d\n", self->N2);
 }
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
index 5f4a84e..245d87b 100644
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -218,7 +218,7 @@ static void irlap_start_poll_timer(struct irlap_cb *self, int timeout)
 	} else
 		self->fast_RR = FALSE;
 
-	IRDA_DEBUG(3, "%s(), timeout=%d (%ld)\n", __func__, timeout, jiffies);
+	pr_debug("%s(), timeout=%d (%ld)\n", __func__, timeout, jiffies);
 #endif /* CONFIG_IRDA_FAST_RR */
 
 	if (timeout == 0)
@@ -242,8 +242,8 @@ void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event,
 	if (!self || self->magic != LAP_MAGIC)
 		return;
 
-	IRDA_DEBUG(3, "%s(), event = %s, state = %s\n", __func__,
-		   irlap_event[event], irlap_state[self->state]);
+	pr_debug("%s(), event = %s, state = %s\n", __func__,
+		 irlap_event[event], irlap_state[self->state]);
 
 	ret = (*state[self->state])(self, event, skb, info);
 
@@ -260,8 +260,8 @@ void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event,
 		 * try to disconnect link if we send any data frames, since
 		 * that will change the state away form XMIT
 		 */
-		IRDA_DEBUG(2, "%s() : queue len = %d\n", __func__,
-			   skb_queue_len(&self->txq));
+		pr_debug("%s() : queue len = %d\n", __func__,
+			 skb_queue_len(&self->txq));
 
 		if (!skb_queue_empty(&self->txq)) {
 			/* Prevent race conditions with irlap_data_request() */
@@ -340,8 +340,8 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 			/* Note : this will never happen, because we test
 			 * media busy in irlap_connect_request() and
 			 * postpone the event... - Jean II */
-			IRDA_DEBUG(0, "%s(), CONNECT_REQUEST: media busy!\n",
-				   __func__);
+			pr_debug("%s(), CONNECT_REQUEST: media busy!\n",
+				 __func__);
 
 			/* Always switch state before calling upper layers */
 			irlap_next_state(self, LAP_NDM);
@@ -367,16 +367,16 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 
 			irlap_connect_indication(self, skb);
 		} else {
-			IRDA_DEBUG(0, "%s(), SNRM frame does not "
-				   "contain an I field!\n", __func__);
+			pr_debug("%s(), SNRM frame does not contain an I field!\n",
+				 __func__);
 		}
 		break;
 	case DISCOVERY_REQUEST:
 		IRDA_ASSERT(info != NULL, return -1;);
 
 		if (self->media_busy) {
-			IRDA_DEBUG(1, "%s(), DISCOVERY_REQUEST: media busy!\n",
-				   __func__);
+			pr_debug("%s(), DISCOVERY_REQUEST: media busy!\n",
+				 __func__);
 			/* irlap->log.condition = MEDIA_BUSY; */
 
 			/* This will make IrLMP try again */
@@ -442,7 +442,8 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 		 * those cases...
 		 * Jean II
 		 */
-			IRDA_DEBUG(1, "%s(), Receiving final discovery request, missed the discovery slots :-(\n", __func__);
+			pr_debug("%s(), Receiving final discovery request, missed the discovery slots :-(\n",
+				 __func__);
 
 			/* Last discovery request -> in the log */
 			irlap_discovery_indication(self, info->discovery);
@@ -520,8 +521,8 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 	case RECV_UI_FRAME:
 		/* Only accept broadcast frames in NDM mode */
 		if (info->caddr != CBROADCAST) {
-			IRDA_DEBUG(0, "%s(), not a broadcast frame!\n",
-				   __func__);
+			pr_debug("%s(), not a broadcast frame!\n",
+				 __func__);
 		} else
 			irlap_unitdata_indication(self, skb);
 		break;
@@ -537,11 +538,11 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_send_test_frame(self, CBROADCAST, info->daddr, skb);
 		break;
 	case RECV_TEST_RSP:
-		IRDA_DEBUG(0, "%s() not implemented!\n", __func__);
+		pr_debug("%s() not implemented!\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
-			   irlap_event[event]);
+		pr_debug("%s(), Unknown event %s\n", __func__,
+			 irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -568,8 +569,8 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 		IRDA_ASSERT(info != NULL, return -1;);
 		IRDA_ASSERT(info->discovery != NULL, return -1;);
 
-		IRDA_DEBUG(4, "%s(), daddr=%08x\n", __func__,
-			   info->discovery->data.daddr);
+		pr_debug("%s(), daddr=%08x\n", __func__,
+			 info->discovery->data.daddr);
 
 		if (!self->discovery_log) {
 			net_warn_ratelimited("%s: discovery log is gone! maybe the discovery timeout has been set too short?\n",
@@ -598,7 +599,8 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 
 		IRDA_ASSERT(info != NULL, return -1;);
 
-		IRDA_DEBUG(1, "%s(), Receiving discovery request (s = %d) while performing discovery :-(\n", __func__, info->s);
+		pr_debug("%s(), Receiving discovery request (s = %d) while performing discovery :-(\n",
+			 __func__, info->s);
 
 		/* Last discovery request ? */
 		if (info->s == 0xff)
@@ -612,8 +614,8 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 		 * timing requirements.
 		 */
 		if (irda_device_is_receiving(self->netdev) && !self->add_wait) {
-			IRDA_DEBUG(2, "%s(), device is slow to answer, "
-				   "waiting some more!\n", __func__);
+			pr_debug("%s(), device is slow to answer, waiting some more!\n",
+				 __func__);
 			irlap_start_slot_timer(self, msecs_to_jiffies(10));
 			self->add_wait = TRUE;
 			return ret;
@@ -649,8 +651,8 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
-			   irlap_event[event]);
+		pr_debug("%s(), Unknown event %s\n", __func__,
+			 irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -671,15 +673,13 @@ static int irlap_state_reply(struct irlap_cb *self, IRLAP_EVENT event,
 	discovery_t *discovery_rsp;
 	int ret=0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
 	case QUERY_TIMER_EXPIRED:
-		IRDA_DEBUG(0, "%s(), QUERY_TIMER_EXPIRED <%ld>\n",
-			   __func__, jiffies);
+		pr_debug("%s(), QUERY_TIMER_EXPIRED <%ld>\n",
+			 __func__, jiffies);
 		irlap_next_state(self, LAP_NDM);
 		break;
 	case RECV_DISCOVERY_XID_CMD:
@@ -717,8 +717,8 @@ static int irlap_state_reply(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __func__,
-			   event, irlap_event[event]);
+		pr_debug("%s(), Unknown event %d, %s\n", __func__,
+			 event, irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -738,7 +738,7 @@ static int irlap_state_conn(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s(), event=%s\n", __func__, irlap_event[ event]);
+	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -798,20 +798,20 @@ static int irlap_state_conn(struct irlap_cb *self, IRLAP_EVENT event,
 
 		break;
 	case RECV_DISCOVERY_XID_CMD:
-		IRDA_DEBUG(3, "%s(), event RECV_DISCOVER_XID_CMD!\n",
-			   __func__);
+		pr_debug("%s(), event RECV_DISCOVER_XID_CMD!\n",
+			 __func__);
 		irlap_next_state(self, LAP_NDM);
 
 		break;
 	case DISCONNECT_REQUEST:
-		IRDA_DEBUG(0, "%s(), Disconnect request!\n", __func__);
+		pr_debug("%s(), Disconnect request!\n", __func__);
 		irlap_send_dm_frame(self);
 		irlap_next_state( self, LAP_NDM);
 		irlap_disconnect_indication(self, LAP_DISC_INDICATION);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __func__,
-			   event, irlap_event[event]);
+		pr_debug("%s(), Unknown event %d, %s\n", __func__,
+			 event, irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -832,8 +832,6 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
@@ -861,7 +859,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 		self->retry_count++;
 		break;
 	case RECV_SNRM_CMD:
-		IRDA_DEBUG(4, "%s(), SNRM battle!\n", __func__);
+		pr_debug("%s(), SNRM battle!\n", __func__);
 
 		IRDA_ASSERT(skb != NULL, return 0;);
 		IRDA_ASSERT(info != NULL, return 0;);
@@ -948,8 +946,8 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_disconnect_indication(self, LAP_DISC_INDICATION);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __func__,
-			   event, irlap_event[event]);
+		pr_debug("%s(), Unknown event %d, %s\n", __func__,
+			 event, irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -966,7 +964,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 static int irlap_state_offline(struct irlap_cb *self, IRLAP_EVENT event,
 			       struct sk_buff *skb, struct irlap_info *info)
 {
-	IRDA_DEBUG( 0, "%s(), Unknown event\n", __func__);
+	pr_debug("%s(), Unknown event\n", __func__);
 
 	return -1;
 }
@@ -1029,8 +1027,8 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 			 *  speed and turn-around-time.
 			 */
 			if((!nextfit) && (skb->len > self->bytes_left)) {
-				IRDA_DEBUG(0, "%s(), Not allowed to transmit"
-					   " more bytes!\n", __func__);
+				pr_debug("%s(), Not allowed to transmit more bytes!\n",
+					 __func__);
 				/* Requeue the skb */
 				skb_queue_head(&self->txq, skb_get(skb));
 				/*
@@ -1081,8 +1079,8 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 			self->fast_RR = FALSE;
 #endif /* CONFIG_IRDA_FAST_RR */
 		} else {
-			IRDA_DEBUG(4, "%s(), Unable to send! remote busy?\n",
-				   __func__);
+			pr_debug("%s(), Unable to send! remote busy?\n",
+				 __func__);
 			skb_queue_head(&self->txq, skb_get(skb));
 
 			/*
@@ -1093,8 +1091,8 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	case POLL_TIMER_EXPIRED:
-		IRDA_DEBUG(3, "%s(), POLL_TIMER_EXPIRED <%ld>\n",
-			    __func__, jiffies);
+		pr_debug("%s(), POLL_TIMER_EXPIRED <%ld>\n",
+			 __func__, jiffies);
 		irlap_send_rr_frame(self, CMD_FRAME);
 		/* Return to NRM properly - Jean II  */
 		self->window = self->window_size;
@@ -1119,8 +1117,8 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 		 * when we return... - Jean II */
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
-			   __func__, irlap_event[event]);
+		pr_debug("%s(), Unknown event %s\n",
+			 __func__, irlap_event[event]);
 
 		ret = -EINVAL;
 		break;
@@ -1138,8 +1136,6 @@ static int irlap_state_pclose(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
@@ -1173,7 +1169,7 @@ static int irlap_state_pclose(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d\n", __func__, event);
+		pr_debug("%s(), Unknown event %d\n", __func__, event);
 
 		ret = -1;
 		break;
@@ -1295,9 +1291,8 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 				/* Keep state */
 				irlap_next_state(self, LAP_NRM_P);
 			} else {
-				IRDA_DEBUG(4,
-				       "%s(), missing or duplicate frame!\n",
-					   __func__);
+				pr_debug("%s(), missing or duplicate frame!\n",
+					 __func__);
 
 				/* Update Nr received */
 				irlap_update_nr_received(self, info->nr);
@@ -1366,8 +1361,8 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		if ((ns_status == NS_UNEXPECTED) &&
 		    (nr_status == NR_UNEXPECTED))
 		{
-			IRDA_DEBUG(4, "%s(), unexpected nr and ns!\n",
-				   __func__);
+			pr_debug("%s(), unexpected nr and ns!\n",
+				 __func__);
 			if (info->pf) {
 				/* Resend rejected frames */
 				irlap_resend_rejected_frames(self, CMD_FRAME);
@@ -1407,9 +1402,9 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			}
 			break;
 		}
-		IRDA_DEBUG(1, "%s(), Not implemented!\n", __func__);
-		IRDA_DEBUG(1, "%s(), event=%s, ns_status=%d, nr_status=%d\n",
-		       __func__, irlap_event[event], ns_status, nr_status);
+		pr_debug("%s(), Not implemented!\n", __func__);
+		pr_debug("%s(), event=%s, ns_status=%d, nr_status=%d\n",
+			 __func__, irlap_event[event], ns_status, nr_status);
 		break;
 	case RECV_UI_FRAME:
 		/* Poll bit cleared? */
@@ -1420,7 +1415,8 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			del_timer(&self->final_timer);
 			irlap_data_indication(self, skb, TRUE);
 			irlap_next_state(self, LAP_XMIT_P);
-			IRDA_DEBUG(1, "%s: RECV_UI_FRAME: next state %s\n", __func__, irlap_state[self->state]);
+			pr_debug("%s: RECV_UI_FRAME: next state %s\n",
+				 __func__, irlap_state[self->state]);
 			irlap_start_poll_timer(self, self->poll_timeout);
 		}
 		break;
@@ -1463,10 +1459,9 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			/* Update Nr received */
 			irlap_update_nr_received(self, info->nr);
 
-			IRDA_DEBUG(4, "RECV_RR_FRAME: Retrans:%d, nr=%d, va=%d, "
-			      "vs=%d, vr=%d\n",
-			      self->retry_count, info->nr, self->va,
-			      self->vs, self->vr);
+			pr_debug("RECV_RR_FRAME: Retrans:%d, nr=%d, va=%d, vs=%d, vr=%d\n",
+				 self->retry_count, info->nr, self->va,
+				 self->vs, self->vr);
 
 			/* Resend rejected frames */
 			irlap_resend_rejected_frames(self, CMD_FRAME);
@@ -1474,8 +1469,8 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 
 			irlap_next_state(self, LAP_NRM_P);
 		} else if (ret == NR_INVALID) {
-			IRDA_DEBUG(1, "%s(), Received RR with "
-				   "invalid nr !\n", __func__);
+			pr_debug("%s(), Received RR with invalid nr !\n",
+				 __func__);
 
 			irlap_next_state(self, LAP_RESET_WAIT);
 
@@ -1511,8 +1506,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		 *  we only do this once for each frame.
 		 */
 		if (irda_device_is_receiving(self->netdev) && !self->add_wait) {
-			IRDA_DEBUG(1, "FINAL_TIMER_EXPIRED when receiving a "
-			      "frame! Waiting a little bit more!\n");
+			pr_debug("FINAL_TIMER_EXPIRED when receiving a frame! Waiting a little bit more!\n");
 			irlap_start_final_timer(self, msecs_to_jiffies(300));
 
 			/*
@@ -1529,18 +1523,18 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		if (self->retry_count < self->N2) {
 			if (skb_peek(&self->wx_list) == NULL) {
 				/* Retry sending the pf bit to the secondary */
-				IRDA_DEBUG(4, "nrm_p: resending rr");
+				pr_debug("nrm_p: resending rr");
 				irlap_wait_min_turn_around(self, &self->qos_tx);
 				irlap_send_rr_frame(self, CMD_FRAME);
 			} else {
-				IRDA_DEBUG(4, "nrm_p: resend frames");
+				pr_debug("nrm_p: resend frames");
 				irlap_resend_rejected_frames(self, CMD_FRAME);
 			}
 
 			irlap_start_final_timer(self, self->final_timeout);
 			self->retry_count++;
-			IRDA_DEBUG(4, "irlap_state_nrm_p: FINAL_TIMER_EXPIRED:"
-				   " retry_count=%d\n", self->retry_count);
+			pr_debug("irlap_state_nrm_p: FINAL_TIMER_EXPIRED: retry_count=%d\n",
+				 self->retry_count);
 
 			/* Early warning event. I'm using a pretty liberal
 			 * interpretation of the spec and generate an event
@@ -1580,7 +1574,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_start_final_timer(self, 2 * self->final_timeout);
 		break;
 	case RECV_RD_RSP:
-		IRDA_DEBUG(1, "%s(), RECV_RD_RSP\n", __func__);
+		pr_debug("%s(), RECV_RD_RSP\n", __func__);
 
 		irlap_flush_all_queues(self);
 		irlap_next_state(self, LAP_XMIT_P);
@@ -1588,8 +1582,8 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_disconnect_request(self);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %s\n",
-			    __func__, irlap_event[event]);
+		pr_debug("%s(), Unknown event %s\n",
+			 __func__, irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -1609,7 +1603,7 @@ static int irlap_state_reset_wait(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(3, "%s(), event = %s\n", __func__, irlap_event[event]);
+	pr_debug("%s(), event = %s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -1635,8 +1629,8 @@ static int irlap_state_reset_wait(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_next_state( self, LAP_PCLOSE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
-			   irlap_event[event]);
+		pr_debug("%s(), Unknown event %s\n", __func__,
+			 irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -1656,7 +1650,7 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(3, "%s(), event = %s\n", __func__, irlap_event[event]);
+	pr_debug("%s(), event = %s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -1714,7 +1708,7 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 		 * state
 		 */
 		if (!info) {
-			IRDA_DEBUG(3, "%s(), RECV_SNRM_CMD\n", __func__);
+			pr_debug("%s(), RECV_SNRM_CMD\n", __func__);
 			irlap_initiate_connection_state(self);
 			irlap_wait_min_turn_around(self, &self->qos_tx);
 			irlap_send_ua_response_frame(self, &self->qos_rx);
@@ -1722,14 +1716,13 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 			irlap_start_wd_timer(self, self->wd_timeout);
 			irlap_next_state(self, LAP_NDM);
 		} else {
-			IRDA_DEBUG(0,
-				   "%s(), SNRM frame contained an I field!\n",
-				   __func__);
+			pr_debug("%s(), SNRM frame contained an I field!\n",
+				 __func__);
 		}
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %s\n",
-			   __func__, irlap_event[event]);
+		pr_debug("%s(), Unknown event %s\n",
+			 __func__, irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -1749,7 +1742,7 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s(), event=%s\n", __func__, irlap_event[event]);
+	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
@@ -1785,8 +1778,8 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 			 *  speed and turn-around-time.
 			 */
 			if((!nextfit) && (skb->len > self->bytes_left)) {
-				IRDA_DEBUG(0, "%s(), Not allowed to transmit"
-					   " more bytes!\n", __func__);
+				pr_debug("%s(), Not allowed to transmit more bytes!\n",
+					 __func__);
 				/* Requeue the skb */
 				skb_queue_head(&self->txq, skb_get(skb));
 
@@ -1832,7 +1825,7 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 				ret = -EPROTO;
 			}
 		} else {
-			IRDA_DEBUG(2, "%s(), Unable to send!\n", __func__);
+			pr_debug("%s(), Unable to send!\n", __func__);
 			skb_queue_head(&self->txq, skb_get(skb));
 			ret = -EPROTO;
 		}
@@ -1848,8 +1841,8 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 		 * when we return... - Jean II */
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
-			   irlap_event[event]);
+		pr_debug("%s(), Unknown event %s\n", __func__,
+			 irlap_event[event]);
 
 		ret = -EINVAL;
 		break;
@@ -1871,7 +1864,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 	int nr_status;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s(), event=%s\n", __func__, irlap_event[ event]);
+	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -1879,10 +1872,9 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 	switch (event) {
 	case RECV_I_CMD: /* Optimize for the common case */
 		/* FIXME: must check for remote_busy below */
-		IRDA_DEBUG(4, "%s(), event=%s nr=%d, vs=%d, ns=%d, "
-			   "vr=%d, pf=%d\n", __func__,
-			   irlap_event[event], info->nr,
-			   self->vs, info->ns, self->vr, info->pf);
+		pr_debug("%s(), event=%s nr=%d, vs=%d, ns=%d, vr=%d, pf=%d\n",
+			 __func__, irlap_event[event], info->nr,
+			 self->vs, info->ns, self->vr, info->pf);
 
 		self->retry_count = 0;
 
@@ -1982,7 +1974,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 		if ((ns_status == NS_EXPECTED) && (nr_status == NR_UNEXPECTED))
 		{
 			if (info->pf) {
-				IRDA_DEBUG(4, "RECV_I_RSP: frame(s) lost\n");
+				pr_debug("RECV_I_RSP: frame(s) lost\n");
 
 				self->vr = (self->vr + 1) % 8;
 
@@ -2019,10 +2011,10 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 
 		if (ret == NR_INVALID) {
-			IRDA_DEBUG(0, "NRM_S, NR_INVALID not implemented!\n");
+			pr_debug("NRM_S, NR_INVALID not implemented!\n");
 		}
 		if (ret == NS_INVALID) {
-			IRDA_DEBUG(0, "NRM_S, NS_INVALID not implemented!\n");
+			pr_debug("NRM_S, NS_INVALID not implemented!\n");
 		}
 		break;
 	case RECV_UI_FRAME:
@@ -2111,22 +2103,21 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 			/* Keep state */
 			irlap_next_state(self, LAP_NRM_S);
 		} else {
-			IRDA_DEBUG(1, "%s(), invalid nr not implemented!\n",
-				   __func__);
+			pr_debug("%s(), invalid nr not implemented!\n",
+				 __func__);
 		}
 		break;
 	case RECV_SNRM_CMD:
 		/* SNRM frame is not allowed to contain an I-field */
 		if (!info) {
 			del_timer(&self->wd_timer);
-			IRDA_DEBUG(1, "%s(), received SNRM cmd\n", __func__);
+			pr_debug("%s(), received SNRM cmd\n", __func__);
 			irlap_next_state(self, LAP_RESET_CHECK);
 
 			irlap_reset_indication(self);
 		} else {
-			IRDA_DEBUG(0,
-				   "%s(), SNRM frame contained an I-field!\n",
-				   __func__);
+			pr_debug("%s(), SNRM frame contained an I-field!\n",
+				 __func__);
 
 		}
 		break;
@@ -2158,8 +2149,8 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 		 *   which explain why we use (self->N2 / 2) here !!!
 		 * Jean II
 		 */
-		IRDA_DEBUG(1, "%s(), retry_count = %d\n", __func__,
-			   self->retry_count);
+		pr_debug("%s(), retry_count = %d\n", __func__,
+			 self->retry_count);
 
 		if (self->retry_count < (self->N2 / 2)) {
 			/* No retry, just wait for primary */
@@ -2211,8 +2202,8 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_send_test_frame(self, self->caddr, info->daddr, skb);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __func__,
-			   event, irlap_event[event]);
+		pr_debug("%s(), Unknown event %d, (%s)\n", __func__,
+			 event, irlap_event[event]);
 
 		ret = -EINVAL;
 		break;
@@ -2226,8 +2217,6 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 			      struct sk_buff *skb, struct irlap_info *info)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
 
@@ -2283,8 +2272,8 @@ static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 			break;		/* stay in SCLOSE */
 		}
 
-		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __func__,
-			   event, irlap_event[event]);
+		pr_debug("%s(), Unknown event %d, (%s)\n", __func__,
+			 event, irlap_event[event]);
 
 		break;
 	}
@@ -2298,7 +2287,7 @@ static int irlap_state_reset_check( struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(1, "%s(), event=%s\n", __func__, irlap_event[event]);
+	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
@@ -2319,8 +2308,8 @@ static int irlap_state_reset_check( struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_next_state(self, LAP_SCLOSE);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __func__,
-			   event, irlap_event[event]);
+		pr_debug("%s(), Unknown event %d, (%s)\n", __func__,
+			 event, irlap_event[event]);
 
 		ret = -EINVAL;
 		break;
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 90ef036..b936b12 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -103,8 +103,8 @@ void irlap_queue_xmit(struct irlap_cb *self, struct sk_buff *skb)
 	irlap_insert_info(self, skb);
 
 	if (unlikely(self->mode & IRDA_MODE_MONITOR)) {
-		IRDA_DEBUG(3, "%s(): %s is in monitor mode\n", __func__,
-			   self->netdev->name);
+		pr_debug("%s(): %s is in monitor mode\n", __func__,
+			 self->netdev->name);
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -182,8 +182,8 @@ static void irlap_recv_snrm_cmd(struct irlap_cb *self, struct sk_buff *skb,
 
 		/* Check if the new connection address is valid */
 		if ((info->caddr == 0x00) || (info->caddr == 0xfe)) {
-			IRDA_DEBUG(3, "%s(), invalid connection address!\n",
-				   __func__);
+			pr_debug("%s(), invalid connection address!\n",
+				 __func__);
 			return;
 		}
 
@@ -193,8 +193,8 @@ static void irlap_recv_snrm_cmd(struct irlap_cb *self, struct sk_buff *skb,
 
 		/* Only accept if addressed directly to us */
 		if (info->saddr != self->saddr) {
-			IRDA_DEBUG(2, "%s(), not addressed to us!\n",
-				   __func__);
+			pr_debug("%s(), not addressed to us!\n",
+				 __func__);
 			return;
 		}
 		irlap_do_event(self, RECV_SNRM_CMD, skb, info);
@@ -216,7 +216,7 @@ void irlap_send_ua_response_frame(struct irlap_cb *self, struct qos_info *qos)
 	struct ua_frame *frame;
 	int ret;
 
-	IRDA_DEBUG(2, "%s() <%ld>\n", __func__, jiffies);
+	pr_debug("%s() <%ld>\n", __func__, jiffies);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -291,8 +291,6 @@ void irlap_send_disc_frame(struct irlap_cb *self)
 	struct sk_buff *tx_skb = NULL;
 	struct disc_frame *frame;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -322,8 +320,8 @@ void irlap_send_discovery_xid_frame(struct irlap_cb *self, int S, __u8 s,
 	__u32 bcast = BROADCAST;
 	__u8 *info;
 
-	IRDA_DEBUG(4, "%s(), s=%d, S=%d, command=%d\n", __func__,
-		   s, S, command);
+	pr_debug("%s(), s=%d, S=%d, command=%d\n", __func__,
+		 s, S, command);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -415,8 +413,6 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	__u8 *discovery_info;
 	char *text;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
@@ -432,8 +428,8 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 
 	/* Make sure frame is addressed to us */
 	if ((info->saddr != self->saddr) && (info->saddr != BROADCAST)) {
-		IRDA_DEBUG(0, "%s(), frame is not addressed to us!\n",
-			   __func__);
+		pr_debug("%s(), frame is not addressed to us!\n",
+			 __func__);
 		return;
 	}
 
@@ -446,15 +442,15 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	discovery->data.saddr = self->saddr;
 	discovery->timestamp = jiffies;
 
-	IRDA_DEBUG(4, "%s(), daddr=%08x\n", __func__,
-		   discovery->data.daddr);
+	pr_debug("%s(), daddr=%08x\n", __func__,
+		 discovery->data.daddr);
 
 	discovery_info = skb_pull(skb, sizeof(struct xid_frame));
 
 	/* Get info returned from peer */
 	discovery->data.hints[0] = discovery_info[0];
 	if (discovery_info[0] & HINT_EXTENSION) {
-		IRDA_DEBUG(4, "EXTENSION\n");
+		pr_debug("EXTENSION\n");
 		discovery->data.hints[1] = discovery_info[1];
 		discovery->data.charset = discovery_info[2];
 		text = (char *) &discovery_info[3];
@@ -503,8 +499,8 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 
 	/* Make sure frame is addressed to us */
 	if ((info->saddr != self->saddr) && (info->saddr != BROADCAST)) {
-		IRDA_DEBUG(0, "%s(), frame is not addressed to us!\n",
-			   __func__);
+		pr_debug("%s(), frame is not addressed to us!\n",
+			 __func__);
 		return;
 	}
 
@@ -656,7 +652,7 @@ static void irlap_recv_rnr_frame(struct irlap_cb *self, struct sk_buff *skb,
 {
 	info->nr = skb->data[1] >> 5;
 
-	IRDA_DEBUG(4, "%s(), nr=%d, %ld\n", __func__, info->nr, jiffies);
+	pr_debug("%s(), nr=%d, %ld\n", __func__, info->nr, jiffies);
 
 	if (command)
 		irlap_do_event(self, RECV_RNR_CMD, skb, info);
@@ -667,8 +663,6 @@ static void irlap_recv_rnr_frame(struct irlap_cb *self, struct sk_buff *skb,
 static void irlap_recv_rej_frame(struct irlap_cb *self, struct sk_buff *skb,
 				 struct irlap_info *info, int command)
 {
-	IRDA_DEBUG(0, "%s()\n", __func__);
-
 	info->nr = skb->data[1] >> 5;
 
 	/* Check if this is a command or a response frame */
@@ -681,8 +675,6 @@ static void irlap_recv_rej_frame(struct irlap_cb *self, struct sk_buff *skb,
 static void irlap_recv_srej_frame(struct irlap_cb *self, struct sk_buff *skb,
 				  struct irlap_info *info, int command)
 {
-	IRDA_DEBUG(0, "%s()\n", __func__);
-
 	info->nr = skb->data[1] >> 5;
 
 	/* Check if this is a command or a response frame */
@@ -695,8 +687,6 @@ static void irlap_recv_srej_frame(struct irlap_cb *self, struct sk_buff *skb,
 static void irlap_recv_disc_frame(struct irlap_cb *self, struct sk_buff *skb,
 				  struct irlap_info *info, int command)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/* Check if this is a command or a response frame */
 	if (command)
 		irlap_do_event(self, RECV_DISC_CMD, skb, info);
@@ -754,7 +744,7 @@ void irlap_send_data_primary(struct irlap_cb *self, struct sk_buff *skb)
 
 		irlap_send_i_frame( self, tx_skb, CMD_FRAME);
 	} else {
-		IRDA_DEBUG(4, "%s(), sending unreliable frame\n", __func__);
+		pr_debug("%s(), sending unreliable frame\n", __func__);
 		irlap_send_ui_frame(self, skb_get(skb), self->caddr, CMD_FRAME);
 		self->window -= 1;
 	}
@@ -807,7 +797,7 @@ void irlap_send_data_primary_poll(struct irlap_cb *self, struct sk_buff *skb)
 		irlap_next_state(self, LAP_NRM_P);
 		irlap_send_i_frame(self, tx_skb, CMD_FRAME);
 	} else {
-		IRDA_DEBUG(4, "%s(), sending unreliable frame\n", __func__);
+		pr_debug("%s(), sending unreliable frame\n", __func__);
 
 		if (self->ack_required) {
 			irlap_send_ui_frame(self, skb_get(skb), self->caddr, CMD_FRAME);
@@ -834,7 +824,9 @@ void irlap_send_data_primary_poll(struct irlap_cb *self, struct sk_buff *skb)
 	 * See max_line_capacities[][] in qos.c for details. Jean II */
 	transmission_time -= (self->final_timeout * self->bytes_left
 			      / self->line_capacity);
-	IRDA_DEBUG(4, "%s() adjusting transmission_time : ft=%d, bl=%d, lc=%d -> tt=%d\n", __func__, self->final_timeout, self->bytes_left, self->line_capacity, transmission_time);
+	pr_debug("%s() adjusting transmission_time : ft=%d, bl=%d, lc=%d -> tt=%d\n",
+		 __func__, self->final_timeout, self->bytes_left,
+		 self->line_capacity, transmission_time);
 
 	/* We are allowed to transmit a maximum number of bytes again. */
 	self->bytes_left = self->line_capacity;
@@ -995,7 +987,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 		/* tx_skb = skb_clone( skb, GFP_ATOMIC); */
 		tx_skb = skb_copy(skb, GFP_ATOMIC);
 		if (!tx_skb) {
-			IRDA_DEBUG(0, "%s(), unable to copy\n", __func__);
+			pr_debug("%s(), unable to copy\n", __func__);
 			return;
 		}
 
@@ -1018,7 +1010,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 	 */
 	while (!skb_queue_empty(&self->txq)) {
 
-		IRDA_DEBUG(0, "%s(), sending additional frames!\n", __func__);
+		pr_debug("%s(), sending additional frames!\n", __func__);
 		if (self->window > 0) {
 			skb = skb_dequeue( &self->txq);
 			IRDA_ASSERT(skb != NULL, return;);
@@ -1058,7 +1050,7 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 		/* tx_skb = skb_clone( skb, GFP_ATOMIC); */
 		tx_skb = skb_copy(skb, GFP_ATOMIC);
 		if (!tx_skb) {
-			IRDA_DEBUG(0, "%s(), unable to copy\n", __func__);
+			pr_debug("%s(), unable to copy\n", __func__);
 			return;
 		}
 
@@ -1081,8 +1073,6 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 void irlap_send_ui_frame(struct irlap_cb *self, struct sk_buff *skb,
 			 __u8 caddr, int command)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -1141,8 +1131,6 @@ static inline void irlap_recv_i_frame(struct irlap_cb *self,
 static void irlap_recv_ui_frame(struct irlap_cb *self, struct sk_buff *skb,
 				struct irlap_info *info)
 {
-	IRDA_DEBUG( 4, "%s()\n", __func__);
-
 	info->pf = skb->data[1] & PF_BIT;      /* Final bit */
 
 	irlap_do_event(self, RECV_UI_FRAME, skb, info);
@@ -1160,8 +1148,6 @@ static void irlap_recv_frmr_frame(struct irlap_cb *self, struct sk_buff *skb,
 	__u8 *frame;
 	int w, x, y, z;
 
-	IRDA_DEBUG(0, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -1184,21 +1170,16 @@ static void irlap_recv_frmr_frame(struct irlap_cb *self, struct sk_buff *skb,
 	z = frame[3] & 0x08;
 
 	if (w) {
-		IRDA_DEBUG(0, "Rejected control field is undefined or not "
-		      "implemented.\n");
+		pr_debug("Rejected control field is undefined or not implemented\n");
 	}
 	if (x) {
-		IRDA_DEBUG(0, "Rejected control field was invalid because it "
-		      "contained a non permitted I field.\n");
+		pr_debug("Rejected control field was invalid because it contained a non permitted I field\n");
 	}
 	if (y) {
-		IRDA_DEBUG(0, "Received I field exceeded the maximum negotiated "
-		      "for the existing connection or exceeded the maximum "
-		      "this station supports if no connection exists.\n");
+		pr_debug("Received I field exceeded the maximum negotiated for the existing connection or exceeded the maximum this station supports if no connection exists\n");
 	}
 	if (z) {
-		IRDA_DEBUG(0, "Rejected control field control field contained an "
-		      "invalid Nr count.\n");
+		pr_debug("Rejected control field control field contained an invalid Nr count\n");
 	}
 	irlap_do_event(self, RECV_FRMR_RSP, skb, info);
 }
@@ -1254,8 +1235,6 @@ static void irlap_recv_test_frame(struct irlap_cb *self, struct sk_buff *skb,
 {
 	struct test_frame *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	if (!pskb_may_pull(skb, sizeof(*frame))) {
 		net_err_ratelimited("%s: frame too short!\n", __func__);
 		return;
@@ -1265,8 +1244,8 @@ static void irlap_recv_test_frame(struct irlap_cb *self, struct sk_buff *skb,
 	/* Broadcast frames must carry saddr and daddr fields */
 	if (info->caddr == CBROADCAST) {
 		if (skb->len < sizeof(struct test_frame)) {
-			IRDA_DEBUG(0, "%s() test frame too short!\n",
-				   __func__);
+			pr_debug("%s() test frame too short!\n",
+				 __func__);
 			return;
 		}
 
@@ -1346,8 +1325,8 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	/*  First we check if this frame has a valid connection address */
 	if ((info.caddr != self->caddr) && (info.caddr != CBROADCAST)) {
-		IRDA_DEBUG(0, "%s(), wrong connection address!\n",
-			   __func__);
+		pr_debug("%s(), wrong connection address!\n",
+			 __func__);
 		goto out;
 	}
 	/*
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 6178e71..a26c401 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -83,7 +83,6 @@ const char *irlmp_reason_str(LM_REASON reason)
  */
 int __init irlmp_init(void)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__);
 	/* Initialize the irlmp structure. */
 	irlmp = kzalloc( sizeof(struct irlmp_cb), GFP_KERNEL);
 	if (irlmp == NULL)
@@ -207,8 +206,6 @@ EXPORT_SYMBOL(irlmp_open_lsap);
  */
 static void __irlmp_close_lsap(struct lsap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
@@ -267,9 +264,8 @@ void irlmp_close_lsap(struct lsap_cb *self)
 				      NULL);
 	}
 	if (!lsap) {
-		IRDA_DEBUG(0,
-		     "%s(), Looks like somebody has removed me already!\n",
-			   __func__);
+		pr_debug("%s(), Looks like somebody has removed me already!\n",
+			 __func__);
 		return;
 	}
 	__irlmp_close_lsap(self);
@@ -340,8 +336,6 @@ void irlmp_unregister_link(__u32 saddr)
 {
 	struct lap_cb *link;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	/* We must remove ourselves from the hashbin *first*. This ensure
 	 * that no more LSAPs will be open on this link and no discovery
 	 * will be triggered anymore. Jean II */
@@ -383,9 +377,8 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 	IRDA_ASSERT(self != NULL, return -EBADR;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -EBADR;);
 
-	IRDA_DEBUG(2,
-	      "%s(), slsap_sel=%02x, dlsap_sel=%02x, saddr=%08x, daddr=%08x\n",
-	      __func__, self->slsap_sel, dlsap_sel, saddr, daddr);
+	pr_debug("%s(), slsap_sel=%02x, dlsap_sel=%02x, saddr=%08x, daddr=%08x\n",
+		 __func__, self->slsap_sel, dlsap_sel, saddr, daddr);
 
 	if (test_bit(0, &self->connected)) {
 		ret = -EISCONN;
@@ -429,7 +422,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 		if (daddr != DEV_ADDR_ANY)
 			discovery = hashbin_find(irlmp->cachelog, daddr, NULL);
 		else {
-			IRDA_DEBUG(2, "%s(), no daddr\n", __func__);
+			pr_debug("%s(), no daddr\n", __func__);
 			discovery = (discovery_t *)
 				hashbin_get_first(irlmp->cachelog);
 		}
@@ -442,7 +435,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 	}
 	lap = hashbin_lock_find(irlmp->links, saddr, NULL);
 	if (lap == NULL) {
-		IRDA_DEBUG(1, "%s(), Unable to find a usable link!\n", __func__);
+		pr_debug("%s(), Unable to find a usable link!\n", __func__);
 		ret = -EHOSTUNREACH;
 		goto err;
 	}
@@ -457,14 +450,15 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 			 * disconnected yet (waiting for timeout in LAP).
 			 * Maybe we could give LAP a bit of help in this case.
 			 */
-			IRDA_DEBUG(0, "%s(), sorry, but I'm waiting for LAP to timeout!\n", __func__);
+			pr_debug("%s(), sorry, but I'm waiting for LAP to timeout!\n",
+				 __func__);
 			ret = -EAGAIN;
 			goto err;
 		}
 
 		/* LAP is already connected to a different node, and LAP
 		 * can only talk to one node at a time */
-		IRDA_DEBUG(0, "%s(), sorry, but link is busy!\n", __func__);
+		pr_debug("%s(), sorry, but link is busy!\n", __func__);
 		ret = -EBUSY;
 		goto err;
 	}
@@ -525,8 +519,8 @@ void irlmp_connect_indication(struct lsap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(skb != NULL, return;);
 	IRDA_ASSERT(self->lap != NULL, return;);
 
-	IRDA_DEBUG(2, "%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
-		   __func__, self->slsap_sel, self->dlsap_sel);
+	pr_debug("%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
+		 __func__, self->slsap_sel, self->dlsap_sel);
 
 	/* Note : self->lap is set in irlmp_link_data_indication(),
 	 * (case CONNECT_CMD:) because we have no way to set it here.
@@ -566,8 +560,8 @@ int irlmp_connect_response(struct lsap_cb *self, struct sk_buff *userdata)
 	/* We set the connected bit and move the lsap to the connected list
 	 * in the state machine itself. Jean II */
 
-	IRDA_DEBUG(2, "%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
-		   __func__, self->slsap_sel, self->dlsap_sel);
+	pr_debug("%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
+		 __func__, self->slsap_sel, self->dlsap_sel);
 
 	/* Make room for MUX control header (3 bytes) */
 	IRDA_ASSERT(skb_headroom(userdata) >= LMP_CONTROL_HEADER, return -1;);
@@ -593,8 +587,6 @@ void irlmp_connect_confirm(struct lsap_cb *self, struct sk_buff *skb)
 	int lap_header_size;
 	int max_seg_size;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(skb != NULL, return;);
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
@@ -606,8 +598,8 @@ void irlmp_connect_confirm(struct lsap_cb *self, struct sk_buff *skb)
 	lap_header_size = IRLAP_GET_HEADER_SIZE(self->lap->irlap);
 	max_header_size = LMP_HEADER + lap_header_size;
 
-	IRDA_DEBUG(2, "%s(), max_header_size=%d\n",
-		   __func__, max_header_size);
+	pr_debug("%s(), max_header_size=%d\n",
+		 __func__, max_header_size);
 
 	/* Hide LMP_CONTROL_HEADER header from layer above */
 	skb_pull(skb, LMP_CONTROL_HEADER);
@@ -633,16 +625,14 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	struct lsap_cb *new;
 	unsigned long flags;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	spin_lock_irqsave(&irlmp->unconnected_lsaps->hb_spinlock, flags);
 
 	/* Only allowed to duplicate unconnected LSAP's, and only LSAPs
 	 * that have received a connect indication. Jean II */
 	if ((!hashbin_find(irlmp->unconnected_lsaps, (long) orig, NULL)) ||
 	    (orig->lap == NULL)) {
-		IRDA_DEBUG(0, "%s(), invalid LSAP (wrong state)\n",
-			   __func__);
+		pr_debug("%s(), invalid LSAP (wrong state)\n",
+			 __func__);
 		spin_unlock_irqrestore(&irlmp->unconnected_lsaps->hb_spinlock,
 				       flags);
 		return NULL;
@@ -651,7 +641,7 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	/* Allocate a new instance */
 	new = kmemdup(orig, sizeof(*new), GFP_ATOMIC);
 	if (!new)  {
-		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __func__);
+		pr_debug("%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irlmp->unconnected_lsaps->hb_spinlock,
 				       flags);
 		return NULL;
@@ -697,7 +687,7 @@ int irlmp_disconnect_request(struct lsap_cb *self, struct sk_buff *userdata)
 	 * and us that might mess up the hashbins below. This fixes it.
 	 * Jean II */
 	if (! test_and_clear_bit(0, &self->connected)) {
-		IRDA_DEBUG(0, "%s(), already disconnected!\n", __func__);
+		pr_debug("%s(), already disconnected!\n", __func__);
 		dev_kfree_skb(userdata);
 		return -1;
 	}
@@ -751,20 +741,20 @@ void irlmp_disconnect_indication(struct lsap_cb *self, LM_REASON reason,
 {
 	struct lsap_cb *lsap;
 
-	IRDA_DEBUG(1, "%s(), reason=%s [%d]\n", __func__,
-		   irlmp_reason_str(reason), reason);
+	pr_debug("%s(), reason=%s [%d]\n", __func__,
+		 irlmp_reason_str(reason), reason);
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
-	IRDA_DEBUG(3, "%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
-		   __func__, self->slsap_sel, self->dlsap_sel);
+	pr_debug("%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
+		 __func__, self->slsap_sel, self->dlsap_sel);
 
 	/* Already disconnected ?
 	 * There is a race condition between irlmp_disconnect_request()
 	 * and us that might mess up the hashbins below. This fixes it.
 	 * Jean II */
 	if (! test_and_clear_bit(0, &self->connected)) {
-		IRDA_DEBUG(0, "%s(), already disconnected!\n", __func__);
+		pr_debug("%s(), already disconnected!\n", __func__);
 		return;
 	}
 
@@ -797,7 +787,7 @@ void irlmp_disconnect_indication(struct lsap_cb *self, LM_REASON reason,
 		self->notify.disconnect_indication(self->notify.instance,
 						   self, reason, skb);
 	} else {
-		IRDA_DEBUG(0, "%s(), no handler\n", __func__);
+		pr_debug("%s(), no handler\n", __func__);
 	}
 }
 
@@ -968,8 +958,6 @@ irlmp_notify_client(irlmp_client_t *client,
 	int	number;			/* Number of nodes in the log */
 	int	i;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	/* Check if client wants or not partial/selective log (optimisation) */
 	if (!client->disco_callback)
 		return;
@@ -1019,8 +1007,6 @@ void irlmp_discovery_confirm(hashbin_t *log, DISCOVERY_MODE mode)
 	irlmp_client_t *client;
 	irlmp_client_t *client_next;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(log != NULL, return;);
 
 	if (!(HASHBIN_GET_SIZE(log)))
@@ -1054,8 +1040,6 @@ void irlmp_discovery_expiry(discinfo_t *expiries, int number)
 	irlmp_client_t *client_next;
 	int		i;
 
-	IRDA_DEBUG(3, "%s()\n", __func__);
-
 	IRDA_ASSERT(expiries != NULL, return;);
 
 	/* For each client - notify callback may touch client list */
@@ -1088,8 +1072,6 @@ void irlmp_discovery_expiry(discinfo_t *expiries, int number)
  */
 discovery_t *irlmp_get_discovery_response(void)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(irlmp != NULL, return NULL;);
 
 	put_unaligned(irlmp->hints.word, (__u16 *)irlmp->discovery_rsp.data.hints);
@@ -1166,8 +1148,6 @@ int irlmp_udata_request(struct lsap_cb *self, struct sk_buff *userdata)
 {
 	int	ret;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(userdata != NULL, return -1;);
 
 	/* Make room for MUX header */
@@ -1190,8 +1170,6 @@ int irlmp_udata_request(struct lsap_cb *self, struct sk_buff *userdata)
  */
 void irlmp_udata_indication(struct lsap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -1217,8 +1195,6 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 	struct sk_buff *clone_skb;
 	struct lap_cb *lap;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(userdata != NULL, return -1;);
 
 	/* Make room for MUX and PID header */
@@ -1268,8 +1244,6 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 #ifdef CONFIG_IRDA_ULTRA
 void irlmp_connless_data_indication(struct lsap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -1311,7 +1285,7 @@ void irlmp_status_indication(struct lap_cb *self,
 			curr->notify.status_indication(curr->notify.instance,
 						       link, lock);
 		else
-			IRDA_DEBUG(2, "%s(), no handler\n", __func__);
+			pr_debug("%s(), no handler\n", __func__);
 
 		curr = next;
 	}
@@ -1339,7 +1313,7 @@ void irlmp_flow_indication(struct lap_cb *self, LOCAL_FLOW flow)
 	/* Get the number of lsap. That's the only safe way to know
 	 * that we have looped around... - Jean II */
 	lsap_todo = HASHBIN_GET_SIZE(self->lsaps);
-	IRDA_DEBUG(4, "%s() : %d lsaps to scan\n", __func__, lsap_todo);
+	pr_debug("%s() : %d lsaps to scan\n", __func__, lsap_todo);
 
 	/* Poll lsap in order until the queue is full or until we
 	 * tried them all.
@@ -1358,14 +1332,16 @@ void irlmp_flow_indication(struct lap_cb *self, LOCAL_FLOW flow)
 		/* Uh-oh... Paranoia */
 		if(curr == NULL)
 			break;
-		IRDA_DEBUG(4, "%s() : curr is %p, next was %p and is now %p, still %d to go - queue len = %d\n", __func__, curr, next, self->flow_next, lsap_todo, IRLAP_GET_TX_QUEUE_LEN(self->irlap));
+		pr_debug("%s() : curr is %p, next was %p and is now %p, still %d to go - queue len = %d\n",
+			 __func__, curr, next, self->flow_next, lsap_todo,
+			 IRLAP_GET_TX_QUEUE_LEN(self->irlap));
 
 		/* Inform lsap user that it can send one more packet. */
 		if (curr->notify.flow_indication != NULL)
 			curr->notify.flow_indication(curr->notify.instance,
 						     curr, flow);
 		else
-			IRDA_DEBUG(1, "%s(), no handler\n", __func__);
+			pr_debug("%s(), no handler\n", __func__);
 	}
 }
 
@@ -1386,32 +1362,30 @@ __u8 *irlmp_hint_to_service(__u8 *hint)
 	 * since we currently only support 2 hint bytes
 	 */
 	service = kmalloc(16, GFP_ATOMIC);
-	if (!service) {
-		IRDA_DEBUG(1, "%s(), Unable to kmalloc!\n", __func__);
+	if (!service)
 		return NULL;
-	}
 
 	if (!hint[0]) {
-		IRDA_DEBUG(1, "<None>\n");
+		pr_debug("<None>\n");
 		kfree(service);
 		return NULL;
 	}
 	if (hint[0] & HINT_PNP)
-		IRDA_DEBUG(1, "PnP Compatible ");
+		pr_debug("PnP Compatible ");
 	if (hint[0] & HINT_PDA)
-		IRDA_DEBUG(1, "PDA/Palmtop ");
+		pr_debug("PDA/Palmtop ");
 	if (hint[0] & HINT_COMPUTER)
-		IRDA_DEBUG(1, "Computer ");
+		pr_debug("Computer ");
 	if (hint[0] & HINT_PRINTER) {
-		IRDA_DEBUG(1, "Printer ");
+		pr_debug("Printer ");
 		service[i++] = S_PRINTER;
 	}
 	if (hint[0] & HINT_MODEM)
-		IRDA_DEBUG(1, "Modem ");
+		pr_debug("Modem ");
 	if (hint[0] & HINT_FAX)
-		IRDA_DEBUG(1, "Fax ");
+		pr_debug("Fax ");
 	if (hint[0] & HINT_LAN) {
-		IRDA_DEBUG(1, "LAN Access ");
+		pr_debug("LAN Access ");
 		service[i++] = S_LAN;
 	}
 	/*
@@ -1421,22 +1395,22 @@ __u8 *irlmp_hint_to_service(__u8 *hint)
 	 */
 	if (hint[0] & HINT_EXTENSION) {
 		if (hint[1] & HINT_TELEPHONY) {
-			IRDA_DEBUG(1, "Telephony ");
+			pr_debug("Telephony ");
 			service[i++] = S_TELEPHONY;
 		}
 		if (hint[1] & HINT_FILE_SERVER)
-			IRDA_DEBUG(1, "File Server ");
+			pr_debug("File Server ");
 
 		if (hint[1] & HINT_COMM) {
-			IRDA_DEBUG(1, "IrCOMM ");
+			pr_debug("IrCOMM ");
 			service[i++] = S_COMM;
 		}
 		if (hint[1] & HINT_OBEX) {
-			IRDA_DEBUG(1, "IrOBEX ");
+			pr_debug("IrOBEX ");
 			service[i++] = S_OBEX;
 		}
 	}
-	IRDA_DEBUG(1, "\n");
+	pr_debug("\n");
 
 	/* So that client can be notified about any discovery */
 	service[i++] = S_ANY;
@@ -1489,14 +1463,13 @@ void *irlmp_register_service(__u16 hints)
 {
 	irlmp_service_t *service;
 
-	IRDA_DEBUG(4, "%s(), hints = %04x\n", __func__, hints);
+	pr_debug("%s(), hints = %04x\n", __func__, hints);
 
 	/* Make a new registration */
 	service = kmalloc(sizeof(irlmp_service_t), GFP_ATOMIC);
-	if (!service) {
-		IRDA_DEBUG(1, "%s(), Unable to kmalloc!\n", __func__);
+	if (!service)
 		return NULL;
-	}
+
 	service->hints.word = hints;
 	hashbin_insert(irlmp->services, (irda_queue_t *) service,
 		       (long) service, NULL);
@@ -1519,15 +1492,13 @@ int irlmp_unregister_service(void *handle)
 	irlmp_service_t *service;
 	unsigned long flags;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	if (!handle)
 		return -1;
 
 	/* Caller may call with invalid handle (it's legal) - Jean II */
 	service = hashbin_lock_find(irlmp->services, (long) handle, NULL);
 	if (!service) {
-		IRDA_DEBUG(1, "%s(), Unknown service!\n", __func__);
+		pr_debug("%s(), Unknown service!\n", __func__);
 		return -1;
 	}
 
@@ -1564,15 +1535,12 @@ void *irlmp_register_client(__u16 hint_mask, DISCOVERY_CALLBACK1 disco_clb,
 {
 	irlmp_client_t *client;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
 	IRDA_ASSERT(irlmp != NULL, return NULL;);
 
 	/* Make a new registration */
 	client = kmalloc(sizeof(irlmp_client_t), GFP_ATOMIC);
-	if (!client) {
-		IRDA_DEBUG( 1, "%s(), Unable to kmalloc!\n", __func__);
+	if (!client)
 		return NULL;
-	}
 
 	/* Register the details */
 	client->hint_mask.word = hint_mask;
@@ -1606,7 +1574,7 @@ int irlmp_update_client(void *handle, __u16 hint_mask,
 
 	client = hashbin_lock_find(irlmp->clients, (long) handle, NULL);
 	if (!client) {
-		IRDA_DEBUG(1, "%s(), Unknown client!\n", __func__);
+		pr_debug("%s(), Unknown client!\n", __func__);
 		return -1;
 	}
 
@@ -1629,19 +1597,17 @@ int irlmp_unregister_client(void *handle)
 {
 	struct irlmp_client *client;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	if (!handle)
 		return -1;
 
 	/* Caller may call with invalid handle (it's legal) - Jean II */
 	client = hashbin_lock_find(irlmp->clients, (long) handle, NULL);
 	if (!client) {
-		IRDA_DEBUG(1, "%s(), Unknown client!\n", __func__);
+		pr_debug("%s(), Unknown client!\n", __func__);
 		return -1;
 	}
 
-	IRDA_DEBUG(4, "%s(), removing client!\n", __func__);
+	pr_debug("%s(), removing client!\n", __func__);
 	hashbin_remove_this(irlmp->clients, (irda_queue_t *) client);
 	kfree(client);
 
@@ -1670,8 +1636,6 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 	IRDA_ASSERT(irlmp->magic == LMP_MAGIC, return TRUE;);
 	IRDA_ASSERT(slsap_sel != LSAP_ANY, return TRUE;);
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 #ifdef CONFIG_IRDA_ULTRA
 	/* Accept all bindings to the connectionless LSAP */
 	if (slsap_sel == LSAP_CONNLESS)
@@ -1705,8 +1669,8 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 				    goto errlsap;);
 
 			if ((self->slsap_sel == slsap_sel)) {
-				IRDA_DEBUG(4, "Source LSAP selector=%02x in use\n",
-					   self->slsap_sel);
+				pr_debug("Source LSAP selector=%02x in use\n",
+					 self->slsap_sel);
 				goto errlsap;
 			}
 			self = (struct lsap_cb*) hashbin_get_next(lap->lsaps);
@@ -1730,8 +1694,8 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 	while (self != NULL) {
 		IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, goto erruncon;);
 		if ((self->slsap_sel == slsap_sel)) {
-			IRDA_DEBUG(4, "Source LSAP selector=%02x in use (unconnected)\n",
-				   self->slsap_sel);
+			pr_debug("Source LSAP selector=%02x in use (unconnected)\n",
+				 self->slsap_sel);
 			goto erruncon;
 		}
 		self = (struct lsap_cb*) hashbin_get_next(irlmp->unconnected_lsaps);
@@ -1811,8 +1775,8 @@ static __u8 irlmp_find_free_slsap(void)
 
 	/* Got it ! */
 	lsap_sel = irlmp->last_lsap_sel;
-	IRDA_DEBUG(4, "%s(), found free lsap_sel=%02x\n",
-		   __func__, lsap_sel);
+	pr_debug("%s(), found free lsap_sel=%02x\n",
+		 __func__, lsap_sel);
 
 	return lsap_sel;
 }
@@ -1830,26 +1794,27 @@ LM_REASON irlmp_convert_lap_reason( LAP_REASON lap_reason)
 
 	switch (lap_reason) {
 	case LAP_DISC_INDICATION: /* Received a disconnect request from peer */
-		IRDA_DEBUG( 1, "%s(), LAP_DISC_INDICATION\n", __func__);
+		pr_debug("%s(), LAP_DISC_INDICATION\n", __func__);
 		reason = LM_USER_REQUEST;
 		break;
 	case LAP_NO_RESPONSE:    /* To many retransmits without response */
-		IRDA_DEBUG( 1, "%s(), LAP_NO_RESPONSE\n", __func__);
+		pr_debug("%s(), LAP_NO_RESPONSE\n", __func__);
 		reason = LM_LAP_DISCONNECT;
 		break;
 	case LAP_RESET_INDICATION:
-		IRDA_DEBUG( 1, "%s(), LAP_RESET_INDICATION\n", __func__);
+		pr_debug("%s(), LAP_RESET_INDICATION\n", __func__);
 		reason = LM_LAP_RESET;
 		break;
 	case LAP_FOUND_NONE:
 	case LAP_MEDIA_BUSY:
 	case LAP_PRIMARY_CONFLICT:
-		IRDA_DEBUG(1, "%s(), LAP_FOUND_NONE, LAP_MEDIA_BUSY or LAP_PRIMARY_CONFLICT\n", __func__);
+		pr_debug("%s(), LAP_FOUND_NONE, LAP_MEDIA_BUSY or LAP_PRIMARY_CONFLICT\n",
+			 __func__);
 		reason = LM_CONNECT_FAILURE;
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown IrLAP disconnect reason %d!\n",
-			   __func__, lap_reason);
+		pr_debug("%s(), Unknown IrLAP disconnect reason %d!\n",
+			 __func__, lap_reason);
 		reason = LM_LAP_DISCONNECT;
 		break;
 	}
diff --git a/net/irda/irlmp_event.c b/net/irda/irlmp_event.c
index 30e51f9..22c019c 100644
--- a/net/irda/irlmp_event.c
+++ b/net/irda/irlmp_event.c
@@ -120,7 +120,7 @@ static inline void irlmp_next_lap_state(struct lap_cb *self,
 					IRLMP_STATE state)
 {
 	/*
-	IRDA_DEBUG(4, "%s(), LMP LAP = %s\n", __func__, irlmp_state[state]);
+	  pr_debug("%s(), LMP LAP = %s\n", __func__, irlmp_state[state]);
 	*/
 	self->lap_state = state;
 }
@@ -130,7 +130,7 @@ static inline void irlmp_next_lsap_state(struct lsap_cb *self,
 {
 	/*
 	IRDA_ASSERT(self != NULL, return;);
-	IRDA_DEBUG(4, "%s(), LMP LSAP = %s\n", __func__, irlsap_state[state]);
+	pr_debug("%s(), LMP LSAP = %s\n", __func__, irlsap_state[state]);
 	*/
 	self->lsap_state = state;
 }
@@ -142,8 +142,8 @@ int irlmp_do_lsap_event(struct lsap_cb *self, IRLMP_EVENT event,
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
-	IRDA_DEBUG(4, "%s(), EVENT = %s, STATE = %s\n",
-		__func__, irlmp_event[event], irlsap_state[ self->lsap_state]);
+	pr_debug("%s(), EVENT = %s, STATE = %s\n",
+		 __func__, irlmp_event[event], irlsap_state[self->lsap_state]);
 
 	return (*lsap_state[self->lsap_state]) (self, event, skb);
 }
@@ -160,17 +160,15 @@ void irlmp_do_lap_event(struct lap_cb *self, IRLMP_EVENT event,
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
-	IRDA_DEBUG(4, "%s(), EVENT = %s, STATE = %s\n", __func__,
-		   irlmp_event[event],
-		   irlmp_state[self->lap_state]);
+	pr_debug("%s(), EVENT = %s, STATE = %s\n", __func__,
+		 irlmp_event[event],
+		 irlmp_state[self->lap_state]);
 
 	(*lap_state[self->lap_state]) (self, event, skb);
 }
 
 void irlmp_discovery_timer_expired(void *data)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	/* We always cleanup the log (active & passive discovery) */
 	irlmp_do_expiry();
 
@@ -184,8 +182,6 @@ void irlmp_watchdog_timer_expired(void *data)
 {
 	struct lsap_cb *self = (struct lsap_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
@@ -196,8 +192,6 @@ void irlmp_idle_timer_expired(void *data)
 {
 	struct lap_cb *self = (struct lap_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
@@ -256,7 +250,6 @@ irlmp_do_all_lsap_event(hashbin_t *	lsap_hashbin,
 static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
 	IRDA_ASSERT(self->irlap != NULL, return;);
 
 	switch (event) {
@@ -276,7 +269,7 @@ static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 		irlap_connect_response(self->irlap, skb);
 		break;
 	case LM_LAP_CONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s() LS_CONNECT_REQUEST\n", __func__);
+		pr_debug("%s() LS_CONNECT_REQUEST\n", __func__);
 
 		irlmp_next_lap_state(self, LAP_U_CONNECT);
 
@@ -284,14 +277,14 @@ static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 		irlap_connect_request(self->irlap, self->daddr, NULL, 0);
 		break;
 	case LM_LAP_DISCONNECT_INDICATION:
-		IRDA_DEBUG(4, "%s(), Error LM_LAP_DISCONNECT_INDICATION\n",
-			   __func__);
+		pr_debug("%s(), Error LM_LAP_DISCONNECT_INDICATION\n",
+			 __func__);
 
 		irlmp_next_lap_state(self, LAP_STANDBY);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
-			   __func__, irlmp_event[event]);
+		pr_debug("%s(), Unknown event %s\n",
+			 __func__, irlmp_event[event]);
 		break;
 	}
 }
@@ -306,7 +299,7 @@ static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 				  struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s(), event=%s\n", __func__, irlmp_event[event]);
+	pr_debug("%s(), event=%s\n", __func__, irlmp_event[event]);
 
 	switch (event) {
 	case LM_LAP_CONNECT_INDICATION:
@@ -326,7 +319,7 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 		 * the lsaps may already have gone. This avoid getting stuck
 		 * forever in LAP_ACTIVE state - Jean II */
 		if (HASHBIN_GET_SIZE(self->lsaps) == 0) {
-			IRDA_DEBUG(0, "%s() NO LSAPs !\n",  __func__);
+			pr_debug("%s() NO LSAPs !\n",  __func__);
 			irlmp_start_idle_timer(self, LM_IDLE_TIMEOUT);
 		}
 		break;
@@ -344,12 +337,12 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 		 * the lsaps may already have gone. This avoid getting stuck
 		 * forever in LAP_ACTIVE state - Jean II */
 		if (HASHBIN_GET_SIZE(self->lsaps) == 0) {
-			IRDA_DEBUG(0, "%s() NO LSAPs !\n",  __func__);
+			pr_debug("%s() NO LSAPs !\n",  __func__);
 			irlmp_start_idle_timer(self, LM_IDLE_TIMEOUT);
 		}
 		break;
 	case LM_LAP_DISCONNECT_INDICATION:
-		IRDA_DEBUG(4, "%s(), LM_LAP_DISCONNECT_INDICATION\n",  __func__);
+		pr_debug("%s(), LM_LAP_DISCONNECT_INDICATION\n",  __func__);
 		irlmp_next_lap_state(self, LAP_STANDBY);
 
 		/* Send disconnect event to all LSAPs using this link */
@@ -357,7 +350,7 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 					LM_LAP_DISCONNECT_INDICATION);
 		break;
 	case LM_LAP_DISCONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s(), LM_LAP_DISCONNECT_REQUEST\n",  __func__);
+		pr_debug("%s(), LM_LAP_DISCONNECT_REQUEST\n",  __func__);
 
 		/* One of the LSAP did timeout or was closed, if it was
 		 * the last one, try to get out of here - Jean II */
@@ -366,7 +359,7 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 		}
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
+		pr_debug("%s(), Unknown event %s\n",
 			 __func__, irlmp_event[event]);
 		break;
 	}
@@ -381,11 +374,9 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 static void irlmp_state_active(struct lap_cb *self, IRLMP_EVENT event,
 			       struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	switch (event) {
 	case LM_LAP_CONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s(), LS_CONNECT_REQUEST\n", __func__);
+		pr_debug("%s(), LS_CONNECT_REQUEST\n", __func__);
 
 		/*
 		 * IrLAP may have a pending disconnect. We tried to close
@@ -467,7 +458,7 @@ static void irlmp_state_active(struct lap_cb *self, IRLMP_EVENT event,
 		irlmp_do_expiry();
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
+		pr_debug("%s(), Unknown event %s\n",
 			 __func__, irlmp_event[event]);
 		break;
 	}
@@ -490,8 +481,6 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
@@ -505,7 +494,7 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 #endif /* CONFIG_IRDA_ULTRA */
 	case LM_CONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s(), LM_CONNECT_REQUEST\n", __func__);
+		pr_debug("%s(), LM_CONNECT_REQUEST\n", __func__);
 
 		if (self->conn_skb) {
 			net_warn_ratelimited("%s: busy with another request!\n",
@@ -551,8 +540,8 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_do_lap_event(self->lap, LM_LAP_CONNECT_REQUEST, NULL);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __func__, irlmp_event[event], self->slsap_sel);
+		pr_debug("%s(), Unknown event %s on LSAP %#02x\n",
+			 __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -570,8 +559,6 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 	struct lsap_cb *lsap;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
@@ -603,7 +590,7 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 	case LM_WATCHDOG_TIMEOUT:
 		/* May happen, who knows...
 		 * Jean II */
-		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n",  __func__);
+		pr_debug("%s() WATCHDOG_TIMEOUT!\n",  __func__);
 
 		/* Disconnect, get out... - Jean II */
 		self->lap = NULL;
@@ -613,8 +600,8 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 	default:
 		/* LM_LAP_DISCONNECT_INDICATION : Should never happen, we
 		 * are *not* yet bound to the IrLAP link. Jean II */
-		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __func__, irlmp_event[event], self->slsap_sel);
+		pr_debug("%s(), Unknown event %s on LSAP %#02x\n",
+			 __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -632,8 +619,6 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	struct sk_buff *tx_skb;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
@@ -642,17 +627,17 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		/* Keep state */
 		break;
 	case LM_CONNECT_RESPONSE:
-		IRDA_DEBUG(0, "%s(), LM_CONNECT_RESPONSE, "
-			   "no indication issued yet\n",  __func__);
+		pr_debug("%s(), LM_CONNECT_RESPONSE, no indication issued yet\n",
+			 __func__);
 		/* Keep state */
 		break;
 	case LM_DISCONNECT_REQUEST:
-		IRDA_DEBUG(0, "%s(), LM_DISCONNECT_REQUEST, "
-			   "not yet bound to IrLAP connection\n",  __func__);
+		pr_debug("%s(), LM_DISCONNECT_REQUEST, not yet bound to IrLAP connection\n",
+			 __func__);
 		/* Keep state */
 		break;
 	case LM_LAP_CONNECT_CONFIRM:
-		IRDA_DEBUG(4, "%s(), LS_CONNECT_CONFIRM\n",  __func__);
+		pr_debug("%s(), LS_CONNECT_CONFIRM\n",  __func__);
 		irlmp_next_lsap_state(self, LSAP_CONNECT);
 
 		tx_skb = self->conn_skb;
@@ -666,7 +651,7 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		/* Will happen in some rare cases because of a race condition.
 		 * Just make sure we don't stay there forever...
 		 * Jean II */
-		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n",  __func__);
+		pr_debug("%s() WATCHDOG_TIMEOUT!\n",  __func__);
 
 		/* Go back to disconnected mode, keep the socket waiting */
 		self->lap = NULL;
@@ -679,8 +664,8 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	default:
 		/* LM_LAP_DISCONNECT_INDICATION : Should never happen, we
 		 * are *not* yet bound to the IrLAP link. Jean II */
-		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __func__, irlmp_event[event], self->slsap_sel);
+		pr_debug("%s(), Unknown event %s on LSAP %#02x\n",
+			 __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -698,8 +683,6 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 	LM_REASON reason;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 	IRDA_ASSERT(self->lap != NULL, return -1;);
@@ -721,13 +704,13 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_udata_indication(self, skb);
 		break;
 	case LM_CONNECT_REQUEST:
-		IRDA_DEBUG(0, "%s(), LM_CONNECT_REQUEST, "
-			   "error, LSAP already connected\n", __func__);
+		pr_debug("%s(), LM_CONNECT_REQUEST, error, LSAP already connected\n",
+			 __func__);
 		/* Keep state */
 		break;
 	case LM_CONNECT_RESPONSE:
-		IRDA_DEBUG(0, "%s(), LM_CONNECT_RESPONSE, "
-			   "error, LSAP already connected\n", __func__);
+		pr_debug("%s(), LM_CONNECT_RESPONSE, error, LSAP already connected\n",
+			 __func__);
 		/* Keep state */
 		break;
 	case LM_DISCONNECT_REQUEST:
@@ -739,8 +722,8 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 
 		/* Try to close the LAP connection if its still there */
 		if (self->lap) {
-			IRDA_DEBUG(4, "%s(), trying to close IrLAP\n",
-				   __func__);
+			pr_debug("%s(), trying to close IrLAP\n",
+				 __func__);
 			irlmp_do_lap_event(self->lap,
 					   LM_LAP_DISCONNECT_REQUEST,
 					   NULL);
@@ -764,14 +747,14 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 		reason = skb->data[3];
 
 		 /* Try to close the LAP connection */
-		IRDA_DEBUG(4, "%s(), trying to close IrLAP\n", __func__);
+		pr_debug("%s(), trying to close IrLAP\n", __func__);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
 
 		irlmp_disconnect_indication(self, reason, skb);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __func__, irlmp_event[event], self->slsap_sel);
+		pr_debug("%s(), Unknown event %s on LSAP %#02x\n",
+			 __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -793,8 +776,6 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	switch (event) {
 	case LM_CONNECT_CONFIRM:
 		irlmp_next_lsap_state(self, LSAP_DATA_TRANSFER_READY);
@@ -814,7 +795,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 		reason = skb->data[3];
 
 		 /* Try to close the LAP connection */
-		IRDA_DEBUG(4, "%s(), trying to close IrLAP\n",  __func__);
+		pr_debug("%s(), trying to close IrLAP\n",  __func__);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
 
 		irlmp_disconnect_indication(self, reason, skb);
@@ -832,7 +813,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_disconnect_indication(self, reason, skb);
 		break;
 	case LM_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n", __func__);
+		pr_debug("%s() WATCHDOG_TIMEOUT!\n", __func__);
 
 		IRDA_ASSERT(self->lap != NULL, return -1;);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
@@ -841,8 +822,8 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_disconnect_indication(self, LM_CONNECT_FAILURE, NULL);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __func__, irlmp_event[event], self->slsap_sel);
+		pr_debug("%s(), Unknown event %s on LSAP %#02x\n",
+			 __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -863,8 +844,6 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	LM_REASON reason;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(irlmp != NULL, return -1;);
 
@@ -883,7 +862,7 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_next_lsap_state(self, LSAP_SETUP);
 		break;
 	case LM_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(0, "%s() : WATCHDOG_TIMEOUT !\n",  __func__);
+		pr_debug("%s() : WATCHDOG_TIMEOUT !\n",  __func__);
 
 		IRDA_ASSERT(self->lap != NULL, return -1;);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
@@ -901,8 +880,8 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_disconnect_indication(self, reason, NULL);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __func__, irlmp_event[event], self->slsap_sel);
+		pr_debug("%s(), Unknown event %s on LSAP %#02x\n",
+			 __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
diff --git a/net/irda/irlmp_frame.c b/net/irda/irlmp_frame.c
index 062e63b..38b0f99 100644
--- a/net/irda/irlmp_frame.c
+++ b/net/irda/irlmp_frame.c
@@ -44,7 +44,7 @@ inline void irlmp_send_data_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap,
 	skb->data[1] = slsap;
 
 	if (expedited) {
-		IRDA_DEBUG(4, "%s(), sending expedited data\n", __func__);
+		pr_debug("%s(), sending expedited data\n", __func__);
 		irlap_data_request(self->irlap, skb, TRUE);
 	} else
 		irlap_data_request(self->irlap, skb, FALSE);
@@ -60,8 +60,6 @@ void irlmp_send_lcf_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap,
 {
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -95,8 +93,6 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 	__u8   dlsap_sel;   /* Destination LSAP address */
 	__u8   *fp;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 	IRDA_ASSERT(skb->len > 2, return;);
@@ -115,9 +111,8 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 	 *  it in a different way than other established connections.
 	 */
 	if ((fp[0] & CONTROL_BIT) && (fp[2] == CONNECT_CMD)) {
-		IRDA_DEBUG(3, "%s(), incoming connection, "
-			   "source LSAP=%d, dest LSAP=%d\n",
-			   __func__, slsap_sel, dlsap_sel);
+		pr_debug("%s(), incoming connection, source LSAP=%d, dest LSAP=%d\n",
+			 __func__, slsap_sel, dlsap_sel);
 
 		/* Try to find LSAP among the unconnected LSAPs */
 		lsap = irlmp_find_lsap(self, dlsap_sel, slsap_sel, CONNECT_CMD,
@@ -125,7 +120,8 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 
 		/* Maybe LSAP was already connected, so try one more time */
 		if (!lsap) {
-			IRDA_DEBUG(1, "%s(), incoming connection for LSAP already connected\n", __func__);
+			pr_debug("%s(), incoming connection for LSAP already connected\n",
+				 __func__);
 			lsap = irlmp_find_lsap(self, dlsap_sel, slsap_sel, 0,
 					       self->lsaps);
 		}
@@ -134,14 +130,14 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 				       self->lsaps);
 
 	if (lsap == NULL) {
-		IRDA_DEBUG(2, "IrLMP, Sorry, no LSAP for received frame!\n");
-		IRDA_DEBUG(2, "%s(), slsap_sel = %02x, dlsap_sel = %02x\n",
-			   __func__, slsap_sel, dlsap_sel);
+		pr_debug("IrLMP, Sorry, no LSAP for received frame!\n");
+		pr_debug("%s(), slsap_sel = %02x, dlsap_sel = %02x\n",
+			 __func__, slsap_sel, dlsap_sel);
 		if (fp[0] & CONTROL_BIT) {
-			IRDA_DEBUG(2, "%s(), received control frame %02x\n",
-				   __func__, fp[2]);
+			pr_debug("%s(), received control frame %02x\n",
+				 __func__, fp[2]);
 		} else {
-			IRDA_DEBUG(2, "%s(), received data frame\n", __func__);
+			pr_debug("%s(), received data frame\n", __func__);
 		}
 		return;
 	}
@@ -159,20 +155,20 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 			irlmp_do_lsap_event(lsap, LM_CONNECT_CONFIRM, skb);
 			break;
 		case DISCONNECT:
-			IRDA_DEBUG(4, "%s(), Disconnect indication!\n",
-				   __func__);
+			pr_debug("%s(), Disconnect indication!\n",
+				 __func__);
 			irlmp_do_lsap_event(lsap, LM_DISCONNECT_INDICATION,
 					    skb);
 			break;
 		case ACCESSMODE_CMD:
-			IRDA_DEBUG(0, "Access mode cmd not implemented!\n");
+			pr_debug("Access mode cmd not implemented!\n");
 			break;
 		case ACCESSMODE_CNF:
-			IRDA_DEBUG(0, "Access mode cnf not implemented!\n");
+			pr_debug("Access mode cnf not implemented!\n");
 			break;
 		default:
-			IRDA_DEBUG(0, "%s(), Unknown control frame %02x\n",
-				   __func__, fp[2]);
+			pr_debug("%s(), Unknown control frame %02x\n",
+				 __func__, fp[2]);
 			break;
 		}
 	} else if (unreliable) {
@@ -206,8 +202,6 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 	__u8   *fp;
 	unsigned long flags;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 	IRDA_ASSERT(skb->len > 2, return;);
@@ -223,14 +217,14 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 	pid       = fp[2];
 
 	if (pid & 0x80) {
-		IRDA_DEBUG(0, "%s(), extension in PID not supp!\n",
-			   __func__);
+		pr_debug("%s(), extension in PID not supp!\n",
+			 __func__);
 		return;
 	}
 
 	/* Check if frame is addressed to the connectionless LSAP */
 	if ((slsap_sel != LSAP_CONNLESS) || (dlsap_sel != LSAP_CONNLESS)) {
-		IRDA_DEBUG(0, "%s(), dropping frame!\n", __func__);
+		pr_debug("%s(), dropping frame!\n", __func__);
 		return;
 	}
 
@@ -254,7 +248,7 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 	if (lsap)
 		irlmp_connless_data_indication(lsap, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), found no matching LSAP!\n", __func__);
+		pr_debug("%s(), found no matching LSAP!\n", __func__);
 	}
 }
 #endif /* CONFIG_IRDA_ULTRA */
@@ -270,8 +264,6 @@ void irlmp_link_disconnect_indication(struct lap_cb *lap,
 				      LAP_REASON reason,
 				      struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(lap != NULL, return;);
 	IRDA_ASSERT(lap->magic == LMP_LAP_MAGIC, return;);
 
@@ -296,8 +288,6 @@ void irlmp_link_connect_indication(struct lap_cb *self, __u32 saddr,
 				   __u32 daddr, struct qos_info *qos,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	/* Copy QoS settings for this session */
 	self->qos = qos;
 
@@ -317,8 +307,6 @@ void irlmp_link_connect_indication(struct lap_cb *self, __u32 saddr,
 void irlmp_link_connect_confirm(struct lap_cb *self, struct qos_info *qos,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 	IRDA_ASSERT(qos != NULL, return;);
@@ -383,8 +371,6 @@ void irlmp_link_discovery_indication(struct lap_cb *self,
  */
 void irlmp_link_discovery_confirm(struct lap_cb *self, hashbin_t *log)
 {
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
diff --git a/net/irda/irmod.c b/net/irda/irmod.c
index 303a68d..c5e35b8 100644
--- a/net/irda/irmod.c
+++ b/net/irda/irmod.c
@@ -42,16 +42,6 @@
 #include <net/irda/irttp.h>		/* irttp_init */
 #include <net/irda/irda_device.h>	/* irda_device_init */
 
-/*
- * Module parameters
- */
-#ifdef CONFIG_IRDA_DEBUG
-unsigned int irda_debug = IRDA_DEBUG_LEVEL;
-module_param_named(debug, irda_debug, uint, 0);
-MODULE_PARM_DESC(debug, "IRDA debugging level");
-EXPORT_SYMBOL(irda_debug);
-#endif
-
 /* Packet type handler.
  * Tell the kernel how IrDA packets should be handled.
  */
@@ -90,8 +80,6 @@ static int __init irda_init(void)
 {
 	int ret = 0;
 
-	IRDA_DEBUG(0, "%s()\n", __func__);
-
 	/* Lower layer of the stack */
 	irlmp_init();
 	irlap_init();
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index a37b81f..e15c40e 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -41,7 +41,7 @@ static struct net_device * ifname_to_netdev(struct net *net, struct genl_info *i
 
 	ifname = nla_data(info->attrs[IRDA_NL_ATTR_IFNAME]);
 
-	IRDA_DEBUG(5, "%s(): Looking for %s\n", __func__, ifname);
+	pr_debug("%s(): Looking for %s\n", __func__, ifname);
 
 	return dev_get_by_name(net, ifname);
 }
@@ -57,7 +57,7 @@ static int irda_nl_set_mode(struct sk_buff *skb, struct genl_info *info)
 
 	mode = nla_get_u32(info->attrs[IRDA_NL_ATTR_MODE]);
 
-	IRDA_DEBUG(5, "%s(): Switching to mode: %d\n", __func__, mode);
+	pr_debug("%s(): Switching to mode: %d\n", __func__, mode);
 
 	dev = ifname_to_netdev(&init_net, info);
 	if (!dev)
diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index 7152624..acbe61c 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -233,8 +233,6 @@ static __u32 hash( const char* name)
 static void enqueue_first(irda_queue_t **queue, irda_queue_t* element)
 {
 
-	IRDA_DEBUG( 4, "%s()\n", __func__);
-
 	/*
 	 * Check if queue is empty.
 	 */
@@ -267,7 +265,7 @@ static irda_queue_t *dequeue_first(irda_queue_t **queue)
 {
 	irda_queue_t *ret;
 
-	IRDA_DEBUG( 4, "dequeue_first()\n");
+	pr_debug("dequeue_first()\n");
 
 	/*
 	 * Set return value
@@ -308,7 +306,7 @@ static irda_queue_t *dequeue_general(irda_queue_t **queue, irda_queue_t* element
 {
 	irda_queue_t *ret;
 
-	IRDA_DEBUG( 4, "dequeue_general()\n");
+	pr_debug("dequeue_general()\n");
 
 	/*
 	 * Set return value
@@ -452,8 +450,6 @@ void hashbin_insert(hashbin_t* hashbin, irda_queue_t* entry, long hashv,
 	unsigned long flags = 0;
 	int bin;
 
-	IRDA_DEBUG( 4, "%s()\n", __func__);
-
 	IRDA_ASSERT( hashbin != NULL, return;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return;);
 
@@ -565,8 +561,6 @@ void* hashbin_remove( hashbin_t* hashbin, long hashv, const char* name)
 	unsigned long flags = 0;
 	irda_queue_t* entry;
 
-	IRDA_DEBUG( 4, "%s()\n", __func__);
-
 	IRDA_ASSERT( hashbin != NULL, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
 
@@ -658,8 +652,6 @@ void* hashbin_remove_this( hashbin_t* hashbin, irda_queue_t* entry)
 	int	bin;
 	long	hashv;
 
-	IRDA_DEBUG( 4, "%s()\n", __func__);
-
 	IRDA_ASSERT( hashbin != NULL, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
 	IRDA_ASSERT( entry != NULL, return NULL;);
@@ -719,7 +711,7 @@ void* hashbin_find( hashbin_t* hashbin, long hashv, const char* name )
 	int bin;
 	irda_queue_t* entry;
 
-	IRDA_DEBUG( 4, "hashbin_find()\n");
+	pr_debug("hashbin_find()\n");
 
 	IRDA_ASSERT( hashbin != NULL, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index d6a5965..873da5e 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -126,15 +126,6 @@ static struct ctl_table irda_table[] = {
 		.mode		= 0644,
 		.proc_handler	= do_devname,
 	},
-#ifdef CONFIG_IRDA_DEBUG
-	{
-		.procname	= "debug",
-		.data		= &irda_debug,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-#endif
 #ifdef CONFIG_IRDA_FAST_RR
 	{
 		.procname	= "fast_poll_increase",
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index e0b2b0d..3ef0b08 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -166,7 +166,7 @@ static void irttp_todo_expired(unsigned long data)
 	if (!self || self->magic != TTP_TSAP_MAGIC)
 		return;
 
-	IRDA_DEBUG(4, "%s(instance=%p)\n", __func__, self);
+	pr_debug("%s(instance=%p)\n", __func__, self);
 
 	/* Try to make some progress, especially on Tx side - Jean II */
 	irttp_run_rx_queue(self);
@@ -207,8 +207,6 @@ static void irttp_flush_queues(struct tsap_cb *self)
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
@@ -240,8 +238,8 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 	IRDA_ASSERT(self != NULL, return NULL;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return NULL;);
 
-	IRDA_DEBUG(2, "%s(), self->rx_sdu_size=%d\n", __func__,
-		   self->rx_sdu_size);
+	pr_debug("%s(), self->rx_sdu_size=%d\n", __func__,
+		 self->rx_sdu_size);
 
 	skb = dev_alloc_skb(TTP_HEADER + self->rx_sdu_size);
 	if (!skb)
@@ -264,9 +262,8 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 		dev_kfree_skb(frag);
 	}
 
-	IRDA_DEBUG(2,
-		   "%s(), frame len=%d, rx_sdu_size=%d, rx_max_sdu_size=%d\n",
-		   __func__, n, self->rx_sdu_size, self->rx_max_sdu_size);
+	pr_debug("%s(), frame len=%d, rx_sdu_size=%d, rx_max_sdu_size=%d\n",
+		 __func__, n, self->rx_sdu_size, self->rx_max_sdu_size);
 	/* Note : irttp_run_rx_queue() calculate self->rx_sdu_size
 	 * by summing the size of all fragments, so we should always
 	 * have n == self->rx_sdu_size, except in cases where we
@@ -295,8 +292,6 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 	struct sk_buff *frag;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
@@ -305,7 +300,7 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 	 *  Split frame into a number of segments
 	 */
 	while (skb->len > self->max_seg_size) {
-		IRDA_DEBUG(2, "%s(), fragmenting ...\n", __func__);
+		pr_debug("%s(), fragmenting ...\n", __func__);
 
 		/* Make new segment */
 		frag = alloc_skb(self->max_seg_size+self->max_header_size,
@@ -330,7 +325,7 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 		skb_queue_tail(&self->tx_queue, frag);
 	}
 	/* Queue what is left of the original skb */
-	IRDA_DEBUG(2, "%s(), queuing last segment\n", __func__);
+	pr_debug("%s(), queuing last segment\n", __func__);
 
 	frame = skb_push(skb, TTP_HEADER);
 	frame[0] = 0x00; /* Clear more bit */
@@ -361,7 +356,7 @@ static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
 	else
 		self->tx_max_sdu_size = param->pv.i;
 
-	IRDA_DEBUG(1, "%s(), MaxSduSize=%d\n", __func__, param->pv.i);
+	pr_debug("%s(), MaxSduSize=%d\n", __func__, param->pv.i);
 
 	return 0;
 }
@@ -402,15 +397,13 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 * JeanII */
 	if ((stsap_sel != LSAP_ANY) &&
 	   ((stsap_sel < 0x01) || (stsap_sel >= 0x70))) {
-		IRDA_DEBUG(0, "%s(), invalid tsap!\n", __func__);
+		pr_debug("%s(), invalid tsap!\n", __func__);
 		return NULL;
 	}
 
 	self = kzalloc(sizeof(struct tsap_cb), GFP_ATOMIC);
-	if (self == NULL) {
-		IRDA_DEBUG(0, "%s(), unable to kmalloc!\n", __func__);
+	if (self == NULL)
 		return NULL;
-	}
 
 	/* Initialize internal objects */
 	irttp_init_tsap(self);
@@ -440,7 +433,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 */
 	lsap = irlmp_open_lsap(stsap_sel, &ttp_notify, 0);
 	if (lsap == NULL) {
-		IRDA_DEBUG(0, "%s: unable to allocate LSAP!!\n", __func__);
+		pr_debug("%s: unable to allocate LSAP!!\n", __func__);
 		__irttp_close_tsap(self);
 		return NULL;
 	}
@@ -451,7 +444,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 *  the stsap_sel we have might not be valid anymore
 	 */
 	self->stsap_sel = lsap->slsap_sel;
-	IRDA_DEBUG(4, "%s(), stsap_sel=%02x\n", __func__, self->stsap_sel);
+	pr_debug("%s(), stsap_sel=%02x\n", __func__, self->stsap_sel);
 
 	self->notify = *notify;
 	self->lsap = lsap;
@@ -509,8 +502,6 @@ int irttp_close_tsap(struct tsap_cb *self)
 {
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 
@@ -558,8 +549,6 @@ int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	/* Take shortcut on zero byte packets */
 	if (skb->len == 0) {
 		ret = 0;
@@ -607,8 +596,8 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s() : queue len = %d\n", __func__,
-		   skb_queue_len(&self->tx_queue));
+	pr_debug("%s() : queue len = %d\n", __func__,
+		 skb_queue_len(&self->tx_queue));
 
 	/* Take shortcut on zero byte packets */
 	if (skb->len == 0) {
@@ -720,9 +709,9 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
 	unsigned long flags;
 	int n;
 
-	IRDA_DEBUG(2, "%s() : send_credit = %d, queue_len = %d\n",
-		   __func__,
-		   self->send_credit, skb_queue_len(&self->tx_queue));
+	pr_debug("%s() : send_credit = %d, queue_len = %d\n",
+		 __func__,
+		 self->send_credit, skb_queue_len(&self->tx_queue));
 
 	/* Get exclusive access to the tx queue, otherwise don't touch it */
 	if (irda_lock(&self->tx_queue_lock) == FALSE)
@@ -827,9 +816,9 @@ static inline void irttp_give_credit(struct tsap_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
-	IRDA_DEBUG(4, "%s() send=%d,avail=%d,remote=%d\n",
-		   __func__,
-		   self->send_credit, self->avail_credit, self->remote_credit);
+	pr_debug("%s() send=%d,avail=%d,remote=%d\n",
+		 __func__,
+		 self->send_credit, self->avail_credit, self->remote_credit);
 
 	/* Give credit to peer */
 	tx_skb = alloc_skb(TTP_MAX_HEADER, GFP_ATOMIC);
@@ -877,8 +866,6 @@ static int irttp_udata_indication(void *instance, void *sap,
 	struct tsap_cb *self;
 	int err;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	self = instance;
 
 	IRDA_ASSERT(self != NULL, return -1;);
@@ -994,8 +981,6 @@ static void irttp_status_indication(void *instance,
 {
 	struct tsap_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
@@ -1012,7 +997,7 @@ static void irttp_status_indication(void *instance,
 		self->notify.status_indication(self->notify.instance,
 					       link, lock);
 	else
-		IRDA_DEBUG(2, "%s(), no handler\n", __func__);
+		pr_debug("%s(), no handler\n", __func__);
 }
 
 /*
@@ -1030,7 +1015,7 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
-	IRDA_DEBUG(4, "%s(instance=%p)\n", __func__, self);
+	pr_debug("%s(instance=%p)\n", __func__, self);
 
 	/* We are "polled" directly from LAP, and the LAP want to fill
 	 * its Tx window. We want to do our best to send it data, so that
@@ -1068,18 +1053,16 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
  */
 void irttp_flow_request(struct tsap_cb *self, LOCAL_FLOW flow)
 {
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	switch (flow) {
 	case FLOW_STOP:
-		IRDA_DEBUG(1, "%s(), flow stop\n", __func__);
+		pr_debug("%s(), flow stop\n", __func__);
 		self->rx_sdu_busy = TRUE;
 		break;
 	case FLOW_START:
-		IRDA_DEBUG(1, "%s(), flow start\n", __func__);
+		pr_debug("%s(), flow start\n", __func__);
 		self->rx_sdu_busy = FALSE;
 
 		/* Client say he can accept more data, try to free our
@@ -1088,7 +1071,7 @@ void irttp_flow_request(struct tsap_cb *self, LOCAL_FLOW flow)
 
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown flow command!\n", __func__);
+		pr_debug("%s(), Unknown flow command!\n", __func__);
 	}
 }
 EXPORT_SYMBOL(irttp_flow_request);
@@ -1108,7 +1091,7 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 	__u8 *frame;
 	__u8 n;
 
-	IRDA_DEBUG(4, "%s(), max_sdu_size=%d\n", __func__, max_sdu_size);
+	pr_debug("%s(), max_sdu_size=%d\n", __func__, max_sdu_size);
 
 	IRDA_ASSERT(self != NULL, return -EBADR;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -EBADR;);
@@ -1206,8 +1189,6 @@ static void irttp_connect_confirm(void *instance, void *sap,
 	__u8 plen;
 	__u8 n;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
@@ -1222,15 +1203,15 @@ static void irttp_connect_confirm(void *instance, void *sap,
 	 *  negotiated QoS for the link.
 	 */
 	if (qos) {
-		IRDA_DEBUG(4, "IrTTP, Negotiated BAUD_RATE: %02x\n",
-		       qos->baud_rate.bits);
-		IRDA_DEBUG(4, "IrTTP, Negotiated BAUD_RATE: %d bps.\n",
-		       qos->baud_rate.value);
+		pr_debug("IrTTP, Negotiated BAUD_RATE: %02x\n",
+			 qos->baud_rate.bits);
+		pr_debug("IrTTP, Negotiated BAUD_RATE: %d bps.\n",
+			 qos->baud_rate.value);
 	}
 
 	n = skb->data[0] & 0x7f;
 
-	IRDA_DEBUG(4, "%s(), Initial send_credit=%d\n", __func__, n);
+	pr_debug("%s(), Initial send_credit=%d\n", __func__, n);
 
 	self->send_credit = n;
 	self->tx_max_sdu_size = 0;
@@ -1261,11 +1242,11 @@ static void irttp_connect_confirm(void *instance, void *sap,
 		skb_pull(skb, IRDA_MIN(skb->len, plen+1));
 	}
 
-	IRDA_DEBUG(4, "%s() send=%d,avail=%d,remote=%d\n", __func__,
-	      self->send_credit, self->avail_credit, self->remote_credit);
+	pr_debug("%s() send=%d,avail=%d,remote=%d\n", __func__,
+		 self->send_credit, self->avail_credit, self->remote_credit);
 
-	IRDA_DEBUG(2, "%s(), MaxSduSize=%d\n", __func__,
-		   self->tx_max_sdu_size);
+	pr_debug("%s(), MaxSduSize=%d\n", __func__,
+		 self->tx_max_sdu_size);
 
 	if (self->notify.connect_confirm) {
 		self->notify.connect_confirm(self->notify.instance, self, qos,
@@ -1303,7 +1284,7 @@ static void irttp_connect_indication(void *instance, void *sap,
 	self->max_seg_size = max_seg_size - TTP_HEADER;
 	self->max_header_size = max_header_size+TTP_HEADER;
 
-	IRDA_DEBUG(4, "%s(), TSAP sel=%02x\n", __func__, self->stsap_sel);
+	pr_debug("%s(), TSAP sel=%02x\n", __func__, self->stsap_sel);
 
 	/* Need to update dtsap_sel if its equal to LSAP_ANY */
 	self->dtsap_sel = lsap->dlsap_sel;
@@ -1365,8 +1346,8 @@ int irttp_connect_response(struct tsap_cb *self, __u32 max_sdu_size,
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 
-	IRDA_DEBUG(4, "%s(), Source TSAP selector=%02x\n", __func__,
-		   self->stsap_sel);
+	pr_debug("%s(), Source TSAP selector=%02x\n", __func__,
+		 self->stsap_sel);
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
@@ -1447,14 +1428,12 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	struct tsap_cb *new;
 	unsigned long flags;
 
-	IRDA_DEBUG(1, "%s()\n", __func__);
-
 	/* Protect our access to the old tsap instance */
 	spin_lock_irqsave(&irttp->tsaps->hb_spinlock, flags);
 
 	/* Find the old instance */
 	if (!hashbin_find(irttp->tsaps, (long) orig, NULL)) {
-		IRDA_DEBUG(0, "%s(), unable to find TSAP\n", __func__);
+		pr_debug("%s(), unable to find TSAP\n", __func__);
 		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
 		return NULL;
 	}
@@ -1462,7 +1441,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	/* Allocate a new instance */
 	new = kmemdup(orig, sizeof(struct tsap_cb), GFP_ATOMIC);
 	if (!new) {
-		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __func__);
+		pr_debug("%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
 		return NULL;
 	}
@@ -1474,7 +1453,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	/* Try to dup the LSAP (may fail if we were too slow) */
 	new->lsap = irlmp_dup(orig->lsap, new);
 	if (!new->lsap) {
-		IRDA_DEBUG(0, "%s(), dup failed!\n", __func__);
+		pr_debug("%s(), dup failed!\n", __func__);
 		kfree(new);
 		return NULL;
 	}
@@ -1509,7 +1488,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 
 	/* Already disconnected? */
 	if (!self->connected) {
-		IRDA_DEBUG(4, "%s(), already disconnected!\n", __func__);
+		pr_debug("%s(), already disconnected!\n", __func__);
 		if (userdata)
 			dev_kfree_skb(userdata);
 		return -1;
@@ -1521,8 +1500,8 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 	 * for following a disconnect_indication() (i.e. net_bh).
 	 * Jean II */
 	if (test_and_set_bit(0, &self->disconnect_pend)) {
-		IRDA_DEBUG(0, "%s(), disconnect already pending\n",
-			   __func__);
+		pr_debug("%s(), disconnect already pending\n",
+			 __func__);
 		if (userdata)
 			dev_kfree_skb(userdata);
 
@@ -1541,7 +1520,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 			 *  disconnecting right now since the data will
 			 *  not have any usable connection to be sent on
 			 */
-			IRDA_DEBUG(1, "%s(): High priority!!()\n", __func__);
+			pr_debug("%s(): High priority!!()\n", __func__);
 			irttp_flush_queues(self);
 		} else if (priority == P_NORMAL) {
 			/*
@@ -1562,7 +1541,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 	 * be sent at the LMP level (so even if the peer has its Tx queue
 	 * full of data). - Jean II */
 
-	IRDA_DEBUG(1, "%s(), Disconnecting ...\n", __func__);
+	pr_debug("%s(), Disconnecting ...\n", __func__);
 	self->connected = FALSE;
 
 	if (!userdata) {
@@ -1598,8 +1577,6 @@ static void irttp_disconnect_indication(void *instance, void *sap,
 {
 	struct tsap_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __func__);
-
 	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
@@ -1658,7 +1635,7 @@ static void irttp_do_data_indication(struct tsap_cb *self, struct sk_buff *skb)
 	 * give an error back
 	 */
 	if (err) {
-		IRDA_DEBUG(0, "%s() requeueing skb!\n", __func__);
+		pr_debug("%s() requeueing skb!\n", __func__);
 
 		/* Make sure we take a break */
 		self->rx_sdu_busy = TRUE;
@@ -1683,8 +1660,8 @@ static void irttp_run_rx_queue(struct tsap_cb *self)
 	struct sk_buff *skb;
 	int more = 0;
 
-	IRDA_DEBUG(2, "%s() send=%d,avail=%d,remote=%d\n", __func__,
-		   self->send_credit, self->avail_credit, self->remote_credit);
+	pr_debug("%s() send=%d,avail=%d,remote=%d\n", __func__,
+		 self->send_credit, self->avail_credit, self->remote_credit);
 
 	/* Get exclusive access to the rx queue, otherwise don't touch it */
 	if (irda_lock(&self->rx_queue_lock) == FALSE)
@@ -1723,8 +1700,8 @@ static void irttp_run_rx_queue(struct tsap_cb *self)
 			 *  limits of the maximum size of the rx_sdu
 			 */
 			if (self->rx_sdu_size <= self->rx_max_sdu_size) {
-				IRDA_DEBUG(4, "%s(), queueing frag\n",
-					   __func__);
+				pr_debug("%s(), queueing frag\n",
+					 __func__);
 				skb_queue_tail(&self->rx_fragments, skb);
 			} else {
 				/* Free the part of the SDU that is too big */
@@ -1753,7 +1730,7 @@ static void irttp_run_rx_queue(struct tsap_cb *self)
 			/* Now we can deliver the reassembled skb */
 			irttp_do_data_indication(self, skb);
 		} else {
-			IRDA_DEBUG(1, "%s(), Truncated frame\n", __func__);
+			pr_debug("%s(), Truncated frame\n", __func__);
 
 			/* Free the part of the SDU that is too big */
 			dev_kfree_skb(skb);
diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index d7a5778..006786b 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
@@ -146,13 +146,13 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 	 */
 	if (p.pl == 0) {
 		if (p.pv.i < 0xff) {
-			IRDA_DEBUG(2, "%s(), using 1 byte\n", __func__);
+			pr_debug("%s(), using 1 byte\n", __func__);
 			p.pl = 1;
 		} else if (p.pv.i < 0xffff) {
-			IRDA_DEBUG(2, "%s(), using 2 bytes\n", __func__);
+			pr_debug("%s(), using 2 bytes\n", __func__);
 			p.pl = 2;
 		} else {
-			IRDA_DEBUG(2, "%s(), using 4 bytes\n", __func__);
+			pr_debug("%s(), using 4 bytes\n", __func__);
 			p.pl = 4; /* Default length */
 		}
 	}
@@ -162,8 +162,8 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 				     __func__);
 		return -1;
 	}
-	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d, pi=%d\n", __func__,
-		   p.pi, p.pl, p.pv.i);
+	pr_debug("%s(), pi=%#x, pl=%d, pi=%d\n", __func__,
+		 p.pi, p.pl, p.pv.i);
 	switch (p.pl) {
 	case 1:
 		n += irda_param_pack(buf, "bbb", p.pi, p.pl, (__u8) p.pv.i);
@@ -270,8 +270,8 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 		return p.pl+2;
 	}
 
-	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d, pi=%d\n", __func__,
-		   p.pi, p.pl, p.pv.i);
+	pr_debug("%s(), pi=%#x, pl=%d, pi=%d\n", __func__,
+		 p.pi, p.pl, p.pv.i);
 	/* Call handler for this parameter */
 	err = (*func)(self, &p, PV_PUT);
 	if (err < 0)
@@ -290,15 +290,13 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 	irda_param_t p;
 	int err;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	p.pi = pi;     /* In case handler needs to know */
 	p.pl = buf[1]; /* Extract length of value */
 	if (p.pl > 32)
 		p.pl = 32;
 
-	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d\n", __func__,
-		   p.pi, p.pl);
+	pr_debug("%s(), pi=%#x, pl=%d\n", __func__,
+		 p.pi, p.pl);
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
@@ -311,8 +309,8 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 	 * checked that the buffer is long enough */
 	strncpy(str, buf+2, p.pl);
 
-	IRDA_DEBUG(2, "%s(), str=0x%02x 0x%02x\n", __func__,
-		   (__u8) str[0], (__u8) str[1]);
+	pr_debug("%s(), str=0x%02x 0x%02x\n",
+		 __func__, (__u8)str[0], (__u8)str[1]);
 
 	/* Null terminate string */
 	str[p.pl] = '\0';
@@ -345,7 +343,7 @@ static int irda_extract_octseq(void *self, __u8 *buf, int len, __u8 pi,
 		return -1;
 	}
 
-	IRDA_DEBUG(0, "%s(), not impl\n", __func__);
+	pr_debug("%s(), not impl\n", __func__);
 
 	return p.pl+2; /* Extracted pl+2 bytes */
 }
@@ -468,8 +466,8 @@ int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len,
 	if ((pi_major > info->len-1) ||
 	    (pi_minor > info->tables[pi_major].len-1))
 	{
-		IRDA_DEBUG(0, "%s(), no handler for parameter=0x%02x\n",
-			   __func__, pi);
+		pr_debug("%s(), no handler for parameter=0x%02x\n",
+			 __func__, pi);
 
 		/* Skip this parameter */
 		return -1;
@@ -523,8 +521,8 @@ static int irda_param_extract(void *self, __u8 *buf, int len,
 	if ((pi_major > info->len-1) ||
 	    (pi_minor > info->tables[pi_major].len-1))
 	{
-		IRDA_DEBUG(0, "%s(), no handler for parameter=0x%02x\n",
-			   __func__, buf[0]);
+		pr_debug("%s(), no handler for parameter=0x%02x\n",
+			 __func__, buf[0]);
 
 		/* Skip this parameter */
 		return 2 + buf[n + 1];  /* Continue */
@@ -536,8 +534,8 @@ static int irda_param_extract(void *self, __u8 *buf, int len,
 	/* Find expected data type for this parameter identifier (pi)*/
 	type = pi_minor_info->type;
 
-	IRDA_DEBUG(3, "%s(), pi=[%d,%d], type=%d\n", __func__,
-		   pi_major, pi_minor, type);
+	pr_debug("%s(), pi=[%d,%d], type=%d\n", __func__,
+		 pi_major, pi_minor, type);
 
 	/*  Check if handler has been implemented */
 	if (!pi_minor_info->func) {
diff --git a/net/irda/qos.c b/net/irda/qos.c
index f3b588c..5ed6c9a 100644
--- a/net/irda/qos.c
+++ b/net/irda/qos.c
@@ -342,8 +342,6 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 	__u32 line_capacity;
 	int index;
 
-	IRDA_DEBUG(2, "%s()\n", __func__);
-
 	/*
 	 * Make sure the mintt is sensible.
 	 * Main culprit : Ericsson T39. - Jean II
@@ -368,9 +366,8 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 	if ((qos->baud_rate.value < 115200) &&
 	    (qos->max_turn_time.value < 500))
 	{
-		IRDA_DEBUG(0,
-			   "%s(), adjusting max turn time from %d to 500 ms\n",
-			   __func__, qos->max_turn_time.value);
+		pr_debug("%s(), adjusting max turn time from %d to 500 ms\n",
+			 __func__, qos->max_turn_time.value);
 		qos->max_turn_time.value = 500;
 	}
 
@@ -385,8 +382,8 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 #ifdef CONFIG_IRDA_DYNAMIC_WINDOW
 	while ((qos->data_size.value > line_capacity) && (index > 0)) {
 		qos->data_size.value = data_sizes[index--];
-		IRDA_DEBUG(2, "%s(), reducing data size to %d\n",
-			   __func__, qos->data_size.value);
+		pr_debug("%s(), reducing data size to %d\n",
+			 __func__, qos->data_size.value);
 	}
 #else /* Use method described in section 6.6.11 of IrLAP */
 	while (irlap_requested_line_capacity(qos) > line_capacity) {
@@ -395,12 +392,12 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 		/* Must be able to send at least one frame */
 		if (qos->window_size.value > 1) {
 			qos->window_size.value--;
-			IRDA_DEBUG(2, "%s(), reducing window size to %d\n",
-				   __func__, qos->window_size.value);
+			pr_debug("%s(), reducing window size to %d\n",
+				 __func__, qos->window_size.value);
 		} else if (index > 1) {
 			qos->data_size.value = data_sizes[index--];
-			IRDA_DEBUG(2, "%s(), reducing data size to %d\n",
-				   __func__, qos->data_size.value);
+			pr_debug("%s(), reducing data size to %d\n",
+				 __func__, qos->data_size.value);
 		} else {
 			net_warn_ratelimited("%s(), nothing more we can do!\n",
 					     __func__);
@@ -440,20 +437,20 @@ int irlap_qos_negotiate(struct irlap_cb *self, struct sk_buff *skb)
 
 	irlap_adjust_qos_settings(&self->qos_tx);
 
-	IRDA_DEBUG(2, "Setting BAUD_RATE to %d bps.\n",
-		   self->qos_tx.baud_rate.value);
-	IRDA_DEBUG(2, "Setting DATA_SIZE to %d bytes\n",
-		   self->qos_tx.data_size.value);
-	IRDA_DEBUG(2, "Setting WINDOW_SIZE to %d\n",
-		   self->qos_tx.window_size.value);
-	IRDA_DEBUG(2, "Setting XBOFS to %d\n",
-		   self->qos_tx.additional_bofs.value);
-	IRDA_DEBUG(2, "Setting MAX_TURN_TIME to %d ms.\n",
-		   self->qos_tx.max_turn_time.value);
-	IRDA_DEBUG(2, "Setting MIN_TURN_TIME to %d usecs.\n",
-		   self->qos_tx.min_turn_time.value);
-	IRDA_DEBUG(2, "Setting LINK_DISC to %d secs.\n",
-		   self->qos_tx.link_disc_time.value);
+	pr_debug("Setting BAUD_RATE to %d bps.\n",
+		 self->qos_tx.baud_rate.value);
+	pr_debug("Setting DATA_SIZE to %d bytes\n",
+		 self->qos_tx.data_size.value);
+	pr_debug("Setting WINDOW_SIZE to %d\n",
+		 self->qos_tx.window_size.value);
+	pr_debug("Setting XBOFS to %d\n",
+		 self->qos_tx.additional_bofs.value);
+	pr_debug("Setting MAX_TURN_TIME to %d ms.\n",
+		 self->qos_tx.max_turn_time.value);
+	pr_debug("Setting MIN_TURN_TIME to %d usecs.\n",
+		 self->qos_tx.min_turn_time.value);
+	pr_debug("Setting LINK_DISC to %d secs.\n",
+		 self->qos_tx.link_disc_time.value);
 	return ret;
 }
 
@@ -537,17 +534,17 @@ static int irlap_param_baud_rate(void *instance, irda_param_t *param, int get)
 
 	if (get) {
 		param->pv.i = self->qos_rx.baud_rate.bits;
-		IRDA_DEBUG(2, "%s(), baud rate = 0x%02x\n",
-			   __func__, param->pv.i);
+		pr_debug("%s(), baud rate = 0x%02x\n",
+			 __func__, param->pv.i);
 	} else {
 		/*
 		 *  Stations must agree on baud rate, so calculate
 		 *  intersection
 		 */
-		IRDA_DEBUG(2, "Requested BAUD_RATE: 0x%04x\n", (__u16) param->pv.i);
+		pr_debug("Requested BAUD_RATE: 0x%04x\n", (__u16)param->pv.i);
 		final = (__u16) param->pv.i & self->qos_rx.baud_rate.bits;
 
-		IRDA_DEBUG(2, "Final BAUD_RATE: 0x%04x\n", final);
+		pr_debug("Final BAUD_RATE: 0x%04x\n", final);
 		self->qos_tx.baud_rate.bits = final;
 		self->qos_rx.baud_rate.bits = final;
 	}
@@ -578,10 +575,10 @@ static int irlap_param_link_disconnect(void *instance, irda_param_t *param,
 		 *  Stations must agree on link disconnect/threshold
 		 *  time.
 		 */
-		IRDA_DEBUG(2, "LINK_DISC: %02x\n", (__u8) param->pv.i);
+		pr_debug("LINK_DISC: %02x\n", (__u8)param->pv.i);
 		final = (__u8) param->pv.i & self->qos_rx.link_disc_time.bits;
 
-		IRDA_DEBUG(2, "Final LINK_DISC: %02x\n", final);
+		pr_debug("Final LINK_DISC: %02x\n", final);
 		self->qos_tx.link_disc_time.bits = final;
 		self->qos_rx.link_disc_time.bits = final;
 	}
@@ -710,8 +707,8 @@ __u32 irlap_max_line_capacity(__u32 speed, __u32 max_turn_time)
 	__u32 line_capacity;
 	int i,j;
 
-	IRDA_DEBUG(2, "%s(), speed=%d, max_turn_time=%d\n",
-		   __func__, speed, max_turn_time);
+	pr_debug("%s(), speed=%d, max_turn_time=%d\n",
+		 __func__, speed, max_turn_time);
 
 	i = value_index(speed, baud_rates, 10);
 	j = value_index(max_turn_time, max_turn_times, 4);
@@ -721,8 +718,8 @@ __u32 irlap_max_line_capacity(__u32 speed, __u32 max_turn_time)
 
 	line_capacity = max_line_capacities[i][j];
 
-	IRDA_DEBUG(2, "%s(), line capacity=%d bytes\n",
-		   __func__, line_capacity);
+	pr_debug("%s(), line capacity=%d bytes\n",
+		 __func__, line_capacity);
 
 	return line_capacity;
 }
@@ -737,8 +734,8 @@ static __u32 irlap_requested_line_capacity(struct qos_info *qos)
 		irlap_min_turn_time_in_bytes(qos->baud_rate.value,
 					     qos->min_turn_time.value);
 
-	IRDA_DEBUG(2, "%s(), requested line capacity=%d\n",
-		   __func__, line_capacity);
+	pr_debug("%s(), requested line capacity=%d\n",
+		 __func__, line_capacity);
 
 	return line_capacity;
 }
diff --git a/net/irda/wrapper.c b/net/irda/wrapper.c
index 9efffeb..40a0f99 100644
--- a/net/irda/wrapper.c
+++ b/net/irda/wrapper.c
@@ -106,17 +106,17 @@ int async_wrap_skb(struct sk_buff *skb, __u8 *tx_buff, int buffsize)
 		 * Nothing to worry about, but we set the default number of
 		 * BOF's
 		 */
-		IRDA_DEBUG(1, "%s(), wrong magic in skb!\n", __func__);
+		pr_debug("%s(), wrong magic in skb!\n", __func__);
 		xbofs = 10;
 	} else
 		xbofs = cb->xbofs + cb->xbofs_delay;
 
-	IRDA_DEBUG(4, "%s(), xbofs=%d\n", __func__, xbofs);
+	pr_debug("%s(), xbofs=%d\n", __func__, xbofs);
 
 	/* Check that we never use more than 115 + 48 xbofs */
 	if (xbofs > 163) {
-		IRDA_DEBUG(0, "%s(), too many xbofs (%d)\n", __func__,
-			   xbofs);
+		pr_debug("%s(), too many xbofs (%d)\n", __func__,
+			 xbofs);
 		xbofs = 163;
 	}
 
@@ -286,8 +286,8 @@ async_unwrap_bof(struct net_device *dev,
 	case INSIDE_FRAME:
 		/* Not supposed to happen, the previous frame is not
 		 * finished - Jean II */
-		IRDA_DEBUG(1, "%s(), Discarding incomplete frame\n",
-			   __func__);
+		pr_debug("%s(), Discarding incomplete frame\n",
+			 __func__);
 		stats->rx_errors++;
 		stats->rx_missed_errors++;
 		irda_device_set_media_busy(dev, TRUE);
@@ -360,7 +360,7 @@ async_unwrap_eof(struct net_device *dev,
 			/* Wrong CRC, discard frame!  */
 			irda_device_set_media_busy(dev, TRUE);
 
-			IRDA_DEBUG(1, "%s(), crc error\n", __func__);
+			pr_debug("%s(), crc error\n", __func__);
 			stats->rx_errors++;
 			stats->rx_crc_errors++;
 		}
@@ -420,8 +420,8 @@ async_unwrap_other(struct net_device *dev,
 			rx_buff->fcs = irda_fcs(rx_buff->fcs, byte);
 #endif
 		} else {
-			IRDA_DEBUG(1, "%s(), Rx buffer overflow, aborting\n",
-				   __func__);
+			pr_debug("%s(), Rx buffer overflow, aborting\n",
+				 __func__);
 			rx_buff->state = OUTSIDE_FRAME;
 		}
 		break;
@@ -439,8 +439,8 @@ async_unwrap_other(struct net_device *dev,
 #endif
 			rx_buff->state = INSIDE_FRAME;
 		} else {
-			IRDA_DEBUG(1, "%s(), Rx buffer overflow, aborting\n",
-				   __func__);
+			pr_debug("%s(), Rx buffer overflow, aborting\n",
+				 __func__);
 			rx_buff->state = OUTSIDE_FRAME;
 		}
 		break;
