From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH] [ATM]: small atm cleanups (from Adrian Bunk <bunk@stusta.de>)
Date: Wed, 08 Dec 2004 20:02:59 -0500
Message-ID: <200412090102.iB912w8T007866@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com, bunk@stusta.de
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/08 17:09:38-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: small atm cleanups (from Adrian Bunk <bunk@stusta.de>)
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/ambassador.c	2004-12-08 18:07:24 -05:00
@@ -1692,7 +1692,7 @@
 };
 
 
-unsigned int command_successes [] = {
+static unsigned int command_successes [] = {
 	[host_memory_test]     = COMMAND_PASSED_TEST,
 	[read_adapter_memory]  = COMMAND_READ_DATA_OK,
 	[write_adapter_memory] = COMMAND_WRITE_DATA_OK,
@@ -2088,7 +2088,7 @@
 }
   
 // swap bits within byte to get Ethernet ordering
-u8 bit_swap (u8 byte)
+static u8 bit_swap (u8 byte)
 {
     const u8 swap[] = {
       0x0, 0x8, 0x4, 0xc,
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/atmtcp.c	2004-12-08 18:07:24 -05:00
@@ -396,7 +396,7 @@
 }
 
 
-int atmtcp_attach(struct atm_vcc *vcc,int itf)
+static int atmtcp_attach(struct atm_vcc *vcc,int itf)
 {
 	struct atm_dev *dev;
 
@@ -427,13 +427,13 @@
 }
 
 
-int atmtcp_create_persistent(int itf)
+static int atmtcp_create_persistent(int itf)
 {
 	return atmtcp_create(itf,1,NULL);
 }
 
 
-int atmtcp_remove_persistent(int itf)
+static int atmtcp_remove_persistent(int itf)
 {
 	struct atm_dev *dev;
 	struct atmtcp_dev_data *dev_data;
diff -Nru a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/firestream.c	2004-12-08 18:07:24 -05:00
@@ -82,14 +82,14 @@
  * would be interpreted. -- REW */
 
 #define NP FS_NR_FREE_POOLS
-int rx_buf_sizes[NP]  = {128,  256,  512, 1024, 2048, 4096, 16384, 65520};
+static int rx_buf_sizes[NP]  = {128,  256,  512, 1024, 2048, 4096, 16384, 65520};
 /* log2:                 7     8     9    10    11    12    14     16 */
 
 #if 0
-int rx_pool_sizes[NP] = {1024, 1024, 512, 256,  128,  64,   32,    32};
+static int rx_pool_sizes[NP] = {1024, 1024, 512, 256,  128,  64,   32,    32};
 #else
 /* debug */
-int rx_pool_sizes[NP] = {128,  128,  128, 64,   64,   64,   32,    32};
+static int rx_pool_sizes[NP] = {128,  128,  128, 64,   64,   64,   32,    32};
 #endif
 /* log2:                 10    10    9    8     7     6     5      5  */
 /* sumlog2:              17    18    18   18    18    18    19     21 */
@@ -250,7 +250,7 @@
 };
 
 
-struct reginit_item PHY_NTC_INIT[] __devinitdata = {
+static struct reginit_item PHY_NTC_INIT[] __devinitdata = {
 	{ PHY_CLEARALL, 0x40 }, 
 	{ 0x12,  0x0001 },
 	{ 0x13,  0x7605 },
@@ -334,7 +334,7 @@
 #define func_exit()  fs_dprintk (FS_DEBUG_FLOW, "fs: exit  %s\n", __FUNCTION__)
 
 
-struct fs_dev *fs_boards = NULL;
+static struct fs_dev *fs_boards = NULL;
 
 #ifdef DEBUG
 
@@ -1921,7 +1921,7 @@
 	return -ENODEV;
 }
 
-void __devexit firestream_remove_one (struct pci_dev *pdev)
+static void __devexit firestream_remove_one (struct pci_dev *pdev)
 {
 	int i;
 	struct fs_dev *dev, *nxtdev;
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/he.c	2004-12-08 18:07:24 -05:00
@@ -147,13 +147,55 @@
 
 /* globals */
 
-struct he_dev *he_devs = NULL;
+static struct he_dev *he_devs = NULL;
 static int disable64 = 0;
 static short nvpibits = -1;
 static short nvcibits = -1;
 static short rx_skb_reserve = 16;
 static int irq_coalesce = 1;
 static int sdh = 0;
+
+/* Read from EEPROM = 0000 0011b */
+static unsigned int readtab[] = {
+	CS_HIGH | CLK_HIGH,
+	CS_LOW | CLK_LOW,
+	CLK_HIGH,               /* 0 */
+	CLK_LOW,
+	CLK_HIGH,               /* 0 */
+	CLK_LOW,
+	CLK_HIGH,               /* 0 */
+	CLK_LOW,
+	CLK_HIGH,               /* 0 */
+	CLK_LOW,
+	CLK_HIGH,               /* 0 */
+	CLK_LOW,
+	CLK_HIGH,               /* 0 */
+	CLK_LOW | SI_HIGH,
+	CLK_HIGH | SI_HIGH,     /* 1 */
+	CLK_LOW | SI_HIGH,
+	CLK_HIGH | SI_HIGH      /* 1 */
+};     
+ 
+/* Clock to read from/write to the EEPROM */
+static unsigned int clocktab[] = {
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
+};     
 
 static struct atmdev_ops he_ops =
 {
diff -Nru a/drivers/atm/he.h b/drivers/atm/he.h
--- a/drivers/atm/he.h	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/he.h	2004-12-08 18:07:24 -05:00
@@ -892,47 +892,4 @@
 #define SI_HIGH		ID_DIN /* HOST_CNTL_ID_PROM_DATA_IN */
 #define EEPROM_DELAY	400 /* microseconds */
 
-/* Read from EEPROM = 0000 0011b */
-unsigned int readtab[] = {
-	CS_HIGH | CLK_HIGH,
-	CS_LOW | CLK_LOW,
-	CLK_HIGH,               /* 0 */
-	CLK_LOW,
-	CLK_HIGH,               /* 0 */
-	CLK_LOW,
-	CLK_HIGH,               /* 0 */
-	CLK_LOW,
-	CLK_HIGH,               /* 0 */
-	CLK_LOW,
-	CLK_HIGH,               /* 0 */
-	CLK_LOW,
-	CLK_HIGH,               /* 0 */
-	CLK_LOW | SI_HIGH,
-	CLK_HIGH | SI_HIGH,     /* 1 */
-	CLK_LOW | SI_HIGH,
-	CLK_HIGH | SI_HIGH      /* 1 */
-};     
- 
-/* Clock to read from/write to the EEPROM */
-unsigned int clocktab[] = {
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW,
-	CLK_HIGH,
-	CLK_LOW
-};     
-
-
 #endif /* _HE_H_ */
diff -Nru a/drivers/atm/idt77105.c b/drivers/atm/idt77105.c
--- a/drivers/atm/idt77105.c	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/idt77105.c	2004-12-08 18:07:24 -05:00
@@ -323,7 +323,7 @@
 }
 
 
-int idt77105_stop(struct atm_dev *dev)
+static int idt77105_stop(struct atm_dev *dev)
 {
 	struct idt77105_priv *walk, *prev;
 
diff -Nru a/drivers/atm/idt77105.h b/drivers/atm/idt77105.h
--- a/drivers/atm/idt77105.h	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/idt77105.h	2004-12-08 18:07:24 -05:00
@@ -77,7 +77,6 @@
 
 #ifdef __KERNEL__
 int idt77105_init(struct atm_dev *dev) __init;
-int idt77105_stop(struct atm_dev *dev);
 #endif
 
 /*
diff -Nru a/drivers/atm/idt77252.h b/drivers/atm/idt77252.h
--- a/drivers/atm/idt77252.h	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/idt77252.h	2004-12-08 18:07:24 -05:00
@@ -275,7 +275,7 @@
 	struct rsq_entry	*next;
 	struct rsq_entry	*last;
 	dma_addr_t		paddr;
-} rsq_info;
+};
 
 
 /*****************************************************************************/
diff -Nru a/drivers/atm/iphase.c b/drivers/atm/iphase.c
--- a/drivers/atm/iphase.c	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/iphase.c	2004-12-08 18:07:24 -05:00
@@ -72,13 +72,13 @@
 #define PRIV(dev) ((struct suni_priv *) dev->phy_data)
 
 static unsigned char ia_phy_get(struct atm_dev *dev, unsigned long addr);
+static void desc_dbg(IADEV *iadev);
 
 static IADEV *ia_dev[8];
 static struct atm_dev *_ia_dev[8];
 static int iadev_count;
 static void ia_led_timer(unsigned long arg);
 static struct timer_list ia_timer = TIMER_INITIALIZER(ia_led_timer, 0, 0);
-struct atm_vcc *vcc_close_que[100];
 static int IA_TX_BUF = DFL_TX_BUFFERS, IA_TX_BUF_SZ = DFL_TX_BUF_SZ;
 static int IA_RX_BUF = DFL_RX_BUFFERS, IA_RX_BUF_SZ = DFL_RX_BUF_SZ;
 static uint IADebugFlag = /* IF_IADBG_ERR | IF_IADBG_CBR| IF_IADBG_INIT_ADAPTER
@@ -147,7 +147,6 @@
   u_short 		desc1;
   u_short		tcq_wr;
   struct ia_vcc         *iavcc_r = NULL; 
-  extern void desc_dbg(IADEV *iadev);
 
   tcq_wr = readl(dev->seg_reg+TCQ_WR_PTR) & 0xffff;
   while (dev->host_tcq_wr != tcq_wr) {
@@ -187,7 +186,6 @@
   unsigned long delta;
   static unsigned long timer = 0;
   int ltimeout;
-  extern void desc_dbg(IADEV *iadev);
 
   ia_hack_tcq (dev);
   if(((jiffies - timer)>50)||((dev->ffL.tcq_rd==dev->host_tcq_wr))){      
@@ -643,7 +641,7 @@
    return 0;
 }
 
-void ia_tx_poll (IADEV *iadev) {
+static void ia_tx_poll (IADEV *iadev) {
    struct atm_vcc *vcc = NULL;
    struct sk_buff *skb = NULL, *skb1 = NULL;
    struct ia_vcc *iavcc;
@@ -860,7 +858,7 @@
   return;
 }
 
-void ia_mb25_init (IADEV *iadev)
+static void ia_mb25_init (IADEV *iadev)
 {
    volatile ia_mb25_t  *mb25 = (ia_mb25_t*)iadev->phy;
 #if 0
@@ -875,7 +873,7 @@
    return;
 }                   
 
-void ia_suni_pm7345_init (IADEV *iadev)
+static void ia_suni_pm7345_init (IADEV *iadev)
 {
    volatile suni_pm7345_t *suni_pm7345 = (suni_pm7345_t *)iadev->phy;
    if (iadev->phy_type & FE_DS3_PHY)
@@ -958,9 +956,8 @@
 
 /***************************** IA_LIB END *****************************/
     
-/* pwang_test debug utility */
-int tcnter = 0, rcnter = 0;
-void xdump( u_char*  cp, int  length, char*  prefix )
+static int tcnter = 0;
+static void xdump( u_char*  cp, int  length, char*  prefix )
 {
     int col, count;
     u_char prntBuf[120];
@@ -1007,7 +1004,7 @@
   
 /*-- some utilities and memory allocation stuff will come here -------------*/  
   
-void desc_dbg(IADEV *iadev) {
+static void desc_dbg(IADEV *iadev) {
 
   u_short tcq_wr_ptr, tcq_st_ptr, tcq_ed_ptr;
   u32 i;
diff -Nru a/drivers/atm/iphase.h b/drivers/atm/iphase.h
--- a/drivers/atm/iphase.h	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/iphase.h	2004-12-08 18:07:24 -05:00
@@ -1126,8 +1126,6 @@
 #define FE_DS3_PHY      0x0080          /* DS3 */
 #define FE_E3_PHY       0x0090          /* E3 */
 		     
-extern void ia_mb25_init (IADEV *);
-
 /*********************** SUNI_PM7345 PHY DEFINE HERE *********************/
 typedef struct _suni_pm7345_t
 {
@@ -1325,8 +1323,6 @@
 #define SUNI_DS3_COCAI  0x04            /* Corr. HCS errors detected    */
 #define SUNI_DS3_FOVRI  0x02            /* FIFO overrun                 */
 #define SUNI_DS3_FUDRI  0x01            /* FIFO underrun                */
-
-extern void ia_suni_pm7345_init (IADEV *iadev);
 
 ///////////////////SUNI_PM7345 PHY DEFINE END /////////////////////////////
 
diff -Nru a/drivers/atm/nicstarmac.c b/drivers/atm/nicstarmac.c
--- a/drivers/atm/nicstarmac.c	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/nicstarmac.c	2004-12-08 18:07:24 -05:00
@@ -35,6 +35,7 @@
 #define SI_LOW		0x0000		/* Serial input data low */
 
 /* Read Status Register = 0000 0101b */
+#if 0
 static u_int32_t rdsrtab[] =
 {
     CS_HIGH | CLK_HIGH, 
@@ -55,6 +56,7 @@
     CLK_LOW | SI_HIGH, 
     CLK_HIGH | SI_HIGH   /* 1 */
 };
+#endif  /*  0  */
 
 
 /* Read from EEPROM = 0000 0011b */
@@ -117,7 +119,7 @@
  * eeprom, then pull the result from bit 16 of the NicSTaR's General Purpose 
  * register.  
  */
-
+#if 0
 u_int32_t
 nicstar_read_eprom_status( virt_addr_t base )
 {
@@ -153,6 +155,7 @@
    osp_MicroDelay( CYCLE_DELAY );
    return rbyte;
 }
+#endif  /*  0  */
 
 
 /*
diff -Nru a/drivers/atm/nicstarmac.h b/drivers/atm/nicstarmac.h
--- a/drivers/atm/nicstarmac.h	2004-12-08 18:07:24 -05:00
+++ b/drivers/atm/nicstarmac.h	2004-12-08 18:07:24 -05:00
@@ -9,6 +9,5 @@
 
 typedef void __iomem *virt_addr_t;
 
-u_int32_t nicstar_read_eprom_status( virt_addr_t base );
 void nicstar_init_eprom( virt_addr_t base );
 void nicstar_read_eprom( virt_addr_t, u_int8_t, u_int8_t *, u_int32_t);
