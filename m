From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] Remove pointless casts from void pointers,
Date: Fri, 26 Oct 2007 05:40:22 -0400 (EDT)
Message-ID: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org,
	kernel-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jwboyer-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org,
	paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bryan.wu-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org, adaplas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

mostly in and around irq handlers.

Signed-off-by: Jeff Garzik <jgarzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 arch/arm/mach-pxa/ssp.c                    |    2 +-
 arch/arm/mach-s3c2410/usb-simtec.c         |    2 +-
 arch/arm/plat-omap/mailbox.c               |    2 +-
 arch/ia64/sn/pci/pcibr/pcibr_provider.c    |    6 +++---
 arch/m68k/amiga/cia.c                      |    2 +-
 arch/ppc/8260_io/enet.c                    |    4 ++--
 arch/ppc/8260_io/fcc_enet.c                |    4 ++--
 arch/ppc/syslib/ppc85xx_rio.c              |    6 +++---
 drivers/input/touchscreen/h3600_ts_input.c |    4 ++--
 drivers/isdn/hardware/eicon/diva.c         |    5 ++---
 drivers/net/ibmlana.c                      |    4 ++--
 drivers/net/wireless/airo.c                |    5 +++--
 drivers/net/wireless/hostap/hostap_hw.c    |    2 +-
 drivers/net/wireless/libertas/if_cs.c      |    2 +-
 drivers/scsi/aic7xxx_old.c                 |    2 +-
 drivers/scsi/ibmvscsi/ibmvstgt.c           |    4 ++--
 drivers/serial/cpm_uart/cpm_uart_core.c    |    2 +-
 drivers/serial/dz.c                        |    2 +-
 drivers/serial/imx.c                       |    4 ++--
 drivers/serial/uartlite.c                  |    2 +-
 drivers/spi/spi_bfin5xx.c                  |    2 +-
 drivers/video/bf54x-lq043fb.c              |    3 +--
 drivers/video/intelfb/intelfbhw.c          |    2 +-
 sound/oss/waveartist.c                     |    2 +-
 24 files changed, 37 insertions(+), 38 deletions(-)

diff --git a/arch/arm/mach-pxa/ssp.c b/arch/arm/mach-pxa/ssp.c
index 71766ac..d042cc8 100644
--- a/arch/arm/mach-pxa/ssp.c
+++ b/arch/arm/mach-pxa/ssp.c
@@ -67,7 +67,7 @@ static int use_count[PXA_SSP_PORTS] = {0, 0, 0};
 
 static irqreturn_t ssp_interrupt(int irq, void *dev_id)
 {
-	struct ssp_dev *dev = (struct ssp_dev*) dev_id;
+	struct ssp_dev *dev = dev_id;
 	unsigned int status = SSSR_P(dev->port);
 
 	SSSR_P(dev->port) = status; /* clear status bits */
diff --git a/arch/arm/mach-s3c2410/usb-simtec.c b/arch/arm/mach-s3c2410/usb-simtec.c
index bcd562a..6aec86a 100644
--- a/arch/arm/mach-s3c2410/usb-simtec.c
+++ b/arch/arm/mach-s3c2410/usb-simtec.c
@@ -60,7 +60,7 @@ usb_simtec_powercontrol(int port, int to)
 static irqreturn_t
 usb_simtec_ocirq(int irq, void *pw)
 {
-	struct s3c2410_hcd_info *info = (struct s3c2410_hcd_info *)pw;
+	struct s3c2410_hcd_info *info = pw;
 
 	if (s3c2410_gpio_getpin(S3C2410_GPG10) == 0) {
 		pr_debug("usb_simtec: over-current irq (oc detected)\n");
diff --git a/arch/arm/plat-omap/mailbox.c b/arch/arm/plat-omap/mailbox.c
index 0360b1f..45a77df 100644
--- a/arch/arm/plat-omap/mailbox.c
+++ b/arch/arm/plat-omap/mailbox.c
@@ -212,7 +212,7 @@ static void __mbox_rx_interrupt(struct omap_mbox *mbox)
 
 static irqreturn_t mbox_interrupt(int irq, void *p)
 {
-	struct omap_mbox *mbox = (struct omap_mbox *)p;
+	struct omap_mbox *mbox = p;
 
 	if (is_mbox_irq(mbox, IRQ_TX))
 		__mbox_tx_interrupt(mbox);
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
index ab3eaf8..2c676cc 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -100,11 +100,11 @@ u16 sn_ioboard_to_pci_bus(struct pci_bus *pci_bus)
 static irqreturn_t
 pcibr_error_intr_handler(int irq, void *arg)
 {
-	struct pcibus_info *soft = (struct pcibus_info *)arg;
+	struct pcibus_info *soft = arg;
 
-	if (sal_pcibr_error_interrupt(soft) < 0) {
+	if (sal_pcibr_error_interrupt(soft) < 0)
 		panic("pcibr_error_intr_handler(): Fatal Bridge Error");
-	}
+
 	return IRQ_HANDLED;
 }
 
diff --git a/arch/m68k/amiga/cia.c b/arch/m68k/amiga/cia.c
index c4a4ffd..343fab4 100644
--- a/arch/m68k/amiga/cia.c
+++ b/arch/m68k/amiga/cia.c
@@ -84,7 +84,7 @@ unsigned char cia_able_irq(struct ciabase *base, unsigned char mask)
 
 static irqreturn_t cia_handler(int irq, void *dev_id)
 {
-	struct ciabase *base = (struct ciabase *)dev_id;
+	struct ciabase *base = dev_id;
 	int mach_irq;
 	unsigned char ints;
 
diff --git a/arch/ppc/8260_io/enet.c b/arch/ppc/8260_io/enet.c
index 615b658..06bb5b7 100644
--- a/arch/ppc/8260_io/enet.c
+++ b/arch/ppc/8260_io/enet.c
@@ -272,7 +272,7 @@ scc_enet_timeout(struct net_device *dev)
  * This is called from the CPM handler, not the MPC core interrupt.
  */
 static irqreturn_t
-scc_enet_interrupt(int irq, void * dev_id)
+scc_enet_interrupt(int irq, void *dev_id)
 {
 	struct	net_device *dev = dev_id;
 	volatile struct	scc_enet_private *cep;
@@ -280,7 +280,7 @@ scc_enet_interrupt(int irq, void * dev_id)
 	ushort	int_events;
 	int	must_restart;
 
-	cep = (struct scc_enet_private *)dev->priv;
+	cep = dev->priv;
 
 	/* Get the interrupt events that caused us to be here.
 	*/
diff --git a/arch/ppc/8260_io/fcc_enet.c b/arch/ppc/8260_io/fcc_enet.c
index 6f3ed6a..a3a27da 100644
--- a/arch/ppc/8260_io/fcc_enet.c
+++ b/arch/ppc/8260_io/fcc_enet.c
@@ -524,7 +524,7 @@ fcc_enet_timeout(struct net_device *dev)
 
 /* The interrupt handler. */
 static irqreturn_t
-fcc_enet_interrupt(int irq, void * dev_id)
+fcc_enet_interrupt(int irq, void *dev_id)
 {
 	struct	net_device *dev = dev_id;
 	volatile struct	fcc_enet_private *cep;
@@ -532,7 +532,7 @@ fcc_enet_interrupt(int irq, void * dev_id)
 	ushort	int_events;
 	int	must_restart;
 
-	cep = (struct fcc_enet_private *)dev->priv;
+	cep = dev->priv;
 
 	/* Get the interrupt events that caused us to be here.
 	*/
diff --git a/arch/ppc/syslib/ppc85xx_rio.c b/arch/ppc/syslib/ppc85xx_rio.c
index af2425e..4db3110 100644
--- a/arch/ppc/syslib/ppc85xx_rio.c
+++ b/arch/ppc/syslib/ppc85xx_rio.c
@@ -355,7 +355,7 @@ static irqreturn_t
 mpc85xx_rio_tx_handler(int irq, void *dev_instance)
 {
 	int osr;
-	struct rio_mport *port = (struct rio_mport *)dev_instance;
+	struct rio_mport *port = dev_instance;
 
 	osr = in_be32((void *)&msg_regs->osr);
 
@@ -522,7 +522,7 @@ static irqreturn_t
 mpc85xx_rio_rx_handler(int irq, void *dev_instance)
 {
 	int isr;
-	struct rio_mport *port = (struct rio_mport *)dev_instance;
+	struct rio_mport *port = dev_instance;
 
 	isr = in_be32((void *)&msg_regs->isr);
 
@@ -740,7 +740,7 @@ static irqreturn_t
 mpc85xx_rio_dbell_handler(int irq, void *dev_instance)
 {
 	int dsr;
-	struct rio_mport *port = (struct rio_mport *)dev_instance;
+	struct rio_mport *port = dev_instance;
 
 	dsr = in_be32((void *)&msg_regs->dsr);
 
diff --git a/drivers/input/touchscreen/h3600_ts_input.c b/drivers/input/touchscreen/h3600_ts_input.c
index 2ae6c60..28ae15e 100644
--- a/drivers/input/touchscreen/h3600_ts_input.c
+++ b/drivers/input/touchscreen/h3600_ts_input.c
@@ -109,7 +109,7 @@ struct h3600_dev {
 static irqreturn_t action_button_handler(int irq, void *dev_id)
 {
 	int down = (GPLR & GPIO_BITSY_ACTION_BUTTON) ? 0 : 1;
-	struct input_dev *dev = (struct input_dev *) dev_id;
+	struct input_dev *dev = dev_id;
 
 	input_report_key(dev, KEY_ENTER, down);
 	input_sync(dev);
@@ -120,7 +120,7 @@ static irqreturn_t action_button_handler(int irq, void *dev_id)
 static irqreturn_t npower_button_handler(int irq, void *dev_id)
 {
 	int down = (GPLR & GPIO_BITSY_NPOWER_BUTTON) ? 0 : 1;
-	struct input_dev *dev = (struct input_dev *) dev_id;
+	struct input_dev *dev = dev_id;
 
 	/*
 	 * This interrupt is only called when we release the key. So we have
diff --git a/drivers/isdn/hardware/eicon/diva.c b/drivers/isdn/hardware/eicon/diva.c
index ffa2afa..1403a54 100644
--- a/drivers/isdn/hardware/eicon/diva.c
+++ b/drivers/isdn/hardware/eicon/diva.c
@@ -515,12 +515,11 @@ diva_xdi_read(void *adapter, void *os_handle, void __user *dst,
 
 irqreturn_t diva_os_irq_wrapper(int irq, void *context)
 {
-	diva_os_xdi_adapter_t *a = (diva_os_xdi_adapter_t *) context;
+	diva_os_xdi_adapter_t *a = context;
 	diva_xdi_clear_interrupts_proc_t clear_int_proc;
 
-	if (!a || !a->xdi_adapter.diva_isr_handler) {
+	if (!a || !a->xdi_adapter.diva_isr_handler)
 		return IRQ_NONE;
-	}
 
 	if ((clear_int_proc = a->clear_interrupts_proc)) {
 		(*clear_int_proc) (a);
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 91d83ac..65626d6 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -704,9 +704,9 @@ static void irqtxerr_handler(struct net_device *dev)
 
 /* general interrupt entry */
 
-static irqreturn_t irq_handler(int irq, void *device)
+static irqreturn_t irq_handler(int dummy, void *device)
 {
-	struct net_device *dev = (struct net_device *) device;
+	struct net_device *dev = device;
 	u16 ival;
 
 	/* in case we're not meant... */
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 074055e..d1febe8 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -3177,8 +3177,9 @@ static int airo_thread(void *data) {
 	return 0;
 }
 
-static irqreturn_t airo_interrupt ( int irq, void* dev_id) {
-	struct net_device *dev = (struct net_device *)dev_id;
+static irqreturn_t airo_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
 	u16 status;
 	u16 fid;
 	struct airo_info *apriv = dev->priv;
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index c592641..286b46c 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -2624,7 +2624,7 @@ static void prism2_check_magic(local_info_t *local)
 /* Called only from hardware IRQ */
 static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
+	struct net_device *dev = dev_id;
 	struct hostap_interface *iface;
 	local_info_t *local;
 	int events = 0;
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 0360cad..f9879d4 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -242,7 +242,7 @@ static inline void if_cs_disable_ints(struct if_cs_card *card)
 
 static irqreturn_t if_cs_interrupt(int irq, void *data)
 {
-	struct if_cs_card *card = (struct if_cs_card *)data;
+	struct if_cs_card *card = data;
 	u16 int_cause;
 
 	lbs_deb_enter(LBS_DEB_CS);
diff --git a/drivers/scsi/aic7xxx_old.c b/drivers/scsi/aic7xxx_old.c
index 8f8db5f..5e32cbc 100644
--- a/drivers/scsi/aic7xxx_old.c
+++ b/drivers/scsi/aic7xxx_old.c
@@ -6472,7 +6472,7 @@ do_aic7xxx_isr(int irq, void *dev_id)
   unsigned long cpu_flags;
   struct aic7xxx_host *p;
   
-  p = (struct aic7xxx_host *)dev_id;
+  p = dev_id;
   if(!p)
     return IRQ_NONE;
   spin_lock_irqsave(p->host->host_lock, cpu_flags);
diff --git a/drivers/scsi/ibmvscsi/ibmvstgt.c b/drivers/scsi/ibmvscsi/ibmvstgt.c
index 82bcab6..9070ae1 100644
--- a/drivers/scsi/ibmvscsi/ibmvstgt.c
+++ b/drivers/scsi/ibmvscsi/ibmvstgt.c
@@ -539,9 +539,9 @@ out:
 		srp_iu_put(iue);
 }
 
-static irqreturn_t ibmvstgt_interrupt(int irq, void *data)
+static irqreturn_t ibmvstgt_interrupt(int dummy, void *data)
 {
-	struct srp_target *target = (struct srp_target *) data;
+	struct srp_target *target = data;
 	struct vio_port *vport = target_to_port(target);
 
 	vio_disable_interrupts(vport->dma_dev);
diff --git a/drivers/serial/cpm_uart/cpm_uart_core.c b/drivers/serial/cpm_uart/cpm_uart_core.c
index b5e4478..236af9d 100644
--- a/drivers/serial/cpm_uart/cpm_uart_core.c
+++ b/drivers/serial/cpm_uart/cpm_uart_core.c
@@ -380,7 +380,7 @@ static void cpm_uart_int_rx(struct uart_port *port)
 static irqreturn_t cpm_uart_int(int irq, void *data)
 {
 	u8 events;
-	struct uart_port *port = (struct uart_port *)data;
+	struct uart_port *port = data;
 	struct uart_cpm_port *pinfo = (struct uart_cpm_port *)port;
 	smc_t __iomem *smcp = pinfo->smcp;
 	scc_t __iomem *sccp = pinfo->sccp;
diff --git a/drivers/serial/dz.c b/drivers/serial/dz.c
index d31721f..bbae5a2 100644
--- a/drivers/serial/dz.c
+++ b/drivers/serial/dz.c
@@ -324,7 +324,7 @@ static inline void check_modem_status(struct dz_port *dport)
  */
 static irqreturn_t dz_interrupt(int irq, void *dev)
 {
-	struct dz_port *dport = (struct dz_port *)dev;
+	struct dz_port *dport = dev;
 	unsigned short status;
 
 	/* get the reason why we just got an irq */
diff --git a/drivers/serial/imx.c b/drivers/serial/imx.c
index dc19671..56af1f5 100644
--- a/drivers/serial/imx.c
+++ b/drivers/serial/imx.c
@@ -308,7 +308,7 @@ static void imx_start_tx(struct uart_port *port)
 
 static irqreturn_t imx_rtsint(int irq, void *dev_id)
 {
-	struct imx_port *sport = (struct imx_port *)dev_id;
+	struct imx_port *sport = dev_id;
 	unsigned int val = readl(sport->port.membase + USR1) & USR1_RTSS;
 	unsigned long flags;
 
@@ -324,7 +324,7 @@ static irqreturn_t imx_rtsint(int irq, void *dev_id)
 
 static irqreturn_t imx_txint(int irq, void *dev_id)
 {
-	struct imx_port *sport = (struct imx_port *)dev_id;
+	struct imx_port *sport = dev_id;
 	struct circ_buf *xmit = &sport->port.info->xmit;
 	unsigned long flags;
 
diff --git a/drivers/serial/uartlite.c b/drivers/serial/uartlite.c
index dfef83f..3a970ed 100644
--- a/drivers/serial/uartlite.c
+++ b/drivers/serial/uartlite.c
@@ -142,7 +142,7 @@ static int ulite_transmit(struct uart_port *port, int stat)
 
 static irqreturn_t ulite_isr(int irq, void *dev_id)
 {
-	struct uart_port *port = (struct uart_port *)dev_id;
+	struct uart_port *port = dev_id;
 	int busy;
 
 	do {
diff --git a/drivers/spi/spi_bfin5xx.c b/drivers/spi/spi_bfin5xx.c
index 2ef11bb..06fd859 100644
--- a/drivers/spi/spi_bfin5xx.c
+++ b/drivers/spi/spi_bfin5xx.c
@@ -575,7 +575,7 @@ static void giveback(struct driver_data *drv_data)
 
 static irqreturn_t dma_irq_handler(int irq, void *dev_id)
 {
-	struct driver_data *drv_data = (struct driver_data *)dev_id;
+	struct driver_data *drv_data = dev_id;
 	struct spi_message *msg = drv_data->cur_msg;
 
 	dev_dbg(&drv_data->pdev->dev, "in dma_irq_handler\n");
diff --git a/drivers/video/bf54x-lq043fb.c b/drivers/video/bf54x-lq043fb.c
index 74d11c3..ac1402c 100644
--- a/drivers/video/bf54x-lq043fb.c
+++ b/drivers/video/bf54x-lq043fb.c
@@ -498,8 +498,7 @@ static struct lcd_device *lcd_dev;
 
 static irqreturn_t bfin_bf54x_irq_error(int irq, void *dev_id)
 {
-
-	/*struct bfin_bf54xfb_info *info = (struct bfin_bf54xfb_info *)dev_id;*/
+	/*struct bfin_bf54xfb_info *info = dev_id;*/
 
 	u16 status = bfin_read_EPPI0_STATUS();
 
diff --git a/drivers/video/intelfb/intelfbhw.c b/drivers/video/intelfb/intelfbhw.c
index 5f6fb7d..fa1fff5 100644
--- a/drivers/video/intelfb/intelfbhw.c
+++ b/drivers/video/intelfb/intelfbhw.c
@@ -1971,7 +1971,7 @@ void intelfbhw_cursor_reset(struct intelfb_info *dinfo)
 static irqreturn_t intelfbhw_irq(int irq, void *dev_id)
 {
 	u16 tmp;
-	struct intelfb_info *dinfo = (struct intelfb_info *)dev_id;
+	struct intelfb_info *dinfo = dev_id;
 
 	spin_lock(&dinfo->int_lock);
 
diff --git a/sound/oss/waveartist.c b/sound/oss/waveartist.c
index b48c729..8849041 100644
--- a/sound/oss/waveartist.c
+++ b/sound/oss/waveartist.c
@@ -835,7 +835,7 @@ static struct audio_driver waveartist_audio_driver = {
 static irqreturn_t
 waveartist_intr(int irq, void *dev_id)
 {
-	wavnc_info *devc = (wavnc_info *)dev_id;
+	wavnc_info *devc = dev_id;
 	int	   irqstatus, status;
 
 	spin_lock(&waveartist_lock);
-- 
1.5.2.4
