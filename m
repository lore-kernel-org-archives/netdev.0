From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/tokenring/ drivers
Date: Thu, 4 Mar 2004 13:19:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131909.068e41ed.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


| 
| From: Carlo Perassi <carlo@linux.it>
| and Randy.Dunlap <rddunlap@osdl.org>


--
~Randy



 linux-264-302-priv-rddunlap/drivers/net/tokenring/abyss.c    |    6 
 linux-264-302-priv-rddunlap/drivers/net/tokenring/madgemc.c  |    6 
 linux-264-302-priv-rddunlap/drivers/net/tokenring/proteon.c  |    4 
 linux-264-302-priv-rddunlap/drivers/net/tokenring/skisa.c    |    4 
 linux-264-302-priv-rddunlap/drivers/net/tokenring/smctr.c    |  174 +++++------
 linux-264-302-priv-rddunlap/drivers/net/tokenring/tms380tr.c |   54 +--
 6 files changed, 124 insertions(+), 124 deletions(-)

diff -puN drivers/net/tokenring/abyss.c~net_token_casts drivers/net/tokenring/abyss.c
--- linux-264-302-priv/drivers/net/tokenring/abyss.c~net_token_casts	2004-03-02 16:30:16.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tokenring/abyss.c	2004-03-02 16:33:00.000000000 -0800
@@ -154,7 +154,7 @@ static int __devinit abyss_attach(struct
 		printk(":%2.2x", dev->dev_addr[i]);
 	printk("\n");
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	tp->setnselout = abyss_setnselout_pins;
 	tp->sifreadb = abyss_sifreadb;
 	tp->sifreadw = abyss_sifreadw;
@@ -188,7 +188,7 @@ err_out_trdev:
 static unsigned short abyss_setnselout_pins(struct net_device *dev)
 {
 	unsigned short val = 0;
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	
 	if(tp->DataRate == SPEED_4)
 		val |= 0x01;  /* Set 4Mbps */
@@ -398,7 +398,7 @@ static void abyss_read_eeprom(struct net
 	unsigned short val;
 	int i;
 	
-	tp = (struct net_local *)dev->priv;
+	tp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 	
 	/* Must enable glue chip first */
diff -puN drivers/net/tokenring/madgemc.c~net_token_casts drivers/net/tokenring/madgemc.c
--- linux-264-302-priv/drivers/net/tokenring/madgemc.c~net_token_casts	2004-03-02 16:30:16.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tokenring/madgemc.c	2004-03-02 16:33:28.000000000 -0800
@@ -365,7 +365,7 @@ static int __init madgemc_probe(void)
 				return 0;
 			return -1;
 		}
-		tp = (struct net_local *)dev->priv;
+		tp = netdev_priv(dev);
 
 		/* 
 		 * The MC16 is physically a 32bit card.  However, Madge
@@ -504,7 +504,7 @@ static irqreturn_t madgemc_interrupt(int
 unsigned short madgemc_setnselout_pins(struct net_device *dev)
 {
 	unsigned char reg1;
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	
 	reg1 = inb(dev->base_addr + MC_CONTROL_REG1);
 
@@ -731,7 +731,7 @@ static int madgemc_mcaproc(char *buf, in
 	}
 	len += sprintf(buf+len, "-------\n");
 	if (curcard) {
-		struct net_local *tp = (struct net_local *)dev->priv;
+		struct net_local *tp = netdev_priv(dev);
 		int i;
 		
 		len += sprintf(buf+len, "Card Revision: %d\n", curcard->cardrev);
diff -puN drivers/net/tokenring/proteon.c~net_token_casts drivers/net/tokenring/proteon.c
--- linux-264-302-priv/drivers/net/tokenring/proteon.c~net_token_casts	2004-03-02 16:30:16.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tokenring/proteon.c	2004-03-02 16:34:30.000000000 -0800
@@ -158,7 +158,7 @@ static int __init setup_card(struct net_
 		printk(":%2.2x", dev->dev_addr[j]);
 	printk("\n");
 		
-	tp = (struct net_local *)dev->priv;
+	tp = netdev_priv(dev);
 	tp->setnselout = proteon_setnselout_pins;
 		
 	tp->sifreadb = proteon_sifreadb;
@@ -316,7 +316,7 @@ unsigned short proteon_setnselout_pins(s
 
 static int proteon_open(struct net_device *dev)
 {  
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned short val = 0;
 	int i;
 
diff -puN drivers/net/tokenring/skisa.c~net_token_casts drivers/net/tokenring/skisa.c
--- linux-264-302-priv/drivers/net/tokenring/skisa.c~net_token_casts	2004-03-02 16:30:16.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tokenring/skisa.c	2004-03-02 16:35:01.000000000 -0800
@@ -175,7 +175,7 @@ static int __init setup_card(struct net_
 		printk(":%2.2x", dev->dev_addr[j]);
 	printk("\n");
 		
-	tp = (struct net_local *)dev->priv;
+	tp = netdev_priv(dev);
 	tp->setnselout = sk_isa_setnselout_pins;
 		
 	tp->sifreadb = sk_isa_sifreadb;
@@ -332,7 +332,7 @@ unsigned short sk_isa_setnselout_pins(st
 
 static int sk_isa_open(struct net_device *dev)
 {  
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned short val = 0;
 	unsigned short oldval;
 	int i;
diff -puN drivers/net/tokenring/smctr.c~net_token_casts drivers/net/tokenring/smctr.c
--- linux-264-302-priv/drivers/net/tokenring/smctr.c~net_token_casts	2004-03-02 16:30:16.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tokenring/smctr.c	2004-03-02 16:38:17.000000000 -0800
@@ -327,7 +327,7 @@ static int smctr_wait_while_cbusy(struct
  */
 static int smctr_alloc_shared_memory(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_alloc_shared_memory\n", dev->name);
@@ -454,7 +454,7 @@ static int smctr_bypass_state(struct net
 
 static int smctr_checksum_firmware(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u16 i, checksum = 0;
 
         if(smctr_debug > 10)
@@ -480,7 +480,7 @@ static int smctr_checksum_firmware(struc
 static int smctr_chk_mca(struct net_device *dev)
 {
 #ifdef CONFIG_MCA
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	int current_slot;
 	__u8 r1, r2, r3, r4, r5;
 
@@ -631,7 +631,7 @@ static int smctr_chk_mca(struct net_devi
 
 static int smctr_chg_rx_mask(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err = 0;
 
         if(smctr_debug > 10)
@@ -694,7 +694,7 @@ static int smctr_chg_rx_mask(struct net_
 
 static int smctr_clear_int(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         outb((tp->trc_mask | CSR_CLRTINT), dev->base_addr + CSR);
 
@@ -716,7 +716,7 @@ static int smctr_clear_trc_reset(int ioa
  */
 static int smctr_close(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         struct sk_buff *skb;
         int err;
 
@@ -752,7 +752,7 @@ static int smctr_close(struct net_device
 
 static int smctr_decode_firmware(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         short bit = 0x80, shift = 12;
         DECODE_TREE_NODE *tree;
         short branch, tsize;
@@ -823,7 +823,7 @@ static int smctr_disable_16bit(struct ne
  */
 static int smctr_disable_adapter_ctrl_store(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
 
         if(smctr_debug > 10)
@@ -837,7 +837,7 @@ static int smctr_disable_adapter_ctrl_st
 
 static int smctr_disable_bic_int(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
 
         tp->trc_mask = CSR_MSK_ALL | CSR_MSKCBUSY
@@ -849,7 +849,7 @@ static int smctr_disable_bic_int(struct 
 
 static int smctr_enable_16bit(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u8    r;
 
         if(tp->adapter_bus == BUS_ISA16_TYPE)
@@ -869,7 +869,7 @@ static int smctr_enable_16bit(struct net
  */
 static int smctr_enable_adapter_ctrl_store(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
 
         if(smctr_debug > 10)
@@ -900,7 +900,7 @@ static int smctr_enable_adapter_ram(stru
 
 static int smctr_enable_bic_int(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
         __u8 r;
 
@@ -926,7 +926,7 @@ static int smctr_enable_bic_int(struct n
 
 static int __init smctr_chk_isa(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
         __u8 r1, r2, b, chksum = 0;
         __u16 r;
@@ -1155,7 +1155,7 @@ out:
 
 static int __init smctr_get_boardid(struct net_device *dev, int mca)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
         __u8 r, r1, IdByte;
         __u16 BoardIdMask;
@@ -1273,7 +1273,7 @@ static int smctr_get_functional_address(
  */
 static unsigned int smctr_get_num_rx_bdbs(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int mem_used = 0;
 
         /* Allocate System Control Blocks. */
@@ -1358,7 +1358,7 @@ static int smctr_get_physical_drop_numbe
 
 static __u8 * smctr_get_rx_pointer(struct net_device *dev, short queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         BDBlock *bdb;
 
         bdb = (BDBlock *)((__u32)tp->ram_access
@@ -1382,7 +1382,7 @@ static int smctr_get_station_id(struct n
  */
 static struct net_device_stats *smctr_get_stats(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         return ((struct net_device_stats *)&tp->MacStat);
 }
@@ -1390,7 +1390,7 @@ static struct net_device_stats *smctr_ge
 static FCBlock *smctr_get_tx_fcb(struct net_device *dev, __u16 queue,
         __u16 bytes_count)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         FCBlock *pFCB;
         BDBlock *pbdb;
         unsigned short alloc_size;
@@ -1513,7 +1513,7 @@ static int smctr_hardware_send_packet(st
 
 static int smctr_init_acbs(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i;
         ACBlock *acb;
 
@@ -1557,7 +1557,7 @@ static int smctr_init_acbs(struct net_de
 
 static int smctr_init_adapter(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
 
         if(smctr_debug > 10)
@@ -1640,7 +1640,7 @@ static int smctr_init_adapter(struct net
 
 static int smctr_init_card_real(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err = 0;
 
         if(smctr_debug > 10)
@@ -1716,7 +1716,7 @@ static int smctr_init_card_real(struct n
 
 static int smctr_init_rx_bdbs(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, j;
         BDBlock *bdb;
         __u16 *buf;
@@ -1768,7 +1768,7 @@ static int smctr_init_rx_bdbs(struct net
 
 static int smctr_init_rx_fcbs(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, j;
         FCBlock *fcb;
 
@@ -1818,7 +1818,7 @@ static int smctr_init_rx_fcbs(struct net
 
 static int smctr_init_shared_memory(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i;
         __u32 *iscpb;
 
@@ -1876,7 +1876,7 @@ static int smctr_init_shared_memory(stru
 
 static int smctr_init_tx_bdbs(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, j;
         BDBlock *bdb;
 
@@ -1906,7 +1906,7 @@ static int smctr_init_tx_bdbs(struct net
 
 static int smctr_init_tx_fcbs(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, j;
         FCBlock *fcb;
 
@@ -1945,7 +1945,7 @@ static int smctr_init_tx_fcbs(struct net
 
 static int smctr_internal_self_test(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
 
         if((err = smctr_issue_test_internal_rom_cmd(dev)))
@@ -1998,7 +1998,7 @@ static irqreturn_t smctr_interrupt(int i
         }
 
         ioaddr = dev->base_addr;
-        tp = (struct net_local *)dev->priv;
+        tp = netdev_priv(dev);
         
 
         if(tp->status == NOT_INITIALIZED)
@@ -2471,7 +2471,7 @@ static irqreturn_t smctr_interrupt(int i
 static int smctr_issue_enable_int_cmd(struct net_device *dev,
         __u16 interrupt_enable_mask)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
@@ -2487,7 +2487,7 @@ static int smctr_issue_enable_int_cmd(st
 
 static int smctr_issue_int_ack(struct net_device *dev, __u16 iack_code, __u16 ibits)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_wait_while_cbusy(dev))
                 return (-1);
@@ -2503,7 +2503,7 @@ static int smctr_issue_int_ack(struct ne
 
 static int smctr_issue_init_timers_cmd(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i;
         int err;
         __u16 *pTimer_Struc = (__u16 *)tp->misc_command_data;
@@ -2660,7 +2660,7 @@ static int smctr_issue_init_timers_cmd(s
 
 static int smctr_issue_init_txrx_cmd(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i;
         int err;
         void **txrx_ptrs = (void *)tp->misc_command_data;
@@ -2748,7 +2748,7 @@ static int smctr_issue_read_word_cmd(str
 
 static int smctr_issue_remove_cmd(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
@@ -2764,7 +2764,7 @@ static int smctr_issue_remove_cmd(struct
 
 static int smctr_issue_resume_acb_cmd(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
@@ -2782,7 +2782,7 @@ static int smctr_issue_resume_acb_cmd(st
 
 static int smctr_issue_resume_rx_bdb_cmd(struct net_device *dev, __u16 queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
@@ -2802,7 +2802,7 @@ static int smctr_issue_resume_rx_bdb_cmd
 
 static int smctr_issue_resume_rx_fcb_cmd(struct net_device *dev, __u16 queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_issue_resume_rx_fcb_cmd\n", dev->name);
@@ -2824,7 +2824,7 @@ static int smctr_issue_resume_rx_fcb_cmd
 
 static int smctr_issue_resume_tx_fcb_cmd(struct net_device *dev, __u16 queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_issue_resume_tx_fcb_cmd\n", dev->name);
@@ -2893,7 +2893,7 @@ static int smctr_issue_tri_loopback_cmd(
 static int smctr_issue_write_byte_cmd(struct net_device *dev,
         short aword_cnt, void *byte)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
         unsigned int iword, ibyte;
 	int err;
 
@@ -2917,7 +2917,7 @@ static int smctr_issue_write_byte_cmd(st
 static int smctr_issue_write_word_cmd(struct net_device *dev,
         short aword_cnt, void *word)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, err;
 
         if((err = smctr_wait_while_cbusy(dev)))
@@ -2947,7 +2947,7 @@ static int smctr_join_complete_state(str
 
 static int smctr_link_tx_fcbs_to_bdbs(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, j;
         FCBlock *fcb;
         BDBlock *bdb;
@@ -2971,7 +2971,7 @@ static int smctr_link_tx_fcbs_to_bdbs(st
 
 static int smctr_load_firmware(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u16 i, checksum = 0;
         int err = 0;
 
@@ -3071,7 +3071,7 @@ static int smctr_load_node_addr(struct n
  */
 static int smctr_lobe_media_test(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, perror = 0;
         unsigned short saved_rcv_mask;
 
@@ -3146,7 +3146,7 @@ static int smctr_lobe_media_test(struct 
 
 static int smctr_lobe_media_test_cmd(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
 
         if(smctr_debug > 10)
@@ -3230,7 +3230,7 @@ static int smctr_make_8025_hdr(struct ne
 
 static int smctr_make_access_pri(struct net_device *dev, MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         tsv->svi = AUTHORIZED_ACCESS_PRIORITY;
         tsv->svl = S_AUTHORIZED_ACCESS_PRIORITY;
@@ -3255,7 +3255,7 @@ static int smctr_make_addr_mod(struct ne
 static int smctr_make_auth_funct_class(struct net_device *dev,
         MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         tsv->svi = AUTHORIZED_FUNCTION_CLASS;
         tsv->svl = S_AUTHORIZED_FUNCTION_CLASS;
@@ -3280,7 +3280,7 @@ static int smctr_make_corr(struct net_de
 
 static int smctr_make_funct_addr(struct net_device *dev, MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         smctr_get_functional_address(dev);
 
@@ -3298,7 +3298,7 @@ static int smctr_make_funct_addr(struct 
 
 static int smctr_make_group_addr(struct net_device *dev, MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         smctr_get_group_address(dev);
 
@@ -3324,7 +3324,7 @@ static int smctr_make_group_addr(struct 
 static int smctr_make_phy_drop_num(struct net_device *dev,
         MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         smctr_get_physical_drop_number(dev);
 
@@ -3355,7 +3355,7 @@ static int smctr_make_product_id(struct 
 
 static int smctr_make_station_id(struct net_device *dev, MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         smctr_get_station_id(dev);
 
@@ -3393,7 +3393,7 @@ static int smctr_make_ring_station_statu
 static int smctr_make_ring_station_version(struct net_device *dev,
         MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         tsv->svi = RING_STATION_VERSION_NUMBER;
         tsv->svl = S_RING_STATION_VERSION_NUMBER;
@@ -3433,7 +3433,7 @@ static int smctr_make_tx_status_code(str
 static int smctr_make_upstream_neighbor_addr(struct net_device *dev,
         MAC_SUB_VECTOR *tsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         smctr_get_upstream_neighbor_addr(dev);
 
@@ -3485,7 +3485,7 @@ static int smctr_open(struct net_device 
 /* Interrupt driven open of Token card. */
 static int smctr_open_tr(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned long flags;
         int err;
 
@@ -3618,7 +3618,7 @@ struct net_device __init *smctr_probe(in
 	return dev;
 out1:
 #ifdef CONFIG_MCA
-	{ struct net_local *tp = (struct net_local *)dev->priv;
+	{ struct net_local *tp = netdev_priv(dev);
 	  if (tp->slot_num)
 		mca_mark_as_unused(tp->slot_num);
 	}
@@ -3634,7 +3634,7 @@ out:
 static int __init smctr_probe1(struct net_device *dev, int ioaddr)
 {
         static unsigned version_printed;
-        struct net_local *tp = dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err;
         __u32 *ram;
 
@@ -3654,7 +3654,7 @@ static int __init smctr_probe1(struct ne
 		}
         }
 
-        tp = (struct net_local *)dev->priv;
+        tp = netdev_priv(dev);
         dev->mem_start = tp->ram_base;
         dev->mem_end = dev->mem_start + 0x10000;
         ram = (__u32 *)phys_to_virt(dev->mem_start);
@@ -3696,7 +3696,7 @@ out:
 static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
         struct net_device *dev, __u16 rx_status)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         struct sk_buff *skb;
         __u16 rcode, correlator;
         int err = 0;
@@ -3917,7 +3917,7 @@ static int smctr_process_rx_packet(MAC_H
 /* Adapter RAM test. Incremental word ODD boundary data test. */
 static int smctr_ram_memory_test(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u16 page, pages_of_ram, start_pattern = 0, word_pattern = 0,
                 word_read = 0, err_word = 0, err_pattern = 0;
         unsigned int err_offset;
@@ -4310,7 +4310,7 @@ static int smctr_rcv_unknown(struct net_
  */
 static int smctr_reset_adapter(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
 
         /* Reseting the NIC will put it in a halted and un-initialized state. */        smctr_set_trc_reset(ioaddr);
@@ -4329,7 +4329,7 @@ static int smctr_reset_adapter(struct ne
 
 static int smctr_restart_tx_chain(struct net_device *dev, short queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err = 0;
 
         if(smctr_debug > 10)
@@ -4347,7 +4347,7 @@ static int smctr_restart_tx_chain(struct
 
 static int smctr_ring_status_chg(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_ring_status_chg\n", dev->name);
@@ -4449,7 +4449,7 @@ static int smctr_ring_status_chg(struct 
 
 static int smctr_rx_frame(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u16 queue, status, rx_size, err = 0;
         __u8 *pbuff;
 
@@ -4516,7 +4516,7 @@ static int smctr_rx_frame(struct net_dev
 
 static int smctr_send_dat(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int i, err;
         MAC_HEADER *tmf;
         FCBlock *fcb;
@@ -4596,7 +4596,7 @@ static void smctr_timeout(struct net_dev
  */
 static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_send_packet\n", dev->name);
@@ -4621,7 +4621,7 @@ static int smctr_send_packet(struct sk_b
 
 static int smctr_send_lobe_media_test(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 	MAC_SUB_VECTOR *tsv;
 	MAC_HEADER *tmf;
         FCBlock *fcb;
@@ -4917,7 +4917,7 @@ static int smctr_send_rsp(struct net_dev
 
 static int smctr_send_rq_init(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         MAC_HEADER *tmf;
         MAC_SUB_VECTOR *tsv;
         FCBlock *fcb;
@@ -5001,7 +5001,7 @@ static int smctr_send_rq_init(struct net
 static int smctr_send_tx_forward(struct net_device *dev, MAC_HEADER *rmf,
         __u16 *tx_fstatus)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         FCBlock *fcb;
         unsigned int i;
 	int err;
@@ -5065,7 +5065,7 @@ static int smctr_send_tx_forward(struct 
 static int smctr_set_auth_access_pri(struct net_device *dev,
         MAC_SUB_VECTOR *rsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(rsv->svl != S_AUTHORIZED_ACCESS_PRIORITY)
                 return (E_SUB_VECTOR_LENGTH_ERROR);
@@ -5078,7 +5078,7 @@ static int smctr_set_auth_access_pri(str
 static int smctr_set_auth_funct_class(struct net_device *dev,
         MAC_SUB_VECTOR *rsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(rsv->svl != S_AUTHORIZED_FUNCTION_CLASS)
                 return (E_SUB_VECTOR_LENGTH_ERROR);
@@ -5139,7 +5139,7 @@ static int smctr_set_frame_forward(struc
 static int smctr_set_local_ring_num(struct net_device *dev,
         MAC_SUB_VECTOR *rsv)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(rsv->svl != S_LOCAL_RING_NUMBER)
                 return (E_SUB_VECTOR_LENGTH_ERROR);
@@ -5153,7 +5153,7 @@ static int smctr_set_local_ring_num(stru
 
 static unsigned short smctr_set_ctrl_attention(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
 
         if(tp->bic_type == BIC_585_CHIP)
@@ -5177,7 +5177,7 @@ static void smctr_set_multicast_list(str
 
 static int smctr_set_page(struct net_device *dev, __u8 *buf)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u8 amask;
         __u32 tptr;
 
@@ -5207,7 +5207,7 @@ static int smctr_set_phy_drop(struct net
  */
 static int smctr_set_ring_speed(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 	int err;
 
         if(tp->media_type == MEDIA_UTP_16)
@@ -5235,7 +5235,7 @@ static int smctr_set_ring_speed(struct n
 
 static int smctr_set_rx_look_ahead(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u16 sword, rword;
 
         if(smctr_debug > 10)
@@ -5278,7 +5278,7 @@ static int smctr_set_trc_reset(int ioadd
 static int smctr_setup_single_cmd(struct net_device *dev,
         __u16 command, __u16 subcommand)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int err;
 
         if(smctr_debug > 10)
@@ -5305,7 +5305,7 @@ static int smctr_setup_single_cmd(struct
 static int smctr_setup_single_cmd_w_data(struct net_device *dev,
         __u16 command, __u16 subcommand)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         tp->acb_head->cmd_done_status   = ACB_COMMAND_NOT_DONE;
         tp->acb_head->cmd               = command;
@@ -5318,7 +5318,7 @@ static int smctr_setup_single_cmd_w_data
 
 static char *smctr_malloc(struct net_device *dev, __u16 size)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         char *m;
 
         m = (char *)(tp->ram_access + tp->sh_mem_used);
@@ -5329,7 +5329,7 @@ static char *smctr_malloc(struct net_dev
 
 static int smctr_status_chg(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_status_chg\n", dev->name);
@@ -5365,7 +5365,7 @@ static int smctr_status_chg(struct net_d
 static int smctr_trc_send_packet(struct net_device *dev, FCBlock *fcb,
         __u16 queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         int err = 0;
 
         if(smctr_debug > 10)
@@ -5386,7 +5386,7 @@ static int smctr_trc_send_packet(struct 
 
 static __u16 smctr_tx_complete(struct net_device *dev, __u16 queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         __u16 status, err = 0;
         int cstatus;
 
@@ -5441,7 +5441,7 @@ static __u16 smctr_tx_complete(struct ne
 static unsigned short smctr_tx_move_frame(struct net_device *dev,
         struct sk_buff *skb, __u8 *pbuff, unsigned int bytes)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int ram_usable;
         __u32 flen, len, offset = 0;
         __u8 *frag, *page;
@@ -5482,7 +5482,7 @@ static unsigned short smctr_tx_move_fram
 /* Update the error statistic counters for this adapter. */
 static int smctr_update_err_stats(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         struct tr_statistics *tstat = &tp->MacStat;
 
         if(tstat->internal_errors)
@@ -5524,7 +5524,7 @@ static int smctr_update_err_stats(struct
 
 static int smctr_update_rx_chain(struct net_device *dev, __u16 queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         FCBlock *fcb;
         BDBlock *bdb;
         __u16 size, len;
@@ -5562,7 +5562,7 @@ static int smctr_update_rx_chain(struct 
 static int smctr_update_tx_chain(struct net_device *dev, FCBlock *fcb,
         __u16 queue)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
 
         if(smctr_debug > 20)
                 printk(KERN_DEBUG "smctr_update_tx_chain\n");
@@ -5598,7 +5598,7 @@ static int smctr_update_tx_chain(struct 
 
 static int smctr_wait_cmd(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int loop_count = 0x20000;
 
         if(smctr_debug > 10)
@@ -5623,7 +5623,7 @@ static int smctr_wait_cmd(struct net_dev
 
 static int smctr_wait_while_cbusy(struct net_device *dev)
 {
-        struct net_local *tp = (struct net_local *)dev->priv;
+        struct net_local *tp = netdev_priv(dev);
         unsigned int timeout = 0x20000;
         int ioaddr = dev->base_addr;
         __u8 r;
@@ -5686,7 +5686,7 @@ static struct net_device *setup_card(int
 	return dev;
  out1:
 #ifdef CONFIG_MCA
-	{ struct net_local *tp = (struct net_local *)dev->priv;
+	{ struct net_local *tp = netdev_priv(dev);
 	  if (tp->slot_num)
 		mca_mark_as_unused(tp->slot_num);
 	}
@@ -5726,7 +5726,7 @@ void cleanup_module(void)
 
 			unregister_netdev(dev);
 #ifdef CONFIG_MCA
-			{ struct net_local *tp = dev->priv;
+			{ struct net_local *tp = netdev_priv(dev);
 			if (tp->slot_num)
 				mca_mark_as_unused(tp->slot_num);
 			}
diff -puN drivers/net/tokenring/tms380tr.c~net_token_casts drivers/net/tokenring/tms380tr.c
--- linux-264-302-priv/drivers/net/tokenring/tms380tr.c~net_token_casts	2004-03-02 16:30:16.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tokenring/tms380tr.c	2004-03-02 16:40:11.000000000 -0800
@@ -243,7 +243,7 @@ static int madgemc_sifprobe(struct net_d
  */
 int tms380tr_open(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	int err;
 	
 	/* init the spinlock */
@@ -313,7 +313,7 @@ int tms380tr_open(struct net_device *dev
 static void tms380tr_timer_end_wait(unsigned long data)
 {
 	struct net_device *dev = (struct net_device*)data;
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	if(tp->Sleeping)
 	{
@@ -329,7 +329,7 @@ static void tms380tr_timer_end_wait(unsi
  */
 static int tms380tr_chipset_init(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	int err;
 
 	tms380tr_init_ipb(tp);
@@ -364,7 +364,7 @@ static int tms380tr_chipset_init(struct 
  */
 static void tms380tr_init_net_local(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	int i;
 	dma_addr_t dmabuf;
 
@@ -492,7 +492,7 @@ static void tms380tr_init_opb(struct net
 	unsigned short BufferSize = BUFFER_SIZE;
 	int i;
 
-	tp = (struct net_local *)dev->priv;
+	tp = netdev_priv(dev);
 
 	tp->ocpl.OPENOptions 	 = 0;
 	tp->ocpl.OPENOptions 	|= ENABLE_FULL_DUPLEX_SELECTION;
@@ -531,7 +531,7 @@ static void tms380tr_init_opb(struct net
  */
 static void tms380tr_open_adapter(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	if(tp->OpenCommandIssued)
 		return;
@@ -569,7 +569,7 @@ static void tms380tr_enable_interrupts(s
  */
 static void tms380tr_exec_cmd(struct net_device *dev, unsigned short Command)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	tp->CMDqueue |= Command;
 	tms380tr_chk_outstanding_cmds(dev);
@@ -596,7 +596,7 @@ static void tms380tr_timeout(struct net_
  */
 static int tms380tr_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	int err;
 
 	err = tms380tr_hardware_send_packet(skb, dev);
@@ -616,7 +616,7 @@ static int tms380tr_hardware_send_packet
 	unsigned long flags;
 	int i;
 	dma_addr_t dmabuf, newbuf;
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
    
 	/* Try to get a free TPL from the chain.
 	 *
@@ -715,7 +715,7 @@ static void tms380tr_chk_src_addr(unsign
 static void tms380tr_timer_chk(unsigned long data)
 {
 	struct net_device *dev = (struct net_device*)data;
-	struct net_local *tp = (struct net_local*)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	if(tp->HaltInProgress)
 		return;
@@ -755,7 +755,7 @@ irqreturn_t tms380tr_interrupt(int irq, 
 		return IRQ_NONE;
 	}
 
-	tp = (struct net_local *)dev->priv;
+	tp = netdev_priv(dev);
 
 	irq_type = SIFREADW(SIFSTS);
 
@@ -843,7 +843,7 @@ irqreturn_t tms380tr_interrupt(int irq, 
  */
 static void tms380tr_reset_interrupt(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	SSB *ssb = &tp->ssb;
 
 	/*
@@ -929,7 +929,7 @@ static unsigned char tms380tr_chk_ssb(st
  */
 static void tms380tr_cmd_status_irq(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned short ssb_cmd, ssb_parm_0;
 	unsigned short ssb_parm_1;
 	char *open_err = "Open error -";
@@ -1126,7 +1126,7 @@ static void tms380tr_cmd_status_irq(stru
  */
 int tms380tr_close(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	netif_stop_queue(dev);
 	
 	del_timer(&tp->timer);
@@ -1172,7 +1172,7 @@ int tms380tr_close(struct net_device *de
  */
 static struct net_device_stats *tms380tr_get_stats(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	return ((struct net_device_stats *)&tp->MacStat);
 }
@@ -1182,7 +1182,7 @@ static struct net_device_stats *tms380tr
  */
 static void tms380tr_set_multicast_list(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned int OpenOptions;
 	
 	OpenOptions = tp->ocpl.OPENOptions &
@@ -1275,7 +1275,7 @@ static void tms380tr_exec_sifcmd(struct 
  */
 static int tms380tr_reset_adapter(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned short *fw_ptr;
 	unsigned short count, c, count2;
 	const struct firmware *fw_entry = NULL;
@@ -1428,7 +1428,7 @@ static int tms380tr_bringup_diags(struct
  */
 static int tms380tr_init_adapter(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	const unsigned char SCB_Test[6] = {0x00, 0x00, 0xC1, 0xE2, 0xD4, 0x8B};
 	const unsigned char SSB_Test[8] = {0xFF, 0xFF, 0xD1, 0xD7,
@@ -1541,7 +1541,7 @@ static int tms380tr_init_adapter(struct 
  */
 static void tms380tr_chk_outstanding_cmds(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned long Addr = 0;
 
 	if(tp->CMDqueue == 0)
@@ -1713,7 +1713,7 @@ static void tms380tr_chk_outstanding_cmd
  */
 static void tms380tr_ring_status_irq(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	tp->CurrentRingStatus = be16_to_cpu((unsigned short)tp->ssb.Parm[0]);
 
@@ -1785,7 +1785,7 @@ static void tms380tr_chk_irq(struct net_
 {
 	int i;
 	unsigned short AdapterCheckBlock[4];
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 
 	tp->AdapterOpenFlag = 0;	/* Adapter closed now */
 
@@ -1941,7 +1941,7 @@ static void tms380tr_chk_irq(struct net_
  */
 static int tms380tr_read_ptr(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned short adapterram;
 
 	tms380tr_read_ram(dev, (unsigned char *)&tp->intptrs.BurnedInAddrPtr,
@@ -2031,7 +2031,7 @@ static void tms380tr_cancel_tx_queue(str
  */
 static void tms380tr_tx_status_irq(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned char HighByte, HighAc, LowAc;
 	TPL *tpl;
 
@@ -2102,7 +2102,7 @@ static void tms380tr_tx_status_irq(struc
  */
 static void tms380tr_rcv_status_irq(struct net_device *dev)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	unsigned char *ReceiveDataPtr;
 	struct sk_buff *skb;
 	unsigned int Length, Length2;
@@ -2293,7 +2293,7 @@ static void tms380tr_update_rcv_stats(st
 
 static int tms380tr_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct net_local *tp = (struct net_local *)dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	struct sockaddr *saddr = addr;
 	
 	if (tp->AdapterOpenFlag || tp->AdapterVirtOpenFlag) {
@@ -2327,7 +2327,7 @@ void tmsdev_term(struct net_device *dev)
 {
 	struct net_local *tp;
 
-	tp = (struct net_local *) dev->priv;
+	tp = netdev_priv(dev);
 	pci_unmap_single(tp->pdev, tp->dmabuffer, sizeof(struct net_local),
 		PCI_DMA_BIDIRECTIONAL);
 }
@@ -2338,7 +2338,7 @@ int tmsdev_init(struct net_device *dev, 
 	struct net_local *tms_local;
 
 	memset(dev->priv, 0, sizeof(struct net_local));
-	tms_local = (struct net_local *)dev->priv;
+	tms_local = netdev_priv(dev);
 	init_waitqueue_head(&tms_local->wait_for_tok_int);
 	tms_local->dmalimit = dmalimit;
 	tms_local->pdev = pdev;

_


--
~Randy
