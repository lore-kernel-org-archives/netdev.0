From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6 1/4] atm: [nicstar] reformatted with Lindent
Date: Sat, 29 May 2010 15:03:44 -0400
Message-ID: <201005291903.o4TJ3iFh004998@thirdoffive.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:58760 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854Ab0E2TPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 15:15:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Author: chas williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Fri May 28 18:43:47 2010 -0400

    atm: [nicstar] reformatted with Lindent
    
    Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index b7473a6..a07b6b7 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -1,5 +1,4 @@
-/******************************************************************************
- *
+/*
  * nicstar.c
  *
  * Device driver supporting CBR for IDT 77201/77211 "NICStAR" based cards.
@@ -16,12 +15,10 @@
  *
  *
  * (C) INESC 1999
- *
- *
- ******************************************************************************/
-
+ */
 
-/**** IMPORTANT INFORMATION ***************************************************
+/*
+ * IMPORTANT INFORMATION
  *
  * There are currently three types of spinlocks:
  *
@@ -31,9 +28,9 @@
  *
  * These must NEVER be grabbed in reverse order.
  *
- ******************************************************************************/
+ */
 
-/* Header files ***************************************************************/
+/* Header files */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -62,15 +59,14 @@
 #endif /* CONFIG_ATM_NICSTAR_USE_IDT77105 */
 
 #if BITS_PER_LONG != 32
-#  error FIXME: this driver requires a 32-bit platform
+# error FIXME: this driver requires a 32-bit platform
 #endif
 
-/* Additional code ************************************************************/
+/* Additional code */
 
 #include "nicstarmac.c"
 
-
-/* Configurable parameters ****************************************************/
+/* Configurable parameters */
 
 #undef PHY_LOOPBACK
 #undef TX_DEBUG
@@ -78,11 +74,10 @@
 #undef GENERAL_DEBUG
 #undef EXTRA_DEBUG
 
-#undef NS_USE_DESTRUCTORS /* For now keep this undefined unless you know
-                             you're going to use only raw ATM */
-
+#undef NS_USE_DESTRUCTORS	/* For now keep this undefined unless you know
+				   you're going to use only raw ATM */
 
-/* Do not touch these *********************************************************/
+/* Do not touch these */
 
 #ifdef TX_DEBUG
 #define TXPRINTK(args...) printk(args)
@@ -108,8 +103,7 @@
 #define XPRINTK(args...)
 #endif /* EXTRA_DEBUG */
 
-
-/* Macros *********************************************************************/
+/* Macros */
 
 #define CMD_BUSY(card) (readl((card)->membase + STAT) & NS_STAT_CMDBZ)
 
@@ -126,2890 +120,2711 @@
 #define ATM_SKB(s) (&(s)->atm)
 #endif
 
+/* Function declarations */
 
-/* Function declarations ******************************************************/
-
-static u32 ns_read_sram(ns_dev *card, u32 sram_address);
-static void ns_write_sram(ns_dev *card, u32 sram_address, u32 *value, int count);
+static u32 ns_read_sram(ns_dev * card, u32 sram_address);
+static void ns_write_sram(ns_dev * card, u32 sram_address, u32 * value,
+			  int count);
 static int __devinit ns_init_card(int i, struct pci_dev *pcidev);
-static void __devinit ns_init_card_error(ns_dev *card, int error);
+static void __devinit ns_init_card_error(ns_dev * card, int error);
 static scq_info *get_scq(int size, u32 scd);
-static void free_scq(scq_info *scq, struct atm_vcc *vcc);
+static void free_scq(scq_info * scq, struct atm_vcc *vcc);
 static void push_rxbufs(ns_dev *, struct sk_buff *);
 static irqreturn_t ns_irq_handler(int irq, void *dev_id);
 static int ns_open(struct atm_vcc *vcc);
 static void ns_close(struct atm_vcc *vcc);
-static void fill_tst(ns_dev *card, int n, vc_map *vc);
+static void fill_tst(ns_dev * card, int n, vc_map * vc);
 static int ns_send(struct atm_vcc *vcc, struct sk_buff *skb);
-static int push_scqe(ns_dev *card, vc_map *vc, scq_info *scq, ns_scqe *tbd,
-                     struct sk_buff *skb);
-static void process_tsq(ns_dev *card);
-static void drain_scq(ns_dev *card, scq_info *scq, int pos);
-static void process_rsq(ns_dev *card);
-static void dequeue_rx(ns_dev *card, ns_rsqe *rsqe);
+static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
+		     struct sk_buff *skb);
+static void process_tsq(ns_dev * card);
+static void drain_scq(ns_dev * card, scq_info * scq, int pos);
+static void process_rsq(ns_dev * card);
+static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe);
 #ifdef NS_USE_DESTRUCTORS
 static void ns_sb_destructor(struct sk_buff *sb);
 static void ns_lb_destructor(struct sk_buff *lb);
 static void ns_hb_destructor(struct sk_buff *hb);
 #endif /* NS_USE_DESTRUCTORS */
-static void recycle_rx_buf(ns_dev *card, struct sk_buff *skb);
-static void recycle_iovec_rx_bufs(ns_dev *card, struct iovec *iov, int count);
-static void recycle_iov_buf(ns_dev *card, struct sk_buff *iovb);
-static void dequeue_sm_buf(ns_dev *card, struct sk_buff *sb);
-static void dequeue_lg_buf(ns_dev *card, struct sk_buff *lb);
-static int ns_proc_read(struct atm_dev *dev, loff_t *pos, char *page);
-static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user *arg);
-static void which_list(ns_dev *card, struct sk_buff *skb);
+static void recycle_rx_buf(ns_dev * card, struct sk_buff *skb);
+static void recycle_iovec_rx_bufs(ns_dev * card, struct iovec *iov, int count);
+static void recycle_iov_buf(ns_dev * card, struct sk_buff *iovb);
+static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb);
+static void dequeue_lg_buf(ns_dev * card, struct sk_buff *lb);
+static int ns_proc_read(struct atm_dev *dev, loff_t * pos, char *page);
+static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg);
+static void which_list(ns_dev * card, struct sk_buff *skb);
 static void ns_poll(unsigned long arg);
 static int ns_parse_mac(char *mac, unsigned char *esi);
 static short ns_h2i(char c);
 static void ns_phy_put(struct atm_dev *dev, unsigned char value,
-                       unsigned long addr);
+		       unsigned long addr);
 static unsigned char ns_phy_get(struct atm_dev *dev, unsigned long addr);
 
-
-
-/* Global variables ***********************************************************/
+/* Global variables */
 
 static struct ns_dev *cards[NS_MAX_CARDS];
 static unsigned num_cards;
-static struct atmdev_ops atm_ops =
-{
-   .open	= ns_open,
-   .close	= ns_close,
-   .ioctl	= ns_ioctl,
-   .send	= ns_send,
-   .phy_put	= ns_phy_put,
-   .phy_get	= ns_phy_get,
-   .proc_read	= ns_proc_read,
-   .owner	= THIS_MODULE,
+static struct atmdev_ops atm_ops = {
+	.open = ns_open,
+	.close = ns_close,
+	.ioctl = ns_ioctl,
+	.send = ns_send,
+	.phy_put = ns_phy_put,
+	.phy_get = ns_phy_get,
+	.proc_read = ns_proc_read,
+	.owner = THIS_MODULE,
 };
+
 static struct timer_list ns_timer;
 static char *mac[NS_MAX_CARDS];
 module_param_array(mac, charp, NULL, 0);
 MODULE_LICENSE("GPL");
 
-
-/* Functions*******************************************************************/
+/* Functions */
 
 static int __devinit nicstar_init_one(struct pci_dev *pcidev,
 				      const struct pci_device_id *ent)
 {
-   static int index = -1;
-   unsigned int error;
+	static int index = -1;
+	unsigned int error;
 
-   index++;
-   cards[index] = NULL;
+	index++;
+	cards[index] = NULL;
 
-   error = ns_init_card(index, pcidev);
-   if (error) {
-      cards[index--] = NULL;	/* don't increment index */
-      goto err_out;
-   }
+	error = ns_init_card(index, pcidev);
+	if (error) {
+		cards[index--] = NULL;	/* don't increment index */
+		goto err_out;
+	}
 
-   return 0;
+	return 0;
 err_out:
-   return -ENODEV;
+	return -ENODEV;
 }
 
-
-
 static void __devexit nicstar_remove_one(struct pci_dev *pcidev)
 {
-   int i, j;
-   ns_dev *card = pci_get_drvdata(pcidev);
-   struct sk_buff *hb;
-   struct sk_buff *iovb;
-   struct sk_buff *lb;
-   struct sk_buff *sb;
-   
-   i = card->index;
-
-   if (cards[i] == NULL)
-      return;
-
-   if (card->atmdev->phy && card->atmdev->phy->stop)
-      card->atmdev->phy->stop(card->atmdev);
-
-   /* Stop everything */
-   writel(0x00000000, card->membase + CFG);
-
-   /* De-register device */
-   atm_dev_deregister(card->atmdev);
-
-   /* Disable PCI device */
-   pci_disable_device(pcidev);
-   
-   /* Free up resources */
-   j = 0;
-   PRINTK("nicstar%d: freeing %d huge buffers.\n", i, card->hbpool.count);
-   while ((hb = skb_dequeue(&card->hbpool.queue)) != NULL)
-   {
-      dev_kfree_skb_any(hb);
-      j++;
-   }
-   PRINTK("nicstar%d: %d huge buffers freed.\n", i, j);
-   j = 0;
-   PRINTK("nicstar%d: freeing %d iovec buffers.\n", i, card->iovpool.count);
-   while ((iovb = skb_dequeue(&card->iovpool.queue)) != NULL)
-   {
-      dev_kfree_skb_any(iovb);
-      j++;
-   }
-   PRINTK("nicstar%d: %d iovec buffers freed.\n", i, j);
-   while ((lb = skb_dequeue(&card->lbpool.queue)) != NULL)
-      dev_kfree_skb_any(lb);
-   while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
-      dev_kfree_skb_any(sb);
-   free_scq(card->scq0, NULL);
-   for (j = 0; j < NS_FRSCD_NUM; j++)
-   {
-      if (card->scd2vc[j] != NULL)
-         free_scq(card->scd2vc[j]->scq, card->scd2vc[j]->tx_vcc);
-   }
-   kfree(card->rsq.org);
-   kfree(card->tsq.org);
-   free_irq(card->pcidev->irq, card);
-   iounmap(card->membase);
-   kfree(card);
+	int i, j;
+	ns_dev *card = pci_get_drvdata(pcidev);
+	struct sk_buff *hb;
+	struct sk_buff *iovb;
+	struct sk_buff *lb;
+	struct sk_buff *sb;
+
+	i = card->index;
+
+	if (cards[i] == NULL)
+		return;
+
+	if (card->atmdev->phy && card->atmdev->phy->stop)
+		card->atmdev->phy->stop(card->atmdev);
+
+	/* Stop everything */
+	writel(0x00000000, card->membase + CFG);
+
+	/* De-register device */
+	atm_dev_deregister(card->atmdev);
+
+	/* Disable PCI device */
+	pci_disable_device(pcidev);
+
+	/* Free up resources */
+	j = 0;
+	PRINTK("nicstar%d: freeing %d huge buffers.\n", i, card->hbpool.count);
+	while ((hb = skb_dequeue(&card->hbpool.queue)) != NULL) {
+		dev_kfree_skb_any(hb);
+		j++;
+	}
+	PRINTK("nicstar%d: %d huge buffers freed.\n", i, j);
+	j = 0;
+	PRINTK("nicstar%d: freeing %d iovec buffers.\n", i,
+	       card->iovpool.count);
+	while ((iovb = skb_dequeue(&card->iovpool.queue)) != NULL) {
+		dev_kfree_skb_any(iovb);
+		j++;
+	}
+	PRINTK("nicstar%d: %d iovec buffers freed.\n", i, j);
+	while ((lb = skb_dequeue(&card->lbpool.queue)) != NULL)
+		dev_kfree_skb_any(lb);
+	while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
+		dev_kfree_skb_any(sb);
+	free_scq(card->scq0, NULL);
+	for (j = 0; j < NS_FRSCD_NUM; j++) {
+		if (card->scd2vc[j] != NULL)
+			free_scq(card->scd2vc[j]->scq, card->scd2vc[j]->tx_vcc);
+	}
+	kfree(card->rsq.org);
+	kfree(card->tsq.org);
+	free_irq(card->pcidev->irq, card);
+	iounmap(card->membase);
+	kfree(card);
 }
 
-
-
-static struct pci_device_id nicstar_pci_tbl[] __devinitdata =
-{
+static struct pci_device_id nicstar_pci_tbl[] __devinitdata = {
 	{PCI_VENDOR_ID_IDT, PCI_DEVICE_ID_IDT_IDT77201,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0,}			/* terminate list */
 };
-MODULE_DEVICE_TABLE(pci, nicstar_pci_tbl);
-
 
+MODULE_DEVICE_TABLE(pci, nicstar_pci_tbl);
 
 static struct pci_driver nicstar_driver = {
-	.name		= "nicstar",
-	.id_table	= nicstar_pci_tbl,
-	.probe		= nicstar_init_one,
-	.remove		= __devexit_p(nicstar_remove_one),
+	.name = "nicstar",
+	.id_table = nicstar_pci_tbl,
+	.probe = nicstar_init_one,
+	.remove = __devexit_p(nicstar_remove_one),
 };
 
-
-
 static int __init nicstar_init(void)
 {
-   unsigned error = 0;	/* Initialized to remove compile warning */
+	unsigned error = 0;	/* Initialized to remove compile warning */
 
-   XPRINTK("nicstar: nicstar_init() called.\n");
+	XPRINTK("nicstar: nicstar_init() called.\n");
 
-   error = pci_register_driver(&nicstar_driver);
-   
-   TXPRINTK("nicstar: TX debug enabled.\n");
-   RXPRINTK("nicstar: RX debug enabled.\n");
-   PRINTK("nicstar: General debug enabled.\n");
+	error = pci_register_driver(&nicstar_driver);
+
+	TXPRINTK("nicstar: TX debug enabled.\n");
+	RXPRINTK("nicstar: RX debug enabled.\n");
+	PRINTK("nicstar: General debug enabled.\n");
 #ifdef PHY_LOOPBACK
-   printk("nicstar: using PHY loopback.\n");
+	printk("nicstar: using PHY loopback.\n");
 #endif /* PHY_LOOPBACK */
-   XPRINTK("nicstar: nicstar_init() returned.\n");
-
-   if (!error) {
-      init_timer(&ns_timer);
-      ns_timer.expires = jiffies + NS_POLL_PERIOD;
-      ns_timer.data = 0UL;
-      ns_timer.function = ns_poll;
-      add_timer(&ns_timer);
-   }
-   
-   return error;
-}
+	XPRINTK("nicstar: nicstar_init() returned.\n");
 
+	if (!error) {
+		init_timer(&ns_timer);
+		ns_timer.expires = jiffies + NS_POLL_PERIOD;
+		ns_timer.data = 0UL;
+		ns_timer.function = ns_poll;
+		add_timer(&ns_timer);
+	}
 
+	return error;
+}
 
 static void __exit nicstar_cleanup(void)
 {
-   XPRINTK("nicstar: nicstar_cleanup() called.\n");
+	XPRINTK("nicstar: nicstar_cleanup() called.\n");
 
-   del_timer(&ns_timer);
+	del_timer(&ns_timer);
 
-   pci_unregister_driver(&nicstar_driver);
+	pci_unregister_driver(&nicstar_driver);
 
-   XPRINTK("nicstar: nicstar_cleanup() returned.\n");
+	XPRINTK("nicstar: nicstar_cleanup() returned.\n");
 }
 
-
-
-static u32 ns_read_sram(ns_dev *card, u32 sram_address)
+static u32 ns_read_sram(ns_dev * card, u32 sram_address)
 {
-   unsigned long flags;
-   u32 data;
-   sram_address <<= 2;
-   sram_address &= 0x0007FFFC;	/* address must be dword aligned */
-   sram_address |= 0x50000000;	/* SRAM read command */
-   spin_lock_irqsave(&card->res_lock, flags);
-   while (CMD_BUSY(card));
-   writel(sram_address, card->membase + CMD);
-   while (CMD_BUSY(card));
-   data = readl(card->membase + DR0);
-   spin_unlock_irqrestore(&card->res_lock, flags);
-   return data;
+	unsigned long flags;
+	u32 data;
+	sram_address <<= 2;
+	sram_address &= 0x0007FFFC;	/* address must be dword aligned */
+	sram_address |= 0x50000000;	/* SRAM read command */
+	spin_lock_irqsave(&card->res_lock, flags);
+	while (CMD_BUSY(card)) ;
+	writel(sram_address, card->membase + CMD);
+	while (CMD_BUSY(card)) ;
+	data = readl(card->membase + DR0);
+	spin_unlock_irqrestore(&card->res_lock, flags);
+	return data;
 }
 
-
-   
-static void ns_write_sram(ns_dev *card, u32 sram_address, u32 *value, int count)
+static void ns_write_sram(ns_dev * card, u32 sram_address, u32 * value,
+			  int count)
 {
-   unsigned long flags;
-   int i, c;
-   count--;	/* count range now is 0..3 instead of 1..4 */
-   c = count;
-   c <<= 2;	/* to use increments of 4 */
-   spin_lock_irqsave(&card->res_lock, flags);
-   while (CMD_BUSY(card));
-   for (i = 0; i <= c; i += 4)
-      writel(*(value++), card->membase + i);
-   /* Note: DR# registers are the first 4 dwords in nicstar's memspace,
-            so card->membase + DR0 == card->membase */
-   sram_address <<= 2;
-   sram_address &= 0x0007FFFC;
-   sram_address |= (0x40000000 | count);
-   writel(sram_address, card->membase + CMD);
-   spin_unlock_irqrestore(&card->res_lock, flags);
+	unsigned long flags;
+	int i, c;
+	count--;		/* count range now is 0..3 instead of 1..4 */
+	c = count;
+	c <<= 2;		/* to use increments of 4 */
+	spin_lock_irqsave(&card->res_lock, flags);
+	while (CMD_BUSY(card)) ;
+	for (i = 0; i <= c; i += 4)
+		writel(*(value++), card->membase + i);
+	/* Note: DR# registers are the first 4 dwords in nicstar's memspace,
+	   so card->membase + DR0 == card->membase */
+	sram_address <<= 2;
+	sram_address &= 0x0007FFFC;
+	sram_address |= (0x40000000 | count);
+	writel(sram_address, card->membase + CMD);
+	spin_unlock_irqrestore(&card->res_lock, flags);
 }
 
-
 static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 {
-   int j;
-   struct ns_dev *card = NULL;
-   unsigned char pci_latency;
-   unsigned error;
-   u32 data;
-   u32 u32d[4];
-   u32 ns_cfg_rctsize;
-   int bcount;
-   unsigned long membase;
-
-   error = 0;
-
-   if (pci_enable_device(pcidev))
-   {
-      printk("nicstar%d: can't enable PCI device\n", i);
-      error = 2;
-      ns_init_card_error(card, error);
-      return error;
-   }
-
-   if ((card = kmalloc(sizeof(ns_dev), GFP_KERNEL)) == NULL)
-   {
-      printk("nicstar%d: can't allocate memory for device structure.\n", i);
-      error = 2;
-      ns_init_card_error(card, error);
-      return error;
-   }
-   cards[i] = card;
-   spin_lock_init(&card->int_lock);
-   spin_lock_init(&card->res_lock);
-      
-   pci_set_drvdata(pcidev, card);
-   
-   card->index = i;
-   card->atmdev = NULL;
-   card->pcidev = pcidev;
-   membase = pci_resource_start(pcidev, 1);
-   card->membase = ioremap(membase, NS_IOREMAP_SIZE);
-   if (!card->membase)
-   {
-      printk("nicstar%d: can't ioremap() membase.\n",i);
-      error = 3;
-      ns_init_card_error(card, error);
-      return error;
-   }
-   PRINTK("nicstar%d: membase at 0x%x.\n", i, card->membase);
-
-   pci_set_master(pcidev);
-
-   if (pci_read_config_byte(pcidev, PCI_LATENCY_TIMER, &pci_latency) != 0)
-   {
-      printk("nicstar%d: can't read PCI latency timer.\n", i);
-      error = 6;
-      ns_init_card_error(card, error);
-      return error;
-   }
+	int j;
+	struct ns_dev *card = NULL;
+	unsigned char pci_latency;
+	unsigned error;
+	u32 data;
+	u32 u32d[4];
+	u32 ns_cfg_rctsize;
+	int bcount;
+	unsigned long membase;
+
+	error = 0;
+
+	if (pci_enable_device(pcidev)) {
+		printk("nicstar%d: can't enable PCI device\n", i);
+		error = 2;
+		ns_init_card_error(card, error);
+		return error;
+	}
+
+	if ((card = kmalloc(sizeof(ns_dev), GFP_KERNEL)) == NULL) {
+		printk
+		    ("nicstar%d: can't allocate memory for device structure.\n",
+		     i);
+		error = 2;
+		ns_init_card_error(card, error);
+		return error;
+	}
+	cards[i] = card;
+	spin_lock_init(&card->int_lock);
+	spin_lock_init(&card->res_lock);
+
+	pci_set_drvdata(pcidev, card);
+
+	card->index = i;
+	card->atmdev = NULL;
+	card->pcidev = pcidev;
+	membase = pci_resource_start(pcidev, 1);
+	card->membase = ioremap(membase, NS_IOREMAP_SIZE);
+	if (!card->membase) {
+		printk("nicstar%d: can't ioremap() membase.\n", i);
+		error = 3;
+		ns_init_card_error(card, error);
+		return error;
+	}
+	PRINTK("nicstar%d: membase at 0x%x.\n", i, card->membase);
+
+	pci_set_master(pcidev);
+
+	if (pci_read_config_byte(pcidev, PCI_LATENCY_TIMER, &pci_latency) != 0) {
+		printk("nicstar%d: can't read PCI latency timer.\n", i);
+		error = 6;
+		ns_init_card_error(card, error);
+		return error;
+	}
 #ifdef NS_PCI_LATENCY
-   if (pci_latency < NS_PCI_LATENCY)
-   {
-      PRINTK("nicstar%d: setting PCI latency timer to %d.\n", i, NS_PCI_LATENCY);
-      for (j = 1; j < 4; j++)
-      {
-         if (pci_write_config_byte(pcidev, PCI_LATENCY_TIMER, NS_PCI_LATENCY) != 0)
-	    break;
-      }
-      if (j == 4)
-      {
-         printk("nicstar%d: can't set PCI latency timer to %d.\n", i, NS_PCI_LATENCY);
-         error = 7;
-         ns_init_card_error(card, error);
-	 return error;
-      }
-   }
+	if (pci_latency < NS_PCI_LATENCY) {
+		PRINTK("nicstar%d: setting PCI latency timer to %d.\n", i,
+		       NS_PCI_LATENCY);
+		for (j = 1; j < 4; j++) {
+			if (pci_write_config_byte
+			    (pcidev, PCI_LATENCY_TIMER, NS_PCI_LATENCY) != 0)
+				break;
+		}
+		if (j == 4) {
+			printk
+			    ("nicstar%d: can't set PCI latency timer to %d.\n",
+			     i, NS_PCI_LATENCY);
+			error = 7;
+			ns_init_card_error(card, error);
+			return error;
+		}
+	}
 #endif /* NS_PCI_LATENCY */
-      
-   /* Clear timer overflow */
-   data = readl(card->membase + STAT);
-   if (data & NS_STAT_TMROF)
-      writel(NS_STAT_TMROF, card->membase + STAT);
-
-   /* Software reset */
-   writel(NS_CFG_SWRST, card->membase + CFG);
-   NS_DELAY;
-   writel(0x00000000, card->membase + CFG);
-
-   /* PHY reset */
-   writel(0x00000008, card->membase + GP);
-   NS_DELAY;
-   writel(0x00000001, card->membase + GP);
-   NS_DELAY;
-   while (CMD_BUSY(card));
-   writel(NS_CMD_WRITE_UTILITY | 0x00000100, card->membase + CMD);	/* Sync UTOPIA with SAR clock */
-   NS_DELAY;
-      
-   /* Detect PHY type */
-   while (CMD_BUSY(card));
-   writel(NS_CMD_READ_UTILITY | 0x00000200, card->membase + CMD);
-   while (CMD_BUSY(card));
-   data = readl(card->membase + DR0);
-   switch(data) {
-      case 0x00000009:
-         printk("nicstar%d: PHY seems to be 25 Mbps.\n", i);
-         card->max_pcr = ATM_25_PCR;
-         while(CMD_BUSY(card));
-         writel(0x00000008, card->membase + DR0);
-         writel(NS_CMD_WRITE_UTILITY | 0x00000200, card->membase + CMD);
-         /* Clear an eventual pending interrupt */
-         writel(NS_STAT_SFBQF, card->membase + STAT);
+
+	/* Clear timer overflow */
+	data = readl(card->membase + STAT);
+	if (data & NS_STAT_TMROF)
+		writel(NS_STAT_TMROF, card->membase + STAT);
+
+	/* Software reset */
+	writel(NS_CFG_SWRST, card->membase + CFG);
+	NS_DELAY;
+	writel(0x00000000, card->membase + CFG);
+
+	/* PHY reset */
+	writel(0x00000008, card->membase + GP);
+	NS_DELAY;
+	writel(0x00000001, card->membase + GP);
+	NS_DELAY;
+	while (CMD_BUSY(card)) ;
+	writel(NS_CMD_WRITE_UTILITY | 0x00000100, card->membase + CMD);	/* Sync UTOPIA with SAR clock */
+	NS_DELAY;
+
+	/* Detect PHY type */
+	while (CMD_BUSY(card)) ;
+	writel(NS_CMD_READ_UTILITY | 0x00000200, card->membase + CMD);
+	while (CMD_BUSY(card)) ;
+	data = readl(card->membase + DR0);
+	switch (data) {
+	case 0x00000009:
+		printk("nicstar%d: PHY seems to be 25 Mbps.\n", i);
+		card->max_pcr = ATM_25_PCR;
+		while (CMD_BUSY(card)) ;
+		writel(0x00000008, card->membase + DR0);
+		writel(NS_CMD_WRITE_UTILITY | 0x00000200, card->membase + CMD);
+		/* Clear an eventual pending interrupt */
+		writel(NS_STAT_SFBQF, card->membase + STAT);
 #ifdef PHY_LOOPBACK
-         while(CMD_BUSY(card));
-         writel(0x00000022, card->membase + DR0);
-         writel(NS_CMD_WRITE_UTILITY | 0x00000202, card->membase + CMD);
+		while (CMD_BUSY(card)) ;
+		writel(0x00000022, card->membase + DR0);
+		writel(NS_CMD_WRITE_UTILITY | 0x00000202, card->membase + CMD);
 #endif /* PHY_LOOPBACK */
-	 break;
-      case 0x00000030:
-      case 0x00000031:
-         printk("nicstar%d: PHY seems to be 155 Mbps.\n", i);
-         card->max_pcr = ATM_OC3_PCR;
+		break;
+	case 0x00000030:
+	case 0x00000031:
+		printk("nicstar%d: PHY seems to be 155 Mbps.\n", i);
+		card->max_pcr = ATM_OC3_PCR;
 #ifdef PHY_LOOPBACK
-         while(CMD_BUSY(card));
-         writel(0x00000002, card->membase + DR0);
-         writel(NS_CMD_WRITE_UTILITY | 0x00000205, card->membase + CMD);
+		while (CMD_BUSY(card)) ;
+		writel(0x00000002, card->membase + DR0);
+		writel(NS_CMD_WRITE_UTILITY | 0x00000205, card->membase + CMD);
 #endif /* PHY_LOOPBACK */
-	 break;
-      default:
-         printk("nicstar%d: unknown PHY type (0x%08X).\n", i, data);
-         error = 8;
-         ns_init_card_error(card, error);
-         return error;
-   }
-   writel(0x00000000, card->membase + GP);
-
-   /* Determine SRAM size */
-   data = 0x76543210;
-   ns_write_sram(card, 0x1C003, &data, 1);
-   data = 0x89ABCDEF;
-   ns_write_sram(card, 0x14003, &data, 1);
-   if (ns_read_sram(card, 0x14003) == 0x89ABCDEF &&
-       ns_read_sram(card, 0x1C003) == 0x76543210)
-       card->sram_size = 128;
-   else
-      card->sram_size = 32;
-   PRINTK("nicstar%d: %dK x 32bit SRAM size.\n", i, card->sram_size);
-
-   card->rct_size = NS_MAX_RCTSIZE;
+		break;
+	default:
+		printk("nicstar%d: unknown PHY type (0x%08X).\n", i, data);
+		error = 8;
+		ns_init_card_error(card, error);
+		return error;
+	}
+	writel(0x00000000, card->membase + GP);
+
+	/* Determine SRAM size */
+	data = 0x76543210;
+	ns_write_sram(card, 0x1C003, &data, 1);
+	data = 0x89ABCDEF;
+	ns_write_sram(card, 0x14003, &data, 1);
+	if (ns_read_sram(card, 0x14003) == 0x89ABCDEF &&
+	    ns_read_sram(card, 0x1C003) == 0x76543210)
+		card->sram_size = 128;
+	else
+		card->sram_size = 32;
+	PRINTK("nicstar%d: %dK x 32bit SRAM size.\n", i, card->sram_size);
+
+	card->rct_size = NS_MAX_RCTSIZE;
 
 #if (NS_MAX_RCTSIZE == 4096)
-   if (card->sram_size == 128)
-      printk("nicstar%d: limiting maximum VCI. See NS_MAX_RCTSIZE in nicstar.h\n", i);
+	if (card->sram_size == 128)
+		printk
+		    ("nicstar%d: limiting maximum VCI. See NS_MAX_RCTSIZE in nicstar.h\n",
+		     i);
 #elif (NS_MAX_RCTSIZE == 16384)
-   if (card->sram_size == 32)
-   {
-      printk("nicstar%d: wasting memory. See NS_MAX_RCTSIZE in nicstar.h\n", i);
-      card->rct_size = 4096;
-   }
+	if (card->sram_size == 32) {
+		printk
+		    ("nicstar%d: wasting memory. See NS_MAX_RCTSIZE in nicstar.h\n",
+		     i);
+		card->rct_size = 4096;
+	}
 #else
 #error NS_MAX_RCTSIZE must be either 4096 or 16384 in nicstar.c
 #endif
 
-   card->vpibits = NS_VPIBITS;
-   if (card->rct_size == 4096)
-      card->vcibits = 12 - NS_VPIBITS;
-   else /* card->rct_size == 16384 */
-      card->vcibits = 14 - NS_VPIBITS;
-
-   /* Initialize the nicstar eeprom/eprom stuff, for the MAC addr */
-   if (mac[i] == NULL)
-      nicstar_init_eprom(card->membase);
-
-   /* Set the VPI/VCI MSb mask to zero so we can receive OAM cells */
-   writel(0x00000000, card->membase + VPM);
-      
-   /* Initialize TSQ */
-   card->tsq.org = kmalloc(NS_TSQSIZE + NS_TSQ_ALIGNMENT, GFP_KERNEL);
-   if (card->tsq.org == NULL)
-   {
-      printk("nicstar%d: can't allocate TSQ.\n", i);
-      error = 10;
-      ns_init_card_error(card, error);
-      return error;
-   }
-   card->tsq.base = (ns_tsi *) ALIGN_ADDRESS(card->tsq.org, NS_TSQ_ALIGNMENT);
-   card->tsq.next = card->tsq.base;
-   card->tsq.last = card->tsq.base + (NS_TSQ_NUM_ENTRIES - 1);
-   for (j = 0; j < NS_TSQ_NUM_ENTRIES; j++)
-      ns_tsi_init(card->tsq.base + j);
-   writel(0x00000000, card->membase + TSQH);
-   writel((u32) virt_to_bus(card->tsq.base), card->membase + TSQB);
-   PRINTK("nicstar%d: TSQ base at 0x%x  0x%x  0x%x.\n", i, (u32) card->tsq.base,
-          (u32) virt_to_bus(card->tsq.base), readl(card->membase + TSQB));
-      
-   /* Initialize RSQ */
-   card->rsq.org = kmalloc(NS_RSQSIZE + NS_RSQ_ALIGNMENT, GFP_KERNEL);
-   if (card->rsq.org == NULL)
-   {
-      printk("nicstar%d: can't allocate RSQ.\n", i);
-      error = 11;
-      ns_init_card_error(card, error);
-      return error;
-   }
-   card->rsq.base = (ns_rsqe *) ALIGN_ADDRESS(card->rsq.org, NS_RSQ_ALIGNMENT);
-   card->rsq.next = card->rsq.base;
-   card->rsq.last = card->rsq.base + (NS_RSQ_NUM_ENTRIES - 1);
-   for (j = 0; j < NS_RSQ_NUM_ENTRIES; j++)
-      ns_rsqe_init(card->rsq.base + j);
-   writel(0x00000000, card->membase + RSQH);
-   writel((u32) virt_to_bus(card->rsq.base), card->membase + RSQB);
-   PRINTK("nicstar%d: RSQ base at 0x%x.\n", i, (u32) card->rsq.base);
-      
-   /* Initialize SCQ0, the only VBR SCQ used */
-   card->scq1 = NULL;
-   card->scq2 = NULL;
-   card->scq0 = get_scq(VBR_SCQSIZE, NS_VRSCD0);
-   if (card->scq0 == NULL)
-   {
-      printk("nicstar%d: can't get SCQ0.\n", i);
-      error = 12;
-      ns_init_card_error(card, error);
-      return error;
-   }
-   u32d[0] = (u32) virt_to_bus(card->scq0->base);
-   u32d[1] = (u32) 0x00000000;
-   u32d[2] = (u32) 0xffffffff;
-   u32d[3] = (u32) 0x00000000;
-   ns_write_sram(card, NS_VRSCD0, u32d, 4);
-   ns_write_sram(card, NS_VRSCD1, u32d, 4);	/* These last two won't be used */
-   ns_write_sram(card, NS_VRSCD2, u32d, 4);	/* but are initialized, just in case... */
-   card->scq0->scd = NS_VRSCD0;
-   PRINTK("nicstar%d: VBR-SCQ0 base at 0x%x.\n", i, (u32) card->scq0->base);
-
-   /* Initialize TSTs */
-   card->tst_addr = NS_TST0;
-   card->tst_free_entries = NS_TST_NUM_ENTRIES;
-   data = NS_TST_OPCODE_VARIABLE;
-   for (j = 0; j < NS_TST_NUM_ENTRIES; j++)
-      ns_write_sram(card, NS_TST0 + j, &data, 1);
-   data = ns_tste_make(NS_TST_OPCODE_END, NS_TST0);
-   ns_write_sram(card, NS_TST0 + NS_TST_NUM_ENTRIES, &data, 1);
-   for (j = 0; j < NS_TST_NUM_ENTRIES; j++)
-      ns_write_sram(card, NS_TST1 + j, &data, 1);
-   data = ns_tste_make(NS_TST_OPCODE_END, NS_TST1);
-   ns_write_sram(card, NS_TST1 + NS_TST_NUM_ENTRIES, &data, 1);
-   for (j = 0; j < NS_TST_NUM_ENTRIES; j++)
-      card->tste2vc[j] = NULL;
-   writel(NS_TST0 << 2, card->membase + TSTB);
-
-
-   /* Initialize RCT. AAL type is set on opening the VC. */
+	card->vpibits = NS_VPIBITS;
+	if (card->rct_size == 4096)
+		card->vcibits = 12 - NS_VPIBITS;
+	else			/* card->rct_size == 16384 */
+		card->vcibits = 14 - NS_VPIBITS;
+
+	/* Initialize the nicstar eeprom/eprom stuff, for the MAC addr */
+	if (mac[i] == NULL)
+		nicstar_init_eprom(card->membase);
+
+	/* Set the VPI/VCI MSb mask to zero so we can receive OAM cells */
+	writel(0x00000000, card->membase + VPM);
+
+	/* Initialize TSQ */
+	card->tsq.org = kmalloc(NS_TSQSIZE + NS_TSQ_ALIGNMENT, GFP_KERNEL);
+	if (card->tsq.org == NULL) {
+		printk("nicstar%d: can't allocate TSQ.\n", i);
+		error = 10;
+		ns_init_card_error(card, error);
+		return error;
+	}
+	card->tsq.base =
+	    (ns_tsi *) ALIGN_ADDRESS(card->tsq.org, NS_TSQ_ALIGNMENT);
+	card->tsq.next = card->tsq.base;
+	card->tsq.last = card->tsq.base + (NS_TSQ_NUM_ENTRIES - 1);
+	for (j = 0; j < NS_TSQ_NUM_ENTRIES; j++)
+		ns_tsi_init(card->tsq.base + j);
+	writel(0x00000000, card->membase + TSQH);
+	writel((u32) virt_to_bus(card->tsq.base), card->membase + TSQB);
+	PRINTK("nicstar%d: TSQ base at 0x%x  0x%x  0x%x.\n", i,
+	       (u32) card->tsq.base, (u32) virt_to_bus(card->tsq.base),
+	       readl(card->membase + TSQB));
+
+	/* Initialize RSQ */
+	card->rsq.org = kmalloc(NS_RSQSIZE + NS_RSQ_ALIGNMENT, GFP_KERNEL);
+	if (card->rsq.org == NULL) {
+		printk("nicstar%d: can't allocate RSQ.\n", i);
+		error = 11;
+		ns_init_card_error(card, error);
+		return error;
+	}
+	card->rsq.base =
+	    (ns_rsqe *) ALIGN_ADDRESS(card->rsq.org, NS_RSQ_ALIGNMENT);
+	card->rsq.next = card->rsq.base;
+	card->rsq.last = card->rsq.base + (NS_RSQ_NUM_ENTRIES - 1);
+	for (j = 0; j < NS_RSQ_NUM_ENTRIES; j++)
+		ns_rsqe_init(card->rsq.base + j);
+	writel(0x00000000, card->membase + RSQH);
+	writel((u32) virt_to_bus(card->rsq.base), card->membase + RSQB);
+	PRINTK("nicstar%d: RSQ base at 0x%x.\n", i, (u32) card->rsq.base);
+
+	/* Initialize SCQ0, the only VBR SCQ used */
+	card->scq1 = NULL;
+	card->scq2 = NULL;
+	card->scq0 = get_scq(VBR_SCQSIZE, NS_VRSCD0);
+	if (card->scq0 == NULL) {
+		printk("nicstar%d: can't get SCQ0.\n", i);
+		error = 12;
+		ns_init_card_error(card, error);
+		return error;
+	}
+	u32d[0] = (u32) virt_to_bus(card->scq0->base);
+	u32d[1] = (u32) 0x00000000;
+	u32d[2] = (u32) 0xffffffff;
+	u32d[3] = (u32) 0x00000000;
+	ns_write_sram(card, NS_VRSCD0, u32d, 4);
+	ns_write_sram(card, NS_VRSCD1, u32d, 4);	/* These last two won't be used */
+	ns_write_sram(card, NS_VRSCD2, u32d, 4);	/* but are initialized, just in case... */
+	card->scq0->scd = NS_VRSCD0;
+	PRINTK("nicstar%d: VBR-SCQ0 base at 0x%x.\n", i,
+	       (u32) card->scq0->base);
+
+	/* Initialize TSTs */
+	card->tst_addr = NS_TST0;
+	card->tst_free_entries = NS_TST_NUM_ENTRIES;
+	data = NS_TST_OPCODE_VARIABLE;
+	for (j = 0; j < NS_TST_NUM_ENTRIES; j++)
+		ns_write_sram(card, NS_TST0 + j, &data, 1);
+	data = ns_tste_make(NS_TST_OPCODE_END, NS_TST0);
+	ns_write_sram(card, NS_TST0 + NS_TST_NUM_ENTRIES, &data, 1);
+	for (j = 0; j < NS_TST_NUM_ENTRIES; j++)
+		ns_write_sram(card, NS_TST1 + j, &data, 1);
+	data = ns_tste_make(NS_TST_OPCODE_END, NS_TST1);
+	ns_write_sram(card, NS_TST1 + NS_TST_NUM_ENTRIES, &data, 1);
+	for (j = 0; j < NS_TST_NUM_ENTRIES; j++)
+		card->tste2vc[j] = NULL;
+	writel(NS_TST0 << 2, card->membase + TSTB);
+
+	/* Initialize RCT. AAL type is set on opening the VC. */
 #ifdef RCQ_SUPPORT
-   u32d[0] = NS_RCTE_RAWCELLINTEN;
+	u32d[0] = NS_RCTE_RAWCELLINTEN;
 #else
-   u32d[0] = 0x00000000;
+	u32d[0] = 0x00000000;
 #endif /* RCQ_SUPPORT */
-   u32d[1] = 0x00000000;
-   u32d[2] = 0x00000000;
-   u32d[3] = 0xFFFFFFFF;
-   for (j = 0; j < card->rct_size; j++)
-      ns_write_sram(card, j * 4, u32d, 4);      
-      
-   memset(card->vcmap, 0, NS_MAX_RCTSIZE * sizeof(vc_map));
-      
-   for (j = 0; j < NS_FRSCD_NUM; j++)
-      card->scd2vc[j] = NULL;
-
-   /* Initialize buffer levels */
-   card->sbnr.min = MIN_SB;
-   card->sbnr.init = NUM_SB;
-   card->sbnr.max = MAX_SB;
-   card->lbnr.min = MIN_LB;
-   card->lbnr.init = NUM_LB;
-   card->lbnr.max = MAX_LB;
-   card->iovnr.min = MIN_IOVB;
-   card->iovnr.init = NUM_IOVB;
-   card->iovnr.max = MAX_IOVB;
-   card->hbnr.min = MIN_HB;
-   card->hbnr.init = NUM_HB;
-   card->hbnr.max = MAX_HB;
-   
-   card->sm_handle = 0x00000000;
-   card->sm_addr = 0x00000000;
-   card->lg_handle = 0x00000000;
-   card->lg_addr = 0x00000000;
-   
-   card->efbie = 1;	/* To prevent push_rxbufs from enabling the interrupt */
-
-   /* Pre-allocate some huge buffers */
-   skb_queue_head_init(&card->hbpool.queue);
-   card->hbpool.count = 0;
-   for (j = 0; j < NUM_HB; j++)
-   {
-      struct sk_buff *hb;
-      hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
-      if (hb == NULL)
-      {
-         printk("nicstar%d: can't allocate %dth of %d huge buffers.\n",
-                i, j, NUM_HB);
-         error = 13;
-         ns_init_card_error(card, error);
-	 return error;
-      }
-      NS_SKB_CB(hb)->buf_type = BUF_NONE;
-      skb_queue_tail(&card->hbpool.queue, hb);
-      card->hbpool.count++;
-   }
-
-
-   /* Allocate large buffers */
-   skb_queue_head_init(&card->lbpool.queue);
-   card->lbpool.count = 0;			/* Not used */
-   for (j = 0; j < NUM_LB; j++)
-   {
-      struct sk_buff *lb;
-      lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
-      if (lb == NULL)
-      {
-         printk("nicstar%d: can't allocate %dth of %d large buffers.\n",
-                i, j, NUM_LB);
-         error = 14;
-         ns_init_card_error(card, error);
-	 return error;
-      }
-      NS_SKB_CB(lb)->buf_type = BUF_LG;
-      skb_queue_tail(&card->lbpool.queue, lb);
-      skb_reserve(lb, NS_SMBUFSIZE);
-      push_rxbufs(card, lb);
-      /* Due to the implementation of push_rxbufs() this is 1, not 0 */
-      if (j == 1)
-      {
-         card->rcbuf = lb;
-         card->rawch = (u32) virt_to_bus(lb->data);
-      }
-   }
-   /* Test for strange behaviour which leads to crashes */
-   if ((bcount = ns_stat_lfbqc_get(readl(card->membase + STAT))) < card->lbnr.min)
-   {
-      printk("nicstar%d: Strange... Just allocated %d large buffers and lfbqc = %d.\n",
-             i, j, bcount);
-      error = 14;
-      ns_init_card_error(card, error);
-      return error;
-   }
-      
-
-   /* Allocate small buffers */
-   skb_queue_head_init(&card->sbpool.queue);
-   card->sbpool.count = 0;			/* Not used */
-   for (j = 0; j < NUM_SB; j++)
-   {
-      struct sk_buff *sb;
-      sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
-      if (sb == NULL)
-      {
-         printk("nicstar%d: can't allocate %dth of %d small buffers.\n",
-                i, j, NUM_SB);
-         error = 15;
-         ns_init_card_error(card, error);
-	 return error;
-      }
-      NS_SKB_CB(sb)->buf_type = BUF_SM;
-      skb_queue_tail(&card->sbpool.queue, sb);
-      skb_reserve(sb, NS_AAL0_HEADER);
-      push_rxbufs(card, sb);
-   }
-   /* Test for strange behaviour which leads to crashes */
-   if ((bcount = ns_stat_sfbqc_get(readl(card->membase + STAT))) < card->sbnr.min)
-   {
-      printk("nicstar%d: Strange... Just allocated %d small buffers and sfbqc = %d.\n",
-             i, j, bcount);
-      error = 15;
-      ns_init_card_error(card, error);
-      return error;
-   }
-      
-
-   /* Allocate iovec buffers */
-   skb_queue_head_init(&card->iovpool.queue);
-   card->iovpool.count = 0;
-   for (j = 0; j < NUM_IOVB; j++)
-   {
-      struct sk_buff *iovb;
-      iovb = alloc_skb(NS_IOVBUFSIZE, GFP_KERNEL);
-      if (iovb == NULL)
-      {
-         printk("nicstar%d: can't allocate %dth of %d iovec buffers.\n",
-                i, j, NUM_IOVB);
-         error = 16;
-         ns_init_card_error(card, error);
-	 return error;
-      }
-      NS_SKB_CB(iovb)->buf_type = BUF_NONE;
-      skb_queue_tail(&card->iovpool.queue, iovb);
-      card->iovpool.count++;
-   }
-
-   /* Configure NICStAR */
-   if (card->rct_size == 4096)
-      ns_cfg_rctsize = NS_CFG_RCTSIZE_4096_ENTRIES;
-   else /* (card->rct_size == 16384) */
-      ns_cfg_rctsize = NS_CFG_RCTSIZE_16384_ENTRIES;
-
-   card->efbie = 1;
-
-   card->intcnt = 0;
-   if (request_irq(pcidev->irq, &ns_irq_handler, IRQF_DISABLED | IRQF_SHARED, "nicstar", card) != 0)
-   {
-      printk("nicstar%d: can't allocate IRQ %d.\n", i, pcidev->irq);
-      error = 9;
-      ns_init_card_error(card, error);
-      return error;
-   }
-
-   /* Register device */
-   card->atmdev = atm_dev_register("nicstar", &atm_ops, -1, NULL);
-   if (card->atmdev == NULL)
-   {
-      printk("nicstar%d: can't register device.\n", i);
-      error = 17;
-      ns_init_card_error(card, error);
-      return error;
-   }
-      
-   if (ns_parse_mac(mac[i], card->atmdev->esi)) {
-      nicstar_read_eprom(card->membase, NICSTAR_EPROM_MAC_ADDR_OFFSET,
-                         card->atmdev->esi, 6);
-      if (memcmp(card->atmdev->esi, "\x00\x00\x00\x00\x00\x00", 6) == 0) {
-         nicstar_read_eprom(card->membase, NICSTAR_EPROM_MAC_ADDR_OFFSET_ALT,
-                         card->atmdev->esi, 6);
-      }
-   }
-
-   printk("nicstar%d: MAC address %pM\n", i, card->atmdev->esi);
-
-   card->atmdev->dev_data = card;
-   card->atmdev->ci_range.vpi_bits = card->vpibits;
-   card->atmdev->ci_range.vci_bits = card->vcibits;
-   card->atmdev->link_rate = card->max_pcr;
-   card->atmdev->phy = NULL;
+	u32d[1] = 0x00000000;
+	u32d[2] = 0x00000000;
+	u32d[3] = 0xFFFFFFFF;
+	for (j = 0; j < card->rct_size; j++)
+		ns_write_sram(card, j * 4, u32d, 4);
+
+	memset(card->vcmap, 0, NS_MAX_RCTSIZE * sizeof(vc_map));
+
+	for (j = 0; j < NS_FRSCD_NUM; j++)
+		card->scd2vc[j] = NULL;
+
+	/* Initialize buffer levels */
+	card->sbnr.min = MIN_SB;
+	card->sbnr.init = NUM_SB;
+	card->sbnr.max = MAX_SB;
+	card->lbnr.min = MIN_LB;
+	card->lbnr.init = NUM_LB;
+	card->lbnr.max = MAX_LB;
+	card->iovnr.min = MIN_IOVB;
+	card->iovnr.init = NUM_IOVB;
+	card->iovnr.max = MAX_IOVB;
+	card->hbnr.min = MIN_HB;
+	card->hbnr.init = NUM_HB;
+	card->hbnr.max = MAX_HB;
+
+	card->sm_handle = 0x00000000;
+	card->sm_addr = 0x00000000;
+	card->lg_handle = 0x00000000;
+	card->lg_addr = 0x00000000;
+
+	card->efbie = 1;	/* To prevent push_rxbufs from enabling the interrupt */
+
+	/* Pre-allocate some huge buffers */
+	skb_queue_head_init(&card->hbpool.queue);
+	card->hbpool.count = 0;
+	for (j = 0; j < NUM_HB; j++) {
+		struct sk_buff *hb;
+		hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
+		if (hb == NULL) {
+			printk
+			    ("nicstar%d: can't allocate %dth of %d huge buffers.\n",
+			     i, j, NUM_HB);
+			error = 13;
+			ns_init_card_error(card, error);
+			return error;
+		}
+		NS_SKB_CB(hb)->buf_type = BUF_NONE;
+		skb_queue_tail(&card->hbpool.queue, hb);
+		card->hbpool.count++;
+	}
+
+	/* Allocate large buffers */
+	skb_queue_head_init(&card->lbpool.queue);
+	card->lbpool.count = 0;	/* Not used */
+	for (j = 0; j < NUM_LB; j++) {
+		struct sk_buff *lb;
+		lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
+		if (lb == NULL) {
+			printk
+			    ("nicstar%d: can't allocate %dth of %d large buffers.\n",
+			     i, j, NUM_LB);
+			error = 14;
+			ns_init_card_error(card, error);
+			return error;
+		}
+		NS_SKB_CB(lb)->buf_type = BUF_LG;
+		skb_queue_tail(&card->lbpool.queue, lb);
+		skb_reserve(lb, NS_SMBUFSIZE);
+		push_rxbufs(card, lb);
+		/* Due to the implementation of push_rxbufs() this is 1, not 0 */
+		if (j == 1) {
+			card->rcbuf = lb;
+			card->rawch = (u32) virt_to_bus(lb->data);
+		}
+	}
+	/* Test for strange behaviour which leads to crashes */
+	if ((bcount =
+	     ns_stat_lfbqc_get(readl(card->membase + STAT))) < card->lbnr.min) {
+		printk
+		    ("nicstar%d: Strange... Just allocated %d large buffers and lfbqc = %d.\n",
+		     i, j, bcount);
+		error = 14;
+		ns_init_card_error(card, error);
+		return error;
+	}
+
+	/* Allocate small buffers */
+	skb_queue_head_init(&card->sbpool.queue);
+	card->sbpool.count = 0;	/* Not used */
+	for (j = 0; j < NUM_SB; j++) {
+		struct sk_buff *sb;
+		sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
+		if (sb == NULL) {
+			printk
+			    ("nicstar%d: can't allocate %dth of %d small buffers.\n",
+			     i, j, NUM_SB);
+			error = 15;
+			ns_init_card_error(card, error);
+			return error;
+		}
+		NS_SKB_CB(sb)->buf_type = BUF_SM;
+		skb_queue_tail(&card->sbpool.queue, sb);
+		skb_reserve(sb, NS_AAL0_HEADER);
+		push_rxbufs(card, sb);
+	}
+	/* Test for strange behaviour which leads to crashes */
+	if ((bcount =
+	     ns_stat_sfbqc_get(readl(card->membase + STAT))) < card->sbnr.min) {
+		printk
+		    ("nicstar%d: Strange... Just allocated %d small buffers and sfbqc = %d.\n",
+		     i, j, bcount);
+		error = 15;
+		ns_init_card_error(card, error);
+		return error;
+	}
+
+	/* Allocate iovec buffers */
+	skb_queue_head_init(&card->iovpool.queue);
+	card->iovpool.count = 0;
+	for (j = 0; j < NUM_IOVB; j++) {
+		struct sk_buff *iovb;
+		iovb = alloc_skb(NS_IOVBUFSIZE, GFP_KERNEL);
+		if (iovb == NULL) {
+			printk
+			    ("nicstar%d: can't allocate %dth of %d iovec buffers.\n",
+			     i, j, NUM_IOVB);
+			error = 16;
+			ns_init_card_error(card, error);
+			return error;
+		}
+		NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+		skb_queue_tail(&card->iovpool.queue, iovb);
+		card->iovpool.count++;
+	}
+
+	/* Configure NICStAR */
+	if (card->rct_size == 4096)
+		ns_cfg_rctsize = NS_CFG_RCTSIZE_4096_ENTRIES;
+	else			/* (card->rct_size == 16384) */
+		ns_cfg_rctsize = NS_CFG_RCTSIZE_16384_ENTRIES;
+
+	card->efbie = 1;
+
+	card->intcnt = 0;
+	if (request_irq
+	    (pcidev->irq, &ns_irq_handler, IRQF_DISABLED | IRQF_SHARED,
+	     "nicstar", card) != 0) {
+		printk("nicstar%d: can't allocate IRQ %d.\n", i, pcidev->irq);
+		error = 9;
+		ns_init_card_error(card, error);
+		return error;
+	}
+
+	/* Register device */
+	card->atmdev = atm_dev_register("nicstar", &atm_ops, -1, NULL);
+	if (card->atmdev == NULL) {
+		printk("nicstar%d: can't register device.\n", i);
+		error = 17;
+		ns_init_card_error(card, error);
+		return error;
+	}
+
+	if (ns_parse_mac(mac[i], card->atmdev->esi)) {
+		nicstar_read_eprom(card->membase, NICSTAR_EPROM_MAC_ADDR_OFFSET,
+				   card->atmdev->esi, 6);
+		if (memcmp(card->atmdev->esi, "\x00\x00\x00\x00\x00\x00", 6) ==
+		    0) {
+			nicstar_read_eprom(card->membase,
+					   NICSTAR_EPROM_MAC_ADDR_OFFSET_ALT,
+					   card->atmdev->esi, 6);
+		}
+	}
+
+	printk("nicstar%d: MAC address %pM\n", i, card->atmdev->esi);
+
+	card->atmdev->dev_data = card;
+	card->atmdev->ci_range.vpi_bits = card->vpibits;
+	card->atmdev->ci_range.vci_bits = card->vcibits;
+	card->atmdev->link_rate = card->max_pcr;
+	card->atmdev->phy = NULL;
 
 #ifdef CONFIG_ATM_NICSTAR_USE_SUNI
-   if (card->max_pcr == ATM_OC3_PCR)
-      suni_init(card->atmdev);
+	if (card->max_pcr == ATM_OC3_PCR)
+		suni_init(card->atmdev);
 #endif /* CONFIG_ATM_NICSTAR_USE_SUNI */
 
 #ifdef CONFIG_ATM_NICSTAR_USE_IDT77105
-   if (card->max_pcr == ATM_25_PCR)
-      idt77105_init(card->atmdev);
+	if (card->max_pcr == ATM_25_PCR)
+		idt77105_init(card->atmdev);
 #endif /* CONFIG_ATM_NICSTAR_USE_IDT77105 */
 
-   if (card->atmdev->phy && card->atmdev->phy->start)
-      card->atmdev->phy->start(card->atmdev);
-
-   writel(NS_CFG_RXPATH |
-          NS_CFG_SMBUFSIZE |
-          NS_CFG_LGBUFSIZE |
-          NS_CFG_EFBIE |
-          NS_CFG_RSQSIZE |
-          NS_CFG_VPIBITS |
-          ns_cfg_rctsize |
-          NS_CFG_RXINT_NODELAY |
-          NS_CFG_RAWIE |		/* Only enabled if RCQ_SUPPORT */
-          NS_CFG_RSQAFIE |
-          NS_CFG_TXEN |
-          NS_CFG_TXIE |
-          NS_CFG_TSQFIE_OPT |		/* Only enabled if ENABLE_TSQFIE */ 
-          NS_CFG_PHYIE,
-          card->membase + CFG);
-
-   num_cards++;
-
-   return error;
-}
+	if (card->atmdev->phy && card->atmdev->phy->start)
+		card->atmdev->phy->start(card->atmdev);
 
+	writel(NS_CFG_RXPATH | NS_CFG_SMBUFSIZE | NS_CFG_LGBUFSIZE | NS_CFG_EFBIE | NS_CFG_RSQSIZE | NS_CFG_VPIBITS | ns_cfg_rctsize | NS_CFG_RXINT_NODELAY | NS_CFG_RAWIE |	/* Only enabled if RCQ_SUPPORT */
+	       NS_CFG_RSQAFIE | NS_CFG_TXEN | NS_CFG_TXIE | NS_CFG_TSQFIE_OPT |	/* Only enabled if ENABLE_TSQFIE */
+	       NS_CFG_PHYIE, card->membase + CFG);
 
+	num_cards++;
 
-static void __devinit ns_init_card_error(ns_dev *card, int error)
-{
-   if (error >= 17)
-   {
-      writel(0x00000000, card->membase + CFG);
-   }
-   if (error >= 16)
-   {
-      struct sk_buff *iovb;
-      while ((iovb = skb_dequeue(&card->iovpool.queue)) != NULL)
-         dev_kfree_skb_any(iovb);
-   }
-   if (error >= 15)
-   {
-      struct sk_buff *sb;
-      while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
-         dev_kfree_skb_any(sb);
-      free_scq(card->scq0, NULL);
-   }
-   if (error >= 14)
-   {
-      struct sk_buff *lb;
-      while ((lb = skb_dequeue(&card->lbpool.queue)) != NULL)
-         dev_kfree_skb_any(lb);
-   }
-   if (error >= 13)
-   {
-      struct sk_buff *hb;
-      while ((hb = skb_dequeue(&card->hbpool.queue)) != NULL)
-         dev_kfree_skb_any(hb);
-   }
-   if (error >= 12)
-   {
-      kfree(card->rsq.org);
-   }
-   if (error >= 11)
-   {
-      kfree(card->tsq.org);
-   }
-   if (error >= 10)
-   {
-      free_irq(card->pcidev->irq, card);
-   }
-   if (error >= 4)
-   {
-      iounmap(card->membase);
-   }
-   if (error >= 3)
-   {
-      pci_disable_device(card->pcidev);
-      kfree(card);
-   }
+	return error;
 }
 
-
+static void __devinit ns_init_card_error(ns_dev * card, int error)
+{
+	if (error >= 17) {
+		writel(0x00000000, card->membase + CFG);
+	}
+	if (error >= 16) {
+		struct sk_buff *iovb;
+		while ((iovb = skb_dequeue(&card->iovpool.queue)) != NULL)
+			dev_kfree_skb_any(iovb);
+	}
+	if (error >= 15) {
+		struct sk_buff *sb;
+		while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
+			dev_kfree_skb_any(sb);
+		free_scq(card->scq0, NULL);
+	}
+	if (error >= 14) {
+		struct sk_buff *lb;
+		while ((lb = skb_dequeue(&card->lbpool.queue)) != NULL)
+			dev_kfree_skb_any(lb);
+	}
+	if (error >= 13) {
+		struct sk_buff *hb;
+		while ((hb = skb_dequeue(&card->hbpool.queue)) != NULL)
+			dev_kfree_skb_any(hb);
+	}
+	if (error >= 12) {
+		kfree(card->rsq.org);
+	}
+	if (error >= 11) {
+		kfree(card->tsq.org);
+	}
+	if (error >= 10) {
+		free_irq(card->pcidev->irq, card);
+	}
+	if (error >= 4) {
+		iounmap(card->membase);
+	}
+	if (error >= 3) {
+		pci_disable_device(card->pcidev);
+		kfree(card);
+	}
+}
 
 static scq_info *get_scq(int size, u32 scd)
 {
-   scq_info *scq;
-   int i;
-
-   if (size != VBR_SCQSIZE && size != CBR_SCQSIZE)
-      return NULL;
-
-   scq = kmalloc(sizeof(scq_info), GFP_KERNEL);
-   if (scq == NULL)
-      return NULL;
-   scq->org = kmalloc(2 * size, GFP_KERNEL);
-   if (scq->org == NULL)
-   {
-      kfree(scq);
-      return NULL;
-   }
-   scq->skb = kmalloc(sizeof(struct sk_buff *) *
-                                          (size / NS_SCQE_SIZE), GFP_KERNEL);
-   if (scq->skb == NULL)
-   {
-      kfree(scq->org);
-      kfree(scq);
-      return NULL;
-   }
-   scq->num_entries = size / NS_SCQE_SIZE;
-   scq->base = (ns_scqe *) ALIGN_ADDRESS(scq->org, size);
-   scq->next = scq->base;
-   scq->last = scq->base + (scq->num_entries - 1);
-   scq->tail = scq->last;
-   scq->scd = scd;
-   scq->num_entries = size / NS_SCQE_SIZE;
-   scq->tbd_count = 0;
-   init_waitqueue_head(&scq->scqfull_waitq);
-   scq->full = 0;
-   spin_lock_init(&scq->lock);
-
-   for (i = 0; i < scq->num_entries; i++)
-      scq->skb[i] = NULL;
-
-   return scq;
+	scq_info *scq;
+	int i;
+
+	if (size != VBR_SCQSIZE && size != CBR_SCQSIZE)
+		return NULL;
+
+	scq = kmalloc(sizeof(scq_info), GFP_KERNEL);
+	if (scq == NULL)
+		return NULL;
+	scq->org = kmalloc(2 * size, GFP_KERNEL);
+	if (scq->org == NULL) {
+		kfree(scq);
+		return NULL;
+	}
+	scq->skb = kmalloc(sizeof(struct sk_buff *) *
+			   (size / NS_SCQE_SIZE), GFP_KERNEL);
+	if (scq->skb == NULL) {
+		kfree(scq->org);
+		kfree(scq);
+		return NULL;
+	}
+	scq->num_entries = size / NS_SCQE_SIZE;
+	scq->base = (ns_scqe *) ALIGN_ADDRESS(scq->org, size);
+	scq->next = scq->base;
+	scq->last = scq->base + (scq->num_entries - 1);
+	scq->tail = scq->last;
+	scq->scd = scd;
+	scq->num_entries = size / NS_SCQE_SIZE;
+	scq->tbd_count = 0;
+	init_waitqueue_head(&scq->scqfull_waitq);
+	scq->full = 0;
+	spin_lock_init(&scq->lock);
+
+	for (i = 0; i < scq->num_entries; i++)
+		scq->skb[i] = NULL;
+
+	return scq;
 }
 
-
-
 /* For variable rate SCQ vcc must be NULL */
-static void free_scq(scq_info *scq, struct atm_vcc *vcc)
+static void free_scq(scq_info * scq, struct atm_vcc *vcc)
 {
-   int i;
-
-   if (scq->num_entries == VBR_SCQ_NUM_ENTRIES)
-      for (i = 0; i < scq->num_entries; i++)
-      {
-         if (scq->skb[i] != NULL)
-	 {
-            vcc = ATM_SKB(scq->skb[i])->vcc;
-            if (vcc->pop != NULL)
-	       vcc->pop(vcc, scq->skb[i]);
-	    else
-               dev_kfree_skb_any(scq->skb[i]);
-         }
-      }
-   else /* vcc must be != NULL */
-   {
-      if (vcc == NULL)
-      {
-         printk("nicstar: free_scq() called with vcc == NULL for fixed rate scq.");
-         for (i = 0; i < scq->num_entries; i++)
-            dev_kfree_skb_any(scq->skb[i]);
-      }
-      else
-         for (i = 0; i < scq->num_entries; i++)
-         {
-            if (scq->skb[i] != NULL)
-            {
-               if (vcc->pop != NULL)
-                  vcc->pop(vcc, scq->skb[i]);
-               else
-                  dev_kfree_skb_any(scq->skb[i]);
-            }
-         }
-   }
-   kfree(scq->skb);
-   kfree(scq->org);
-   kfree(scq);
+	int i;
+
+	if (scq->num_entries == VBR_SCQ_NUM_ENTRIES)
+		for (i = 0; i < scq->num_entries; i++) {
+			if (scq->skb[i] != NULL) {
+				vcc = ATM_SKB(scq->skb[i])->vcc;
+				if (vcc->pop != NULL)
+					vcc->pop(vcc, scq->skb[i]);
+				else
+					dev_kfree_skb_any(scq->skb[i]);
+			}
+	} else {		/* vcc must be != NULL */
+
+		if (vcc == NULL) {
+			printk
+			    ("nicstar: free_scq() called with vcc == NULL for fixed rate scq.");
+			for (i = 0; i < scq->num_entries; i++)
+				dev_kfree_skb_any(scq->skb[i]);
+		} else
+			for (i = 0; i < scq->num_entries; i++) {
+				if (scq->skb[i] != NULL) {
+					if (vcc->pop != NULL)
+						vcc->pop(vcc, scq->skb[i]);
+					else
+						dev_kfree_skb_any(scq->skb[i]);
+				}
+			}
+	}
+	kfree(scq->skb);
+	kfree(scq->org);
+	kfree(scq);
 }
 
-
-
 /* The handles passed must be pointers to the sk_buff containing the small
    or large buffer(s) cast to u32. */
-static void push_rxbufs(ns_dev *card, struct sk_buff *skb)
+static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 {
-   struct ns_skb_cb *cb = NS_SKB_CB(skb);
-   u32 handle1, addr1;
-   u32 handle2, addr2;
-   u32 stat;
-   unsigned long flags;
-   
-   /* *BARF* */
-   handle2 = addr2 = 0;
-   handle1 = (u32)skb;
-   addr1 = (u32)virt_to_bus(skb->data);
+	struct ns_skb_cb *cb = NS_SKB_CB(skb);
+	u32 handle1, addr1;
+	u32 handle2, addr2;
+	u32 stat;
+	unsigned long flags;
+
+	/* *BARF* */
+	handle2 = addr2 = 0;
+	handle1 = (u32) skb;
+	addr1 = (u32) virt_to_bus(skb->data);
 
 #ifdef GENERAL_DEBUG
-   if (!addr1)
-      printk("nicstar%d: push_rxbufs called with addr1 = 0.\n", card->index);
+	if (!addr1)
+		printk("nicstar%d: push_rxbufs called with addr1 = 0.\n",
+		       card->index);
 #endif /* GENERAL_DEBUG */
 
-   stat = readl(card->membase + STAT);
-   card->sbfqc = ns_stat_sfbqc_get(stat);
-   card->lbfqc = ns_stat_lfbqc_get(stat);
-   if (cb->buf_type == BUF_SM)
-   {
-      if (!addr2)
-      {
-         if (card->sm_addr)
-	 {
-	    addr2 = card->sm_addr;
-	    handle2 = card->sm_handle;
-	    card->sm_addr = 0x00000000;
-	    card->sm_handle = 0x00000000;
-	 }
-	 else /* (!sm_addr) */
-	 {
-	    card->sm_addr = addr1;
-	    card->sm_handle = handle1;
-	 }
-      }      
-   }
-   else /* buf_type == BUF_LG */
-   {
-      if (!addr2)
-      {
-         if (card->lg_addr)
-	 {
-	    addr2 = card->lg_addr;
-	    handle2 = card->lg_handle;
-	    card->lg_addr = 0x00000000;
-	    card->lg_handle = 0x00000000;
-	 }
-	 else /* (!lg_addr) */
-	 {
-	    card->lg_addr = addr1;
-	    card->lg_handle = handle1;
-	 }
-      }      
-   }
-
-   if (addr2)
-   {
-      if (cb->buf_type == BUF_SM)
-      {
-         if (card->sbfqc >= card->sbnr.max)
-         {
-            skb_unlink((struct sk_buff *) handle1, &card->sbpool.queue);
-            dev_kfree_skb_any((struct sk_buff *) handle1);
-            skb_unlink((struct sk_buff *) handle2, &card->sbpool.queue);
-            dev_kfree_skb_any((struct sk_buff *) handle2);
-            return;
-         }
-	 else
-            card->sbfqc += 2;
-      }
-      else /* (buf_type == BUF_LG) */
-      {
-         if (card->lbfqc >= card->lbnr.max)
-         {
-            skb_unlink((struct sk_buff *) handle1, &card->lbpool.queue);
-            dev_kfree_skb_any((struct sk_buff *) handle1);
-            skb_unlink((struct sk_buff *) handle2, &card->lbpool.queue);
-            dev_kfree_skb_any((struct sk_buff *) handle2);
-            return;
-         }
-         else
-            card->lbfqc += 2;
-      }
-
-      spin_lock_irqsave(&card->res_lock, flags);
-
-      while (CMD_BUSY(card));
-      writel(addr2, card->membase + DR3);
-      writel(handle2, card->membase + DR2);
-      writel(addr1, card->membase + DR1);
-      writel(handle1, card->membase + DR0);
-      writel(NS_CMD_WRITE_FREEBUFQ | cb->buf_type, card->membase + CMD);
- 
-      spin_unlock_irqrestore(&card->res_lock, flags);
-
-      XPRINTK("nicstar%d: Pushing %s buffers at 0x%x and 0x%x.\n", card->index,
-              (cb->buf_type == BUF_SM ? "small" : "large"), addr1, addr2);
-   }
-
-   if (!card->efbie && card->sbfqc >= card->sbnr.min &&
-       card->lbfqc >= card->lbnr.min)
-   {
-      card->efbie = 1;
-      writel((readl(card->membase + CFG) | NS_CFG_EFBIE), card->membase + CFG);
-   }
-
-   return;
+	stat = readl(card->membase + STAT);
+	card->sbfqc = ns_stat_sfbqc_get(stat);
+	card->lbfqc = ns_stat_lfbqc_get(stat);
+	if (cb->buf_type == BUF_SM) {
+		if (!addr2) {
+			if (card->sm_addr) {
+				addr2 = card->sm_addr;
+				handle2 = card->sm_handle;
+				card->sm_addr = 0x00000000;
+				card->sm_handle = 0x00000000;
+			} else {	/* (!sm_addr) */
+
+				card->sm_addr = addr1;
+				card->sm_handle = handle1;
+			}
+		}
+	} else {		/* buf_type == BUF_LG */
+
+		if (!addr2) {
+			if (card->lg_addr) {
+				addr2 = card->lg_addr;
+				handle2 = card->lg_handle;
+				card->lg_addr = 0x00000000;
+				card->lg_handle = 0x00000000;
+			} else {	/* (!lg_addr) */
+
+				card->lg_addr = addr1;
+				card->lg_handle = handle1;
+			}
+		}
+	}
+
+	if (addr2) {
+		if (cb->buf_type == BUF_SM) {
+			if (card->sbfqc >= card->sbnr.max) {
+				skb_unlink((struct sk_buff *)handle1,
+					   &card->sbpool.queue);
+				dev_kfree_skb_any((struct sk_buff *)handle1);
+				skb_unlink((struct sk_buff *)handle2,
+					   &card->sbpool.queue);
+				dev_kfree_skb_any((struct sk_buff *)handle2);
+				return;
+			} else
+				card->sbfqc += 2;
+		} else {	/* (buf_type == BUF_LG) */
+
+			if (card->lbfqc >= card->lbnr.max) {
+				skb_unlink((struct sk_buff *)handle1,
+					   &card->lbpool.queue);
+				dev_kfree_skb_any((struct sk_buff *)handle1);
+				skb_unlink((struct sk_buff *)handle2,
+					   &card->lbpool.queue);
+				dev_kfree_skb_any((struct sk_buff *)handle2);
+				return;
+			} else
+				card->lbfqc += 2;
+		}
+
+		spin_lock_irqsave(&card->res_lock, flags);
+
+		while (CMD_BUSY(card)) ;
+		writel(addr2, card->membase + DR3);
+		writel(handle2, card->membase + DR2);
+		writel(addr1, card->membase + DR1);
+		writel(handle1, card->membase + DR0);
+		writel(NS_CMD_WRITE_FREEBUFQ | cb->buf_type,
+		       card->membase + CMD);
+
+		spin_unlock_irqrestore(&card->res_lock, flags);
+
+		XPRINTK("nicstar%d: Pushing %s buffers at 0x%x and 0x%x.\n",
+			card->index,
+			(cb->buf_type == BUF_SM ? "small" : "large"), addr1,
+			addr2);
+	}
+
+	if (!card->efbie && card->sbfqc >= card->sbnr.min &&
+	    card->lbfqc >= card->lbnr.min) {
+		card->efbie = 1;
+		writel((readl(card->membase + CFG) | NS_CFG_EFBIE),
+		       card->membase + CFG);
+	}
+
+	return;
 }
 
-
-
 static irqreturn_t ns_irq_handler(int irq, void *dev_id)
 {
-   u32 stat_r;
-   ns_dev *card;
-   struct atm_dev *dev;
-   unsigned long flags;
-
-   card = (ns_dev *) dev_id;
-   dev = card->atmdev;
-   card->intcnt++;
-
-   PRINTK("nicstar%d: NICStAR generated an interrupt\n", card->index);
-
-   spin_lock_irqsave(&card->int_lock, flags);
-   
-   stat_r = readl(card->membase + STAT);
-
-   /* Transmit Status Indicator has been written to T. S. Queue */
-   if (stat_r & NS_STAT_TSIF)
-   {
-      TXPRINTK("nicstar%d: TSI interrupt\n", card->index);
-      process_tsq(card);
-      writel(NS_STAT_TSIF, card->membase + STAT);
-   }
-   
-   /* Incomplete CS-PDU has been transmitted */
-   if (stat_r & NS_STAT_TXICP)
-   {
-      writel(NS_STAT_TXICP, card->membase + STAT);
-      TXPRINTK("nicstar%d: Incomplete CS-PDU transmitted.\n",
-               card->index);
-   }
-   
-   /* Transmit Status Queue 7/8 full */
-   if (stat_r & NS_STAT_TSQF)
-   {
-      writel(NS_STAT_TSQF, card->membase + STAT);
-      PRINTK("nicstar%d: TSQ full.\n", card->index);
-      process_tsq(card);
-   }
-   
-   /* Timer overflow */
-   if (stat_r & NS_STAT_TMROF)
-   {
-      writel(NS_STAT_TMROF, card->membase + STAT);
-      PRINTK("nicstar%d: Timer overflow.\n", card->index);
-   }
-   
-   /* PHY device interrupt signal active */
-   if (stat_r & NS_STAT_PHYI)
-   {
-      writel(NS_STAT_PHYI, card->membase + STAT);
-      PRINTK("nicstar%d: PHY interrupt.\n", card->index);
-      if (dev->phy && dev->phy->interrupt) {
-         dev->phy->interrupt(dev);
-      }
-   }
-
-   /* Small Buffer Queue is full */
-   if (stat_r & NS_STAT_SFBQF)
-   {
-      writel(NS_STAT_SFBQF, card->membase + STAT);
-      printk("nicstar%d: Small free buffer queue is full.\n", card->index);
-   }
-   
-   /* Large Buffer Queue is full */
-   if (stat_r & NS_STAT_LFBQF)
-   {
-      writel(NS_STAT_LFBQF, card->membase + STAT);
-      printk("nicstar%d: Large free buffer queue is full.\n", card->index);
-   }
-
-   /* Receive Status Queue is full */
-   if (stat_r & NS_STAT_RSQF)
-   {
-      writel(NS_STAT_RSQF, card->membase + STAT);
-      printk("nicstar%d: RSQ full.\n", card->index);
-      process_rsq(card);
-   }
-
-   /* Complete CS-PDU received */
-   if (stat_r & NS_STAT_EOPDU)
-   {
-      RXPRINTK("nicstar%d: End of CS-PDU received.\n", card->index);
-      process_rsq(card);
-      writel(NS_STAT_EOPDU, card->membase + STAT);
-   }
-
-   /* Raw cell received */
-   if (stat_r & NS_STAT_RAWCF)
-   {
-      writel(NS_STAT_RAWCF, card->membase + STAT);
+	u32 stat_r;
+	ns_dev *card;
+	struct atm_dev *dev;
+	unsigned long flags;
+
+	card = (ns_dev *) dev_id;
+	dev = card->atmdev;
+	card->intcnt++;
+
+	PRINTK("nicstar%d: NICStAR generated an interrupt\n", card->index);
+
+	spin_lock_irqsave(&card->int_lock, flags);
+
+	stat_r = readl(card->membase + STAT);
+
+	/* Transmit Status Indicator has been written to T. S. Queue */
+	if (stat_r & NS_STAT_TSIF) {
+		TXPRINTK("nicstar%d: TSI interrupt\n", card->index);
+		process_tsq(card);
+		writel(NS_STAT_TSIF, card->membase + STAT);
+	}
+
+	/* Incomplete CS-PDU has been transmitted */
+	if (stat_r & NS_STAT_TXICP) {
+		writel(NS_STAT_TXICP, card->membase + STAT);
+		TXPRINTK("nicstar%d: Incomplete CS-PDU transmitted.\n",
+			 card->index);
+	}
+
+	/* Transmit Status Queue 7/8 full */
+	if (stat_r & NS_STAT_TSQF) {
+		writel(NS_STAT_TSQF, card->membase + STAT);
+		PRINTK("nicstar%d: TSQ full.\n", card->index);
+		process_tsq(card);
+	}
+
+	/* Timer overflow */
+	if (stat_r & NS_STAT_TMROF) {
+		writel(NS_STAT_TMROF, card->membase + STAT);
+		PRINTK("nicstar%d: Timer overflow.\n", card->index);
+	}
+
+	/* PHY device interrupt signal active */
+	if (stat_r & NS_STAT_PHYI) {
+		writel(NS_STAT_PHYI, card->membase + STAT);
+		PRINTK("nicstar%d: PHY interrupt.\n", card->index);
+		if (dev->phy && dev->phy->interrupt) {
+			dev->phy->interrupt(dev);
+		}
+	}
+
+	/* Small Buffer Queue is full */
+	if (stat_r & NS_STAT_SFBQF) {
+		writel(NS_STAT_SFBQF, card->membase + STAT);
+		printk("nicstar%d: Small free buffer queue is full.\n",
+		       card->index);
+	}
+
+	/* Large Buffer Queue is full */
+	if (stat_r & NS_STAT_LFBQF) {
+		writel(NS_STAT_LFBQF, card->membase + STAT);
+		printk("nicstar%d: Large free buffer queue is full.\n",
+		       card->index);
+	}
+
+	/* Receive Status Queue is full */
+	if (stat_r & NS_STAT_RSQF) {
+		writel(NS_STAT_RSQF, card->membase + STAT);
+		printk("nicstar%d: RSQ full.\n", card->index);
+		process_rsq(card);
+	}
+
+	/* Complete CS-PDU received */
+	if (stat_r & NS_STAT_EOPDU) {
+		RXPRINTK("nicstar%d: End of CS-PDU received.\n", card->index);
+		process_rsq(card);
+		writel(NS_STAT_EOPDU, card->membase + STAT);
+	}
+
+	/* Raw cell received */
+	if (stat_r & NS_STAT_RAWCF) {
+		writel(NS_STAT_RAWCF, card->membase + STAT);
 #ifndef RCQ_SUPPORT
-      printk("nicstar%d: Raw cell received and no support yet...\n",
-             card->index);
+		printk("nicstar%d: Raw cell received and no support yet...\n",
+		       card->index);
 #endif /* RCQ_SUPPORT */
-      /* NOTE: the following procedure may keep a raw cell pending until the
-               next interrupt. As this preliminary support is only meant to
-               avoid buffer leakage, this is not an issue. */
-      while (readl(card->membase + RAWCT) != card->rawch)
-      {
-         ns_rcqe *rawcell;
-
-         rawcell = (ns_rcqe *) bus_to_virt(card->rawch);
-         if (ns_rcqe_islast(rawcell))
-         {
-            struct sk_buff *oldbuf;
-
-            oldbuf = card->rcbuf;
-            card->rcbuf = (struct sk_buff *) ns_rcqe_nextbufhandle(rawcell);
-            card->rawch = (u32) virt_to_bus(card->rcbuf->data);
-            recycle_rx_buf(card, oldbuf);
-         }
-         else
-            card->rawch += NS_RCQE_SIZE;
-      }
-   }
-
-   /* Small buffer queue is empty */
-   if (stat_r & NS_STAT_SFBQE)
-   {
-      int i;
-      struct sk_buff *sb;
-
-      writel(NS_STAT_SFBQE, card->membase + STAT);
-      printk("nicstar%d: Small free buffer queue empty.\n",
-             card->index);
-      for (i = 0; i < card->sbnr.min; i++)
-      {
-         sb = dev_alloc_skb(NS_SMSKBSIZE);
-         if (sb == NULL)
-         {
-            writel(readl(card->membase + CFG) & ~NS_CFG_EFBIE, card->membase + CFG);
-            card->efbie = 0;
-            break;
-         }
-         NS_SKB_CB(sb)->buf_type = BUF_SM;
-         skb_queue_tail(&card->sbpool.queue, sb);
-         skb_reserve(sb, NS_AAL0_HEADER);
-         push_rxbufs(card, sb);
-      }
-      card->sbfqc = i;
-      process_rsq(card);
-   }
-
-   /* Large buffer queue empty */
-   if (stat_r & NS_STAT_LFBQE)
-   {
-      int i;
-      struct sk_buff *lb;
-
-      writel(NS_STAT_LFBQE, card->membase + STAT);
-      printk("nicstar%d: Large free buffer queue empty.\n",
-             card->index);
-      for (i = 0; i < card->lbnr.min; i++)
-      {
-         lb = dev_alloc_skb(NS_LGSKBSIZE);
-         if (lb == NULL)
-         {
-            writel(readl(card->membase + CFG) & ~NS_CFG_EFBIE, card->membase + CFG);
-            card->efbie = 0;
-            break;
-         }
-         NS_SKB_CB(lb)->buf_type = BUF_LG;
-         skb_queue_tail(&card->lbpool.queue, lb);
-         skb_reserve(lb, NS_SMBUFSIZE);
-         push_rxbufs(card, lb);
-      }
-      card->lbfqc = i;
-      process_rsq(card);
-   }
-
-   /* Receive Status Queue is 7/8 full */
-   if (stat_r & NS_STAT_RSQAF)
-   {
-      writel(NS_STAT_RSQAF, card->membase + STAT);
-      RXPRINTK("nicstar%d: RSQ almost full.\n", card->index);
-      process_rsq(card);
-   }
-   
-   spin_unlock_irqrestore(&card->int_lock, flags);
-   PRINTK("nicstar%d: end of interrupt service\n", card->index);
-   return IRQ_HANDLED;
+		/* NOTE: the following procedure may keep a raw cell pending until the
+		   next interrupt. As this preliminary support is only meant to
+		   avoid buffer leakage, this is not an issue. */
+		while (readl(card->membase + RAWCT) != card->rawch) {
+			ns_rcqe *rawcell;
+
+			rawcell = (ns_rcqe *) bus_to_virt(card->rawch);
+			if (ns_rcqe_islast(rawcell)) {
+				struct sk_buff *oldbuf;
+
+				oldbuf = card->rcbuf;
+				card->rcbuf =
+				    (struct sk_buff *)
+				    ns_rcqe_nextbufhandle(rawcell);
+				card->rawch =
+				    (u32) virt_to_bus(card->rcbuf->data);
+				recycle_rx_buf(card, oldbuf);
+			} else
+				card->rawch += NS_RCQE_SIZE;
+		}
+	}
+
+	/* Small buffer queue is empty */
+	if (stat_r & NS_STAT_SFBQE) {
+		int i;
+		struct sk_buff *sb;
+
+		writel(NS_STAT_SFBQE, card->membase + STAT);
+		printk("nicstar%d: Small free buffer queue empty.\n",
+		       card->index);
+		for (i = 0; i < card->sbnr.min; i++) {
+			sb = dev_alloc_skb(NS_SMSKBSIZE);
+			if (sb == NULL) {
+				writel(readl(card->membase + CFG) &
+				       ~NS_CFG_EFBIE, card->membase + CFG);
+				card->efbie = 0;
+				break;
+			}
+			NS_SKB_CB(sb)->buf_type = BUF_SM;
+			skb_queue_tail(&card->sbpool.queue, sb);
+			skb_reserve(sb, NS_AAL0_HEADER);
+			push_rxbufs(card, sb);
+		}
+		card->sbfqc = i;
+		process_rsq(card);
+	}
+
+	/* Large buffer queue empty */
+	if (stat_r & NS_STAT_LFBQE) {
+		int i;
+		struct sk_buff *lb;
+
+		writel(NS_STAT_LFBQE, card->membase + STAT);
+		printk("nicstar%d: Large free buffer queue empty.\n",
+		       card->index);
+		for (i = 0; i < card->lbnr.min; i++) {
+			lb = dev_alloc_skb(NS_LGSKBSIZE);
+			if (lb == NULL) {
+				writel(readl(card->membase + CFG) &
+				       ~NS_CFG_EFBIE, card->membase + CFG);
+				card->efbie = 0;
+				break;
+			}
+			NS_SKB_CB(lb)->buf_type = BUF_LG;
+			skb_queue_tail(&card->lbpool.queue, lb);
+			skb_reserve(lb, NS_SMBUFSIZE);
+			push_rxbufs(card, lb);
+		}
+		card->lbfqc = i;
+		process_rsq(card);
+	}
+
+	/* Receive Status Queue is 7/8 full */
+	if (stat_r & NS_STAT_RSQAF) {
+		writel(NS_STAT_RSQAF, card->membase + STAT);
+		RXPRINTK("nicstar%d: RSQ almost full.\n", card->index);
+		process_rsq(card);
+	}
+
+	spin_unlock_irqrestore(&card->int_lock, flags);
+	PRINTK("nicstar%d: end of interrupt service\n", card->index);
+	return IRQ_HANDLED;
 }
 
-
-
 static int ns_open(struct atm_vcc *vcc)
 {
-   ns_dev *card;
-   vc_map *vc;
-   unsigned long tmpl, modl;
-   int tcr, tcra;	/* target cell rate, and absolute value */
-   int n = 0;		/* Number of entries in the TST. Initialized to remove
-                           the compiler warning. */
-   u32 u32d[4];
-   int frscdi = 0;	/* Index of the SCD. Initialized to remove the compiler
-                           warning. How I wish compilers were clever enough to
-			   tell which variables can truly be used
-			   uninitialized... */
-   int inuse;		/* tx or rx vc already in use by another vcc */
-   short vpi = vcc->vpi;
-   int vci = vcc->vci;
-
-   card = (ns_dev *) vcc->dev->dev_data;
-   PRINTK("nicstar%d: opening vpi.vci %d.%d \n", card->index, (int) vpi, vci);
-   if (vcc->qos.aal != ATM_AAL5 && vcc->qos.aal != ATM_AAL0)
-   {
-      PRINTK("nicstar%d: unsupported AAL.\n", card->index);
-      return -EINVAL;
-   }
-
-   vc = &(card->vcmap[vpi << card->vcibits | vci]);
-   vcc->dev_data = vc;
-
-   inuse = 0;
-   if (vcc->qos.txtp.traffic_class != ATM_NONE && vc->tx)
-      inuse = 1;
-   if (vcc->qos.rxtp.traffic_class != ATM_NONE && vc->rx)
-      inuse += 2;
-   if (inuse)
-   {
-      printk("nicstar%d: %s vci already in use.\n", card->index,
-             inuse == 1 ? "tx" : inuse == 2 ? "rx" : "tx and rx");
-      return -EINVAL;
-   }
-
-   set_bit(ATM_VF_ADDR,&vcc->flags);
-
-   /* NOTE: You are not allowed to modify an open connection's QOS. To change
-      that, remove the ATM_VF_PARTIAL flag checking. There may be other changes
-      needed to do that. */
-   if (!test_bit(ATM_VF_PARTIAL,&vcc->flags))
-   {
-      scq_info *scq;
-      
-      set_bit(ATM_VF_PARTIAL,&vcc->flags);
-      if (vcc->qos.txtp.traffic_class == ATM_CBR)
-      {
-         /* Check requested cell rate and availability of SCD */
-         if (vcc->qos.txtp.max_pcr == 0 && vcc->qos.txtp.pcr == 0 &&
-             vcc->qos.txtp.min_pcr == 0)
-         {
-            PRINTK("nicstar%d: trying to open a CBR vc with cell rate = 0 \n",
-	           card->index);
-	    clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	    clear_bit(ATM_VF_ADDR,&vcc->flags);
-            return -EINVAL;
-         }
-
-         tcr = atm_pcr_goal(&(vcc->qos.txtp));
-         tcra = tcr >= 0 ? tcr : -tcr;
-      
-         PRINTK("nicstar%d: target cell rate = %d.\n", card->index,
-                vcc->qos.txtp.max_pcr);
-
-         tmpl = (unsigned long)tcra * (unsigned long)NS_TST_NUM_ENTRIES;
-         modl = tmpl % card->max_pcr;
-
-         n = (int)(tmpl / card->max_pcr);
-         if (tcr > 0)
-         {
-            if (modl > 0) n++;
-         }
-         else if (tcr == 0)
-         {
-            if ((n = (card->tst_free_entries - NS_TST_RESERVED)) <= 0)
-	    {
-               PRINTK("nicstar%d: no CBR bandwidth free.\n", card->index);
-	       clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	       clear_bit(ATM_VF_ADDR,&vcc->flags);
-               return -EINVAL;
-            }
-         }
-
-         if (n == 0)
-         {
-            printk("nicstar%d: selected bandwidth < granularity.\n", card->index);
-	    clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	    clear_bit(ATM_VF_ADDR,&vcc->flags);
-            return -EINVAL;
-         }
-
-         if (n > (card->tst_free_entries - NS_TST_RESERVED))
-         {
-            PRINTK("nicstar%d: not enough free CBR bandwidth.\n", card->index);
-	    clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	    clear_bit(ATM_VF_ADDR,&vcc->flags);
-            return -EINVAL;
-         }
-         else
-            card->tst_free_entries -= n;
-
-         XPRINTK("nicstar%d: writing %d tst entries.\n", card->index, n);
-         for (frscdi = 0; frscdi < NS_FRSCD_NUM; frscdi++)
-         {
-            if (card->scd2vc[frscdi] == NULL)
-            {
-               card->scd2vc[frscdi] = vc;
-               break;
-	    }
-         }
-         if (frscdi == NS_FRSCD_NUM)
-         {
-            PRINTK("nicstar%d: no SCD available for CBR channel.\n", card->index);
-            card->tst_free_entries += n;
-	    clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	    clear_bit(ATM_VF_ADDR,&vcc->flags);
-	    return -EBUSY;
-         }
-
-         vc->cbr_scd = NS_FRSCD + frscdi * NS_FRSCD_SIZE;
-
-         scq = get_scq(CBR_SCQSIZE, vc->cbr_scd);
-         if (scq == NULL)
-         {
-            PRINTK("nicstar%d: can't get fixed rate SCQ.\n", card->index);
-            card->scd2vc[frscdi] = NULL;
-            card->tst_free_entries += n;
-	    clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	    clear_bit(ATM_VF_ADDR,&vcc->flags);
-            return -ENOMEM;
-         }
-	 vc->scq = scq;
-         u32d[0] = (u32) virt_to_bus(scq->base);
-         u32d[1] = (u32) 0x00000000;
-         u32d[2] = (u32) 0xffffffff;
-         u32d[3] = (u32) 0x00000000;
-         ns_write_sram(card, vc->cbr_scd, u32d, 4);
-         
-	 fill_tst(card, n, vc);
-      }
-      else if (vcc->qos.txtp.traffic_class == ATM_UBR)
-      {
-         vc->cbr_scd = 0x00000000;
-	 vc->scq = card->scq0;
-      }
-      
-      if (vcc->qos.txtp.traffic_class != ATM_NONE)
-      {
-         vc->tx = 1;
-	 vc->tx_vcc = vcc;
-	 vc->tbd_count = 0;
-      }
-      if (vcc->qos.rxtp.traffic_class != ATM_NONE)
-      {
-         u32 status;
-      
-         vc->rx = 1;
-         vc->rx_vcc = vcc;
-         vc->rx_iov = NULL;
-
-	 /* Open the connection in hardware */
-	 if (vcc->qos.aal == ATM_AAL5)
-	    status = NS_RCTE_AAL5 | NS_RCTE_CONNECTOPEN;
-	 else /* vcc->qos.aal == ATM_AAL0 */
-	    status = NS_RCTE_AAL0 | NS_RCTE_CONNECTOPEN;
+	ns_dev *card;
+	vc_map *vc;
+	unsigned long tmpl, modl;
+	int tcr, tcra;		/* target cell rate, and absolute value */
+	int n = 0;		/* Number of entries in the TST. Initialized to remove
+				   the compiler warning. */
+	u32 u32d[4];
+	int frscdi = 0;		/* Index of the SCD. Initialized to remove the compiler
+				   warning. How I wish compilers were clever enough to
+				   tell which variables can truly be used
+				   uninitialized... */
+	int inuse;		/* tx or rx vc already in use by another vcc */
+	short vpi = vcc->vpi;
+	int vci = vcc->vci;
+
+	card = (ns_dev *) vcc->dev->dev_data;
+	PRINTK("nicstar%d: opening vpi.vci %d.%d \n", card->index, (int)vpi,
+	       vci);
+	if (vcc->qos.aal != ATM_AAL5 && vcc->qos.aal != ATM_AAL0) {
+		PRINTK("nicstar%d: unsupported AAL.\n", card->index);
+		return -EINVAL;
+	}
+
+	vc = &(card->vcmap[vpi << card->vcibits | vci]);
+	vcc->dev_data = vc;
+
+	inuse = 0;
+	if (vcc->qos.txtp.traffic_class != ATM_NONE && vc->tx)
+		inuse = 1;
+	if (vcc->qos.rxtp.traffic_class != ATM_NONE && vc->rx)
+		inuse += 2;
+	if (inuse) {
+		printk("nicstar%d: %s vci already in use.\n", card->index,
+		       inuse == 1 ? "tx" : inuse == 2 ? "rx" : "tx and rx");
+		return -EINVAL;
+	}
+
+	set_bit(ATM_VF_ADDR, &vcc->flags);
+
+	/* NOTE: You are not allowed to modify an open connection's QOS. To change
+	   that, remove the ATM_VF_PARTIAL flag checking. There may be other changes
+	   needed to do that. */
+	if (!test_bit(ATM_VF_PARTIAL, &vcc->flags)) {
+		scq_info *scq;
+
+		set_bit(ATM_VF_PARTIAL, &vcc->flags);
+		if (vcc->qos.txtp.traffic_class == ATM_CBR) {
+			/* Check requested cell rate and availability of SCD */
+			if (vcc->qos.txtp.max_pcr == 0 && vcc->qos.txtp.pcr == 0
+			    && vcc->qos.txtp.min_pcr == 0) {
+				PRINTK
+				    ("nicstar%d: trying to open a CBR vc with cell rate = 0 \n",
+				     card->index);
+				clear_bit(ATM_VF_PARTIAL, &vcc->flags);
+				clear_bit(ATM_VF_ADDR, &vcc->flags);
+				return -EINVAL;
+			}
+
+			tcr = atm_pcr_goal(&(vcc->qos.txtp));
+			tcra = tcr >= 0 ? tcr : -tcr;
+
+			PRINTK("nicstar%d: target cell rate = %d.\n",
+			       card->index, vcc->qos.txtp.max_pcr);
+
+			tmpl =
+			    (unsigned long)tcra *(unsigned long)
+			    NS_TST_NUM_ENTRIES;
+			modl = tmpl % card->max_pcr;
+
+			n = (int)(tmpl / card->max_pcr);
+			if (tcr > 0) {
+				if (modl > 0)
+					n++;
+			} else if (tcr == 0) {
+				if ((n =
+				     (card->tst_free_entries -
+				      NS_TST_RESERVED)) <= 0) {
+					PRINTK
+					    ("nicstar%d: no CBR bandwidth free.\n",
+					     card->index);
+					clear_bit(ATM_VF_PARTIAL, &vcc->flags);
+					clear_bit(ATM_VF_ADDR, &vcc->flags);
+					return -EINVAL;
+				}
+			}
+
+			if (n == 0) {
+				printk
+				    ("nicstar%d: selected bandwidth < granularity.\n",
+				     card->index);
+				clear_bit(ATM_VF_PARTIAL, &vcc->flags);
+				clear_bit(ATM_VF_ADDR, &vcc->flags);
+				return -EINVAL;
+			}
+
+			if (n > (card->tst_free_entries - NS_TST_RESERVED)) {
+				PRINTK
+				    ("nicstar%d: not enough free CBR bandwidth.\n",
+				     card->index);
+				clear_bit(ATM_VF_PARTIAL, &vcc->flags);
+				clear_bit(ATM_VF_ADDR, &vcc->flags);
+				return -EINVAL;
+			} else
+				card->tst_free_entries -= n;
+
+			XPRINTK("nicstar%d: writing %d tst entries.\n",
+				card->index, n);
+			for (frscdi = 0; frscdi < NS_FRSCD_NUM; frscdi++) {
+				if (card->scd2vc[frscdi] == NULL) {
+					card->scd2vc[frscdi] = vc;
+					break;
+				}
+			}
+			if (frscdi == NS_FRSCD_NUM) {
+				PRINTK
+				    ("nicstar%d: no SCD available for CBR channel.\n",
+				     card->index);
+				card->tst_free_entries += n;
+				clear_bit(ATM_VF_PARTIAL, &vcc->flags);
+				clear_bit(ATM_VF_ADDR, &vcc->flags);
+				return -EBUSY;
+			}
+
+			vc->cbr_scd = NS_FRSCD + frscdi * NS_FRSCD_SIZE;
+
+			scq = get_scq(CBR_SCQSIZE, vc->cbr_scd);
+			if (scq == NULL) {
+				PRINTK("nicstar%d: can't get fixed rate SCQ.\n",
+				       card->index);
+				card->scd2vc[frscdi] = NULL;
+				card->tst_free_entries += n;
+				clear_bit(ATM_VF_PARTIAL, &vcc->flags);
+				clear_bit(ATM_VF_ADDR, &vcc->flags);
+				return -ENOMEM;
+			}
+			vc->scq = scq;
+			u32d[0] = (u32) virt_to_bus(scq->base);
+			u32d[1] = (u32) 0x00000000;
+			u32d[2] = (u32) 0xffffffff;
+			u32d[3] = (u32) 0x00000000;
+			ns_write_sram(card, vc->cbr_scd, u32d, 4);
+
+			fill_tst(card, n, vc);
+		} else if (vcc->qos.txtp.traffic_class == ATM_UBR) {
+			vc->cbr_scd = 0x00000000;
+			vc->scq = card->scq0;
+		}
+
+		if (vcc->qos.txtp.traffic_class != ATM_NONE) {
+			vc->tx = 1;
+			vc->tx_vcc = vcc;
+			vc->tbd_count = 0;
+		}
+		if (vcc->qos.rxtp.traffic_class != ATM_NONE) {
+			u32 status;
+
+			vc->rx = 1;
+			vc->rx_vcc = vcc;
+			vc->rx_iov = NULL;
+
+			/* Open the connection in hardware */
+			if (vcc->qos.aal == ATM_AAL5)
+				status = NS_RCTE_AAL5 | NS_RCTE_CONNECTOPEN;
+			else	/* vcc->qos.aal == ATM_AAL0 */
+				status = NS_RCTE_AAL0 | NS_RCTE_CONNECTOPEN;
 #ifdef RCQ_SUPPORT
-         status |= NS_RCTE_RAWCELLINTEN;
+			status |= NS_RCTE_RAWCELLINTEN;
 #endif /* RCQ_SUPPORT */
-         ns_write_sram(card, NS_RCT + (vpi << card->vcibits | vci) *
-	               NS_RCT_ENTRY_SIZE, &status, 1);
-      }
-      
-   }
-   
-   set_bit(ATM_VF_READY,&vcc->flags);
-   return 0;
-}
+			ns_write_sram(card,
+				      NS_RCT +
+				      (vpi << card->vcibits | vci) *
+				      NS_RCT_ENTRY_SIZE, &status, 1);
+		}
 
+	}
 
+	set_bit(ATM_VF_READY, &vcc->flags);
+	return 0;
+}
 
 static void ns_close(struct atm_vcc *vcc)
 {
-   vc_map *vc;
-   ns_dev *card;
-   u32 data;
-   int i;
-   
-   vc = vcc->dev_data;
-   card = vcc->dev->dev_data;
-   PRINTK("nicstar%d: closing vpi.vci %d.%d \n", card->index,
-          (int) vcc->vpi, vcc->vci);
-
-   clear_bit(ATM_VF_READY,&vcc->flags);
-   
-   if (vcc->qos.rxtp.traffic_class != ATM_NONE)
-   {
-      u32 addr;
-      unsigned long flags;
-      
-      addr = NS_RCT + (vcc->vpi << card->vcibits | vcc->vci) * NS_RCT_ENTRY_SIZE;
-      spin_lock_irqsave(&card->res_lock, flags);
-      while(CMD_BUSY(card));
-      writel(NS_CMD_CLOSE_CONNECTION | addr << 2, card->membase + CMD);
-      spin_unlock_irqrestore(&card->res_lock, flags);
-      
-      vc->rx = 0;
-      if (vc->rx_iov != NULL)
-      {
-	 struct sk_buff *iovb;
-	 u32 stat;
-   
-         stat = readl(card->membase + STAT);
-         card->sbfqc = ns_stat_sfbqc_get(stat);   
-         card->lbfqc = ns_stat_lfbqc_get(stat);
-
-         PRINTK("nicstar%d: closing a VC with pending rx buffers.\n",
-	        card->index);
-         iovb = vc->rx_iov;
-         recycle_iovec_rx_bufs(card, (struct iovec *) iovb->data,
-	                       NS_SKB(iovb)->iovcnt);
-         NS_SKB(iovb)->iovcnt = 0;
-         NS_SKB(iovb)->vcc = NULL;
-         spin_lock_irqsave(&card->int_lock, flags);
-         recycle_iov_buf(card, iovb);
-         spin_unlock_irqrestore(&card->int_lock, flags);
-         vc->rx_iov = NULL;
-      }
-   }
-
-   if (vcc->qos.txtp.traffic_class != ATM_NONE)
-   {
-      vc->tx = 0;
-   }
-
-   if (vcc->qos.txtp.traffic_class == ATM_CBR)
-   {
-      unsigned long flags;
-      ns_scqe *scqep;
-      scq_info *scq;
-
-      scq = vc->scq;
-
-      for (;;)
-      {
-         spin_lock_irqsave(&scq->lock, flags);
-         scqep = scq->next;
-         if (scqep == scq->base)
-            scqep = scq->last;
-         else
-            scqep--;
-         if (scqep == scq->tail)
-         {
-            spin_unlock_irqrestore(&scq->lock, flags);
-            break;
-         }
-         /* If the last entry is not a TSR, place one in the SCQ in order to
-            be able to completely drain it and then close. */
-         if (!ns_scqe_is_tsr(scqep) && scq->tail != scq->next)
-         {
-            ns_scqe tsr;
-            u32 scdi, scqi;
-            u32 data;
-            int index;
-
-            tsr.word_1 = ns_tsr_mkword_1(NS_TSR_INTENABLE);
-            scdi = (vc->cbr_scd - NS_FRSCD) / NS_FRSCD_SIZE;
-            scqi = scq->next - scq->base;
-            tsr.word_2 = ns_tsr_mkword_2(scdi, scqi);
-            tsr.word_3 = 0x00000000;
-            tsr.word_4 = 0x00000000;
-            *scq->next = tsr;
-            index = (int) scqi;
-            scq->skb[index] = NULL;
-            if (scq->next == scq->last)
-               scq->next = scq->base;
-            else
-               scq->next++;
-            data = (u32) virt_to_bus(scq->next);
-            ns_write_sram(card, scq->scd, &data, 1);
-         }
-         spin_unlock_irqrestore(&scq->lock, flags);
-         schedule();
-      }
-
-      /* Free all TST entries */
-      data = NS_TST_OPCODE_VARIABLE;
-      for (i = 0; i < NS_TST_NUM_ENTRIES; i++)
-      {
-         if (card->tste2vc[i] == vc)
-	 {
-            ns_write_sram(card, card->tst_addr + i, &data, 1);
-            card->tste2vc[i] = NULL;
-            card->tst_free_entries++;
-	 }
-      }
-      
-      card->scd2vc[(vc->cbr_scd - NS_FRSCD) / NS_FRSCD_SIZE] = NULL;
-      free_scq(vc->scq, vcc);
-   }
-
-   /* remove all references to vcc before deleting it */
-   if (vcc->qos.txtp.traffic_class != ATM_NONE)
-   {
-     unsigned long flags;
-     scq_info *scq = card->scq0;
-
-     spin_lock_irqsave(&scq->lock, flags);
-
-     for(i = 0; i < scq->num_entries; i++) {
-       if(scq->skb[i] && ATM_SKB(scq->skb[i])->vcc == vcc) {
-        ATM_SKB(scq->skb[i])->vcc = NULL;
-	atm_return(vcc, scq->skb[i]->truesize);
-        PRINTK("nicstar: deleted pending vcc mapping\n");
-       }
-     }
-
-     spin_unlock_irqrestore(&scq->lock, flags);
-   }
-
-   vcc->dev_data = NULL;
-   clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-   clear_bit(ATM_VF_ADDR,&vcc->flags);
+	vc_map *vc;
+	ns_dev *card;
+	u32 data;
+	int i;
+
+	vc = vcc->dev_data;
+	card = vcc->dev->dev_data;
+	PRINTK("nicstar%d: closing vpi.vci %d.%d \n", card->index,
+	       (int)vcc->vpi, vcc->vci);
+
+	clear_bit(ATM_VF_READY, &vcc->flags);
+
+	if (vcc->qos.rxtp.traffic_class != ATM_NONE) {
+		u32 addr;
+		unsigned long flags;
+
+		addr =
+		    NS_RCT +
+		    (vcc->vpi << card->vcibits | vcc->vci) * NS_RCT_ENTRY_SIZE;
+		spin_lock_irqsave(&card->res_lock, flags);
+		while (CMD_BUSY(card)) ;
+		writel(NS_CMD_CLOSE_CONNECTION | addr << 2,
+		       card->membase + CMD);
+		spin_unlock_irqrestore(&card->res_lock, flags);
+
+		vc->rx = 0;
+		if (vc->rx_iov != NULL) {
+			struct sk_buff *iovb;
+			u32 stat;
+
+			stat = readl(card->membase + STAT);
+			card->sbfqc = ns_stat_sfbqc_get(stat);
+			card->lbfqc = ns_stat_lfbqc_get(stat);
+
+			PRINTK
+			    ("nicstar%d: closing a VC with pending rx buffers.\n",
+			     card->index);
+			iovb = vc->rx_iov;
+			recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
+					      NS_SKB(iovb)->iovcnt);
+			NS_SKB(iovb)->iovcnt = 0;
+			NS_SKB(iovb)->vcc = NULL;
+			spin_lock_irqsave(&card->int_lock, flags);
+			recycle_iov_buf(card, iovb);
+			spin_unlock_irqrestore(&card->int_lock, flags);
+			vc->rx_iov = NULL;
+		}
+	}
+
+	if (vcc->qos.txtp.traffic_class != ATM_NONE) {
+		vc->tx = 0;
+	}
+
+	if (vcc->qos.txtp.traffic_class == ATM_CBR) {
+		unsigned long flags;
+		ns_scqe *scqep;
+		scq_info *scq;
+
+		scq = vc->scq;
+
+		for (;;) {
+			spin_lock_irqsave(&scq->lock, flags);
+			scqep = scq->next;
+			if (scqep == scq->base)
+				scqep = scq->last;
+			else
+				scqep--;
+			if (scqep == scq->tail) {
+				spin_unlock_irqrestore(&scq->lock, flags);
+				break;
+			}
+			/* If the last entry is not a TSR, place one in the SCQ in order to
+			   be able to completely drain it and then close. */
+			if (!ns_scqe_is_tsr(scqep) && scq->tail != scq->next) {
+				ns_scqe tsr;
+				u32 scdi, scqi;
+				u32 data;
+				int index;
+
+				tsr.word_1 = ns_tsr_mkword_1(NS_TSR_INTENABLE);
+				scdi = (vc->cbr_scd - NS_FRSCD) / NS_FRSCD_SIZE;
+				scqi = scq->next - scq->base;
+				tsr.word_2 = ns_tsr_mkword_2(scdi, scqi);
+				tsr.word_3 = 0x00000000;
+				tsr.word_4 = 0x00000000;
+				*scq->next = tsr;
+				index = (int)scqi;
+				scq->skb[index] = NULL;
+				if (scq->next == scq->last)
+					scq->next = scq->base;
+				else
+					scq->next++;
+				data = (u32) virt_to_bus(scq->next);
+				ns_write_sram(card, scq->scd, &data, 1);
+			}
+			spin_unlock_irqrestore(&scq->lock, flags);
+			schedule();
+		}
+
+		/* Free all TST entries */
+		data = NS_TST_OPCODE_VARIABLE;
+		for (i = 0; i < NS_TST_NUM_ENTRIES; i++) {
+			if (card->tste2vc[i] == vc) {
+				ns_write_sram(card, card->tst_addr + i, &data,
+					      1);
+				card->tste2vc[i] = NULL;
+				card->tst_free_entries++;
+			}
+		}
+
+		card->scd2vc[(vc->cbr_scd - NS_FRSCD) / NS_FRSCD_SIZE] = NULL;
+		free_scq(vc->scq, vcc);
+	}
+
+	/* remove all references to vcc before deleting it */
+	if (vcc->qos.txtp.traffic_class != ATM_NONE) {
+		unsigned long flags;
+		scq_info *scq = card->scq0;
+
+		spin_lock_irqsave(&scq->lock, flags);
+
+		for (i = 0; i < scq->num_entries; i++) {
+			if (scq->skb[i] && ATM_SKB(scq->skb[i])->vcc == vcc) {
+				ATM_SKB(scq->skb[i])->vcc = NULL;
+				atm_return(vcc, scq->skb[i]->truesize);
+				PRINTK
+				    ("nicstar: deleted pending vcc mapping\n");
+			}
+		}
+
+		spin_unlock_irqrestore(&scq->lock, flags);
+	}
+
+	vcc->dev_data = NULL;
+	clear_bit(ATM_VF_PARTIAL, &vcc->flags);
+	clear_bit(ATM_VF_ADDR, &vcc->flags);
 
 #ifdef RX_DEBUG
-   {
-      u32 stat, cfg;
-      stat = readl(card->membase + STAT);
-      cfg = readl(card->membase + CFG);
-      printk("STAT = 0x%08X  CFG = 0x%08X  \n", stat, cfg);
-      printk("TSQ: base = 0x%08X  next = 0x%08X  last = 0x%08X  TSQT = 0x%08X \n",
-             (u32) card->tsq.base, (u32) card->tsq.next,(u32) card->tsq.last,
-	     readl(card->membase + TSQT));
-      printk("RSQ: base = 0x%08X  next = 0x%08X  last = 0x%08X  RSQT = 0x%08X \n",
-             (u32) card->rsq.base, (u32) card->rsq.next,(u32) card->rsq.last,
-	     readl(card->membase + RSQT));
-      printk("Empty free buffer queue interrupt %s \n",
-             card->efbie ? "enabled" : "disabled");
-      printk("SBCNT = %d  count = %d   LBCNT = %d count = %d \n",
-             ns_stat_sfbqc_get(stat), card->sbpool.count,
-	     ns_stat_lfbqc_get(stat), card->lbpool.count);
-      printk("hbpool.count = %d  iovpool.count = %d \n",
-             card->hbpool.count, card->iovpool.count);
-   }
+	{
+		u32 stat, cfg;
+		stat = readl(card->membase + STAT);
+		cfg = readl(card->membase + CFG);
+		printk("STAT = 0x%08X  CFG = 0x%08X  \n", stat, cfg);
+		printk
+		    ("TSQ: base = 0x%08X  next = 0x%08X  last = 0x%08X  TSQT = 0x%08X \n",
+		     (u32) card->tsq.base, (u32) card->tsq.next,
+		     (u32) card->tsq.last, readl(card->membase + TSQT));
+		printk
+		    ("RSQ: base = 0x%08X  next = 0x%08X  last = 0x%08X  RSQT = 0x%08X \n",
+		     (u32) card->rsq.base, (u32) card->rsq.next,
+		     (u32) card->rsq.last, readl(card->membase + RSQT));
+		printk("Empty free buffer queue interrupt %s \n",
+		       card->efbie ? "enabled" : "disabled");
+		printk("SBCNT = %d  count = %d   LBCNT = %d count = %d \n",
+		       ns_stat_sfbqc_get(stat), card->sbpool.count,
+		       ns_stat_lfbqc_get(stat), card->lbpool.count);
+		printk("hbpool.count = %d  iovpool.count = %d \n",
+		       card->hbpool.count, card->iovpool.count);
+	}
 #endif /* RX_DEBUG */
 }
 
-
-
-static void fill_tst(ns_dev *card, int n, vc_map *vc)
+static void fill_tst(ns_dev * card, int n, vc_map * vc)
 {
-   u32 new_tst;
-   unsigned long cl;
-   int e, r;
-   u32 data;
-      
-   /* It would be very complicated to keep the two TSTs synchronized while
-      assuring that writes are only made to the inactive TST. So, for now I
-      will use only one TST. If problems occur, I will change this again */
-   
-   new_tst = card->tst_addr;
-
-   /* Fill procedure */
-
-   for (e = 0; e < NS_TST_NUM_ENTRIES; e++)
-   {
-      if (card->tste2vc[e] == NULL)
-         break;
-   }
-   if (e == NS_TST_NUM_ENTRIES) {
-      printk("nicstar%d: No free TST entries found. \n", card->index);
-      return;
-   }
-
-   r = n;
-   cl = NS_TST_NUM_ENTRIES;
-   data = ns_tste_make(NS_TST_OPCODE_FIXED, vc->cbr_scd);
-      
-   while (r > 0)
-   {
-      if (cl >= NS_TST_NUM_ENTRIES && card->tste2vc[e] == NULL)
-      {
-         card->tste2vc[e] = vc;
-         ns_write_sram(card, new_tst + e, &data, 1);
-         cl -= NS_TST_NUM_ENTRIES;
-         r--;
-      }
-
-      if (++e == NS_TST_NUM_ENTRIES) {
-         e = 0;
-      }
-      cl += n;
-   }
-   
-   /* End of fill procedure */
-   
-   data = ns_tste_make(NS_TST_OPCODE_END, new_tst);
-   ns_write_sram(card, new_tst + NS_TST_NUM_ENTRIES, &data, 1);
-   ns_write_sram(card, card->tst_addr + NS_TST_NUM_ENTRIES, &data, 1);
-   card->tst_addr = new_tst;
+	u32 new_tst;
+	unsigned long cl;
+	int e, r;
+	u32 data;
+
+	/* It would be very complicated to keep the two TSTs synchronized while
+	   assuring that writes are only made to the inactive TST. So, for now I
+	   will use only one TST. If problems occur, I will change this again */
+
+	new_tst = card->tst_addr;
+
+	/* Fill procedure */
+
+	for (e = 0; e < NS_TST_NUM_ENTRIES; e++) {
+		if (card->tste2vc[e] == NULL)
+			break;
+	}
+	if (e == NS_TST_NUM_ENTRIES) {
+		printk("nicstar%d: No free TST entries found. \n", card->index);
+		return;
+	}
+
+	r = n;
+	cl = NS_TST_NUM_ENTRIES;
+	data = ns_tste_make(NS_TST_OPCODE_FIXED, vc->cbr_scd);
+
+	while (r > 0) {
+		if (cl >= NS_TST_NUM_ENTRIES && card->tste2vc[e] == NULL) {
+			card->tste2vc[e] = vc;
+			ns_write_sram(card, new_tst + e, &data, 1);
+			cl -= NS_TST_NUM_ENTRIES;
+			r--;
+		}
+
+		if (++e == NS_TST_NUM_ENTRIES) {
+			e = 0;
+		}
+		cl += n;
+	}
+
+	/* End of fill procedure */
+
+	data = ns_tste_make(NS_TST_OPCODE_END, new_tst);
+	ns_write_sram(card, new_tst + NS_TST_NUM_ENTRIES, &data, 1);
+	ns_write_sram(card, card->tst_addr + NS_TST_NUM_ENTRIES, &data, 1);
+	card->tst_addr = new_tst;
 }
 
-
-
 static int ns_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
-   ns_dev *card;
-   vc_map *vc;
-   scq_info *scq;
-   unsigned long buflen;
-   ns_scqe scqe;
-   u32 flags;		/* TBD flags, not CPU flags */
-   
-   card = vcc->dev->dev_data;
-   TXPRINTK("nicstar%d: ns_send() called.\n", card->index);
-   if ((vc = (vc_map *) vcc->dev_data) == NULL)
-   {
-      printk("nicstar%d: vcc->dev_data == NULL on ns_send().\n", card->index);
-      atomic_inc(&vcc->stats->tx_err);
-      dev_kfree_skb_any(skb);
-      return -EINVAL;
-   }
-   
-   if (!vc->tx)
-   {
-      printk("nicstar%d: Trying to transmit on a non-tx VC.\n", card->index);
-      atomic_inc(&vcc->stats->tx_err);
-      dev_kfree_skb_any(skb);
-      return -EINVAL;
-   }
-   
-   if (vcc->qos.aal != ATM_AAL5 && vcc->qos.aal != ATM_AAL0)
-   {
-      printk("nicstar%d: Only AAL0 and AAL5 are supported.\n", card->index);
-      atomic_inc(&vcc->stats->tx_err);
-      dev_kfree_skb_any(skb);
-      return -EINVAL;
-   }
-   
-   if (skb_shinfo(skb)->nr_frags != 0)
-   {
-      printk("nicstar%d: No scatter-gather yet.\n", card->index);
-      atomic_inc(&vcc->stats->tx_err);
-      dev_kfree_skb_any(skb);
-      return -EINVAL;
-   }
-   
-   ATM_SKB(skb)->vcc = vcc;
-
-   if (vcc->qos.aal == ATM_AAL5)
-   {
-      buflen = (skb->len + 47 + 8) / 48 * 48;	/* Multiple of 48 */
-      flags = NS_TBD_AAL5;
-      scqe.word_2 = cpu_to_le32((u32) virt_to_bus(skb->data));
-      scqe.word_3 = cpu_to_le32((u32) skb->len);
-      scqe.word_4 = ns_tbd_mkword_4(0, (u32) vcc->vpi, (u32) vcc->vci, 0,
-                           ATM_SKB(skb)->atm_options & ATM_ATMOPT_CLP ? 1 : 0);
-      flags |= NS_TBD_EOPDU;
-   }
-   else /* (vcc->qos.aal == ATM_AAL0) */
-   {
-      buflen = ATM_CELL_PAYLOAD;	/* i.e., 48 bytes */
-      flags = NS_TBD_AAL0;
-      scqe.word_2 = cpu_to_le32((u32) virt_to_bus(skb->data) + NS_AAL0_HEADER);
-      scqe.word_3 = cpu_to_le32(0x00000000);
-      if (*skb->data & 0x02)	/* Payload type 1 - end of pdu */
-         flags |= NS_TBD_EOPDU;
-      scqe.word_4 = cpu_to_le32(*((u32 *) skb->data) & ~NS_TBD_VC_MASK);
-      /* Force the VPI/VCI to be the same as in VCC struct */
-      scqe.word_4 |= cpu_to_le32((((u32) vcc->vpi) << NS_TBD_VPI_SHIFT |
-                                 ((u32) vcc->vci) << NS_TBD_VCI_SHIFT) &
-                                 NS_TBD_VC_MASK);
-   }
-
-   if (vcc->qos.txtp.traffic_class == ATM_CBR)
-   {
-      scqe.word_1 = ns_tbd_mkword_1_novbr(flags, (u32) buflen);
-      scq = ((vc_map *) vcc->dev_data)->scq;
-   }
-   else
-   {
-      scqe.word_1 = ns_tbd_mkword_1(flags, (u32) 1, (u32) 1, (u32) buflen);
-      scq = card->scq0;
-   }
-
-   if (push_scqe(card, vc, scq, &scqe, skb) != 0)
-   {
-      atomic_inc(&vcc->stats->tx_err);
-      dev_kfree_skb_any(skb);
-      return -EIO;
-   }
-   atomic_inc(&vcc->stats->tx);
-
-   return 0;
-}
-
+	ns_dev *card;
+	vc_map *vc;
+	scq_info *scq;
+	unsigned long buflen;
+	ns_scqe scqe;
+	u32 flags;		/* TBD flags, not CPU flags */
+
+	card = vcc->dev->dev_data;
+	TXPRINTK("nicstar%d: ns_send() called.\n", card->index);
+	if ((vc = (vc_map *) vcc->dev_data) == NULL) {
+		printk("nicstar%d: vcc->dev_data == NULL on ns_send().\n",
+		       card->index);
+		atomic_inc(&vcc->stats->tx_err);
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
+	}
 
+	if (!vc->tx) {
+		printk("nicstar%d: Trying to transmit on a non-tx VC.\n",
+		       card->index);
+		atomic_inc(&vcc->stats->tx_err);
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
+	}
 
-static int push_scqe(ns_dev *card, vc_map *vc, scq_info *scq, ns_scqe *tbd,
-                     struct sk_buff *skb)
-{
-   unsigned long flags;
-   ns_scqe tsr;
-   u32 scdi, scqi;
-   int scq_is_vbr;
-   u32 data;
-   int index;
-   
-   spin_lock_irqsave(&scq->lock, flags);
-   while (scq->tail == scq->next)
-   {
-      if (in_interrupt()) {
-         spin_unlock_irqrestore(&scq->lock, flags);
-         printk("nicstar%d: Error pushing TBD.\n", card->index);
-         return 1;
-      }
-
-      scq->full = 1;
-      spin_unlock_irqrestore(&scq->lock, flags);
-      interruptible_sleep_on_timeout(&scq->scqfull_waitq, SCQFULL_TIMEOUT);
-      spin_lock_irqsave(&scq->lock, flags);
-
-      if (scq->full) {
-         spin_unlock_irqrestore(&scq->lock, flags);
-         printk("nicstar%d: Timeout pushing TBD.\n", card->index);
-         return 1;
-      }
-   }
-   *scq->next = *tbd;
-   index = (int) (scq->next - scq->base);
-   scq->skb[index] = skb;
-   XPRINTK("nicstar%d: sending skb at 0x%x (pos %d).\n",
-           card->index, (u32) skb, index);
-   XPRINTK("nicstar%d: TBD written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%x.\n",
-           card->index, le32_to_cpu(tbd->word_1), le32_to_cpu(tbd->word_2),
-           le32_to_cpu(tbd->word_3), le32_to_cpu(tbd->word_4),
-           (u32) scq->next);
-   if (scq->next == scq->last)
-      scq->next = scq->base;
-   else
-      scq->next++;
-
-   vc->tbd_count++;
-   if (scq->num_entries == VBR_SCQ_NUM_ENTRIES)
-   {
-      scq->tbd_count++;
-      scq_is_vbr = 1;
-   }
-   else
-      scq_is_vbr = 0;
-
-   if (vc->tbd_count >= MAX_TBD_PER_VC || scq->tbd_count >= MAX_TBD_PER_SCQ)
-   {
-      int has_run = 0;
-
-      while (scq->tail == scq->next)
-      {
-         if (in_interrupt()) {
-            data = (u32) virt_to_bus(scq->next);
-            ns_write_sram(card, scq->scd, &data, 1);
-            spin_unlock_irqrestore(&scq->lock, flags);
-            printk("nicstar%d: Error pushing TSR.\n", card->index);
-            return 0;
-         }
-
-         scq->full = 1;
-         if (has_run++) break;
-         spin_unlock_irqrestore(&scq->lock, flags);
-         interruptible_sleep_on_timeout(&scq->scqfull_waitq, SCQFULL_TIMEOUT);
-         spin_lock_irqsave(&scq->lock, flags);
-      }
-
-      if (!scq->full)
-      {
-         tsr.word_1 = ns_tsr_mkword_1(NS_TSR_INTENABLE);
-         if (scq_is_vbr)
-            scdi = NS_TSR_SCDISVBR;
-         else
-            scdi = (vc->cbr_scd - NS_FRSCD) / NS_FRSCD_SIZE;
-         scqi = scq->next - scq->base;
-         tsr.word_2 = ns_tsr_mkword_2(scdi, scqi);
-         tsr.word_3 = 0x00000000;
-         tsr.word_4 = 0x00000000;
-
-         *scq->next = tsr;
-         index = (int) scqi;
-         scq->skb[index] = NULL;
-         XPRINTK("nicstar%d: TSR written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%x.\n",
-                 card->index, le32_to_cpu(tsr.word_1), le32_to_cpu(tsr.word_2),
-                 le32_to_cpu(tsr.word_3), le32_to_cpu(tsr.word_4),
-		 (u32) scq->next);
-         if (scq->next == scq->last)
-            scq->next = scq->base;
-         else
-            scq->next++;
-         vc->tbd_count = 0;
-         scq->tbd_count = 0;
-      }
-      else
-         PRINTK("nicstar%d: Timeout pushing TSR.\n", card->index);
-   }
-   data = (u32) virt_to_bus(scq->next);
-   ns_write_sram(card, scq->scd, &data, 1);
-   
-   spin_unlock_irqrestore(&scq->lock, flags);
-   
-   return 0;
-}
+	if (vcc->qos.aal != ATM_AAL5 && vcc->qos.aal != ATM_AAL0) {
+		printk("nicstar%d: Only AAL0 and AAL5 are supported.\n",
+		       card->index);
+		atomic_inc(&vcc->stats->tx_err);
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
+	}
 
+	if (skb_shinfo(skb)->nr_frags != 0) {
+		printk("nicstar%d: No scatter-gather yet.\n", card->index);
+		atomic_inc(&vcc->stats->tx_err);
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
+	}
+
+	ATM_SKB(skb)->vcc = vcc;
+
+	if (vcc->qos.aal == ATM_AAL5) {
+		buflen = (skb->len + 47 + 8) / 48 * 48;	/* Multiple of 48 */
+		flags = NS_TBD_AAL5;
+		scqe.word_2 = cpu_to_le32((u32) virt_to_bus(skb->data));
+		scqe.word_3 = cpu_to_le32((u32) skb->len);
+		scqe.word_4 =
+		    ns_tbd_mkword_4(0, (u32) vcc->vpi, (u32) vcc->vci, 0,
+				    ATM_SKB(skb)->
+				    atm_options & ATM_ATMOPT_CLP ? 1 : 0);
+		flags |= NS_TBD_EOPDU;
+	} else {		/* (vcc->qos.aal == ATM_AAL0) */
+
+		buflen = ATM_CELL_PAYLOAD;	/* i.e., 48 bytes */
+		flags = NS_TBD_AAL0;
+		scqe.word_2 =
+		    cpu_to_le32((u32) virt_to_bus(skb->data) + NS_AAL0_HEADER);
+		scqe.word_3 = cpu_to_le32(0x00000000);
+		if (*skb->data & 0x02)	/* Payload type 1 - end of pdu */
+			flags |= NS_TBD_EOPDU;
+		scqe.word_4 =
+		    cpu_to_le32(*((u32 *) skb->data) & ~NS_TBD_VC_MASK);
+		/* Force the VPI/VCI to be the same as in VCC struct */
+		scqe.word_4 |=
+		    cpu_to_le32((((u32) vcc->
+				  vpi) << NS_TBD_VPI_SHIFT | ((u32) vcc->
+							      vci) <<
+				 NS_TBD_VCI_SHIFT) & NS_TBD_VC_MASK);
+	}
+
+	if (vcc->qos.txtp.traffic_class == ATM_CBR) {
+		scqe.word_1 = ns_tbd_mkword_1_novbr(flags, (u32) buflen);
+		scq = ((vc_map *) vcc->dev_data)->scq;
+	} else {
+		scqe.word_1 =
+		    ns_tbd_mkword_1(flags, (u32) 1, (u32) 1, (u32) buflen);
+		scq = card->scq0;
+	}
+
+	if (push_scqe(card, vc, scq, &scqe, skb) != 0) {
+		atomic_inc(&vcc->stats->tx_err);
+		dev_kfree_skb_any(skb);
+		return -EIO;
+	}
+	atomic_inc(&vcc->stats->tx);
 
+	return 0;
+}
 
-static void process_tsq(ns_dev *card)
+static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
+		     struct sk_buff *skb)
 {
-   u32 scdi;
-   scq_info *scq;
-   ns_tsi *previous = NULL, *one_ahead, *two_ahead;
-   int serviced_entries;   /* flag indicating at least on entry was serviced */
-   
-   serviced_entries = 0;
-   
-   if (card->tsq.next == card->tsq.last)
-      one_ahead = card->tsq.base;
-   else
-      one_ahead = card->tsq.next + 1;
-
-   if (one_ahead == card->tsq.last)
-      two_ahead = card->tsq.base;
-   else
-      two_ahead = one_ahead + 1;
-   
-   while (!ns_tsi_isempty(card->tsq.next) || !ns_tsi_isempty(one_ahead) ||
-          !ns_tsi_isempty(two_ahead))
-          /* At most two empty, as stated in the 77201 errata */
-   {
-      serviced_entries = 1;
-    
-      /* Skip the one or two possible empty entries */
-      while (ns_tsi_isempty(card->tsq.next)) {
-         if (card->tsq.next == card->tsq.last)
-            card->tsq.next = card->tsq.base;
-         else
-            card->tsq.next++;
-      }
-    
-      if (!ns_tsi_tmrof(card->tsq.next))
-      {
-         scdi = ns_tsi_getscdindex(card->tsq.next);
-	 if (scdi == NS_TSI_SCDISVBR)
-	    scq = card->scq0;
-	 else
-	 {
-	    if (card->scd2vc[scdi] == NULL)
-	    {
-	       printk("nicstar%d: could not find VC from SCD index.\n",
-	              card->index);
-               ns_tsi_init(card->tsq.next);
-               return;
-            }
-            scq = card->scd2vc[scdi]->scq;
-         }
-         drain_scq(card, scq, ns_tsi_getscqpos(card->tsq.next));
-         scq->full = 0;
-         wake_up_interruptible(&(scq->scqfull_waitq));
-      }
-
-      ns_tsi_init(card->tsq.next);
-      previous = card->tsq.next;
-      if (card->tsq.next == card->tsq.last)
-         card->tsq.next = card->tsq.base;
-      else
-         card->tsq.next++;
-
-      if (card->tsq.next == card->tsq.last)
-         one_ahead = card->tsq.base;
-      else
-         one_ahead = card->tsq.next + 1;
-
-      if (one_ahead == card->tsq.last)
-         two_ahead = card->tsq.base;
-      else
-         two_ahead = one_ahead + 1;
-   }
-
-   if (serviced_entries) {
-      writel((((u32) previous) - ((u32) card->tsq.base)),
-             card->membase + TSQH);
-   }
+	unsigned long flags;
+	ns_scqe tsr;
+	u32 scdi, scqi;
+	int scq_is_vbr;
+	u32 data;
+	int index;
+
+	spin_lock_irqsave(&scq->lock, flags);
+	while (scq->tail == scq->next) {
+		if (in_interrupt()) {
+			spin_unlock_irqrestore(&scq->lock, flags);
+			printk("nicstar%d: Error pushing TBD.\n", card->index);
+			return 1;
+		}
+
+		scq->full = 1;
+		spin_unlock_irqrestore(&scq->lock, flags);
+		interruptible_sleep_on_timeout(&scq->scqfull_waitq,
+					       SCQFULL_TIMEOUT);
+		spin_lock_irqsave(&scq->lock, flags);
+
+		if (scq->full) {
+			spin_unlock_irqrestore(&scq->lock, flags);
+			printk("nicstar%d: Timeout pushing TBD.\n",
+			       card->index);
+			return 1;
+		}
+	}
+	*scq->next = *tbd;
+	index = (int)(scq->next - scq->base);
+	scq->skb[index] = skb;
+	XPRINTK("nicstar%d: sending skb at 0x%x (pos %d).\n",
+		card->index, (u32) skb, index);
+	XPRINTK("nicstar%d: TBD written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%x.\n",
+		card->index, le32_to_cpu(tbd->word_1), le32_to_cpu(tbd->word_2),
+		le32_to_cpu(tbd->word_3), le32_to_cpu(tbd->word_4),
+		(u32) scq->next);
+	if (scq->next == scq->last)
+		scq->next = scq->base;
+	else
+		scq->next++;
+
+	vc->tbd_count++;
+	if (scq->num_entries == VBR_SCQ_NUM_ENTRIES) {
+		scq->tbd_count++;
+		scq_is_vbr = 1;
+	} else
+		scq_is_vbr = 0;
+
+	if (vc->tbd_count >= MAX_TBD_PER_VC
+	    || scq->tbd_count >= MAX_TBD_PER_SCQ) {
+		int has_run = 0;
+
+		while (scq->tail == scq->next) {
+			if (in_interrupt()) {
+				data = (u32) virt_to_bus(scq->next);
+				ns_write_sram(card, scq->scd, &data, 1);
+				spin_unlock_irqrestore(&scq->lock, flags);
+				printk("nicstar%d: Error pushing TSR.\n",
+				       card->index);
+				return 0;
+			}
+
+			scq->full = 1;
+			if (has_run++)
+				break;
+			spin_unlock_irqrestore(&scq->lock, flags);
+			interruptible_sleep_on_timeout(&scq->scqfull_waitq,
+						       SCQFULL_TIMEOUT);
+			spin_lock_irqsave(&scq->lock, flags);
+		}
+
+		if (!scq->full) {
+			tsr.word_1 = ns_tsr_mkword_1(NS_TSR_INTENABLE);
+			if (scq_is_vbr)
+				scdi = NS_TSR_SCDISVBR;
+			else
+				scdi = (vc->cbr_scd - NS_FRSCD) / NS_FRSCD_SIZE;
+			scqi = scq->next - scq->base;
+			tsr.word_2 = ns_tsr_mkword_2(scdi, scqi);
+			tsr.word_3 = 0x00000000;
+			tsr.word_4 = 0x00000000;
+
+			*scq->next = tsr;
+			index = (int)scqi;
+			scq->skb[index] = NULL;
+			XPRINTK
+			    ("nicstar%d: TSR written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%x.\n",
+			     card->index, le32_to_cpu(tsr.word_1),
+			     le32_to_cpu(tsr.word_2), le32_to_cpu(tsr.word_3),
+			     le32_to_cpu(tsr.word_4), (u32) scq->next);
+			if (scq->next == scq->last)
+				scq->next = scq->base;
+			else
+				scq->next++;
+			vc->tbd_count = 0;
+			scq->tbd_count = 0;
+		} else
+			PRINTK("nicstar%d: Timeout pushing TSR.\n",
+			       card->index);
+	}
+	data = (u32) virt_to_bus(scq->next);
+	ns_write_sram(card, scq->scd, &data, 1);
+
+	spin_unlock_irqrestore(&scq->lock, flags);
+
+	return 0;
 }
 
-
-
-static void drain_scq(ns_dev *card, scq_info *scq, int pos)
+static void process_tsq(ns_dev * card)
 {
-   struct atm_vcc *vcc;
-   struct sk_buff *skb;
-   int i;
-   unsigned long flags;
-   
-   XPRINTK("nicstar%d: drain_scq() called, scq at 0x%x, pos %d.\n",
-           card->index, (u32) scq, pos);
-   if (pos >= scq->num_entries)
-   {
-      printk("nicstar%d: Bad index on drain_scq().\n", card->index);
-      return;
-   }
-
-   spin_lock_irqsave(&scq->lock, flags);
-   i = (int) (scq->tail - scq->base);
-   if (++i == scq->num_entries)
-      i = 0;
-   while (i != pos)
-   {
-      skb = scq->skb[i];
-      XPRINTK("nicstar%d: freeing skb at 0x%x (index %d).\n",
-              card->index, (u32) skb, i);
-      if (skb != NULL)
-      {
-         vcc = ATM_SKB(skb)->vcc;
-	 if (vcc && vcc->pop != NULL) {
-	    vcc->pop(vcc, skb);
-	 } else {
-	    dev_kfree_skb_irq(skb);
-         }
-	 scq->skb[i] = NULL;
-      }
-      if (++i == scq->num_entries)
-         i = 0;
-   }
-   scq->tail = scq->base + pos;
-   spin_unlock_irqrestore(&scq->lock, flags);
+	u32 scdi;
+	scq_info *scq;
+	ns_tsi *previous = NULL, *one_ahead, *two_ahead;
+	int serviced_entries;	/* flag indicating at least on entry was serviced */
+
+	serviced_entries = 0;
+
+	if (card->tsq.next == card->tsq.last)
+		one_ahead = card->tsq.base;
+	else
+		one_ahead = card->tsq.next + 1;
+
+	if (one_ahead == card->tsq.last)
+		two_ahead = card->tsq.base;
+	else
+		two_ahead = one_ahead + 1;
+
+	while (!ns_tsi_isempty(card->tsq.next) || !ns_tsi_isempty(one_ahead) ||
+	       !ns_tsi_isempty(two_ahead))
+		/* At most two empty, as stated in the 77201 errata */
+	{
+		serviced_entries = 1;
+
+		/* Skip the one or two possible empty entries */
+		while (ns_tsi_isempty(card->tsq.next)) {
+			if (card->tsq.next == card->tsq.last)
+				card->tsq.next = card->tsq.base;
+			else
+				card->tsq.next++;
+		}
+
+		if (!ns_tsi_tmrof(card->tsq.next)) {
+			scdi = ns_tsi_getscdindex(card->tsq.next);
+			if (scdi == NS_TSI_SCDISVBR)
+				scq = card->scq0;
+			else {
+				if (card->scd2vc[scdi] == NULL) {
+					printk
+					    ("nicstar%d: could not find VC from SCD index.\n",
+					     card->index);
+					ns_tsi_init(card->tsq.next);
+					return;
+				}
+				scq = card->scd2vc[scdi]->scq;
+			}
+			drain_scq(card, scq, ns_tsi_getscqpos(card->tsq.next));
+			scq->full = 0;
+			wake_up_interruptible(&(scq->scqfull_waitq));
+		}
+
+		ns_tsi_init(card->tsq.next);
+		previous = card->tsq.next;
+		if (card->tsq.next == card->tsq.last)
+			card->tsq.next = card->tsq.base;
+		else
+			card->tsq.next++;
+
+		if (card->tsq.next == card->tsq.last)
+			one_ahead = card->tsq.base;
+		else
+			one_ahead = card->tsq.next + 1;
+
+		if (one_ahead == card->tsq.last)
+			two_ahead = card->tsq.base;
+		else
+			two_ahead = one_ahead + 1;
+	}
+
+	if (serviced_entries) {
+		writel((((u32) previous) - ((u32) card->tsq.base)),
+		       card->membase + TSQH);
+	}
 }
 
-
-
-static void process_rsq(ns_dev *card)
+static void drain_scq(ns_dev * card, scq_info * scq, int pos)
 {
-   ns_rsqe *previous;
-
-   if (!ns_rsqe_valid(card->rsq.next))
-      return;
-   do {
-      dequeue_rx(card, card->rsq.next);
-      ns_rsqe_init(card->rsq.next);
-      previous = card->rsq.next;
-      if (card->rsq.next == card->rsq.last)
-         card->rsq.next = card->rsq.base;
-      else
-         card->rsq.next++;
-   } while (ns_rsqe_valid(card->rsq.next));
-   writel((((u32) previous) - ((u32) card->rsq.base)),
-          card->membase + RSQH);
+	struct atm_vcc *vcc;
+	struct sk_buff *skb;
+	int i;
+	unsigned long flags;
+
+	XPRINTK("nicstar%d: drain_scq() called, scq at 0x%x, pos %d.\n",
+		card->index, (u32) scq, pos);
+	if (pos >= scq->num_entries) {
+		printk("nicstar%d: Bad index on drain_scq().\n", card->index);
+		return;
+	}
+
+	spin_lock_irqsave(&scq->lock, flags);
+	i = (int)(scq->tail - scq->base);
+	if (++i == scq->num_entries)
+		i = 0;
+	while (i != pos) {
+		skb = scq->skb[i];
+		XPRINTK("nicstar%d: freeing skb at 0x%x (index %d).\n",
+			card->index, (u32) skb, i);
+		if (skb != NULL) {
+			vcc = ATM_SKB(skb)->vcc;
+			if (vcc && vcc->pop != NULL) {
+				vcc->pop(vcc, skb);
+			} else {
+				dev_kfree_skb_irq(skb);
+			}
+			scq->skb[i] = NULL;
+		}
+		if (++i == scq->num_entries)
+			i = 0;
+	}
+	scq->tail = scq->base + pos;
+	spin_unlock_irqrestore(&scq->lock, flags);
 }
 
+static void process_rsq(ns_dev * card)
+{
+	ns_rsqe *previous;
+
+	if (!ns_rsqe_valid(card->rsq.next))
+		return;
+	do {
+		dequeue_rx(card, card->rsq.next);
+		ns_rsqe_init(card->rsq.next);
+		previous = card->rsq.next;
+		if (card->rsq.next == card->rsq.last)
+			card->rsq.next = card->rsq.base;
+		else
+			card->rsq.next++;
+	} while (ns_rsqe_valid(card->rsq.next));
+	writel((((u32) previous) - ((u32) card->rsq.base)),
+	       card->membase + RSQH);
+}
 
-
-static void dequeue_rx(ns_dev *card, ns_rsqe *rsqe)
+static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 {
-   u32 vpi, vci;
-   vc_map *vc;
-   struct sk_buff *iovb;
-   struct iovec *iov;
-   struct atm_vcc *vcc;
-   struct sk_buff *skb;
-   unsigned short aal5_len;
-   int len;
-   u32 stat;
-
-   stat = readl(card->membase + STAT);
-   card->sbfqc = ns_stat_sfbqc_get(stat);   
-   card->lbfqc = ns_stat_lfbqc_get(stat);
-
-   skb = (struct sk_buff *) le32_to_cpu(rsqe->buffer_handle);
-   vpi = ns_rsqe_vpi(rsqe);
-   vci = ns_rsqe_vci(rsqe);
-   if (vpi >= 1UL << card->vpibits || vci >= 1UL << card->vcibits)
-   {
-      printk("nicstar%d: SDU received for out-of-range vc %d.%d.\n",
-             card->index, vpi, vci);
-      recycle_rx_buf(card, skb);
-      return;
-   }
-   
-   vc = &(card->vcmap[vpi << card->vcibits | vci]);
-   if (!vc->rx)
-   {
-      RXPRINTK("nicstar%d: SDU received on non-rx vc %d.%d.\n",
-             card->index, vpi, vci);
-      recycle_rx_buf(card, skb);
-      return;
-   }
-
-   vcc = vc->rx_vcc;
-
-   if (vcc->qos.aal == ATM_AAL0)
-   {
-      struct sk_buff *sb;
-      unsigned char *cell;
-      int i;
-
-      cell = skb->data;
-      for (i = ns_rsqe_cellcount(rsqe); i; i--)
-      {
-         if ((sb = dev_alloc_skb(NS_SMSKBSIZE)) == NULL)
-         {
-            printk("nicstar%d: Can't allocate buffers for aal0.\n",
-                   card->index);
-            atomic_add(i,&vcc->stats->rx_drop);
-            break;
-         }
-         if (!atm_charge(vcc, sb->truesize))
-         {
-            RXPRINTK("nicstar%d: atm_charge() dropped aal0 packets.\n",
-                     card->index);
-            atomic_add(i-1,&vcc->stats->rx_drop); /* already increased by 1 */
-            dev_kfree_skb_any(sb);
-            break;
-         }
-         /* Rebuild the header */
-         *((u32 *) sb->data) = le32_to_cpu(rsqe->word_1) << 4 |
-                               (ns_rsqe_clp(rsqe) ? 0x00000001 : 0x00000000);
-         if (i == 1 && ns_rsqe_eopdu(rsqe))
-            *((u32 *) sb->data) |= 0x00000002;
-         skb_put(sb, NS_AAL0_HEADER);
-         memcpy(skb_tail_pointer(sb), cell, ATM_CELL_PAYLOAD);
-         skb_put(sb, ATM_CELL_PAYLOAD);
-         ATM_SKB(sb)->vcc = vcc;
-	 __net_timestamp(sb);
-         vcc->push(vcc, sb);
-         atomic_inc(&vcc->stats->rx);
-         cell += ATM_CELL_PAYLOAD;
-      }
-
-      recycle_rx_buf(card, skb);
-      return;
-   }
-
-   /* To reach this point, the AAL layer can only be AAL5 */
-
-   if ((iovb = vc->rx_iov) == NULL)
-   {
-      iovb = skb_dequeue(&(card->iovpool.queue));
-      if (iovb == NULL)		/* No buffers in the queue */
-      {
-         iovb = alloc_skb(NS_IOVBUFSIZE, GFP_ATOMIC);
-	 if (iovb == NULL)
-	 {
-	    printk("nicstar%d: Out of iovec buffers.\n", card->index);
-            atomic_inc(&vcc->stats->rx_drop);
-            recycle_rx_buf(card, skb);
-            return;
-	 }
-         NS_SKB_CB(iovb)->buf_type = BUF_NONE;
-      }
-      else
-         if (--card->iovpool.count < card->iovnr.min)
-	 {
-	    struct sk_buff *new_iovb;
-	    if ((new_iovb = alloc_skb(NS_IOVBUFSIZE, GFP_ATOMIC)) != NULL)
-	    {
-               NS_SKB_CB(iovb)->buf_type = BUF_NONE;
-               skb_queue_tail(&card->iovpool.queue, new_iovb);
-               card->iovpool.count++;
-	    }
-	 }
-      vc->rx_iov = iovb;
-      NS_SKB(iovb)->iovcnt = 0;
-      iovb->len = 0;
-      iovb->data = iovb->head;
-      skb_reset_tail_pointer(iovb);
-      NS_SKB(iovb)->vcc = vcc;
-      /* IMPORTANT: a pointer to the sk_buff containing the small or large
-                    buffer is stored as iovec base, NOT a pointer to the 
-	            small or large buffer itself. */
-   }
-   else if (NS_SKB(iovb)->iovcnt >= NS_MAX_IOVECS)
-   {
-      printk("nicstar%d: received too big AAL5 SDU.\n", card->index);
-      atomic_inc(&vcc->stats->rx_err);
-      recycle_iovec_rx_bufs(card, (struct iovec *) iovb->data, NS_MAX_IOVECS);
-      NS_SKB(iovb)->iovcnt = 0;
-      iovb->len = 0;
-      iovb->data = iovb->head;
-      skb_reset_tail_pointer(iovb);
-      NS_SKB(iovb)->vcc = vcc;
-   }
-   iov = &((struct iovec *) iovb->data)[NS_SKB(iovb)->iovcnt++];
-   iov->iov_base = (void *) skb;
-   iov->iov_len = ns_rsqe_cellcount(rsqe) * 48;
-   iovb->len += iov->iov_len;
-
-   if (NS_SKB(iovb)->iovcnt == 1)
-   {
-      if (NS_SKB_CB(skb)->buf_type != BUF_SM)
-      {
-         printk("nicstar%d: Expected a small buffer, and this is not one.\n",
-	        card->index);
-         which_list(card, skb);
-         atomic_inc(&vcc->stats->rx_err);
-         recycle_rx_buf(card, skb);
-         vc->rx_iov = NULL;
-         recycle_iov_buf(card, iovb);
-         return;
-      }
-   }
-   else /* NS_SKB(iovb)->iovcnt >= 2 */
-   {
-      if (NS_SKB_CB(skb)->buf_type != BUF_LG)
-      {
-         printk("nicstar%d: Expected a large buffer, and this is not one.\n",
-	        card->index);
-         which_list(card, skb);
-         atomic_inc(&vcc->stats->rx_err);
-         recycle_iovec_rx_bufs(card, (struct iovec *) iovb->data,
-	                       NS_SKB(iovb)->iovcnt);
-         vc->rx_iov = NULL;
-         recycle_iov_buf(card, iovb);
-	 return;
-      }
-   }
-
-   if (ns_rsqe_eopdu(rsqe))
-   {
-      /* This works correctly regardless of the endianness of the host */
-      unsigned char *L1L2 = (unsigned char *)((u32)skb->data +
-                                              iov->iov_len - 6);
-      aal5_len = L1L2[0] << 8 | L1L2[1];
-      len = (aal5_len == 0x0000) ? 0x10000 : aal5_len;
-      if (ns_rsqe_crcerr(rsqe) ||
-          len + 8 > iovb->len || len + (47 + 8) < iovb->len)
-      {
-         printk("nicstar%d: AAL5 CRC error", card->index);
-         if (len + 8 > iovb->len || len + (47 + 8) < iovb->len)
-            printk(" - PDU size mismatch.\n");
-         else
-            printk(".\n");
-         atomic_inc(&vcc->stats->rx_err);
-         recycle_iovec_rx_bufs(card, (struct iovec *) iovb->data,
-	   NS_SKB(iovb)->iovcnt);
-	 vc->rx_iov = NULL;
-         recycle_iov_buf(card, iovb);
-	 return;
-      }
-
-      /* By this point we (hopefully) have a complete SDU without errors. */
-
-      if (NS_SKB(iovb)->iovcnt == 1)	/* Just a small buffer */
-      {
-         /* skb points to a small buffer */
-         if (!atm_charge(vcc, skb->truesize))
-         {
-            push_rxbufs(card, skb);
-            atomic_inc(&vcc->stats->rx_drop);
-         }
-         else
-	 {
-            skb_put(skb, len);
-            dequeue_sm_buf(card, skb);
+	u32 vpi, vci;
+	vc_map *vc;
+	struct sk_buff *iovb;
+	struct iovec *iov;
+	struct atm_vcc *vcc;
+	struct sk_buff *skb;
+	unsigned short aal5_len;
+	int len;
+	u32 stat;
+
+	stat = readl(card->membase + STAT);
+	card->sbfqc = ns_stat_sfbqc_get(stat);
+	card->lbfqc = ns_stat_lfbqc_get(stat);
+
+	skb = (struct sk_buff *)le32_to_cpu(rsqe->buffer_handle);
+	vpi = ns_rsqe_vpi(rsqe);
+	vci = ns_rsqe_vci(rsqe);
+	if (vpi >= 1UL << card->vpibits || vci >= 1UL << card->vcibits) {
+		printk("nicstar%d: SDU received for out-of-range vc %d.%d.\n",
+		       card->index, vpi, vci);
+		recycle_rx_buf(card, skb);
+		return;
+	}
+
+	vc = &(card->vcmap[vpi << card->vcibits | vci]);
+	if (!vc->rx) {
+		RXPRINTK("nicstar%d: SDU received on non-rx vc %d.%d.\n",
+			 card->index, vpi, vci);
+		recycle_rx_buf(card, skb);
+		return;
+	}
+
+	vcc = vc->rx_vcc;
+
+	if (vcc->qos.aal == ATM_AAL0) {
+		struct sk_buff *sb;
+		unsigned char *cell;
+		int i;
+
+		cell = skb->data;
+		for (i = ns_rsqe_cellcount(rsqe); i; i--) {
+			if ((sb = dev_alloc_skb(NS_SMSKBSIZE)) == NULL) {
+				printk
+				    ("nicstar%d: Can't allocate buffers for aal0.\n",
+				     card->index);
+				atomic_add(i, &vcc->stats->rx_drop);
+				break;
+			}
+			if (!atm_charge(vcc, sb->truesize)) {
+				RXPRINTK
+				    ("nicstar%d: atm_charge() dropped aal0 packets.\n",
+				     card->index);
+				atomic_add(i - 1, &vcc->stats->rx_drop);	/* already increased by 1 */
+				dev_kfree_skb_any(sb);
+				break;
+			}
+			/* Rebuild the header */
+			*((u32 *) sb->data) = le32_to_cpu(rsqe->word_1) << 4 |
+			    (ns_rsqe_clp(rsqe) ? 0x00000001 : 0x00000000);
+			if (i == 1 && ns_rsqe_eopdu(rsqe))
+				*((u32 *) sb->data) |= 0x00000002;
+			skb_put(sb, NS_AAL0_HEADER);
+			memcpy(skb_tail_pointer(sb), cell, ATM_CELL_PAYLOAD);
+			skb_put(sb, ATM_CELL_PAYLOAD);
+			ATM_SKB(sb)->vcc = vcc;
+			__net_timestamp(sb);
+			vcc->push(vcc, sb);
+			atomic_inc(&vcc->stats->rx);
+			cell += ATM_CELL_PAYLOAD;
+		}
+
+		recycle_rx_buf(card, skb);
+		return;
+	}
+
+	/* To reach this point, the AAL layer can only be AAL5 */
+
+	if ((iovb = vc->rx_iov) == NULL) {
+		iovb = skb_dequeue(&(card->iovpool.queue));
+		if (iovb == NULL) {	/* No buffers in the queue */
+			iovb = alloc_skb(NS_IOVBUFSIZE, GFP_ATOMIC);
+			if (iovb == NULL) {
+				printk("nicstar%d: Out of iovec buffers.\n",
+				       card->index);
+				atomic_inc(&vcc->stats->rx_drop);
+				recycle_rx_buf(card, skb);
+				return;
+			}
+			NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+		} else if (--card->iovpool.count < card->iovnr.min) {
+			struct sk_buff *new_iovb;
+			if ((new_iovb =
+			     alloc_skb(NS_IOVBUFSIZE, GFP_ATOMIC)) != NULL) {
+				NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+				skb_queue_tail(&card->iovpool.queue, new_iovb);
+				card->iovpool.count++;
+			}
+		}
+		vc->rx_iov = iovb;
+		NS_SKB(iovb)->iovcnt = 0;
+		iovb->len = 0;
+		iovb->data = iovb->head;
+		skb_reset_tail_pointer(iovb);
+		NS_SKB(iovb)->vcc = vcc;
+		/* IMPORTANT: a pointer to the sk_buff containing the small or large
+		   buffer is stored as iovec base, NOT a pointer to the
+		   small or large buffer itself. */
+	} else if (NS_SKB(iovb)->iovcnt >= NS_MAX_IOVECS) {
+		printk("nicstar%d: received too big AAL5 SDU.\n", card->index);
+		atomic_inc(&vcc->stats->rx_err);
+		recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
+				      NS_MAX_IOVECS);
+		NS_SKB(iovb)->iovcnt = 0;
+		iovb->len = 0;
+		iovb->data = iovb->head;
+		skb_reset_tail_pointer(iovb);
+		NS_SKB(iovb)->vcc = vcc;
+	}
+	iov = &((struct iovec *)iovb->data)[NS_SKB(iovb)->iovcnt++];
+	iov->iov_base = (void *)skb;
+	iov->iov_len = ns_rsqe_cellcount(rsqe) * 48;
+	iovb->len += iov->iov_len;
+
+	if (NS_SKB(iovb)->iovcnt == 1) {
+		if (NS_SKB_CB(skb)->buf_type != BUF_SM) {
+			printk
+			    ("nicstar%d: Expected a small buffer, and this is not one.\n",
+			     card->index);
+			which_list(card, skb);
+			atomic_inc(&vcc->stats->rx_err);
+			recycle_rx_buf(card, skb);
+			vc->rx_iov = NULL;
+			recycle_iov_buf(card, iovb);
+			return;
+		}
+	} else {		/* NS_SKB(iovb)->iovcnt >= 2 */
+
+		if (NS_SKB_CB(skb)->buf_type != BUF_LG) {
+			printk
+			    ("nicstar%d: Expected a large buffer, and this is not one.\n",
+			     card->index);
+			which_list(card, skb);
+			atomic_inc(&vcc->stats->rx_err);
+			recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
+					      NS_SKB(iovb)->iovcnt);
+			vc->rx_iov = NULL;
+			recycle_iov_buf(card, iovb);
+			return;
+		}
+	}
+
+	if (ns_rsqe_eopdu(rsqe)) {
+		/* This works correctly regardless of the endianness of the host */
+		unsigned char *L1L2 = (unsigned char *)((u32) skb->data +
+							iov->iov_len - 6);
+		aal5_len = L1L2[0] << 8 | L1L2[1];
+		len = (aal5_len == 0x0000) ? 0x10000 : aal5_len;
+		if (ns_rsqe_crcerr(rsqe) ||
+		    len + 8 > iovb->len || len + (47 + 8) < iovb->len) {
+			printk("nicstar%d: AAL5 CRC error", card->index);
+			if (len + 8 > iovb->len || len + (47 + 8) < iovb->len)
+				printk(" - PDU size mismatch.\n");
+			else
+				printk(".\n");
+			atomic_inc(&vcc->stats->rx_err);
+			recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
+					      NS_SKB(iovb)->iovcnt);
+			vc->rx_iov = NULL;
+			recycle_iov_buf(card, iovb);
+			return;
+		}
+
+		/* By this point we (hopefully) have a complete SDU without errors. */
+
+		if (NS_SKB(iovb)->iovcnt == 1) {	/* Just a small buffer */
+			/* skb points to a small buffer */
+			if (!atm_charge(vcc, skb->truesize)) {
+				push_rxbufs(card, skb);
+				atomic_inc(&vcc->stats->rx_drop);
+			} else {
+				skb_put(skb, len);
+				dequeue_sm_buf(card, skb);
 #ifdef NS_USE_DESTRUCTORS
-            skb->destructor = ns_sb_destructor;
+				skb->destructor = ns_sb_destructor;
 #endif /* NS_USE_DESTRUCTORS */
-            ATM_SKB(skb)->vcc = vcc;
-	    __net_timestamp(skb);
-            vcc->push(vcc, skb);
-            atomic_inc(&vcc->stats->rx);
-         }
-      }
-      else if (NS_SKB(iovb)->iovcnt == 2)	/* One small plus one large buffer */
-      {
-         struct sk_buff *sb;
-
-         sb = (struct sk_buff *) (iov - 1)->iov_base;
-         /* skb points to a large buffer */
-
-         if (len <= NS_SMBUFSIZE)
-	 {
-            if (!atm_charge(vcc, sb->truesize))
-            {
-               push_rxbufs(card, sb);
-               atomic_inc(&vcc->stats->rx_drop);
-            }
-            else
-	    {
-               skb_put(sb, len);
-               dequeue_sm_buf(card, sb);
+				ATM_SKB(skb)->vcc = vcc;
+				__net_timestamp(skb);
+				vcc->push(vcc, skb);
+				atomic_inc(&vcc->stats->rx);
+			}
+		} else if (NS_SKB(iovb)->iovcnt == 2) {	/* One small plus one large buffer */
+			struct sk_buff *sb;
+
+			sb = (struct sk_buff *)(iov - 1)->iov_base;
+			/* skb points to a large buffer */
+
+			if (len <= NS_SMBUFSIZE) {
+				if (!atm_charge(vcc, sb->truesize)) {
+					push_rxbufs(card, sb);
+					atomic_inc(&vcc->stats->rx_drop);
+				} else {
+					skb_put(sb, len);
+					dequeue_sm_buf(card, sb);
 #ifdef NS_USE_DESTRUCTORS
-               sb->destructor = ns_sb_destructor;
+					sb->destructor = ns_sb_destructor;
 #endif /* NS_USE_DESTRUCTORS */
-               ATM_SKB(sb)->vcc = vcc;
-	       __net_timestamp(sb);
-               vcc->push(vcc, sb);
-               atomic_inc(&vcc->stats->rx);
-            }
-
-            push_rxbufs(card, skb);
-
-	 }
-	 else			/* len > NS_SMBUFSIZE, the usual case */
-	 {
-            if (!atm_charge(vcc, skb->truesize))
-            {
-               push_rxbufs(card, skb);
-               atomic_inc(&vcc->stats->rx_drop);
-            }
-            else
-            {
-               dequeue_lg_buf(card, skb);
+					ATM_SKB(sb)->vcc = vcc;
+					__net_timestamp(sb);
+					vcc->push(vcc, sb);
+					atomic_inc(&vcc->stats->rx);
+				}
+
+				push_rxbufs(card, skb);
+
+			} else {	/* len > NS_SMBUFSIZE, the usual case */
+
+				if (!atm_charge(vcc, skb->truesize)) {
+					push_rxbufs(card, skb);
+					atomic_inc(&vcc->stats->rx_drop);
+				} else {
+					dequeue_lg_buf(card, skb);
 #ifdef NS_USE_DESTRUCTORS
-               skb->destructor = ns_lb_destructor;
+					skb->destructor = ns_lb_destructor;
 #endif /* NS_USE_DESTRUCTORS */
-               skb_push(skb, NS_SMBUFSIZE);
-               skb_copy_from_linear_data(sb, skb->data, NS_SMBUFSIZE);
-               skb_put(skb, len - NS_SMBUFSIZE);
-               ATM_SKB(skb)->vcc = vcc;
-	       __net_timestamp(skb);
-               vcc->push(vcc, skb);
-               atomic_inc(&vcc->stats->rx);
-            }
-
-            push_rxbufs(card, sb);
-
-         }
-	 
-      }
-      else				/* Must push a huge buffer */
-      {
-         struct sk_buff *hb, *sb, *lb;
-	 int remaining, tocopy;
-         int j;
-
-         hb = skb_dequeue(&(card->hbpool.queue));
-         if (hb == NULL)		/* No buffers in the queue */
-         {
-
-            hb = dev_alloc_skb(NS_HBUFSIZE);
-            if (hb == NULL)
-            {
-               printk("nicstar%d: Out of huge buffers.\n", card->index);
-               atomic_inc(&vcc->stats->rx_drop);
-               recycle_iovec_rx_bufs(card, (struct iovec *) iovb->data,
-	                             NS_SKB(iovb)->iovcnt);
-               vc->rx_iov = NULL;
-               recycle_iov_buf(card, iovb);
-               return;
-            }
-            else if (card->hbpool.count < card->hbnr.min)
-	    {
-               struct sk_buff *new_hb;
-               if ((new_hb = dev_alloc_skb(NS_HBUFSIZE)) != NULL)
-               {
-                  skb_queue_tail(&card->hbpool.queue, new_hb);
-                  card->hbpool.count++;
-               }
-            }
-            NS_SKB_CB(hb)->buf_type = BUF_NONE;
-	 }
-	 else
-         if (--card->hbpool.count < card->hbnr.min)
-         {
-            struct sk_buff *new_hb;
-            if ((new_hb = dev_alloc_skb(NS_HBUFSIZE)) != NULL)
-            {
-               NS_SKB_CB(new_hb)->buf_type = BUF_NONE;
-               skb_queue_tail(&card->hbpool.queue, new_hb);
-               card->hbpool.count++;
-            }
-            if (card->hbpool.count < card->hbnr.min)
-	    {
-               if ((new_hb = dev_alloc_skb(NS_HBUFSIZE)) != NULL)
-               {
-                  NS_SKB_CB(new_hb)->buf_type = BUF_NONE;
-                  skb_queue_tail(&card->hbpool.queue, new_hb);
-                  card->hbpool.count++;
-               }
-            }
-         }
-
-         iov = (struct iovec *) iovb->data;
-
-         if (!atm_charge(vcc, hb->truesize))
-	 {
-            recycle_iovec_rx_bufs(card, iov, NS_SKB(iovb)->iovcnt);
-            if (card->hbpool.count < card->hbnr.max)
-            {
-               skb_queue_tail(&card->hbpool.queue, hb);
-               card->hbpool.count++;
-            }
-	    else
-	       dev_kfree_skb_any(hb);
-	    atomic_inc(&vcc->stats->rx_drop);
-         }
-         else
-	 {
-            /* Copy the small buffer to the huge buffer */
-            sb = (struct sk_buff *) iov->iov_base;
-            skb_copy_from_linear_data(sb, hb->data, iov->iov_len);
-            skb_put(hb, iov->iov_len);
-            remaining = len - iov->iov_len;
-            iov++;
-            /* Free the small buffer */
-            push_rxbufs(card, sb);
-
-            /* Copy all large buffers to the huge buffer and free them */
-            for (j = 1; j < NS_SKB(iovb)->iovcnt; j++)
-            {
-               lb = (struct sk_buff *) iov->iov_base;
-               tocopy = min_t(int, remaining, iov->iov_len);
-               skb_copy_from_linear_data(lb, skb_tail_pointer(hb), tocopy);
-               skb_put(hb, tocopy);
-               iov++;
-               remaining -= tocopy;
-               push_rxbufs(card, lb);
-            }
+					skb_push(skb, NS_SMBUFSIZE);
+					skb_copy_from_linear_data(sb, skb->data,
+								  NS_SMBUFSIZE);
+					skb_put(skb, len - NS_SMBUFSIZE);
+					ATM_SKB(skb)->vcc = vcc;
+					__net_timestamp(skb);
+					vcc->push(vcc, skb);
+					atomic_inc(&vcc->stats->rx);
+				}
+
+				push_rxbufs(card, sb);
+
+			}
+
+		} else {	/* Must push a huge buffer */
+
+			struct sk_buff *hb, *sb, *lb;
+			int remaining, tocopy;
+			int j;
+
+			hb = skb_dequeue(&(card->hbpool.queue));
+			if (hb == NULL) {	/* No buffers in the queue */
+
+				hb = dev_alloc_skb(NS_HBUFSIZE);
+				if (hb == NULL) {
+					printk
+					    ("nicstar%d: Out of huge buffers.\n",
+					     card->index);
+					atomic_inc(&vcc->stats->rx_drop);
+					recycle_iovec_rx_bufs(card,
+							      (struct iovec *)
+							      iovb->data,
+							      NS_SKB(iovb)->
+							      iovcnt);
+					vc->rx_iov = NULL;
+					recycle_iov_buf(card, iovb);
+					return;
+				} else if (card->hbpool.count < card->hbnr.min) {
+					struct sk_buff *new_hb;
+					if ((new_hb =
+					     dev_alloc_skb(NS_HBUFSIZE)) !=
+					    NULL) {
+						skb_queue_tail(&card->hbpool.
+							       queue, new_hb);
+						card->hbpool.count++;
+					}
+				}
+				NS_SKB_CB(hb)->buf_type = BUF_NONE;
+			} else if (--card->hbpool.count < card->hbnr.min) {
+				struct sk_buff *new_hb;
+				if ((new_hb =
+				     dev_alloc_skb(NS_HBUFSIZE)) != NULL) {
+					NS_SKB_CB(new_hb)->buf_type = BUF_NONE;
+					skb_queue_tail(&card->hbpool.queue,
+						       new_hb);
+					card->hbpool.count++;
+				}
+				if (card->hbpool.count < card->hbnr.min) {
+					if ((new_hb =
+					     dev_alloc_skb(NS_HBUFSIZE)) !=
+					    NULL) {
+						NS_SKB_CB(new_hb)->buf_type =
+						    BUF_NONE;
+						skb_queue_tail(&card->hbpool.
+							       queue, new_hb);
+						card->hbpool.count++;
+					}
+				}
+			}
+
+			iov = (struct iovec *)iovb->data;
+
+			if (!atm_charge(vcc, hb->truesize)) {
+				recycle_iovec_rx_bufs(card, iov,
+						      NS_SKB(iovb)->iovcnt);
+				if (card->hbpool.count < card->hbnr.max) {
+					skb_queue_tail(&card->hbpool.queue, hb);
+					card->hbpool.count++;
+				} else
+					dev_kfree_skb_any(hb);
+				atomic_inc(&vcc->stats->rx_drop);
+			} else {
+				/* Copy the small buffer to the huge buffer */
+				sb = (struct sk_buff *)iov->iov_base;
+				skb_copy_from_linear_data(sb, hb->data,
+							  iov->iov_len);
+				skb_put(hb, iov->iov_len);
+				remaining = len - iov->iov_len;
+				iov++;
+				/* Free the small buffer */
+				push_rxbufs(card, sb);
+
+				/* Copy all large buffers to the huge buffer and free them */
+				for (j = 1; j < NS_SKB(iovb)->iovcnt; j++) {
+					lb = (struct sk_buff *)iov->iov_base;
+					tocopy =
+					    min_t(int, remaining, iov->iov_len);
+					skb_copy_from_linear_data(lb,
+								  skb_tail_pointer
+								  (hb), tocopy);
+					skb_put(hb, tocopy);
+					iov++;
+					remaining -= tocopy;
+					push_rxbufs(card, lb);
+				}
 #ifdef EXTRA_DEBUG
-            if (remaining != 0 || hb->len != len)
-               printk("nicstar%d: Huge buffer len mismatch.\n", card->index);
+				if (remaining != 0 || hb->len != len)
+					printk
+					    ("nicstar%d: Huge buffer len mismatch.\n",
+					     card->index);
 #endif /* EXTRA_DEBUG */
-            ATM_SKB(hb)->vcc = vcc;
+				ATM_SKB(hb)->vcc = vcc;
 #ifdef NS_USE_DESTRUCTORS
-            hb->destructor = ns_hb_destructor;
+				hb->destructor = ns_hb_destructor;
 #endif /* NS_USE_DESTRUCTORS */
-	    __net_timestamp(hb);
-            vcc->push(vcc, hb);
-            atomic_inc(&vcc->stats->rx);
-         }
-      }
+				__net_timestamp(hb);
+				vcc->push(vcc, hb);
+				atomic_inc(&vcc->stats->rx);
+			}
+		}
 
-      vc->rx_iov = NULL;
-      recycle_iov_buf(card, iovb);
-   }
+		vc->rx_iov = NULL;
+		recycle_iov_buf(card, iovb);
+	}
 
 }
 
-
-
 #ifdef NS_USE_DESTRUCTORS
 
 static void ns_sb_destructor(struct sk_buff *sb)
 {
-   ns_dev *card;
-   u32 stat;
-
-   card = (ns_dev *) ATM_SKB(sb)->vcc->dev->dev_data;
-   stat = readl(card->membase + STAT);
-   card->sbfqc = ns_stat_sfbqc_get(stat);   
-   card->lbfqc = ns_stat_lfbqc_get(stat);
-
-   do
-   {
-      sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
-      if (sb == NULL)
-         break;
-      NS_SKB_CB(sb)->buf_type = BUF_SM;
-      skb_queue_tail(&card->sbpool.queue, sb);
-      skb_reserve(sb, NS_AAL0_HEADER);
-      push_rxbufs(card, sb);
-   } while (card->sbfqc < card->sbnr.min);
+	ns_dev *card;
+	u32 stat;
+
+	card = (ns_dev *) ATM_SKB(sb)->vcc->dev->dev_data;
+	stat = readl(card->membase + STAT);
+	card->sbfqc = ns_stat_sfbqc_get(stat);
+	card->lbfqc = ns_stat_lfbqc_get(stat);
+
+	do {
+		sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
+		if (sb == NULL)
+			break;
+		NS_SKB_CB(sb)->buf_type = BUF_SM;
+		skb_queue_tail(&card->sbpool.queue, sb);
+		skb_reserve(sb, NS_AAL0_HEADER);
+		push_rxbufs(card, sb);
+	} while (card->sbfqc < card->sbnr.min);
 }
 
-
-
 static void ns_lb_destructor(struct sk_buff *lb)
 {
-   ns_dev *card;
-   u32 stat;
-
-   card = (ns_dev *) ATM_SKB(lb)->vcc->dev->dev_data;
-   stat = readl(card->membase + STAT);
-   card->sbfqc = ns_stat_sfbqc_get(stat);   
-   card->lbfqc = ns_stat_lfbqc_get(stat);
-
-   do
-   {
-      lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
-      if (lb == NULL)
-         break;
-      NS_SKB_CB(lb)->buf_type = BUF_LG;
-      skb_queue_tail(&card->lbpool.queue, lb);
-      skb_reserve(lb, NS_SMBUFSIZE);
-      push_rxbufs(card, lb);
-   } while (card->lbfqc < card->lbnr.min);
+	ns_dev *card;
+	u32 stat;
+
+	card = (ns_dev *) ATM_SKB(lb)->vcc->dev->dev_data;
+	stat = readl(card->membase + STAT);
+	card->sbfqc = ns_stat_sfbqc_get(stat);
+	card->lbfqc = ns_stat_lfbqc_get(stat);
+
+	do {
+		lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
+		if (lb == NULL)
+			break;
+		NS_SKB_CB(lb)->buf_type = BUF_LG;
+		skb_queue_tail(&card->lbpool.queue, lb);
+		skb_reserve(lb, NS_SMBUFSIZE);
+		push_rxbufs(card, lb);
+	} while (card->lbfqc < card->lbnr.min);
 }
 
-
-
 static void ns_hb_destructor(struct sk_buff *hb)
 {
-   ns_dev *card;
-
-   card = (ns_dev *) ATM_SKB(hb)->vcc->dev->dev_data;
-
-   while (card->hbpool.count < card->hbnr.init)
-   {
-      hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
-      if (hb == NULL)
-         break;
-      NS_SKB_CB(hb)->buf_type = BUF_NONE;
-      skb_queue_tail(&card->hbpool.queue, hb);
-      card->hbpool.count++;
-   }
+	ns_dev *card;
+
+	card = (ns_dev *) ATM_SKB(hb)->vcc->dev->dev_data;
+
+	while (card->hbpool.count < card->hbnr.init) {
+		hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
+		if (hb == NULL)
+			break;
+		NS_SKB_CB(hb)->buf_type = BUF_NONE;
+		skb_queue_tail(&card->hbpool.queue, hb);
+		card->hbpool.count++;
+	}
 }
 
 #endif /* NS_USE_DESTRUCTORS */
 
-
-static void recycle_rx_buf(ns_dev *card, struct sk_buff *skb)
+static void recycle_rx_buf(ns_dev * card, struct sk_buff *skb)
 {
 	struct ns_skb_cb *cb = NS_SKB_CB(skb);
 
 	if (unlikely(cb->buf_type == BUF_NONE)) {
-		printk("nicstar%d: What kind of rx buffer is this?\n", card->index);
+		printk("nicstar%d: What kind of rx buffer is this?\n",
+		       card->index);
 		dev_kfree_skb_any(skb);
 	} else
 		push_rxbufs(card, skb);
 }
 
-
-static void recycle_iovec_rx_bufs(ns_dev *card, struct iovec *iov, int count)
+static void recycle_iovec_rx_bufs(ns_dev * card, struct iovec *iov, int count)
 {
 	while (count-- > 0)
-		recycle_rx_buf(card, (struct sk_buff *) (iov++)->iov_base);
+		recycle_rx_buf(card, (struct sk_buff *)(iov++)->iov_base);
 }
 
-
-static void recycle_iov_buf(ns_dev *card, struct sk_buff *iovb)
+static void recycle_iov_buf(ns_dev * card, struct sk_buff *iovb)
 {
-   if (card->iovpool.count < card->iovnr.max)
-   {
-      skb_queue_tail(&card->iovpool.queue, iovb);
-      card->iovpool.count++;
-   }
-   else
-      dev_kfree_skb_any(iovb);
+	if (card->iovpool.count < card->iovnr.max) {
+		skb_queue_tail(&card->iovpool.queue, iovb);
+		card->iovpool.count++;
+	} else
+		dev_kfree_skb_any(iovb);
 }
 
-
-
-static void dequeue_sm_buf(ns_dev *card, struct sk_buff *sb)
+static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb)
 {
-   skb_unlink(sb, &card->sbpool.queue);
+	skb_unlink(sb, &card->sbpool.queue);
 #ifdef NS_USE_DESTRUCTORS
-   if (card->sbfqc < card->sbnr.min)
+	if (card->sbfqc < card->sbnr.min)
 #else
-   if (card->sbfqc < card->sbnr.init)
-   {
-      struct sk_buff *new_sb;
-      if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL)
-      {
-         NS_SKB_CB(new_sb)->buf_type = BUF_SM;
-         skb_queue_tail(&card->sbpool.queue, new_sb);
-         skb_reserve(new_sb, NS_AAL0_HEADER);
-         push_rxbufs(card, new_sb);
-      }
-   }
-   if (card->sbfqc < card->sbnr.init)
+	if (card->sbfqc < card->sbnr.init) {
+		struct sk_buff *new_sb;
+		if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL) {
+			NS_SKB_CB(new_sb)->buf_type = BUF_SM;
+			skb_queue_tail(&card->sbpool.queue, new_sb);
+			skb_reserve(new_sb, NS_AAL0_HEADER);
+			push_rxbufs(card, new_sb);
+		}
+	}
+	if (card->sbfqc < card->sbnr.init)
 #endif /* NS_USE_DESTRUCTORS */
-   {
-      struct sk_buff *new_sb;
-      if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL)
-      {
-         NS_SKB_CB(new_sb)->buf_type = BUF_SM;
-         skb_queue_tail(&card->sbpool.queue, new_sb);
-         skb_reserve(new_sb, NS_AAL0_HEADER);
-         push_rxbufs(card, new_sb);
-      }
-   }
+	{
+		struct sk_buff *new_sb;
+		if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL) {
+			NS_SKB_CB(new_sb)->buf_type = BUF_SM;
+			skb_queue_tail(&card->sbpool.queue, new_sb);
+			skb_reserve(new_sb, NS_AAL0_HEADER);
+			push_rxbufs(card, new_sb);
+		}
+	}
 }
 
-
-
-static void dequeue_lg_buf(ns_dev *card, struct sk_buff *lb)
+static void dequeue_lg_buf(ns_dev * card, struct sk_buff *lb)
 {
-   skb_unlink(lb, &card->lbpool.queue);
+	skb_unlink(lb, &card->lbpool.queue);
 #ifdef NS_USE_DESTRUCTORS
-   if (card->lbfqc < card->lbnr.min)
+	if (card->lbfqc < card->lbnr.min)
 #else
-   if (card->lbfqc < card->lbnr.init)
-   {
-      struct sk_buff *new_lb;
-      if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL)
-      {
-         NS_SKB_CB(new_lb)->buf_type = BUF_LG;
-         skb_queue_tail(&card->lbpool.queue, new_lb);
-         skb_reserve(new_lb, NS_SMBUFSIZE);
-         push_rxbufs(card, new_lb);
-      }
-   }
-   if (card->lbfqc < card->lbnr.init)
+	if (card->lbfqc < card->lbnr.init) {
+		struct sk_buff *new_lb;
+		if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL) {
+			NS_SKB_CB(new_lb)->buf_type = BUF_LG;
+			skb_queue_tail(&card->lbpool.queue, new_lb);
+			skb_reserve(new_lb, NS_SMBUFSIZE);
+			push_rxbufs(card, new_lb);
+		}
+	}
+	if (card->lbfqc < card->lbnr.init)
 #endif /* NS_USE_DESTRUCTORS */
-   {
-      struct sk_buff *new_lb;
-      if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL)
-      {
-         NS_SKB_CB(new_lb)->buf_type = BUF_LG;
-         skb_queue_tail(&card->lbpool.queue, new_lb);
-         skb_reserve(new_lb, NS_SMBUFSIZE);
-         push_rxbufs(card, new_lb);
-      }
-   }
+	{
+		struct sk_buff *new_lb;
+		if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL) {
+			NS_SKB_CB(new_lb)->buf_type = BUF_LG;
+			skb_queue_tail(&card->lbpool.queue, new_lb);
+			skb_reserve(new_lb, NS_SMBUFSIZE);
+			push_rxbufs(card, new_lb);
+		}
+	}
 }
 
-
-
-static int ns_proc_read(struct atm_dev *dev, loff_t *pos, char *page)
+static int ns_proc_read(struct atm_dev *dev, loff_t * pos, char *page)
 {
-   u32 stat;
-   ns_dev *card;
-   int left;
-
-   left = (int) *pos;
-   card = (ns_dev *) dev->dev_data;
-   stat = readl(card->membase + STAT);
-   if (!left--)
-      return sprintf(page, "Pool   count    min   init    max \n");
-   if (!left--)
-      return sprintf(page, "Small  %5d  %5d  %5d  %5d \n",
-                     ns_stat_sfbqc_get(stat), card->sbnr.min, card->sbnr.init,
-		     card->sbnr.max);
-   if (!left--)
-      return sprintf(page, "Large  %5d  %5d  %5d  %5d \n",
-                     ns_stat_lfbqc_get(stat), card->lbnr.min, card->lbnr.init,
-		     card->lbnr.max);
-   if (!left--)
-      return sprintf(page, "Huge   %5d  %5d  %5d  %5d \n", card->hbpool.count,
-                     card->hbnr.min, card->hbnr.init, card->hbnr.max);
-   if (!left--)
-      return sprintf(page, "Iovec  %5d  %5d  %5d  %5d \n", card->iovpool.count,
-                     card->iovnr.min, card->iovnr.init, card->iovnr.max);
-   if (!left--)
-   {
-      int retval;
-      retval = sprintf(page, "Interrupt counter: %u \n", card->intcnt);
-      card->intcnt = 0;
-      return retval;
-   }
+	u32 stat;
+	ns_dev *card;
+	int left;
+
+	left = (int)*pos;
+	card = (ns_dev *) dev->dev_data;
+	stat = readl(card->membase + STAT);
+	if (!left--)
+		return sprintf(page, "Pool   count    min   init    max \n");
+	if (!left--)
+		return sprintf(page, "Small  %5d  %5d  %5d  %5d \n",
+			       ns_stat_sfbqc_get(stat), card->sbnr.min,
+			       card->sbnr.init, card->sbnr.max);
+	if (!left--)
+		return sprintf(page, "Large  %5d  %5d  %5d  %5d \n",
+			       ns_stat_lfbqc_get(stat), card->lbnr.min,
+			       card->lbnr.init, card->lbnr.max);
+	if (!left--)
+		return sprintf(page, "Huge   %5d  %5d  %5d  %5d \n",
+			       card->hbpool.count, card->hbnr.min,
+			       card->hbnr.init, card->hbnr.max);
+	if (!left--)
+		return sprintf(page, "Iovec  %5d  %5d  %5d  %5d \n",
+			       card->iovpool.count, card->iovnr.min,
+			       card->iovnr.init, card->iovnr.max);
+	if (!left--) {
+		int retval;
+		retval =
+		    sprintf(page, "Interrupt counter: %u \n", card->intcnt);
+		card->intcnt = 0;
+		return retval;
+	}
 #if 0
-   /* Dump 25.6 Mbps PHY registers */
-   /* Now there's a 25.6 Mbps PHY driver this code isn't needed. I left it
-      here just in case it's needed for debugging. */
-   if (card->max_pcr == ATM_25_PCR && !left--)
-   {
-      u32 phy_regs[4];
-      u32 i;
-
-      for (i = 0; i < 4; i++)
-      {
-         while (CMD_BUSY(card));
-         writel(NS_CMD_READ_UTILITY | 0x00000200 | i, card->membase + CMD);
-         while (CMD_BUSY(card));
-         phy_regs[i] = readl(card->membase + DR0) & 0x000000FF;
-      }
-
-      return sprintf(page, "PHY regs: 0x%02X 0x%02X 0x%02X 0x%02X \n",
-                     phy_regs[0], phy_regs[1], phy_regs[2], phy_regs[3]);
-   }
+	/* Dump 25.6 Mbps PHY registers */
+	/* Now there's a 25.6 Mbps PHY driver this code isn't needed. I left it
+	   here just in case it's needed for debugging. */
+	if (card->max_pcr == ATM_25_PCR && !left--) {
+		u32 phy_regs[4];
+		u32 i;
+
+		for (i = 0; i < 4; i++) {
+			while (CMD_BUSY(card)) ;
+			writel(NS_CMD_READ_UTILITY | 0x00000200 | i,
+			       card->membase + CMD);
+			while (CMD_BUSY(card)) ;
+			phy_regs[i] = readl(card->membase + DR0) & 0x000000FF;
+		}
+
+		return sprintf(page, "PHY regs: 0x%02X 0x%02X 0x%02X 0x%02X \n",
+			       phy_regs[0], phy_regs[1], phy_regs[2],
+			       phy_regs[3]);
+	}
 #endif /* 0 - Dump 25.6 Mbps PHY registers */
 #if 0
-   /* Dump TST */
-   if (left-- < NS_TST_NUM_ENTRIES)
-   {
-      if (card->tste2vc[left + 1] == NULL)
-         return sprintf(page, "%5d - VBR/UBR \n", left + 1);
-      else
-         return sprintf(page, "%5d - %d %d \n", left + 1,
-                        card->tste2vc[left + 1]->tx_vcc->vpi,
-                        card->tste2vc[left + 1]->tx_vcc->vci);
-   }
+	/* Dump TST */
+	if (left-- < NS_TST_NUM_ENTRIES) {
+		if (card->tste2vc[left + 1] == NULL)
+			return sprintf(page, "%5d - VBR/UBR \n", left + 1);
+		else
+			return sprintf(page, "%5d - %d %d \n", left + 1,
+				       card->tste2vc[left + 1]->tx_vcc->vpi,
+				       card->tste2vc[left + 1]->tx_vcc->vci);
+	}
 #endif /* 0 */
-   return 0;
+	return 0;
 }
 
-
-
-static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user *arg)
+static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg)
 {
-   ns_dev *card;
-   pool_levels pl;
-   long btype;
-   unsigned long flags;
-
-   card = dev->dev_data;
-   switch (cmd)
-   {
-      case NS_GETPSTAT:
-         if (get_user(pl.buftype, &((pool_levels __user *) arg)->buftype))
-	    return -EFAULT;
-         switch (pl.buftype)
-	 {
-	    case NS_BUFTYPE_SMALL:
-	       pl.count = ns_stat_sfbqc_get(readl(card->membase + STAT));
-	       pl.level.min = card->sbnr.min;
-	       pl.level.init = card->sbnr.init;
-	       pl.level.max = card->sbnr.max;
-	       break;
-
-	    case NS_BUFTYPE_LARGE:
-	       pl.count = ns_stat_lfbqc_get(readl(card->membase + STAT));
-	       pl.level.min = card->lbnr.min;
-	       pl.level.init = card->lbnr.init;
-	       pl.level.max = card->lbnr.max;
-	       break;
-
-	    case NS_BUFTYPE_HUGE:
-	       pl.count = card->hbpool.count;
-	       pl.level.min = card->hbnr.min;
-	       pl.level.init = card->hbnr.init;
-	       pl.level.max = card->hbnr.max;
-	       break;
-
-	    case NS_BUFTYPE_IOVEC:
-	       pl.count = card->iovpool.count;
-	       pl.level.min = card->iovnr.min;
-	       pl.level.init = card->iovnr.init;
-	       pl.level.max = card->iovnr.max;
-	       break;
-
-            default:
-	       return -ENOIOCTLCMD;
-
-	 }
-         if (!copy_to_user((pool_levels __user *) arg, &pl, sizeof(pl)))
-	    return (sizeof(pl));
-	 else
-	    return -EFAULT;
-
-      case NS_SETBUFLEV:
-         if (!capable(CAP_NET_ADMIN))
-	    return -EPERM;
-         if (copy_from_user(&pl, (pool_levels __user *) arg, sizeof(pl)))
-	    return -EFAULT;
-	 if (pl.level.min >= pl.level.init || pl.level.init >= pl.level.max)
-	    return -EINVAL;
-	 if (pl.level.min == 0)
-	    return -EINVAL;
-         switch (pl.buftype)
-	 {
-	    case NS_BUFTYPE_SMALL:
-               if (pl.level.max > TOP_SB)
-	          return -EINVAL;
-	       card->sbnr.min = pl.level.min;
-	       card->sbnr.init = pl.level.init;
-	       card->sbnr.max = pl.level.max;
-	       break;
-
-	    case NS_BUFTYPE_LARGE:
-               if (pl.level.max > TOP_LB)
-	          return -EINVAL;
-	       card->lbnr.min = pl.level.min;
-	       card->lbnr.init = pl.level.init;
-	       card->lbnr.max = pl.level.max;
-	       break;
-
-	    case NS_BUFTYPE_HUGE:
-               if (pl.level.max > TOP_HB)
-	          return -EINVAL;
-	       card->hbnr.min = pl.level.min;
-	       card->hbnr.init = pl.level.init;
-	       card->hbnr.max = pl.level.max;
-	       break;
-
-	    case NS_BUFTYPE_IOVEC:
-               if (pl.level.max > TOP_IOVB)
-	          return -EINVAL;
-	       card->iovnr.min = pl.level.min;
-	       card->iovnr.init = pl.level.init;
-	       card->iovnr.max = pl.level.max;
-	       break;
-
-            default:
-	       return -EINVAL;
-
-         }	 
-         return 0;
-
-      case NS_ADJBUFLEV:
-         if (!capable(CAP_NET_ADMIN))
-	    return -EPERM;
-         btype = (long) arg;	/* a long is the same size as a pointer or bigger */
-         switch (btype)
-	 {
-	    case NS_BUFTYPE_SMALL:
-	       while (card->sbfqc < card->sbnr.init)
-	       {
-                  struct sk_buff *sb;
-
-                  sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
-                  if (sb == NULL)
-                     return -ENOMEM;
-                  NS_SKB_CB(sb)->buf_type = BUF_SM;
-                  skb_queue_tail(&card->sbpool.queue, sb);
-                  skb_reserve(sb, NS_AAL0_HEADER);
-                  push_rxbufs(card, sb);
-	       }
-	       break;
-
-            case NS_BUFTYPE_LARGE:
-	       while (card->lbfqc < card->lbnr.init)
-	       {
-                  struct sk_buff *lb;
-
-                  lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
-                  if (lb == NULL)
-                     return -ENOMEM;
-                  NS_SKB_CB(lb)->buf_type = BUF_LG;
-                  skb_queue_tail(&card->lbpool.queue, lb);
-                  skb_reserve(lb, NS_SMBUFSIZE);
-                  push_rxbufs(card, lb);
-	       }
-	       break;
-
-            case NS_BUFTYPE_HUGE:
-               while (card->hbpool.count > card->hbnr.init)
-	       {
-                  struct sk_buff *hb;
-
-                  spin_lock_irqsave(&card->int_lock, flags);
-		  hb = skb_dequeue(&card->hbpool.queue);
-		  card->hbpool.count--;
-                  spin_unlock_irqrestore(&card->int_lock, flags);
-                  if (hb == NULL)
-		     printk("nicstar%d: huge buffer count inconsistent.\n",
-		            card->index);
-                  else
-		     dev_kfree_skb_any(hb);
-		  
-	       }
-               while (card->hbpool.count < card->hbnr.init)
-               {
-                  struct sk_buff *hb;
-
-                  hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
-                  if (hb == NULL)
-                     return -ENOMEM;
-                  NS_SKB_CB(hb)->buf_type = BUF_NONE;
-                  spin_lock_irqsave(&card->int_lock, flags);
-                  skb_queue_tail(&card->hbpool.queue, hb);
-                  card->hbpool.count++;
-                  spin_unlock_irqrestore(&card->int_lock, flags);
-               }
-	       break;
-
-            case NS_BUFTYPE_IOVEC:
-	       while (card->iovpool.count > card->iovnr.init)
-	       {
-	          struct sk_buff *iovb;
-
-                  spin_lock_irqsave(&card->int_lock, flags);
-		  iovb = skb_dequeue(&card->iovpool.queue);
-		  card->iovpool.count--;
-                  spin_unlock_irqrestore(&card->int_lock, flags);
-                  if (iovb == NULL)
-		     printk("nicstar%d: iovec buffer count inconsistent.\n",
-		            card->index);
-                  else
-		     dev_kfree_skb_any(iovb);
-
-	       }
-               while (card->iovpool.count < card->iovnr.init)
-	       {
-	          struct sk_buff *iovb;
-
-                  iovb = alloc_skb(NS_IOVBUFSIZE, GFP_KERNEL);
-                  if (iovb == NULL)
-                     return -ENOMEM;
-                  NS_SKB_CB(iovb)->buf_type = BUF_NONE;
-                  spin_lock_irqsave(&card->int_lock, flags);
-                  skb_queue_tail(&card->iovpool.queue, iovb);
-                  card->iovpool.count++;
-                  spin_unlock_irqrestore(&card->int_lock, flags);
-	       }
-	       break;
-
-            default:
-	       return -EINVAL;
-
-	 }
-         return 0;
-
-      default:
-         if (dev->phy && dev->phy->ioctl) {
-            return dev->phy->ioctl(dev, cmd, arg);
-         }
-         else {
-            printk("nicstar%d: %s == NULL \n", card->index,
-                   dev->phy ? "dev->phy->ioctl" : "dev->phy");
-            return -ENOIOCTLCMD;
-         }
-   }
+	ns_dev *card;
+	pool_levels pl;
+	long btype;
+	unsigned long flags;
+
+	card = dev->dev_data;
+	switch (cmd) {
+	case NS_GETPSTAT:
+		if (get_user
+		    (pl.buftype, &((pool_levels __user *) arg)->buftype))
+			return -EFAULT;
+		switch (pl.buftype) {
+		case NS_BUFTYPE_SMALL:
+			pl.count =
+			    ns_stat_sfbqc_get(readl(card->membase + STAT));
+			pl.level.min = card->sbnr.min;
+			pl.level.init = card->sbnr.init;
+			pl.level.max = card->sbnr.max;
+			break;
+
+		case NS_BUFTYPE_LARGE:
+			pl.count =
+			    ns_stat_lfbqc_get(readl(card->membase + STAT));
+			pl.level.min = card->lbnr.min;
+			pl.level.init = card->lbnr.init;
+			pl.level.max = card->lbnr.max;
+			break;
+
+		case NS_BUFTYPE_HUGE:
+			pl.count = card->hbpool.count;
+			pl.level.min = card->hbnr.min;
+			pl.level.init = card->hbnr.init;
+			pl.level.max = card->hbnr.max;
+			break;
+
+		case NS_BUFTYPE_IOVEC:
+			pl.count = card->iovpool.count;
+			pl.level.min = card->iovnr.min;
+			pl.level.init = card->iovnr.init;
+			pl.level.max = card->iovnr.max;
+			break;
+
+		default:
+			return -ENOIOCTLCMD;
+
+		}
+		if (!copy_to_user((pool_levels __user *) arg, &pl, sizeof(pl)))
+			return (sizeof(pl));
+		else
+			return -EFAULT;
+
+	case NS_SETBUFLEV:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (copy_from_user(&pl, (pool_levels __user *) arg, sizeof(pl)))
+			return -EFAULT;
+		if (pl.level.min >= pl.level.init
+		    || pl.level.init >= pl.level.max)
+			return -EINVAL;
+		if (pl.level.min == 0)
+			return -EINVAL;
+		switch (pl.buftype) {
+		case NS_BUFTYPE_SMALL:
+			if (pl.level.max > TOP_SB)
+				return -EINVAL;
+			card->sbnr.min = pl.level.min;
+			card->sbnr.init = pl.level.init;
+			card->sbnr.max = pl.level.max;
+			break;
+
+		case NS_BUFTYPE_LARGE:
+			if (pl.level.max > TOP_LB)
+				return -EINVAL;
+			card->lbnr.min = pl.level.min;
+			card->lbnr.init = pl.level.init;
+			card->lbnr.max = pl.level.max;
+			break;
+
+		case NS_BUFTYPE_HUGE:
+			if (pl.level.max > TOP_HB)
+				return -EINVAL;
+			card->hbnr.min = pl.level.min;
+			card->hbnr.init = pl.level.init;
+			card->hbnr.max = pl.level.max;
+			break;
+
+		case NS_BUFTYPE_IOVEC:
+			if (pl.level.max > TOP_IOVB)
+				return -EINVAL;
+			card->iovnr.min = pl.level.min;
+			card->iovnr.init = pl.level.init;
+			card->iovnr.max = pl.level.max;
+			break;
+
+		default:
+			return -EINVAL;
+
+		}
+		return 0;
+
+	case NS_ADJBUFLEV:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		btype = (long)arg;	/* a long is the same size as a pointer or bigger */
+		switch (btype) {
+		case NS_BUFTYPE_SMALL:
+			while (card->sbfqc < card->sbnr.init) {
+				struct sk_buff *sb;
+
+				sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
+				if (sb == NULL)
+					return -ENOMEM;
+				NS_SKB_CB(sb)->buf_type = BUF_SM;
+				skb_queue_tail(&card->sbpool.queue, sb);
+				skb_reserve(sb, NS_AAL0_HEADER);
+				push_rxbufs(card, sb);
+			}
+			break;
+
+		case NS_BUFTYPE_LARGE:
+			while (card->lbfqc < card->lbnr.init) {
+				struct sk_buff *lb;
+
+				lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
+				if (lb == NULL)
+					return -ENOMEM;
+				NS_SKB_CB(lb)->buf_type = BUF_LG;
+				skb_queue_tail(&card->lbpool.queue, lb);
+				skb_reserve(lb, NS_SMBUFSIZE);
+				push_rxbufs(card, lb);
+			}
+			break;
+
+		case NS_BUFTYPE_HUGE:
+			while (card->hbpool.count > card->hbnr.init) {
+				struct sk_buff *hb;
+
+				spin_lock_irqsave(&card->int_lock, flags);
+				hb = skb_dequeue(&card->hbpool.queue);
+				card->hbpool.count--;
+				spin_unlock_irqrestore(&card->int_lock, flags);
+				if (hb == NULL)
+					printk
+					    ("nicstar%d: huge buffer count inconsistent.\n",
+					     card->index);
+				else
+					dev_kfree_skb_any(hb);
+
+			}
+			while (card->hbpool.count < card->hbnr.init) {
+				struct sk_buff *hb;
+
+				hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
+				if (hb == NULL)
+					return -ENOMEM;
+				NS_SKB_CB(hb)->buf_type = BUF_NONE;
+				spin_lock_irqsave(&card->int_lock, flags);
+				skb_queue_tail(&card->hbpool.queue, hb);
+				card->hbpool.count++;
+				spin_unlock_irqrestore(&card->int_lock, flags);
+			}
+			break;
+
+		case NS_BUFTYPE_IOVEC:
+			while (card->iovpool.count > card->iovnr.init) {
+				struct sk_buff *iovb;
+
+				spin_lock_irqsave(&card->int_lock, flags);
+				iovb = skb_dequeue(&card->iovpool.queue);
+				card->iovpool.count--;
+				spin_unlock_irqrestore(&card->int_lock, flags);
+				if (iovb == NULL)
+					printk
+					    ("nicstar%d: iovec buffer count inconsistent.\n",
+					     card->index);
+				else
+					dev_kfree_skb_any(iovb);
+
+			}
+			while (card->iovpool.count < card->iovnr.init) {
+				struct sk_buff *iovb;
+
+				iovb = alloc_skb(NS_IOVBUFSIZE, GFP_KERNEL);
+				if (iovb == NULL)
+					return -ENOMEM;
+				NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+				spin_lock_irqsave(&card->int_lock, flags);
+				skb_queue_tail(&card->iovpool.queue, iovb);
+				card->iovpool.count++;
+				spin_unlock_irqrestore(&card->int_lock, flags);
+			}
+			break;
+
+		default:
+			return -EINVAL;
+
+		}
+		return 0;
+
+	default:
+		if (dev->phy && dev->phy->ioctl) {
+			return dev->phy->ioctl(dev, cmd, arg);
+		} else {
+			printk("nicstar%d: %s == NULL \n", card->index,
+			       dev->phy ? "dev->phy->ioctl" : "dev->phy");
+			return -ENOIOCTLCMD;
+		}
+	}
 }
 
-
-static void which_list(ns_dev *card, struct sk_buff *skb)
+static void which_list(ns_dev * card, struct sk_buff *skb)
 {
 	printk("skb buf_type: 0x%08x\n", NS_SKB_CB(skb)->buf_type);
 }
 
-
 static void ns_poll(unsigned long arg)
 {
-   int i;
-   ns_dev *card;
-   unsigned long flags;
-   u32 stat_r, stat_w;
-
-   PRINTK("nicstar: Entering ns_poll().\n");
-   for (i = 0; i < num_cards; i++)
-   {
-      card = cards[i];
-      if (spin_is_locked(&card->int_lock)) {
-      /* Probably it isn't worth spinning */
-         continue;
-      }
-      spin_lock_irqsave(&card->int_lock, flags);
-
-      stat_w = 0;
-      stat_r = readl(card->membase + STAT);
-      if (stat_r & NS_STAT_TSIF)
-         stat_w |= NS_STAT_TSIF;
-      if (stat_r & NS_STAT_EOPDU)
-         stat_w |= NS_STAT_EOPDU;
-
-      process_tsq(card);
-      process_rsq(card);
-
-      writel(stat_w, card->membase + STAT);
-      spin_unlock_irqrestore(&card->int_lock, flags);
-   }
-   mod_timer(&ns_timer, jiffies + NS_POLL_PERIOD);
-   PRINTK("nicstar: Leaving ns_poll().\n");
+	int i;
+	ns_dev *card;
+	unsigned long flags;
+	u32 stat_r, stat_w;
+
+	PRINTK("nicstar: Entering ns_poll().\n");
+	for (i = 0; i < num_cards; i++) {
+		card = cards[i];
+		if (spin_is_locked(&card->int_lock)) {
+			/* Probably it isn't worth spinning */
+			continue;
+		}
+		spin_lock_irqsave(&card->int_lock, flags);
+
+		stat_w = 0;
+		stat_r = readl(card->membase + STAT);
+		if (stat_r & NS_STAT_TSIF)
+			stat_w |= NS_STAT_TSIF;
+		if (stat_r & NS_STAT_EOPDU)
+			stat_w |= NS_STAT_EOPDU;
+
+		process_tsq(card);
+		process_rsq(card);
+
+		writel(stat_w, card->membase + STAT);
+		spin_unlock_irqrestore(&card->int_lock, flags);
+	}
+	mod_timer(&ns_timer, jiffies + NS_POLL_PERIOD);
+	PRINTK("nicstar: Leaving ns_poll().\n");
 }
 
-
-
 static int ns_parse_mac(char *mac, unsigned char *esi)
 {
-   int i, j;
-   short byte1, byte0;
-
-   if (mac == NULL || esi == NULL)
-      return -1;
-   j = 0;
-   for (i = 0; i < 6; i++)
-   {
-      if ((byte1 = ns_h2i(mac[j++])) < 0)
-         return -1;
-      if ((byte0 = ns_h2i(mac[j++])) < 0)
-         return -1;
-      esi[i] = (unsigned char) (byte1 * 16 + byte0);
-      if (i < 5)
-      {
-         if (mac[j++] != ':')
-            return -1;
-      }
-   }
-   return 0;
+	int i, j;
+	short byte1, byte0;
+
+	if (mac == NULL || esi == NULL)
+		return -1;
+	j = 0;
+	for (i = 0; i < 6; i++) {
+		if ((byte1 = ns_h2i(mac[j++])) < 0)
+			return -1;
+		if ((byte0 = ns_h2i(mac[j++])) < 0)
+			return -1;
+		esi[i] = (unsigned char)(byte1 * 16 + byte0);
+		if (i < 5) {
+			if (mac[j++] != ':')
+				return -1;
+		}
+	}
+	return 0;
 }
 
-
-
 static short ns_h2i(char c)
 {
-   if (c >= '0' && c <= '9')
-      return (short) (c - '0');
-   if (c >= 'A' && c <= 'F')
-      return (short) (c - 'A' + 10);
-   if (c >= 'a' && c <= 'f')
-      return (short) (c - 'a' + 10);
-   return -1;
+	if (c >= '0' && c <= '9')
+		return (short)(c - '0');
+	if (c >= 'A' && c <= 'F')
+		return (short)(c - 'A' + 10);
+	if (c >= 'a' && c <= 'f')
+		return (short)(c - 'a' + 10);
+	return -1;
 }
 
-
-
 static void ns_phy_put(struct atm_dev *dev, unsigned char value,
-                    unsigned long addr)
+		       unsigned long addr)
 {
-   ns_dev *card;
-   unsigned long flags;
-
-   card = dev->dev_data;
-   spin_lock_irqsave(&card->res_lock, flags);
-   while(CMD_BUSY(card));
-   writel((unsigned long) value, card->membase + DR0);
-   writel(NS_CMD_WRITE_UTILITY | 0x00000200 | (addr & 0x000000FF),
-          card->membase + CMD);
-   spin_unlock_irqrestore(&card->res_lock, flags);
+	ns_dev *card;
+	unsigned long flags;
+
+	card = dev->dev_data;
+	spin_lock_irqsave(&card->res_lock, flags);
+	while (CMD_BUSY(card)) ;
+	writel((unsigned long)value, card->membase + DR0);
+	writel(NS_CMD_WRITE_UTILITY | 0x00000200 | (addr & 0x000000FF),
+	       card->membase + CMD);
+	spin_unlock_irqrestore(&card->res_lock, flags);
 }
 
-
-
 static unsigned char ns_phy_get(struct atm_dev *dev, unsigned long addr)
 {
-   ns_dev *card;
-   unsigned long flags;
-   unsigned long data;
-
-   card = dev->dev_data;
-   spin_lock_irqsave(&card->res_lock, flags);
-   while(CMD_BUSY(card));
-   writel(NS_CMD_READ_UTILITY | 0x00000200 | (addr & 0x000000FF),
-          card->membase + CMD);
-   while(CMD_BUSY(card));
-   data = readl(card->membase + DR0) & 0x000000FF;
-   spin_unlock_irqrestore(&card->res_lock, flags);
-   return (unsigned char) data;
+	ns_dev *card;
+	unsigned long flags;
+	unsigned long data;
+
+	card = dev->dev_data;
+	spin_lock_irqsave(&card->res_lock, flags);
+	while (CMD_BUSY(card)) ;
+	writel(NS_CMD_READ_UTILITY | 0x00000200 | (addr & 0x000000FF),
+	       card->membase + CMD);
+	while (CMD_BUSY(card)) ;
+	data = readl(card->membase + DR0) & 0x000000FF;
+	spin_unlock_irqrestore(&card->res_lock, flags);
+	return (unsigned char)data;
 }
 
-
-
 module_init(nicstar_init);
 module_exit(nicstar_cleanup);
diff --git a/drivers/atm/nicstar.h b/drivers/atm/nicstar.h
index 6010e3d..43eb2db 100644
--- a/drivers/atm/nicstar.h
+++ b/drivers/atm/nicstar.h
@@ -1,5 +1,4 @@
-/******************************************************************************
- *
+/*
  * nicstar.h
  *
  * Header file for the nicstar device driver.
@@ -8,15 +7,12 @@
  * PowerPC support by Jay Talbott (jay_talbott@mcg.mot.com) April 1999
  *
  * (C) INESC 1998
- *
- ******************************************************************************/
-
+ */
 
 #ifndef _LINUX_NICSTAR_H_
 #define _LINUX_NICSTAR_H_
 
-
-/* Includes *******************************************************************/
+/* Includes */
 
 #include <linux/types.h>
 #include <linux/pci.h>
@@ -25,12 +21,11 @@
 #include <linux/atmdev.h>
 #include <linux/atm_nicstar.h>
 
-
-/* Options ********************************************************************/
+/* Options */
 
 #define NS_MAX_CARDS 4		/* Maximum number of NICStAR based cards
 				   controlled by the device driver. Must
-                                   be <= 5 */
+				   be <= 5 */
 
 #undef RCQ_SUPPORT		/* Do not define this for now */
 
@@ -43,7 +38,7 @@
 #define NS_VPIBITS 2		/* 0, 1, 2, or 8 */
 
 #define NS_MAX_RCTSIZE 4096	/* Number of entries. 4096 or 16384.
-                                   Define 4096 only if (all) your card(s)
+				   Define 4096 only if (all) your card(s)
 				   have 32K x 32bit SRAM, in which case
 				   setting this to 16384 will just waste a
 				   lot of memory.
@@ -51,33 +46,32 @@
 				   128K x 32bit SRAM will limit the maximum
 				   VCI. */
 
-/*#define NS_PCI_LATENCY 64*/	/* Must be a multiple of 32 */
+				/*#define NS_PCI_LATENCY 64*//* Must be a multiple of 32 */
 
 	/* Number of buffers initially allocated */
-#define NUM_SB 32	/* Must be even */
-#define NUM_LB 24	/* Must be even */
-#define NUM_HB 8	/* Pre-allocated huge buffers */
-#define NUM_IOVB 48	/* Iovec buffers */
+#define NUM_SB 32		/* Must be even */
+#define NUM_LB 24		/* Must be even */
+#define NUM_HB 8		/* Pre-allocated huge buffers */
+#define NUM_IOVB 48		/* Iovec buffers */
 
 	/* Lower level for count of buffers */
-#define MIN_SB 8	/* Must be even */
-#define MIN_LB 8	/* Must be even */
+#define MIN_SB 8		/* Must be even */
+#define MIN_LB 8		/* Must be even */
 #define MIN_HB 6
 #define MIN_IOVB 8
 
 	/* Upper level for count of buffers */
-#define MAX_SB 64	/* Must be even, <= 508 */
-#define MAX_LB 48	/* Must be even, <= 508 */
+#define MAX_SB 64		/* Must be even, <= 508 */
+#define MAX_LB 48		/* Must be even, <= 508 */
 #define MAX_HB 10
 #define MAX_IOVB 80
 
 	/* These are the absolute maximum allowed for the ioctl() */
-#define TOP_SB 256	/* Must be even, <= 508 */
-#define TOP_LB 128	/* Must be even, <= 508 */
+#define TOP_SB 256		/* Must be even, <= 508 */
+#define TOP_LB 128		/* Must be even, <= 508 */
 #define TOP_HB 64
 #define TOP_IOVB 256
 
-
 #define MAX_TBD_PER_VC 1	/* Number of TBDs before a TSR */
 #define MAX_TBD_PER_SCQ 10	/* Only meaningful for variable rate SCQs */
 
@@ -89,15 +83,12 @@
 
 #define PCR_TOLERANCE (1.0001)
 
-
-
-/* ESI stuff ******************************************************************/
+/* ESI stuff */
 
 #define NICSTAR_EPROM_MAC_ADDR_OFFSET 0x6C
 #define NICSTAR_EPROM_MAC_ADDR_OFFSET_ALT 0xF6
 
-
-/* #defines *******************************************************************/
+/* #defines */
 
 #define NS_IOREMAP_SIZE 4096
 
@@ -123,22 +114,19 @@
 #define NS_SMSKBSIZE (NS_SMBUFSIZE + NS_AAL0_HEADER)
 #define NS_LGSKBSIZE (NS_SMBUFSIZE + NS_LGBUFSIZE)
 
+/* NICStAR structures located in host memory */
 
-/* NICStAR structures located in host memory **********************************/
-
-
-
-/* RSQ - Receive Status Queue 
+/*
+ * RSQ - Receive Status Queue
  *
  * Written by the NICStAR, read by the device driver.
  */
 
-typedef struct ns_rsqe
-{
-   u32 word_1;
-   u32 buffer_handle;
-   u32 final_aal5_crc32;
-   u32 word_4;
+typedef struct ns_rsqe {
+	u32 word_1;
+	u32 buffer_handle;
+	u32 final_aal5_crc32;
+	u32 word_4;
 } ns_rsqe;
 
 #define ns_rsqe_vpi(ns_rsqep) \
@@ -175,30 +163,27 @@ typedef struct ns_rsqe
 #define ns_rsqe_cellcount(ns_rsqep) \
         (le32_to_cpu((ns_rsqep)->word_4) & 0x000001FF)
 #define ns_rsqe_init(ns_rsqep) \
-        ((ns_rsqep)->word_4 = cpu_to_le32(0x00000000)) 
+        ((ns_rsqep)->word_4 = cpu_to_le32(0x00000000))
 
 #define NS_RSQ_NUM_ENTRIES (NS_RSQSIZE / 16)
 #define NS_RSQ_ALIGNMENT NS_RSQSIZE
 
-
-
-/* RCQ - Raw Cell Queue
+/*
+ * RCQ - Raw Cell Queue
  *
  * Written by the NICStAR, read by the device driver.
  */
 
-typedef struct cell_payload
-{
-   u32 word[12];
+typedef struct cell_payload {
+	u32 word[12];
 } cell_payload;
 
-typedef struct ns_rcqe
-{
-   u32 word_1;
-   u32 word_2;
-   u32 word_3;
-   u32 word_4;
-   cell_payload payload;
+typedef struct ns_rcqe {
+	u32 word_1;
+	u32 word_2;
+	u32 word_3;
+	u32 word_4;
+	cell_payload payload;
 } ns_rcqe;
 
 #define NS_RCQE_SIZE 64		/* bytes */
@@ -210,28 +195,25 @@ typedef struct ns_rcqe
 #define ns_rcqe_nextbufhandle(ns_rcqep) \
         (le32_to_cpu((ns_rcqep)->word_2))
 
-
-
-/* SCQ - Segmentation Channel Queue 
+/*
+ * SCQ - Segmentation Channel Queue
  *
  * Written by the device driver, read by the NICStAR.
  */
 
-typedef struct ns_scqe
-{
-   u32 word_1;
-   u32 word_2;
-   u32 word_3;
-   u32 word_4;
+typedef struct ns_scqe {
+	u32 word_1;
+	u32 word_2;
+	u32 word_3;
+	u32 word_4;
 } ns_scqe;
 
    /* NOTE: SCQ entries can be either a TBD (Transmit Buffer Descriptors)
-            or TSR (Transmit Status Requests) */
+      or TSR (Transmit Status Requests) */
 
 #define NS_SCQE_TYPE_TBD 0x00000000
 #define NS_SCQE_TYPE_TSR 0x80000000
 
-
 #define NS_TBD_EOPDU 0x40000000
 #define NS_TBD_AAL0  0x00000000
 #define NS_TBD_AAL34 0x04000000
@@ -253,10 +235,9 @@ typedef struct ns_scqe
 #define ns_tbd_mkword_4(gfc, vpi, vci, pt, clp) \
       (cpu_to_le32((gfc) << 28 | (vpi) << 20 | (vci) << 4 | (pt) << 1 | (clp)))
 
-
 #define NS_TSR_INTENABLE 0x20000000
 
-#define NS_TSR_SCDISVBR 0xFFFF		/* Use as scdi for VBR SCD */
+#define NS_TSR_SCDISVBR 0xFFFF	/* Use as scdi for VBR SCD */
 
 #define ns_tsr_mkword_1(flags) \
         (cpu_to_le32(NS_SCQE_TYPE_TSR | (flags)))
@@ -273,22 +254,20 @@ typedef struct ns_scqe
 
 #define NS_SCQE_SIZE 16
 
-
-
-/* TSQ - Transmit Status Queue
+/*
+ * TSQ - Transmit Status Queue
  *
  * Written by the NICStAR, read by the device driver.
  */
 
-typedef struct ns_tsi
-{
-   u32 word_1;
-   u32 word_2;
+typedef struct ns_tsi {
+	u32 word_1;
+	u32 word_2;
 } ns_tsi;
 
    /* NOTE: The first word can be a status word copied from the TSR which
-            originated the TSI, or a timer overflow indicator. In this last
-	    case, the value of the first word is all zeroes. */
+      originated the TSI, or a timer overflow indicator. In this last
+      case, the value of the first word is all zeroes. */
 
 #define NS_TSI_EMPTY          0x80000000
 #define NS_TSI_TIMESTAMP_MASK 0x00FFFFFF
@@ -301,12 +280,10 @@ typedef struct ns_tsi
 #define ns_tsi_init(ns_tsip) \
         ((ns_tsip)->word_2 = cpu_to_le32(NS_TSI_EMPTY))
 
-
 #define NS_TSQSIZE 8192
 #define NS_TSQ_NUM_ENTRIES 1024
 #define NS_TSQ_ALIGNMENT 8192
 
-
 #define NS_TSI_SCDISVBR NS_TSR_SCDISVBR
 
 #define ns_tsi_tmrof(ns_tsip) \
@@ -316,26 +293,22 @@ typedef struct ns_tsi
 #define ns_tsi_getscqpos(ns_tsip) \
         (le32_to_cpu((ns_tsip)->word_1) & 0x00007FFF)
 
+/* NICStAR structures located in local SRAM */
 
-
-/* NICStAR structures located in local SRAM ***********************************/
-
-
-
-/* RCT - Receive Connection Table
+/*
+ * RCT - Receive Connection Table
  *
  * Written by both the NICStAR and the device driver.
  */
 
-typedef struct ns_rcte
-{
-   u32 word_1;
-   u32 buffer_handle;
-   u32 dma_address;
-   u32 aal5_crc32;
+typedef struct ns_rcte {
+	u32 word_1;
+	u32 buffer_handle;
+	u32 dma_address;
+	u32 aal5_crc32;
 } ns_rcte;
 
-#define NS_RCTE_BSFB            0x00200000  /* Rev. D only */
+#define NS_RCTE_BSFB            0x00200000	/* Rev. D only */
 #define NS_RCTE_NZGFC           0x00100000
 #define NS_RCTE_CONNECTOPEN     0x00080000
 #define NS_RCTE_AALMASK         0x00070000
@@ -358,25 +331,21 @@ typedef struct ns_rcte
 #define NS_RCT_ENTRY_SIZE 4	/* Number of dwords */
 
    /* NOTE: We could make macros to contruct the first word of the RCTE,
-            but that doesn't seem to make much sense... */
-
-
+      but that doesn't seem to make much sense... */
 
-/* FBD - Free Buffer Descriptor
+/*
+ * FBD - Free Buffer Descriptor
  *
  * Written by the device driver using via the command register.
  */
 
-typedef struct ns_fbd
-{
-   u32 buffer_handle;
-   u32 dma_address;
+typedef struct ns_fbd {
+	u32 buffer_handle;
+	u32 dma_address;
 } ns_fbd;
 
-
-
-
-/* TST - Transmit Schedule Table
+/*
+ * TST - Transmit Schedule Table
  *
  * Written by the device driver.
  */
@@ -385,40 +354,38 @@ typedef u32 ns_tste;
 
 #define NS_TST_OPCODE_MASK 0x60000000
 
-#define NS_TST_OPCODE_NULL     0x00000000 /* Insert null cell */
-#define NS_TST_OPCODE_FIXED    0x20000000 /* Cell from a fixed rate channel */
+#define NS_TST_OPCODE_NULL     0x00000000	/* Insert null cell */
+#define NS_TST_OPCODE_FIXED    0x20000000	/* Cell from a fixed rate channel */
 #define NS_TST_OPCODE_VARIABLE 0x40000000
-#define NS_TST_OPCODE_END      0x60000000 /* Jump */
+#define NS_TST_OPCODE_END      0x60000000	/* Jump */
 
 #define ns_tste_make(opcode, sramad) (opcode | sramad)
 
    /* NOTE:
 
       - When the opcode is FIXED, sramad specifies the SRAM address of the
-        SCD for that fixed rate channel.
+      SCD for that fixed rate channel.
       - When the opcode is END, sramad specifies the SRAM address of the
-        location of the next TST entry to read.
+      location of the next TST entry to read.
     */
 
-
-
-/* SCD - Segmentation Channel Descriptor
+/*
+ * SCD - Segmentation Channel Descriptor
  *
  * Written by both the device driver and the NICStAR
  */
 
-typedef struct ns_scd
-{
-   u32 word_1;
-   u32 word_2;
-   u32 partial_aal5_crc;
-   u32 reserved;
-   ns_scqe cache_a;
-   ns_scqe cache_b;
+typedef struct ns_scd {
+	u32 word_1;
+	u32 word_2;
+	u32 partial_aal5_crc;
+	u32 reserved;
+	ns_scqe cache_a;
+	ns_scqe cache_b;
 } ns_scd;
 
-#define NS_SCD_BASE_MASK_VAR 0xFFFFE000		/* Variable rate */
-#define NS_SCD_BASE_MASK_FIX 0xFFFFFC00		/* Fixed rate */
+#define NS_SCD_BASE_MASK_VAR 0xFFFFE000	/* Variable rate */
+#define NS_SCD_BASE_MASK_FIX 0xFFFFFC00	/* Fixed rate */
 #define NS_SCD_TAIL_MASK_VAR 0x00001FF0
 #define NS_SCD_TAIL_MASK_FIX 0x000003F0
 #define NS_SCD_HEAD_MASK_VAR 0x00001FF0
@@ -426,13 +393,9 @@ typedef struct ns_scd
 #define NS_SCD_XMITFOREVER   0x02000000
 
    /* NOTE: There are other fields in word 2 of the SCD, but as they should
-            not be needed in the device driver they are not defined here. */
-
-
-
-
-/* NICStAR local SRAM memory map **********************************************/
+      not be needed in the device driver they are not defined here. */
 
+/* NICStAR local SRAM memory map */
 
 #define NS_RCT           0x00000
 #define NS_RCT_32_END    0x03FFF
@@ -455,100 +418,93 @@ typedef struct ns_scd
 #define NS_LGFBQ         0x1FC00
 #define NS_LGFBQ_END     0x1FFFF
 
-
-
-/* NISCtAR operation registers ************************************************/
-
+/* NISCtAR operation registers */
 
 /* See Section 3.4 of `IDT77211 NICStAR User Manual' from www.idt.com */
 
-enum ns_regs
-{
-   DR0   = 0x00,      /* Data Register 0 R/W*/
-   DR1   = 0x04,      /* Data Register 1 W */
-   DR2   = 0x08,      /* Data Register 2 W */
-   DR3   = 0x0C,      /* Data Register 3 W */
-   CMD   = 0x10,      /* Command W */
-   CFG   = 0x14,      /* Configuration R/W */
-   STAT  = 0x18,      /* Status R/W */
-   RSQB  = 0x1C,      /* Receive Status Queue Base W */
-   RSQT  = 0x20,      /* Receive Status Queue Tail R */
-   RSQH  = 0x24,      /* Receive Status Queue Head W */
-   CDC   = 0x28,      /* Cell Drop Counter R/clear */
-   VPEC  = 0x2C,      /* VPI/VCI Lookup Error Count R/clear */
-   ICC   = 0x30,      /* Invalid Cell Count R/clear */
-   RAWCT = 0x34,      /* Raw Cell Tail R */
-   TMR   = 0x38,      /* Timer R */
-   TSTB  = 0x3C,      /* Transmit Schedule Table Base R/W */
-   TSQB  = 0x40,      /* Transmit Status Queue Base W */
-   TSQT  = 0x44,      /* Transmit Status Queue Tail R */
-   TSQH  = 0x48,      /* Transmit Status Queue Head W */
-   GP    = 0x4C,      /* General Purpose R/W */
-   VPM   = 0x50       /* VPI/VCI Mask W */
+enum ns_regs {
+	DR0 = 0x00,		/* Data Register 0 R/W */
+	DR1 = 0x04,		/* Data Register 1 W */
+	DR2 = 0x08,		/* Data Register 2 W */
+	DR3 = 0x0C,		/* Data Register 3 W */
+	CMD = 0x10,		/* Command W */
+	CFG = 0x14,		/* Configuration R/W */
+	STAT = 0x18,		/* Status R/W */
+	RSQB = 0x1C,		/* Receive Status Queue Base W */
+	RSQT = 0x20,		/* Receive Status Queue Tail R */
+	RSQH = 0x24,		/* Receive Status Queue Head W */
+	CDC = 0x28,		/* Cell Drop Counter R/clear */
+	VPEC = 0x2C,		/* VPI/VCI Lookup Error Count R/clear */
+	ICC = 0x30,		/* Invalid Cell Count R/clear */
+	RAWCT = 0x34,		/* Raw Cell Tail R */
+	TMR = 0x38,		/* Timer R */
+	TSTB = 0x3C,		/* Transmit Schedule Table Base R/W */
+	TSQB = 0x40,		/* Transmit Status Queue Base W */
+	TSQT = 0x44,		/* Transmit Status Queue Tail R */
+	TSQH = 0x48,		/* Transmit Status Queue Head W */
+	GP = 0x4C,		/* General Purpose R/W */
+	VPM = 0x50		/* VPI/VCI Mask W */
 };
 
-
-/* NICStAR commands issued to the CMD register ********************************/
-
+/* NICStAR commands issued to the CMD register */
 
 /* Top 4 bits are command opcode, lower 28 are parameters. */
 
 #define NS_CMD_NO_OPERATION         0x00000000
-        /* params always 0 */
+	/* params always 0 */
 
 #define NS_CMD_OPENCLOSE_CONNECTION 0x20000000
-        /* b19{1=open,0=close} b18-2{SRAM addr} */
+	/* b19{1=open,0=close} b18-2{SRAM addr} */
 
 #define NS_CMD_WRITE_SRAM           0x40000000
-        /* b18-2{SRAM addr} b1-0{burst size} */
+	/* b18-2{SRAM addr} b1-0{burst size} */
 
 #define NS_CMD_READ_SRAM            0x50000000
-        /* b18-2{SRAM addr} */
+	/* b18-2{SRAM addr} */
 
 #define NS_CMD_WRITE_FREEBUFQ       0x60000000
-        /* b0{large buf indicator} */
+	/* b0{large buf indicator} */
 
 #define NS_CMD_READ_UTILITY         0x80000000
-        /* b8{1=select UTL_CS1} b9{1=select UTL_CS0} b7-0{bus addr} */
+	/* b8{1=select UTL_CS1} b9{1=select UTL_CS0} b7-0{bus addr} */
 
 #define NS_CMD_WRITE_UTILITY        0x90000000
-        /* b8{1=select UTL_CS1} b9{1=select UTL_CS0} b7-0{bus addr} */
+	/* b8{1=select UTL_CS1} b9{1=select UTL_CS0} b7-0{bus addr} */
 
 #define NS_CMD_OPEN_CONNECTION (NS_CMD_OPENCLOSE_CONNECTION | 0x00080000)
 #define NS_CMD_CLOSE_CONNECTION NS_CMD_OPENCLOSE_CONNECTION
 
-
-/* NICStAR configuration bits *************************************************/
-
-#define NS_CFG_SWRST          0x80000000    /* Software Reset */
-#define NS_CFG_RXPATH         0x20000000    /* Receive Path Enable */
-#define NS_CFG_SMBUFSIZE_MASK 0x18000000    /* Small Receive Buffer Size */
-#define NS_CFG_LGBUFSIZE_MASK 0x06000000    /* Large Receive Buffer Size */
-#define NS_CFG_EFBIE          0x01000000    /* Empty Free Buffer Queue
-                                               Interrupt Enable */
-#define NS_CFG_RSQSIZE_MASK   0x00C00000    /* Receive Status Queue Size */
-#define NS_CFG_ICACCEPT       0x00200000    /* Invalid Cell Accept */
-#define NS_CFG_IGNOREGFC      0x00100000    /* Ignore General Flow Control */
-#define NS_CFG_VPIBITS_MASK   0x000C0000    /* VPI/VCI Bits Size Select */
-#define NS_CFG_RCTSIZE_MASK   0x00030000    /* Receive Connection Table Size */
-#define NS_CFG_VCERRACCEPT    0x00008000    /* VPI/VCI Error Cell Accept */
-#define NS_CFG_RXINT_MASK     0x00007000    /* End of Receive PDU Interrupt
-                                               Handling */
-#define NS_CFG_RAWIE          0x00000800    /* Raw Cell Qu' Interrupt Enable */
-#define NS_CFG_RSQAFIE        0x00000400    /* Receive Queue Almost Full
-                                               Interrupt Enable */
-#define NS_CFG_RXRM           0x00000200    /* Receive RM Cells */
-#define NS_CFG_TMRROIE        0x00000080    /* Timer Roll Over Interrupt
-                                               Enable */
-#define NS_CFG_TXEN           0x00000020    /* Transmit Operation Enable */
-#define NS_CFG_TXIE           0x00000010    /* Transmit Status Interrupt
-                                               Enable */
-#define NS_CFG_TXURIE         0x00000008    /* Transmit Under-run Interrupt
-                                               Enable */
-#define NS_CFG_UMODE          0x00000004    /* Utopia Mode (cell/byte) Select */
-#define NS_CFG_TSQFIE         0x00000002    /* Transmit Status Queue Full
-                                               Interrupt Enable */
-#define NS_CFG_PHYIE          0x00000001    /* PHY Interrupt Enable */
+/* NICStAR configuration bits */
+
+#define NS_CFG_SWRST          0x80000000	/* Software Reset */
+#define NS_CFG_RXPATH         0x20000000	/* Receive Path Enable */
+#define NS_CFG_SMBUFSIZE_MASK 0x18000000	/* Small Receive Buffer Size */
+#define NS_CFG_LGBUFSIZE_MASK 0x06000000	/* Large Receive Buffer Size */
+#define NS_CFG_EFBIE          0x01000000	/* Empty Free Buffer Queue
+						   Interrupt Enable */
+#define NS_CFG_RSQSIZE_MASK   0x00C00000	/* Receive Status Queue Size */
+#define NS_CFG_ICACCEPT       0x00200000	/* Invalid Cell Accept */
+#define NS_CFG_IGNOREGFC      0x00100000	/* Ignore General Flow Control */
+#define NS_CFG_VPIBITS_MASK   0x000C0000	/* VPI/VCI Bits Size Select */
+#define NS_CFG_RCTSIZE_MASK   0x00030000	/* Receive Connection Table Size */
+#define NS_CFG_VCERRACCEPT    0x00008000	/* VPI/VCI Error Cell Accept */
+#define NS_CFG_RXINT_MASK     0x00007000	/* End of Receive PDU Interrupt
+						   Handling */
+#define NS_CFG_RAWIE          0x00000800	/* Raw Cell Qu' Interrupt Enable */
+#define NS_CFG_RSQAFIE        0x00000400	/* Receive Queue Almost Full
+						   Interrupt Enable */
+#define NS_CFG_RXRM           0x00000200	/* Receive RM Cells */
+#define NS_CFG_TMRROIE        0x00000080	/* Timer Roll Over Interrupt
+						   Enable */
+#define NS_CFG_TXEN           0x00000020	/* Transmit Operation Enable */
+#define NS_CFG_TXIE           0x00000010	/* Transmit Status Interrupt
+						   Enable */
+#define NS_CFG_TXURIE         0x00000008	/* Transmit Under-run Interrupt
+						   Enable */
+#define NS_CFG_UMODE          0x00000004	/* Utopia Mode (cell/byte) Select */
+#define NS_CFG_TSQFIE         0x00000002	/* Transmit Status Queue Full
+						   Interrupt Enable */
+#define NS_CFG_PHYIE          0x00000001	/* PHY Interrupt Enable */
 
 #define NS_CFG_SMBUFSIZE_48    0x00000000
 #define NS_CFG_SMBUFSIZE_96    0x08000000
@@ -579,33 +535,29 @@ enum ns_regs
 #define NS_CFG_RXINT_624US   0x00003000
 #define NS_CFG_RXINT_899US   0x00004000
 
-
-/* NICStAR STATus bits ********************************************************/
-
-#define NS_STAT_SFBQC_MASK 0xFF000000   /* hi 8 bits Small Buffer Queue Count */
-#define NS_STAT_LFBQC_MASK 0x00FF0000   /* hi 8 bits Large Buffer Queue Count */
-#define NS_STAT_TSIF       0x00008000   /* Transmit Status Queue Indicator */
-#define NS_STAT_TXICP      0x00004000   /* Transmit Incomplete PDU */
-#define NS_STAT_TSQF       0x00001000   /* Transmit Status Queue Full */
-#define NS_STAT_TMROF      0x00000800   /* Timer Overflow */
-#define NS_STAT_PHYI       0x00000400   /* PHY Device Interrupt */
-#define NS_STAT_CMDBZ      0x00000200   /* Command Busy */
-#define NS_STAT_SFBQF      0x00000100   /* Small Buffer Queue Full */
-#define NS_STAT_LFBQF      0x00000080   /* Large Buffer Queue Full */
-#define NS_STAT_RSQF       0x00000040   /* Receive Status Queue Full */
-#define NS_STAT_EOPDU      0x00000020   /* End of PDU */
-#define NS_STAT_RAWCF      0x00000010   /* Raw Cell Flag */
-#define NS_STAT_SFBQE      0x00000008   /* Small Buffer Queue Empty */
-#define NS_STAT_LFBQE      0x00000004   /* Large Buffer Queue Empty */
-#define NS_STAT_RSQAF      0x00000002   /* Receive Status Queue Almost Full */
+/* NICStAR STATus bits */
+
+#define NS_STAT_SFBQC_MASK 0xFF000000	/* hi 8 bits Small Buffer Queue Count */
+#define NS_STAT_LFBQC_MASK 0x00FF0000	/* hi 8 bits Large Buffer Queue Count */
+#define NS_STAT_TSIF       0x00008000	/* Transmit Status Queue Indicator */
+#define NS_STAT_TXICP      0x00004000	/* Transmit Incomplete PDU */
+#define NS_STAT_TSQF       0x00001000	/* Transmit Status Queue Full */
+#define NS_STAT_TMROF      0x00000800	/* Timer Overflow */
+#define NS_STAT_PHYI       0x00000400	/* PHY Device Interrupt */
+#define NS_STAT_CMDBZ      0x00000200	/* Command Busy */
+#define NS_STAT_SFBQF      0x00000100	/* Small Buffer Queue Full */
+#define NS_STAT_LFBQF      0x00000080	/* Large Buffer Queue Full */
+#define NS_STAT_RSQF       0x00000040	/* Receive Status Queue Full */
+#define NS_STAT_EOPDU      0x00000020	/* End of PDU */
+#define NS_STAT_RAWCF      0x00000010	/* Raw Cell Flag */
+#define NS_STAT_SFBQE      0x00000008	/* Small Buffer Queue Empty */
+#define NS_STAT_LFBQE      0x00000004	/* Large Buffer Queue Empty */
+#define NS_STAT_RSQAF      0x00000002	/* Receive Status Queue Almost Full */
 
 #define ns_stat_sfbqc_get(stat) (((stat) & NS_STAT_SFBQC_MASK) >> 23)
 #define ns_stat_lfbqc_get(stat) (((stat) & NS_STAT_LFBQC_MASK) >> 15)
 
-
-
-/* #defines which depend on other #defines ************************************/
-
+/* #defines which depend on other #defines */
 
 #define NS_TST0 NS_TST_FRSCD
 #define NS_TST1 (NS_TST_FRSCD + NS_TST_NUM_ENTRIES + 1)
@@ -672,8 +624,7 @@ enum ns_regs
 #define NS_CFG_TSQFIE_OPT 0x00000000
 #endif /* ENABLE_TSQFIE */
 
-
-/* PCI stuff ******************************************************************/
+/* PCI stuff */
 
 #ifndef PCI_VENDOR_ID_IDT
 #define PCI_VENDOR_ID_IDT 0x111D
@@ -683,138 +634,119 @@ enum ns_regs
 #define PCI_DEVICE_ID_IDT_IDT77201 0x0001
 #endif /* PCI_DEVICE_ID_IDT_IDT77201 */
 
-
-
-/* Device driver structures ***************************************************/
-
+/* Device driver structures */
 
 struct ns_skb_cb {
-	u32 buf_type;			/* BUF_SM/BUF_LG/BUF_NONE */
+	u32 buf_type;		/* BUF_SM/BUF_LG/BUF_NONE */
 };
 
 #define NS_SKB_CB(skb)	((struct ns_skb_cb *)((skb)->cb))
 
-typedef struct tsq_info
-{
-   void *org;
-   ns_tsi *base;
-   ns_tsi *next;
-   ns_tsi *last;
+typedef struct tsq_info {
+	void *org;
+	ns_tsi *base;
+	ns_tsi *next;
+	ns_tsi *last;
 } tsq_info;
 
-
-typedef struct scq_info
-{
-   void *org;
-   ns_scqe *base;
-   ns_scqe *last;
-   ns_scqe *next;
-   volatile ns_scqe *tail;		/* Not related to the nicstar register */
-   unsigned num_entries;
-   struct sk_buff **skb;		/* Pointer to an array of pointers
-                                           to the sk_buffs used for tx */
-   u32 scd;				/* SRAM address of the corresponding
-                                           SCD */
-   int tbd_count;			/* Only meaningful on variable rate */
-   wait_queue_head_t scqfull_waitq;
-   volatile char full;			/* SCQ full indicator */
-   spinlock_t lock;			/* SCQ spinlock */
+typedef struct scq_info {
+	void *org;
+	ns_scqe *base;
+	ns_scqe *last;
+	ns_scqe *next;
+	volatile ns_scqe *tail;	/* Not related to the nicstar register */
+	unsigned num_entries;
+	struct sk_buff **skb;	/* Pointer to an array of pointers
+				   to the sk_buffs used for tx */
+	u32 scd;		/* SRAM address of the corresponding
+				   SCD */
+	int tbd_count;		/* Only meaningful on variable rate */
+	wait_queue_head_t scqfull_waitq;
+	volatile char full;	/* SCQ full indicator */
+	spinlock_t lock;	/* SCQ spinlock */
 } scq_info;
 
-
-
-typedef struct rsq_info
-{
-   void *org;
-   ns_rsqe *base;
-   ns_rsqe *next;
-   ns_rsqe *last;
+typedef struct rsq_info {
+	void *org;
+	ns_rsqe *base;
+	ns_rsqe *next;
+	ns_rsqe *last;
 } rsq_info;
 
-
-typedef struct skb_pool
-{
-   volatile int count;			/* number of buffers in the queue */
-   struct sk_buff_head queue;
+typedef struct skb_pool {
+	volatile int count;	/* number of buffers in the queue */
+	struct sk_buff_head queue;
 } skb_pool;
 
 /* NOTE: for small and large buffer pools, the count is not used, as the
          actual value used for buffer management is the one read from the
 	 card. */
 
-
-typedef struct vc_map
-{
-   volatile unsigned int tx:1;				/* TX vc? */
-   volatile unsigned int rx:1;				/* RX vc? */
-   struct atm_vcc *tx_vcc, *rx_vcc;
-   struct sk_buff *rx_iov;		/* RX iovector skb */
-   scq_info *scq;			/* To keep track of the SCQ */
-   u32 cbr_scd;				/* SRAM address of the corresponding
-               				   SCD. 0x00000000 for UBR/VBR/ABR */
-   int tbd_count;
+typedef struct vc_map {
+	volatile unsigned int tx:1;	/* TX vc? */
+	volatile unsigned int rx:1;	/* RX vc? */
+	struct atm_vcc *tx_vcc, *rx_vcc;
+	struct sk_buff *rx_iov;	/* RX iovector skb */
+	scq_info *scq;		/* To keep track of the SCQ */
+	u32 cbr_scd;		/* SRAM address of the corresponding
+				   SCD. 0x00000000 for UBR/VBR/ABR */
+	int tbd_count;
 } vc_map;
 
-
-struct ns_skb_data
-{
+struct ns_skb_data {
 	struct atm_vcc *vcc;
 	int iovcnt;
 };
 
 #define NS_SKB(skb) (((struct ns_skb_data *) (skb)->cb))
 
-
-typedef struct ns_dev
-{
-   int index;				/* Card ID to the device driver */
-   int sram_size;			/* In k x 32bit words. 32 or 128 */
-   void __iomem *membase;		/* Card's memory base address */
-   unsigned long max_pcr;
-   int rct_size;			/* Number of entries */
-   int vpibits;
-   int vcibits;
-   struct pci_dev *pcidev;
-   struct atm_dev *atmdev;
-   tsq_info tsq;
-   rsq_info rsq;
-   scq_info *scq0, *scq1, *scq2;	/* VBR SCQs */
-   skb_pool sbpool;			/* Small buffers */
-   skb_pool lbpool;			/* Large buffers */
-   skb_pool hbpool;			/* Pre-allocated huge buffers */
-   skb_pool iovpool;			/* iovector buffers */
-   volatile int efbie;			/* Empty free buf. queue int. enabled */
-   volatile u32 tst_addr;		/* SRAM address of the TST in use */
-   volatile int tst_free_entries;
-   vc_map vcmap[NS_MAX_RCTSIZE];
-   vc_map *tste2vc[NS_TST_NUM_ENTRIES];
-   vc_map *scd2vc[NS_FRSCD_NUM];
-   buf_nr sbnr;
-   buf_nr lbnr;
-   buf_nr hbnr;
-   buf_nr iovnr;
-   int sbfqc;
-   int lbfqc;
-   u32 sm_handle;
-   u32 sm_addr;
-   u32 lg_handle;
-   u32 lg_addr;
-   struct sk_buff *rcbuf;		/* Current raw cell buffer */
-   u32 rawch;				/* Raw cell queue head */
-   unsigned intcnt;			/* Interrupt counter */
-   spinlock_t int_lock;		/* Interrupt lock */
-   spinlock_t res_lock;		/* Card resource lock */
+typedef struct ns_dev {
+	int index;		/* Card ID to the device driver */
+	int sram_size;		/* In k x 32bit words. 32 or 128 */
+	void __iomem *membase;	/* Card's memory base address */
+	unsigned long max_pcr;
+	int rct_size;		/* Number of entries */
+	int vpibits;
+	int vcibits;
+	struct pci_dev *pcidev;
+	struct atm_dev *atmdev;
+	tsq_info tsq;
+	rsq_info rsq;
+	scq_info *scq0, *scq1, *scq2;	/* VBR SCQs */
+	skb_pool sbpool;	/* Small buffers */
+	skb_pool lbpool;	/* Large buffers */
+	skb_pool hbpool;	/* Pre-allocated huge buffers */
+	skb_pool iovpool;	/* iovector buffers */
+	volatile int efbie;	/* Empty free buf. queue int. enabled */
+	volatile u32 tst_addr;	/* SRAM address of the TST in use */
+	volatile int tst_free_entries;
+	vc_map vcmap[NS_MAX_RCTSIZE];
+	vc_map *tste2vc[NS_TST_NUM_ENTRIES];
+	vc_map *scd2vc[NS_FRSCD_NUM];
+	buf_nr sbnr;
+	buf_nr lbnr;
+	buf_nr hbnr;
+	buf_nr iovnr;
+	int sbfqc;
+	int lbfqc;
+	u32 sm_handle;
+	u32 sm_addr;
+	u32 lg_handle;
+	u32 lg_addr;
+	struct sk_buff *rcbuf;	/* Current raw cell buffer */
+	u32 rawch;		/* Raw cell queue head */
+	unsigned intcnt;	/* Interrupt counter */
+	spinlock_t int_lock;	/* Interrupt lock */
+	spinlock_t res_lock;	/* Card resource lock */
 } ns_dev;
 
-
    /* NOTE: Each tste2vc entry relates a given TST entry to the corresponding
-            CBR vc. If the entry is not allocated, it must be NULL.
-	    
-	    There are two TSTs so the driver can modify them on the fly
-	    without stopping the transmission.
-	    
-	    scd2vc allows us to find out unused fixed rate SCDs, because
-	    they must have a NULL pointer here. */
+      CBR vc. If the entry is not allocated, it must be NULL.
+
+      There are two TSTs so the driver can modify them on the fly
+      without stopping the transmission.
 
+      scd2vc allows us to find out unused fixed rate SCDs, because
+      they must have a NULL pointer here. */
 
 #endif /* _LINUX_NICSTAR_H_ */
diff --git a/drivers/atm/nicstarmac.c b/drivers/atm/nicstarmac.c
index 842e26c..f594526 100644
--- a/drivers/atm/nicstarmac.c
+++ b/drivers/atm/nicstarmac.c
@@ -13,15 +13,15 @@ typedef void __iomem *virt_addr_t;
 
 #define CYCLE_DELAY 5
 
-/* This was the original definition
+/*
+   This was the original definition
 #define osp_MicroDelay(microsec) \
     do { int _i = 4*microsec; while (--_i > 0) { __SLOW_DOWN_IO; }} while (0)
 */
 #define osp_MicroDelay(microsec) {unsigned long useconds = (microsec); \
                                   udelay((useconds));}
-
-
-/* The following tables represent the timing diagrams found in
+/*
+ * The following tables represent the timing diagrams found in
  * the Data Sheet for the Xicor X25020 EEProm.  The #defines below
  * represent the bits in the NICStAR's General Purpose register
  * that must be toggled for the corresponding actions on the EEProm
@@ -31,86 +31,80 @@ typedef void __iomem *virt_addr_t;
 /* Write Data To EEProm from SI line on rising edge of CLK */
 /* Read Data From EEProm on falling edge of CLK */
 
-#define CS_HIGH		0x0002		/* Chip select high */
-#define CS_LOW		0x0000		/* Chip select low (active low)*/
-#define CLK_HIGH	0x0004		/* Clock high */
-#define CLK_LOW		0x0000		/* Clock low  */
-#define SI_HIGH		0x0001		/* Serial input data high */
-#define SI_LOW		0x0000		/* Serial input data low */
+#define CS_HIGH		0x0002	/* Chip select high */
+#define CS_LOW		0x0000	/* Chip select low (active low) */
+#define CLK_HIGH	0x0004	/* Clock high */
+#define CLK_LOW		0x0000	/* Clock low  */
+#define SI_HIGH		0x0001	/* Serial input data high */
+#define SI_LOW		0x0000	/* Serial input data low */
 
 /* Read Status Register = 0000 0101b */
 #if 0
-static u_int32_t rdsrtab[] =
-{
-    CS_HIGH | CLK_HIGH, 
-    CS_LOW | CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW,
-    CLK_HIGH,             /* 0 */
-    CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW | SI_HIGH, 
-    CLK_HIGH | SI_HIGH,   /* 1 */
-    CLK_LOW | SI_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW | SI_HIGH, 
-    CLK_HIGH | SI_HIGH   /* 1 */
+static u_int32_t rdsrtab[] = {
+	CS_HIGH | CLK_HIGH,
+	CS_LOW | CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW | SI_HIGH,
+	CLK_HIGH | SI_HIGH,	/* 1 */
+	CLK_LOW | SI_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW | SI_HIGH,
+	CLK_HIGH | SI_HIGH	/* 1 */
 };
-#endif  /*  0  */
-
+#endif /*  0  */
 
 /* Read from EEPROM = 0000 0011b */
-static u_int32_t readtab[] =
-{
-    /*
-    CS_HIGH | CLK_HIGH, 
-    */
-    CS_LOW | CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW,
-    CLK_HIGH,             /* 0 */
-    CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW, 
-    CLK_HIGH,             /* 0 */
-    CLK_LOW | SI_HIGH, 
-    CLK_HIGH | SI_HIGH,   /* 1 */
-    CLK_LOW | SI_HIGH, 
-    CLK_HIGH | SI_HIGH    /* 1 */
+static u_int32_t readtab[] = {
+	/*
+	   CS_HIGH | CLK_HIGH,
+	 */
+	CS_LOW | CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW,
+	CLK_HIGH,		/* 0 */
+	CLK_LOW | SI_HIGH,
+	CLK_HIGH | SI_HIGH,	/* 1 */
+	CLK_LOW | SI_HIGH,
+	CLK_HIGH | SI_HIGH	/* 1 */
 };
 
-
 /* Clock to read from/write to the eeprom */
-static u_int32_t clocktab[] =
-{	
-    CLK_LOW,
-    CLK_HIGH,
-    CLK_LOW, 
-    CLK_HIGH,
-    CLK_LOW,
-    CLK_HIGH,
-    CLK_LOW, 
-    CLK_HIGH,
-    CLK_LOW, 
-    CLK_HIGH,
-    CLK_LOW, 
-    CLK_HIGH, 
-    CLK_LOW, 
-    CLK_HIGH,
-    CLK_LOW, 
-    CLK_HIGH,
-    CLK_LOW 
+static u_int32_t clocktab[] = {
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW,
+	CLK_HIGH,
+	CLK_LOW
 };
 
-
 #define NICSTAR_REG_WRITE(bs, reg, val) \
 	while ( readl(bs + STAT) & 0x0200 ) ; \
 	writel((val),(base)+(reg))
@@ -124,153 +118,131 @@ static u_int32_t clocktab[] =
  * register.  
  */
 #if 0
-u_int32_t
-nicstar_read_eprom_status( virt_addr_t base )
+u_int32_t nicstar_read_eprom_status(virt_addr_t base)
 {
-   u_int32_t	val;
-   u_int32_t	rbyte;
-   int32_t	i, j;
-
-   /* Send read instruction */
-   val = NICSTAR_REG_READ( base, NICSTAR_REG_GENERAL_PURPOSE ) & 0xFFFFFFF0;
-
-   for (i=0; i<ARRAY_SIZE(rdsrtab); i++)
-   {
-	NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-		(val | rdsrtab[i]) );
-        osp_MicroDelay( CYCLE_DELAY );
-   }
-
-   /* Done sending instruction - now pull data off of bit 16, MSB first */
-   /* Data clocked out of eeprom on falling edge of clock */
-
-   rbyte = 0;
-   for (i=7, j=0; i>=0; i--)
-   {
-	NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-		(val | clocktab[j++]) );
-        rbyte |= (((NICSTAR_REG_READ( base, NICSTAR_REG_GENERAL_PURPOSE)
-			& 0x00010000) >> 16) << i);
-	NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-		(val | clocktab[j++]) );
-        osp_MicroDelay( CYCLE_DELAY );
-   }
-   NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE, 2 );
-   osp_MicroDelay( CYCLE_DELAY );
-   return rbyte;
+	u_int32_t val;
+	u_int32_t rbyte;
+	int32_t i, j;
+
+	/* Send read instruction */
+	val = NICSTAR_REG_READ(base, NICSTAR_REG_GENERAL_PURPOSE) & 0xFFFFFFF0;
+
+	for (i = 0; i < ARRAY_SIZE(rdsrtab); i++) {
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | rdsrtab[i]));
+		osp_MicroDelay(CYCLE_DELAY);
+	}
+
+	/* Done sending instruction - now pull data off of bit 16, MSB first */
+	/* Data clocked out of eeprom on falling edge of clock */
+
+	rbyte = 0;
+	for (i = 7, j = 0; i >= 0; i--) {
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | clocktab[j++]));
+		rbyte |= (((NICSTAR_REG_READ(base, NICSTAR_REG_GENERAL_PURPOSE)
+			    & 0x00010000) >> 16) << i);
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | clocktab[j++]));
+		osp_MicroDelay(CYCLE_DELAY);
+	}
+	NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE, 2);
+	osp_MicroDelay(CYCLE_DELAY);
+	return rbyte;
 }
-#endif  /*  0  */
-
+#endif /*  0  */
 
 /*
  * This routine will clock the Read_data function into the X2520
  * eeprom, followed by the address to read from, through the NicSTaR's General
  * Purpose register.  
  */
- 
-static u_int8_t 
-read_eprom_byte(virt_addr_t base, u_int8_t offset)
+
+static u_int8_t read_eprom_byte(virt_addr_t base, u_int8_t offset)
 {
-   u_int32_t val = 0;
-   int i,j=0;
-   u_int8_t tempread = 0;
-
-   val = NICSTAR_REG_READ( base, NICSTAR_REG_GENERAL_PURPOSE ) & 0xFFFFFFF0;
-
-   /* Send READ instruction */
-   for (i=0; i<ARRAY_SIZE(readtab); i++)
-   {
-	NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-		(val | readtab[i]) );
-        osp_MicroDelay( CYCLE_DELAY );
-   }
-
-   /* Next, we need to send the byte address to read from */
-   for (i=7; i>=0; i--)
-   {
-      NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-      		(val | clocktab[j++] | ((offset >> i) & 1) ) );
-      osp_MicroDelay(CYCLE_DELAY);
-      NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-      		(val | clocktab[j++] | ((offset >> i) & 1) ) );
-      osp_MicroDelay( CYCLE_DELAY );
-   }
-
-   j = 0;
-   
-   /* Now, we can read data from the eeprom by clocking it in */
-   for (i=7; i>=0; i--)
-   {
-      NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-      		(val | clocktab[j++]) );
-      osp_MicroDelay( CYCLE_DELAY );
-      tempread |= (((NICSTAR_REG_READ( base, NICSTAR_REG_GENERAL_PURPOSE )
-		& 0x00010000) >> 16) << i);
-      NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
-      		(val | clocktab[j++]) );
-      osp_MicroDelay( CYCLE_DELAY );
-   }
-
-   NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE, 2 );
-   osp_MicroDelay( CYCLE_DELAY );
-   return tempread;
+	u_int32_t val = 0;
+	int i, j = 0;
+	u_int8_t tempread = 0;
+
+	val = NICSTAR_REG_READ(base, NICSTAR_REG_GENERAL_PURPOSE) & 0xFFFFFFF0;
+
+	/* Send READ instruction */
+	for (i = 0; i < ARRAY_SIZE(readtab); i++) {
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | readtab[i]));
+		osp_MicroDelay(CYCLE_DELAY);
+	}
+
+	/* Next, we need to send the byte address to read from */
+	for (i = 7; i >= 0; i--) {
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | clocktab[j++] | ((offset >> i) & 1)));
+		osp_MicroDelay(CYCLE_DELAY);
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | clocktab[j++] | ((offset >> i) & 1)));
+		osp_MicroDelay(CYCLE_DELAY);
+	}
+
+	j = 0;
+
+	/* Now, we can read data from the eeprom by clocking it in */
+	for (i = 7; i >= 0; i--) {
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | clocktab[j++]));
+		osp_MicroDelay(CYCLE_DELAY);
+		tempread |=
+		    (((NICSTAR_REG_READ(base, NICSTAR_REG_GENERAL_PURPOSE)
+		       & 0x00010000) >> 16) << i);
+		NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+				  (val | clocktab[j++]));
+		osp_MicroDelay(CYCLE_DELAY);
+	}
+
+	NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE, 2);
+	osp_MicroDelay(CYCLE_DELAY);
+	return tempread;
 }
 
-
-static void
-nicstar_init_eprom( virt_addr_t base )
+static void nicstar_init_eprom(virt_addr_t base)
 {
-    u_int32_t val;
+	u_int32_t val;
 
-    /*
-     * turn chip select off
-     */
-    val = NICSTAR_REG_READ(base, NICSTAR_REG_GENERAL_PURPOSE) & 0xFFFFFFF0;
+	/*
+	 * turn chip select off
+	 */
+	val = NICSTAR_REG_READ(base, NICSTAR_REG_GENERAL_PURPOSE) & 0xFFFFFFF0;
 
-    NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
-    	(val | CS_HIGH | CLK_HIGH));
-    osp_MicroDelay( CYCLE_DELAY );
+	NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+			  (val | CS_HIGH | CLK_HIGH));
+	osp_MicroDelay(CYCLE_DELAY);
 
-    NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
-    	(val | CS_HIGH | CLK_LOW));
-    osp_MicroDelay( CYCLE_DELAY );
+	NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+			  (val | CS_HIGH | CLK_LOW));
+	osp_MicroDelay(CYCLE_DELAY);
 
-    NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
-    	(val | CS_HIGH | CLK_HIGH));
-    osp_MicroDelay( CYCLE_DELAY );
+	NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+			  (val | CS_HIGH | CLK_HIGH));
+	osp_MicroDelay(CYCLE_DELAY);
 
-    NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
-    	(val | CS_HIGH | CLK_LOW));
-    osp_MicroDelay( CYCLE_DELAY );
+	NICSTAR_REG_WRITE(base, NICSTAR_REG_GENERAL_PURPOSE,
+			  (val | CS_HIGH | CLK_LOW));
+	osp_MicroDelay(CYCLE_DELAY);
 }
 
-
 /*
  * This routine will be the interface to the ReadPromByte function
  * above.
- */ 
+ */
 
 static void
-nicstar_read_eprom(
-    virt_addr_t	base,
-    u_int8_t	prom_offset,
-    u_int8_t	*buffer,
-    u_int32_t	nbytes )
+nicstar_read_eprom(virt_addr_t base,
+		   u_int8_t prom_offset, u_int8_t * buffer, u_int32_t nbytes)
 {
-    u_int		i;
-    
-    for (i=0; i<nbytes; i++)
-    {
-	buffer[i] = read_eprom_byte( base, prom_offset );
-	++prom_offset;
- 	osp_MicroDelay( CYCLE_DELAY );
-    }
-}
-
+	u_int i;
 
-/*
-void osp_MicroDelay(int x) {
-    
+	for (i = 0; i < nbytes; i++) {
+		buffer[i] = read_eprom_byte(base, prom_offset);
+		++prom_offset;
+		osp_MicroDelay(CYCLE_DELAY);
+	}
 }
-*/
-
