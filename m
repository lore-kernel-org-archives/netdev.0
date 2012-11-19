From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 204/493] atm: remove use of __devinit
Date: Mon, 19 Nov 2012 13:22:33 -0500
Message-ID: <1353349642-3677-204-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41322 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab2KSScy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:32:54 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil> 
Cc: linux-atm-general@lists.sourceforge.net 
Cc: netdev@vger.kernel.org 
---
 drivers/atm/ambassador.c | 24 ++++++++++++------------
 drivers/atm/eni.c        | 10 +++++-----
 drivers/atm/firestream.c | 16 ++++++++--------
 drivers/atm/fore200e.c   | 38 +++++++++++++++++++-------------------
 drivers/atm/he.c         | 20 ++++++++++----------
 drivers/atm/horizon.c    |  6 +++---
 drivers/atm/idt77252.c   | 10 +++++-----
 drivers/atm/iphase.c     |  6 +++---
 drivers/atm/lanai.c      | 24 ++++++++++++------------
 drivers/atm/nicstar.c    | 10 +++++-----
 drivers/atm/zatm.c       | 18 +++++++++---------
 11 files changed, 91 insertions(+), 91 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 9e9df4f..eb8d486 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -1507,7 +1507,7 @@ static void do_housekeeping (unsigned long arg) {
 
 /********** creation of communication queues **********/
 
-static int __devinit create_queues (amb_dev * dev, unsigned int cmds,
+static int create_queues (amb_dev * dev, unsigned int cmds,
 				 unsigned int txs, unsigned int * rxs,
 				 unsigned int * rx_buffer_sizes) {
   unsigned char pool;
@@ -1737,7 +1737,7 @@ static  int decode_loader_result (loader_command cmd, u32 result)
 	return res;
 }
 
-static int __devinit do_loader_command (volatile loader_block * lb,
+static int do_loader_command (volatile loader_block * lb,
 				     const amb_dev * dev, loader_command cmd) {
   
   unsigned long timeout;
@@ -1793,7 +1793,7 @@ static int __devinit do_loader_command (volatile loader_block * lb,
 
 /* loader: determine loader version */
 
-static int __devinit get_loader_version (loader_block * lb,
+static int get_loader_version (loader_block * lb,
 				      const amb_dev * dev, u32 * version) {
   int res;
   
@@ -1809,7 +1809,7 @@ static int __devinit get_loader_version (loader_block * lb,
 
 /* loader: write memory data blocks */
 
-static int __devinit loader_write (loader_block* lb,
+static int loader_write (loader_block* lb,
 				   const amb_dev *dev,
 				   const struct ihex_binrec *rec) {
   transfer_block * tb = &lb->payload.transfer;
@@ -1824,7 +1824,7 @@ static int __devinit loader_write (loader_block* lb,
 
 /* loader: verify memory data blocks */
 
-static int __devinit loader_verify (loader_block * lb,
+static int loader_verify (loader_block * lb,
 				    const amb_dev *dev,
 				    const struct ihex_binrec *rec) {
   transfer_block * tb = &lb->payload.transfer;
@@ -1842,7 +1842,7 @@ static int __devinit loader_verify (loader_block * lb,
 
 /* loader: start microcode */
 
-static int __devinit loader_start (loader_block * lb,
+static int loader_start (loader_block * lb,
 				const amb_dev * dev, u32 address) {
   PRINTD (DBG_FLOW|DBG_LOAD, "loader_start");
   
@@ -1918,7 +1918,7 @@ static int amb_reset (amb_dev * dev, int diags) {
 
 /********** transfer and start the microcode **********/
 
-static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
+static int ucode_init (loader_block * lb, amb_dev * dev) {
   const struct firmware *fw;
   unsigned long start_address;
   const struct ihex_binrec *rec;
@@ -1979,7 +1979,7 @@ static inline __be32 bus_addr(void * addr) {
     return cpu_to_be32 (virt_to_bus (addr));
 }
 
-static int __devinit amb_talk (amb_dev * dev) {
+static int amb_talk (amb_dev * dev) {
   adap_talk_block a;
   unsigned char pool;
   unsigned long timeout;
@@ -2026,7 +2026,7 @@ static int __devinit amb_talk (amb_dev * dev) {
 }
 
 // get microcode version
-static void __devinit amb_ucode_version (amb_dev * dev) {
+static void amb_ucode_version (amb_dev * dev) {
   u32 major;
   u32 minor;
   command cmd;
@@ -2041,7 +2041,7 @@ static void __devinit amb_ucode_version (amb_dev * dev) {
 }
   
 // get end station address
-static void __devinit amb_esi (amb_dev * dev, u8 * esi) {
+static void amb_esi (amb_dev * dev, u8 * esi) {
   u32 lower4;
   u16 upper2;
   command cmd;
@@ -2087,7 +2087,7 @@ static void fixup_plx_window (amb_dev *dev, loader_block *lb)
 	return;
 }
 
-static int __devinit amb_init (amb_dev * dev)
+static int amb_init (amb_dev * dev)
 {
   loader_block lb;
   
@@ -2183,7 +2183,7 @@ static void setup_pci_dev(struct pci_dev *pci_dev)
 	}
 }
 
-static int __devinit amb_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
+static int amb_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
 	amb_dev * dev;
 	int err;
diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 2dd26f9..34416f6 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1591,7 +1591,7 @@ static char * const media_name[] __devinitconst = {
   } })
 
 
-static int __devinit get_esi_asic(struct atm_dev *dev)
+static int get_esi_asic(struct atm_dev *dev)
 {
 	struct eni_dev *eni_dev;
 	unsigned char tonga;
@@ -1683,7 +1683,7 @@ static int __devinit get_esi_asic(struct atm_dev *dev)
 #undef GET_SEPROM
 
 
-static int __devinit get_esi_fpga(struct atm_dev *dev, void __iomem *base)
+static int get_esi_fpga(struct atm_dev *dev, void __iomem *base)
 {
 	void __iomem *mac_base;
 	int i;
@@ -1694,7 +1694,7 @@ static int __devinit get_esi_fpga(struct atm_dev *dev, void __iomem *base)
 }
 
 
-static int __devinit eni_do_init(struct atm_dev *dev)
+static int eni_do_init(struct atm_dev *dev)
 {
 	struct midway_eprom __iomem *eprom;
 	struct eni_dev *eni_dev;
@@ -1797,7 +1797,7 @@ static void eni_do_release(struct atm_dev *dev)
 	iounmap(ed->ioaddr);
 }
 
-static int __devinit eni_start(struct atm_dev *dev)
+static int eni_start(struct atm_dev *dev)
 {
 	struct eni_dev *eni_dev;
 	
@@ -2226,7 +2226,7 @@ static const struct atmdev_ops ops = {
 };
 
 
-static int __devinit eni_init_one(struct pci_dev *pci_dev,
+static int eni_init_one(struct pci_dev *pci_dev,
 				  const struct pci_device_id *ent)
 {
 	struct atm_dev *dev;
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 5aae55d..a173c77 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1295,7 +1295,7 @@ static const struct atmdev_ops ops = {
 };
 
 
-static void __devinit undocumented_pci_fix (struct pci_dev *pdev)
+static void undocumented_pci_fix (struct pci_dev *pdev)
 {
 	u32 tint;
 
@@ -1319,13 +1319,13 @@ static void __devinit undocumented_pci_fix (struct pci_dev *pdev)
  *                              PHY routines                              *
  **************************************************************************/
 
-static void __devinit write_phy (struct fs_dev *dev, int regnum, int val)
+static void write_phy (struct fs_dev *dev, int regnum, int val)
 {
 	submit_command (dev,  &dev->hp_txq, QE_CMD_PRP_WR | QE_CMD_IMM_INQ,
 			regnum, val, 0);
 }
 
-static int __devinit init_phy (struct fs_dev *dev, struct reginit_item *reginit)
+static int init_phy (struct fs_dev *dev, struct reginit_item *reginit)
 {
 	int i;
 
@@ -1381,7 +1381,7 @@ static void reset_chip (struct fs_dev *dev)
 	}
 }
 
-static void __devinit *aligned_kmalloc (int size, gfp_t flags, int alignment)
+static void *aligned_kmalloc (int size, gfp_t flags, int alignment)
 {
 	void  *t;
 
@@ -1398,7 +1398,7 @@ static void __devinit *aligned_kmalloc (int size, gfp_t flags, int alignment)
 	return NULL;
 }
 
-static int __devinit init_q (struct fs_dev *dev, 
+static int init_q (struct fs_dev *dev,
 			  struct queue *txq, int queue, int nentries, int is_rq)
 {
 	int sz = nentries * sizeof (struct FS_QENTRY);
@@ -1434,7 +1434,7 @@ static int __devinit init_q (struct fs_dev *dev,
 }
 
 
-static int __devinit init_fp (struct fs_dev *dev, 
+static int init_fp (struct fs_dev *dev,
 			   struct freepool *fp, int queue, int bufsize, int nr_buffers)
 {
 	func_enter ();
@@ -1662,7 +1662,7 @@ static void fs_poll (unsigned long data)
 }
 #endif
 
-static int __devinit fs_init (struct fs_dev *dev)
+static int fs_init (struct fs_dev *dev)
 {
 	struct pci_dev  *pci_dev;
 	int isr, to;
@@ -1897,7 +1897,7 @@ unmap:
 	return 1;
 }
 
-static int __devinit firestream_init_one (struct pci_dev *pci_dev,
+static int firestream_init_one (struct pci_dev *pci_dev,
 				       const struct pci_device_id *ent) 
 {
 	struct atm_dev *atm_dev;
diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index c162162..4b34891 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -527,7 +527,7 @@ fore200e_pca_reset(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_pca_map(struct fore200e* fore200e)
 {
     DPRINTK(2, "device %s being mapped in memory\n", fore200e->name);
@@ -561,7 +561,7 @@ fore200e_pca_unmap(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_pca_configure(struct fore200e* fore200e)
 {
     struct pci_dev* pci_dev = (struct pci_dev*)fore200e->bus_dev;
@@ -2028,7 +2028,7 @@ fore200e_change_qos(struct atm_vcc* vcc,struct atm_qos* qos, int flags)
 }
     
 
-static int __devinit
+static int
 fore200e_irq_request(struct fore200e* fore200e)
 {
     if (request_irq(fore200e->irq, fore200e_interrupt, IRQF_SHARED, fore200e->name, fore200e->atm_dev) < 0) {
@@ -2051,7 +2051,7 @@ fore200e_irq_request(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_get_esi(struct fore200e* fore200e)
 {
     struct prom_data* prom = kzalloc(sizeof(struct prom_data), GFP_KERNEL | GFP_DMA);
@@ -2081,7 +2081,7 @@ fore200e_get_esi(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_alloc_rx_buf(struct fore200e* fore200e)
 {
     int scheme, magn, nbr, size, i;
@@ -2146,7 +2146,7 @@ fore200e_alloc_rx_buf(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_init_bs_queue(struct fore200e* fore200e)
 {
     int scheme, magn, i;
@@ -2209,7 +2209,7 @@ fore200e_init_bs_queue(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_init_rx_queue(struct fore200e* fore200e)
 {
     struct host_rxq*     rxq =  &fore200e->host_rxq;
@@ -2269,7 +2269,7 @@ fore200e_init_rx_queue(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_init_tx_queue(struct fore200e* fore200e)
 {
     struct host_txq*     txq =  &fore200e->host_txq;
@@ -2332,7 +2332,7 @@ fore200e_init_tx_queue(struct fore200e* fore200e)
 }
 
 
-static int __devinit
+static int
 fore200e_init_cmd_queue(struct fore200e* fore200e)
 {
     struct host_cmdq*     cmdq =  &fore200e->host_cmdq;
@@ -2374,7 +2374,7 @@ fore200e_init_cmd_queue(struct fore200e* fore200e)
 }
 
 
-static void __devinit
+static void
 fore200e_param_bs_queue(struct fore200e* fore200e,
 			enum buffer_scheme scheme, enum buffer_magn magn,
 			int queue_length, int pool_size, int supply_blksize)
@@ -2388,7 +2388,7 @@ fore200e_param_bs_queue(struct fore200e* fore200e,
 }
 
 
-static int __devinit
+static int
 fore200e_initialize(struct fore200e* fore200e)
 {
     struct cp_queues __iomem * cpq;
@@ -2440,7 +2440,7 @@ fore200e_initialize(struct fore200e* fore200e)
 }
 
 
-static void __devinit
+static void
 fore200e_monitor_putc(struct fore200e* fore200e, char c)
 {
     struct cp_monitor __iomem * monitor = fore200e->cp_monitor;
@@ -2452,7 +2452,7 @@ fore200e_monitor_putc(struct fore200e* fore200e, char c)
 }
 
 
-static int __devinit
+static int
 fore200e_monitor_getc(struct fore200e* fore200e)
 {
     struct cp_monitor __iomem * monitor = fore200e->cp_monitor;
@@ -2477,7 +2477,7 @@ fore200e_monitor_getc(struct fore200e* fore200e)
 }
 
 
-static void __devinit
+static void
 fore200e_monitor_puts(struct fore200e* fore200e, char* str)
 {
     while (*str) {
@@ -2497,7 +2497,7 @@ fore200e_monitor_puts(struct fore200e* fore200e, char* str)
 #define FW_EXT "_ecd.bin2"
 #endif
 
-static int __devinit
+static int
 fore200e_load_and_start_fw(struct fore200e* fore200e)
 {
     const struct firmware *firmware;
@@ -2566,7 +2566,7 @@ release:
 }
 
 
-static int __devinit
+static int
 fore200e_register(struct fore200e* fore200e, struct device *parent)
 {
     struct atm_dev* atm_dev;
@@ -2593,7 +2593,7 @@ fore200e_register(struct fore200e* fore200e, struct device *parent)
 }
 
 
-static int __devinit
+static int
 fore200e_init(struct fore200e* fore200e, struct device *parent)
 {
     if (fore200e_register(fore200e, parent) < 0)
@@ -2644,7 +2644,7 @@ fore200e_init(struct fore200e* fore200e, struct device *parent)
 
 #ifdef CONFIG_SBUS
 static const struct of_device_id fore200e_sba_match[];
-static int __devinit fore200e_sba_probe(struct platform_device *op)
+static int fore200e_sba_probe(struct platform_device *op)
 {
 	const struct of_device_id *match;
 	const struct fore200e_bus *bus;
@@ -2712,7 +2712,7 @@ static struct platform_driver fore200e_sba_driver = {
 #endif
 
 #ifdef CONFIG_PCI
-static int __devinit
+static int
 fore200e_pca_detect(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
     const struct fore200e_bus* bus = (struct fore200e_bus*) pci_ent->driver_data;
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index c372814..dac5144 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -349,7 +349,7 @@ __find_vcc(struct he_dev *he_dev, unsigned cid)
 	return NULL;
 }
 
-static int __devinit
+static int
 he_init_one(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
 	struct atm_dev *atm_dev = NULL;
@@ -445,7 +445,7 @@ rate_to_atmf(unsigned rate)		/* cps to atm forum format */
 	return (NONZERO | (exp << 9) | (rate & 0x1ff));
 }
 
-static void __devinit
+static void
 he_init_rx_lbfp0(struct he_dev *he_dev)
 {
 	unsigned i, lbm_offset, lbufd_index, lbuf_addr, lbuf_count;
@@ -476,7 +476,7 @@ he_init_rx_lbfp0(struct he_dev *he_dev)
 	he_writel(he_dev, he_dev->r0_numbuffs, RLBF0_C);
 }
 
-static void __devinit
+static void
 he_init_rx_lbfp1(struct he_dev *he_dev)
 {
 	unsigned i, lbm_offset, lbufd_index, lbuf_addr, lbuf_count;
@@ -507,7 +507,7 @@ he_init_rx_lbfp1(struct he_dev *he_dev)
 	he_writel(he_dev, he_dev->r1_numbuffs, RLBF1_C);
 }
 
-static void __devinit
+static void
 he_init_tx_lbfp(struct he_dev *he_dev)
 {
 	unsigned i, lbm_offset, lbufd_index, lbuf_addr, lbuf_count;
@@ -537,7 +537,7 @@ he_init_tx_lbfp(struct he_dev *he_dev)
 	he_writel(he_dev, lbufd_index - 1, TLBF_T);
 }
 
-static int __devinit
+static int
 he_init_tpdrq(struct he_dev *he_dev)
 {
 	he_dev->tpdrq_base = pci_alloc_consistent(he_dev->pci_dev,
@@ -559,7 +559,7 @@ he_init_tpdrq(struct he_dev *he_dev)
 	return 0;
 }
 
-static void __devinit
+static void
 he_init_cs_block(struct he_dev *he_dev)
 {
 	unsigned clock, rate, delta;
@@ -655,7 +655,7 @@ he_init_cs_block(struct he_dev *he_dev)
 
 }
 
-static int __devinit
+static int
 he_init_cs_block_rcm(struct he_dev *he_dev)
 {
 	unsigned (*rategrid)[16][16];
@@ -776,7 +776,7 @@ he_init_cs_block_rcm(struct he_dev *he_dev)
 	return 0;
 }
 
-static int __devinit
+static int
 he_init_group(struct he_dev *he_dev, int group)
 {
 	struct he_buff *heb, *next;
@@ -915,7 +915,7 @@ out_free_rbpl_table:
 	return -ENOMEM;
 }
 
-static int __devinit
+static int
 he_init_irq(struct he_dev *he_dev)
 {
 	int i;
@@ -978,7 +978,7 @@ he_init_irq(struct he_dev *he_dev)
 	return 0;
 }
 
-static int __devinit
+static int
 he_start(struct atm_dev *dev)
 {
 	struct he_dev *he_dev;
diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 9d98421..67b570a 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -1789,7 +1789,7 @@ static void CLOCK_IT (const hrz_dev *dev, u32 ctrl)
 	WRITE_IT_WAIT(dev, ctrl | SEEPROM_SK);
 }
 
-static u16 __devinit read_bia (const hrz_dev * dev, u16 addr)
+static u16 read_bia (const hrz_dev * dev, u16 addr)
 {
   u32 ctrl = rd_regl (dev, CONTROL_0_REG);
   
@@ -1845,7 +1845,7 @@ static u16 __devinit read_bia (const hrz_dev * dev, u16 addr)
 
 /********** initialise a card **********/
 
-static int __devinit hrz_init (hrz_dev * dev) {
+static int hrz_init (hrz_dev * dev) {
   int onefivefive;
   
   u16 chan;
@@ -2681,7 +2681,7 @@ static const struct atmdev_ops hrz_ops = {
   .owner	= THIS_MODULE,
 };
 
-static int __devinit hrz_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
+static int hrz_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
 	hrz_dev * dev;
 	int err = 0;
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 8974bd2..cfa6a9d 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3109,7 +3109,7 @@ deinit_card(struct idt77252_dev *card)
 }
 
 
-static void __devinit
+static void
 init_sram(struct idt77252_dev *card)
 {
 	int i;
@@ -3257,7 +3257,7 @@ init_sram(struct idt77252_dev *card)
 	IPRINTK("%s: SRAM initialization complete.\n", card->name);
 }
 
-static int __devinit
+static int
 init_card(struct atm_dev *dev)
 {
 	struct idt77252_dev *card = dev->dev_data;
@@ -3537,7 +3537,7 @@ init_card(struct atm_dev *dev)
 /*****************************************************************************/
 
 
-static int __devinit
+static int
 idt77252_preset(struct idt77252_dev *card)
 {
 	u16 pci_command;
@@ -3579,7 +3579,7 @@ idt77252_preset(struct idt77252_dev *card)
 }
 
 
-static unsigned long __devinit
+static unsigned long
 probe_sram(struct idt77252_dev *card)
 {
 	u32 data, addr;
@@ -3601,7 +3601,7 @@ probe_sram(struct idt77252_dev *card)
 	return addr * sizeof(u32);
 }
 
-static int __devinit
+static int
 idt77252_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 {
 	static struct idt77252_dev **last = &idt77252_chain;
diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 23b3627..444e81e 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -2299,7 +2299,7 @@ static int reset_sar(struct atm_dev *dev)
 }  
 	  
 	  
-static int __devinit ia_init(struct atm_dev *dev)
+static int ia_init(struct atm_dev *dev)
 {  
 	IADEV *iadev;  
 	unsigned long real_base;
@@ -2492,7 +2492,7 @@ static void ia_free_rx(IADEV *iadev)
 			  iadev->rx_dle_dma);  
 }
 
-static int __devinit ia_start(struct atm_dev *dev)
+static int ia_start(struct atm_dev *dev)
 {  
 	IADEV *iadev;  
 	int error;  
@@ -3168,7 +3168,7 @@ static const struct atmdev_ops ops = {
 	.owner		= THIS_MODULE,
 };  
 	  
-static int __devinit ia_init_one(struct pci_dev *pdev,
+static int ia_init_one(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {  
 	struct atm_dev *dev;  
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 68c7588..e6d132b 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -551,7 +551,7 @@ static inline void sram_write(const struct lanai_dev *lanai,
 	writel(val, sram_addr(lanai, offset));
 }
 
-static int __devinit sram_test_word(const struct lanai_dev *lanai,
+static int sram_test_word(const struct lanai_dev *lanai,
 				    int offset, u32 pattern)
 {
 	u32 readback;
@@ -566,7 +566,7 @@ static int __devinit sram_test_word(const struct lanai_dev *lanai,
 	return -EIO;
 }
 
-static int __devinit sram_test_pass(const struct lanai_dev *lanai, u32 pattern)
+static int sram_test_pass(const struct lanai_dev *lanai, u32 pattern)
 {
 	int offset, result = 0;
 	for (offset = 0; offset < SRAM_BYTES && result == 0; offset += 4)
@@ -574,7 +574,7 @@ static int __devinit sram_test_pass(const struct lanai_dev *lanai, u32 pattern)
 	return result;
 }
 
-static int __devinit sram_test_and_clear(const struct lanai_dev *lanai)
+static int sram_test_and_clear(const struct lanai_dev *lanai)
 {
 #ifdef FULL_MEMORY_TEST
 	int result;
@@ -860,7 +860,7 @@ static inline void aal0_buffer_free(struct lanai_dev *lanai)
 #ifndef READ_EEPROM
 
 /* Stub functions to use if EEPROM reading is disabled */
-static int __devinit eeprom_read(struct lanai_dev *lanai)
+static int eeprom_read(struct lanai_dev *lanai)
 {
 	printk(KERN_INFO DEV_LABEL "(itf %d): *NOT* reading EEPROM\n",
 	    lanai->number);
@@ -868,7 +868,7 @@ static int __devinit eeprom_read(struct lanai_dev *lanai)
 	return 0;
 }
 
-static int __devinit eeprom_validate(struct lanai_dev *lanai)
+static int eeprom_validate(struct lanai_dev *lanai)
 {
 	lanai->serialno = 0;
 	lanai->magicno = EEPROM_MAGIC_VALUE;
@@ -877,7 +877,7 @@ static int __devinit eeprom_validate(struct lanai_dev *lanai)
 
 #else /* READ_EEPROM */
 
-static int __devinit eeprom_read(struct lanai_dev *lanai)
+static int eeprom_read(struct lanai_dev *lanai)
 {
 	int i, address;
 	u8 data;
@@ -953,7 +953,7 @@ static inline u32 eeprom_be4(const struct lanai_dev *lanai, int address)
 }
 
 /* Checksum/validate EEPROM contents */
-static int __devinit eeprom_validate(struct lanai_dev *lanai)
+static int eeprom_validate(struct lanai_dev *lanai)
 {
 	int i, s;
 	u32 v;
@@ -1448,7 +1448,7 @@ static void vcc_rx_aal0(struct lanai_dev *lanai)
 #include <linux/vmalloc.h>
 #endif
 
-static int __devinit vcc_table_allocate(struct lanai_dev *lanai)
+static int vcc_table_allocate(struct lanai_dev *lanai)
 {
 #ifdef VCCTABLE_GETFREEPAGE
 	APRINTK((lanai->num_vci) * sizeof(struct lanai_vcc *) <= PAGE_SIZE,
@@ -1588,7 +1588,7 @@ static void lanai_reset(struct lanai_dev *lanai)
 /*
  * Allocate service buffer and tell card about it
  */
-static int __devinit service_buffer_allocate(struct lanai_dev *lanai)
+static int service_buffer_allocate(struct lanai_dev *lanai)
 {
 	lanai_buf_allocate(&lanai->service, SERVICE_ENTRIES * 4, 8,
 	    lanai->pci);
@@ -1942,7 +1942,7 @@ static int check_board_id_and_rev(const char *name, u32 val, int *revp)
 
 /* -------------------- PCI INITIALIZATION/SHUTDOWN: */
 
-static int __devinit lanai_pci_start(struct lanai_dev *lanai)
+static int lanai_pci_start(struct lanai_dev *lanai)
 {
 	struct pci_dev *pci = lanai->pci;
 	int result;
@@ -2123,7 +2123,7 @@ static inline void lanai_cbr_shutdown(struct lanai_dev *lanai)
 /* -------------------- OPERATIONS: */
 
 /* setup a newly detected device */
-static int __devinit lanai_dev_open(struct atm_dev *atmdev)
+static int lanai_dev_open(struct atm_dev *atmdev)
 {
 	struct lanai_dev *lanai = (struct lanai_dev *) atmdev->dev_data;
 	unsigned long raw_base;
@@ -2566,7 +2566,7 @@ static const struct atmdev_ops ops = {
 };
 
 /* initialize one probed card */
-static int __devinit lanai_init_one(struct pci_dev *pci,
+static int lanai_init_one(struct pci_dev *pci,
 				    const struct pci_device_id *ident)
 {
 	struct lanai_dev *lanai;
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index cd4b90b..a6845a0 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -121,8 +121,8 @@
 static u32 ns_read_sram(ns_dev * card, u32 sram_address);
 static void ns_write_sram(ns_dev * card, u32 sram_address, u32 * value,
 			  int count);
-static int __devinit ns_init_card(int i, struct pci_dev *pcidev);
-static void __devinit ns_init_card_error(ns_dev * card, int error);
+static int ns_init_card(int i, struct pci_dev *pcidev);
+static void ns_init_card_error(ns_dev * card, int error);
 static scq_info *get_scq(ns_dev *card, int size, u32 scd);
 static void free_scq(ns_dev *card, scq_info * scq, struct atm_vcc *vcc);
 static void push_rxbufs(ns_dev *, struct sk_buff *);
@@ -180,7 +180,7 @@ MODULE_LICENSE("GPL");
 
 /* Functions */
 
-static int __devinit nicstar_init_one(struct pci_dev *pcidev,
+static int nicstar_init_one(struct pci_dev *pcidev,
 				      const struct pci_device_id *ent)
 {
 	static int index = -1;
@@ -351,7 +351,7 @@ static void ns_write_sram(ns_dev * card, u32 sram_address, u32 * value,
 	spin_unlock_irqrestore(&card->res_lock, flags);
 }
 
-static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
+static int ns_init_card(int i, struct pci_dev *pcidev)
 {
 	int j;
 	struct ns_dev *card = NULL;
@@ -821,7 +821,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 	return error;
 }
 
-static void __devinit ns_init_card_error(ns_dev * card, int error)
+static void ns_init_card_error(ns_dev * card, int error)
 {
 	if (error >= 17) {
 		writel(0x00000000, card->membase + CFG);
diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index abe4e20..7436362 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1094,7 +1094,7 @@ static irqreturn_t zatm_int(int irq,void *dev_id)
 /*----------------------------- (E)EPROM access -----------------------------*/
 
 
-static void __devinit eprom_set(struct zatm_dev *zatm_dev,unsigned long value,
+static void eprom_set(struct zatm_dev *zatm_dev,unsigned long value,
     unsigned short cmd)
 {
 	int error;
@@ -1105,7 +1105,7 @@ static void __devinit eprom_set(struct zatm_dev *zatm_dev,unsigned long value,
 }
 
 
-static unsigned long __devinit eprom_get(struct zatm_dev *zatm_dev,
+static unsigned long eprom_get(struct zatm_dev *zatm_dev,
     unsigned short cmd)
 {
 	unsigned int value;
@@ -1118,7 +1118,7 @@ static unsigned long __devinit eprom_get(struct zatm_dev *zatm_dev,
 }
 
 
-static void __devinit eprom_put_bits(struct zatm_dev *zatm_dev,
+static void eprom_put_bits(struct zatm_dev *zatm_dev,
     unsigned long data,int bits,unsigned short cmd)
 {
 	unsigned long value;
@@ -1133,7 +1133,7 @@ static void __devinit eprom_put_bits(struct zatm_dev *zatm_dev,
 }
 
 
-static void __devinit eprom_get_byte(struct zatm_dev *zatm_dev,
+static void eprom_get_byte(struct zatm_dev *zatm_dev,
     unsigned char *byte,unsigned short cmd)
 {
 	int i;
@@ -1149,7 +1149,7 @@ static void __devinit eprom_get_byte(struct zatm_dev *zatm_dev,
 }
 
 
-static unsigned char __devinit eprom_try_esi(struct atm_dev *dev,
+static unsigned char eprom_try_esi(struct atm_dev *dev,
     unsigned short cmd,int offset,int swap)
 {
 	unsigned char buf[ZEPROM_SIZE];
@@ -1170,7 +1170,7 @@ static unsigned char __devinit eprom_try_esi(struct atm_dev *dev,
 }
 
 
-static void __devinit eprom_get_esi(struct atm_dev *dev)
+static void eprom_get_esi(struct atm_dev *dev)
 {
 	if (eprom_try_esi(dev,ZEPROM_V1_REG,ZEPROM_V1_ESI_OFF,1)) return;
 	(void) eprom_try_esi(dev,ZEPROM_V2_REG,ZEPROM_V2_ESI_OFF,0);
@@ -1180,7 +1180,7 @@ static void __devinit eprom_get_esi(struct atm_dev *dev)
 /*--------------------------------- entries ---------------------------------*/
 
 
-static int __devinit zatm_init(struct atm_dev *dev)
+static int zatm_init(struct atm_dev *dev)
 {
 	struct zatm_dev *zatm_dev;
 	struct pci_dev *pci_dev;
@@ -1257,7 +1257,7 @@ static int __devinit zatm_init(struct atm_dev *dev)
 }
 
 
-static int __devinit zatm_start(struct atm_dev *dev)
+static int zatm_start(struct atm_dev *dev)
 {
 	struct zatm_dev *zatm_dev = ZATM_DEV(dev);
 	struct pci_dev *pdev = zatm_dev->pci_dev;
@@ -1584,7 +1584,7 @@ static const struct atmdev_ops ops = {
 	.change_qos	= zatm_change_qos,
 };
 
-static int __devinit zatm_init_one(struct pci_dev *pci_dev,
+static int zatm_init_one(struct pci_dev *pci_dev,
 				   const struct pci_device_id *ent)
 {
 	struct atm_dev *dev;
-- 
1.8.0
