From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 4/5] netxen: cleanup unused code
Date: Sun, 22 Feb 2009 23:42:15 -0800
Message-ID: <1235374936-28778-4-git-send-email-dhananjay@netxen.com>
References: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:42588 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752860AbZBWHmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 02:42:21 -0500
In-Reply-To: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c |   75 -------
 drivers/net/netxen/netxen_nic_hw.c      |   13 --
 drivers/net/netxen/netxen_nic_hw.h      |   27 ---
 drivers/net/netxen/netxen_nic_init.c    |  360 -------------------------------
 drivers/net/netxen/netxen_nic_niu.c     |  219 -------------------
 5 files changed, 0 insertions(+), 694 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 0012b31..87803f1 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -473,78 +473,6 @@ netxen_nic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	return 0;
 }
 
-#if 0
-static int
-netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
-			u8 * bytes)
-{
-	struct netxen_adapter *adapter = netdev_priv(dev);
-	int offset = eeprom->offset;
-	static int flash_start;
-	static int ready_to_flash;
-	int ret;
-
-	if (flash_start == 0) {
-		netxen_halt_pegs(adapter);
-		ret = netxen_flash_unlock(adapter);
-		if (ret < 0) {
-			printk(KERN_ERR "%s: Flash unlock failed.\n",
-				netxen_nic_driver_name);
-			return ret;
-		}
-		printk(KERN_INFO "%s: flash unlocked. \n",
-			netxen_nic_driver_name);
-		ret = netxen_flash_erase_secondary(adapter);
-		if (ret != FLASH_SUCCESS) {
-			printk(KERN_ERR "%s: Flash erase failed.\n",
-				netxen_nic_driver_name);
-			return ret;
-		}
-		printk(KERN_INFO "%s: secondary flash erased successfully.\n",
-			netxen_nic_driver_name);
-		flash_start = 1;
-		return 0;
-	}
-
-	if (offset == NETXEN_BOOTLD_START) {
-		ret = netxen_flash_erase_primary(adapter);
-		if (ret != FLASH_SUCCESS) {
-			printk(KERN_ERR "%s: Flash erase failed.\n",
-				netxen_nic_driver_name);
-			return ret;
-		}
-
-		ret = netxen_rom_se(adapter, NETXEN_USER_START);
-		if (ret != FLASH_SUCCESS)
-			return ret;
-		ret = netxen_rom_se(adapter, NETXEN_FIXED_START);
-		if (ret != FLASH_SUCCESS)
-			return ret;
-
-		printk(KERN_INFO "%s: primary flash erased successfully\n",
-			netxen_nic_driver_name);
-
-		ret = netxen_backup_crbinit(adapter);
-		if (ret != FLASH_SUCCESS) {
-			printk(KERN_ERR "%s: CRBinit backup failed.\n",
-				netxen_nic_driver_name);
-			return ret;
-		}
-		printk(KERN_INFO "%s: CRBinit backup done.\n",
-			netxen_nic_driver_name);
-		ready_to_flash = 1;
-	}
-
-	if (!ready_to_flash) {
-		printk(KERN_ERR "%s: Invalid write sequence, returning...\n",
-			netxen_nic_driver_name);
-		return -EINVAL;
-	}
-
-	return netxen_rom_fast_write_words(adapter, offset, bytes, eeprom->len);
-}
-#endif /* 0 */
-
 static void
 netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 {
@@ -953,9 +881,6 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_eeprom_len = netxen_nic_get_eeprom_len,
 	.get_eeprom = netxen_nic_get_eeprom,
-#if 0
-	.set_eeprom = netxen_nic_set_eeprom,
-#endif
 	.get_ringparam = netxen_nic_get_ringparam,
 	.get_pauseparam = netxen_nic_get_pauseparam,
 	.set_pauseparam = netxen_nic_set_pauseparam,
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index aef39e7..b6b777e 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2077,19 +2077,6 @@ u32 netxen_nic_pci_read_normalize_2M(struct netxen_adapter *adapter, u64 off)
 	return temp;
 }
 
-#if 0
-int
-netxen_nic_erase_pxe(struct netxen_adapter *adapter)
-{
-	if (netxen_rom_fast_write(adapter, NETXEN_PXE_START, 0) == -1) {
-		printk(KERN_ERR "%s: erase pxe failed\n",
-			netxen_nic_driver_name);
-		return -1;
-	}
-	return 0;
-}
-#endif  /*  0  */
-
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 {
 	int rv = 0;
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 70238bf..9dcfb32 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -124,33 +124,6 @@ typedef enum {
 #define netxen_gb_get_soft_reset(config_word)	\
 		_netxen_crb_get_bit((config_word), 31)
 
-/*
- * NIU GB MAC Config Register 1 (applies to GB0, GB1, GB2, GB3)
- *
- *	Bit 0	    : duplex => 1:full duplex mode, 0:half duplex
- *	Bit 1	    : crc_enable => 1:append CRC to xmit frames, 0:dont append
- *	Bit 2	    : padshort => 1:pad short frames and add CRC, 0:dont pad
- *	Bit 4	    : checklength => 1:check framelen with actual,0:dont check
- *	Bit 5	    : hugeframes => 1:allow oversize xmit frames, 0:dont allow
- *	Bits 8-9    : intfmode => 01:nibble (10/100), 10:byte (1000)
- *	Bits 12-15  : preamblelen => preamble field length in bytes, default 7
- */
-
-#define netxen_gb_set_duplex(config_word)	\
-		((config_word) |= 1 << 0)
-#define netxen_gb_set_crc_enable(config_word)	\
-		((config_word) |= 1 << 1)
-#define netxen_gb_set_padshort(config_word)	\
-		((config_word) |= 1 << 2)
-#define netxen_gb_set_checklength(config_word)	\
-		((config_word) |= 1 << 4)
-#define netxen_gb_set_hugeframes(config_word)	\
-		((config_word) |= 1 << 5)
-#define netxen_gb_set_preamblelen(config_word, val)	\
-		((config_word) |= ((val) << 12) & 0xF000)
-#define netxen_gb_set_intfmode(config_word, val)		\
-		((config_word) |= ((val) << 8) & 0x300)
-
 #define netxen_gb_get_stationaddress_low(config_word) ((config_word) >> 16)
 
 #define netxen_gb_set_mii_mgmt_clockselect(config_word, val)	\
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index ffd37be..688f880 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -55,15 +55,6 @@ static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
 static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 					uint32_t ctx, uint32_t ringid);
 
-#if 0
-static void netxen_nic_locked_write_reg(struct netxen_adapter *adapter,
-					unsigned long off, int *data)
-{
-	void __iomem *addr = pci_base_offset(adapter, off);
-	writel(*data, addr);
-}
-#endif  /*  0  */
-
 static void crb_addr_transform_setup(void)
 {
 	crb_addr_transform(XDMA);
@@ -399,9 +390,6 @@ static u32 netxen_decode_crb_addr(u32 addr)
 
 static long rom_max_timeout = 100;
 static long rom_lock_timeout = 10000;
-#if 0
-static long rom_write_timeout = 700;
-#endif
 
 static int rom_lock(struct netxen_adapter *adapter)
 {
@@ -452,38 +440,6 @@ static int netxen_wait_rom_done(struct netxen_adapter *adapter)
 	return 0;
 }
 
-#if 0
-static int netxen_rom_wren(struct netxen_adapter *adapter)
-{
-	/* Set write enable latch in ROM status register */
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
-			     M25P_INSTR_WREN);
-	if (netxen_wait_rom_done(adapter)) {
-		return -1;
-	}
-	return 0;
-}
-
-static unsigned int netxen_rdcrbreg(struct netxen_adapter *adapter,
-				    unsigned int addr)
-{
-	unsigned int data = 0xdeaddead;
-	data = netxen_nic_reg_read(adapter, addr);
-	return data;
-}
-
-static int netxen_do_rom_rdsr(struct netxen_adapter *adapter)
-{
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
-			     M25P_INSTR_RDSR);
-	if (netxen_wait_rom_done(adapter)) {
-		return -1;
-	}
-	return netxen_rdcrbreg(adapter, NETXEN_ROMUSB_ROM_RDATA);
-}
-#endif
-
 static void netxen_rom_unlock(struct netxen_adapter *adapter)
 {
 	u32 val;
@@ -493,44 +449,6 @@ static void netxen_rom_unlock(struct netxen_adapter *adapter)
 
 }
 
-#if 0
-static int netxen_rom_wip_poll(struct netxen_adapter *adapter)
-{
-	long timeout = 0;
-	long wip = 1;
-	int val;
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-	while (wip != 0) {
-		val = netxen_do_rom_rdsr(adapter);
-		wip = val & 1;
-		timeout++;
-		if (timeout > rom_max_timeout) {
-			return -1;
-		}
-	}
-	return 0;
-}
-
-static int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
-			     int data)
-{
-	if (netxen_rom_wren(adapter)) {
-		return -1;
-	}
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_WDATA, data);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
-			     M25P_INSTR_PP);
-	if (netxen_wait_rom_done(adapter)) {
-		netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-		return -1;
-	}
-
-	return netxen_rom_wip_poll(adapter);
-}
-#endif
-
 static int do_rom_fast_read(struct netxen_adapter *adapter,
 			    int addr, int *valp)
 {
@@ -597,284 +515,6 @@ int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 	return ret;
 }
 
-#if 0
-int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data)
-{
-	int ret = 0;
-
-	if (rom_lock(adapter) != 0) {
-		return -1;
-	}
-	ret = do_rom_fast_write(adapter, addr, data);
-	netxen_rom_unlock(adapter);
-	return ret;
-}
-
-static int do_rom_fast_write_words(struct netxen_adapter *adapter,
-				   int addr, u8 *bytes, size_t size)
-{
-	int addridx = addr;
-	int ret = 0;
-
-	while (addridx < (addr + size)) {
-		int last_attempt = 0;
-		int timeout = 0;
-		int data;
-
-		data = le32_to_cpu((*(__le32*)bytes));
-		ret = do_rom_fast_write(adapter, addridx, data);
-		if (ret < 0)
-			return ret;
-
-		while(1) {
-			int data1;
-
-			ret = do_rom_fast_read(adapter, addridx, &data1);
-			if (ret < 0)
-				return ret;
-
-			if (data1 == data)
-				break;
-
-			if (timeout++ >= rom_write_timeout) {
-				if (last_attempt++ < 4) {
-					ret = do_rom_fast_write(adapter,
-								addridx, data);
-					if (ret < 0)
-						return ret;
-				}
-				else {
-					printk(KERN_INFO "Data write did not "
-					   "succeed at address 0x%x\n", addridx);
-					break;
-				}
-			}
-		}
-
-		bytes += 4;
-		addridx += 4;
-	}
-
-	return ret;
-}
-
-int netxen_rom_fast_write_words(struct netxen_adapter *adapter, int addr,
-					u8 *bytes, size_t size)
-{
-	int ret = 0;
-
-	ret = rom_lock(adapter);
-	if (ret < 0)
-		return ret;
-
-	ret = do_rom_fast_write_words(adapter, addr, bytes, size);
-	netxen_rom_unlock(adapter);
-
-	return ret;
-}
-
-static int netxen_rom_wrsr(struct netxen_adapter *adapter, int data)
-{
-	int ret;
-
-	ret = netxen_rom_wren(adapter);
-	if (ret < 0)
-		return ret;
-
-	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_ROM_WDATA, data);
-	netxen_crb_writelit_adapter(adapter,
-					NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0x1);
-
-	ret = netxen_wait_rom_done(adapter);
-	if (ret < 0)
-		return ret;
-
-	return netxen_rom_wip_poll(adapter);
-}
-
-static int netxen_rom_rdsr(struct netxen_adapter *adapter)
-{
-	int ret;
-
-	ret = rom_lock(adapter);
-	if (ret < 0)
-		return ret;
-
-	ret = netxen_do_rom_rdsr(adapter);
-	netxen_rom_unlock(adapter);
-	return ret;
-}
-
-int netxen_backup_crbinit(struct netxen_adapter *adapter)
-{
-	int ret = FLASH_SUCCESS;
-	int val;
-	char *buffer = kmalloc(NETXEN_FLASH_SECTOR_SIZE, GFP_KERNEL);
-
-	if (!buffer)
-		return -ENOMEM;
-	/* unlock sector 63 */
-	val = netxen_rom_rdsr(adapter);
-	val = val & 0xe3;
-	ret = netxen_rom_wrsr(adapter, val);
-	if (ret != FLASH_SUCCESS)
-		goto out_kfree;
-
-	ret = netxen_rom_wip_poll(adapter);
-	if (ret != FLASH_SUCCESS)
-		goto out_kfree;
-
-	/* copy  sector 0 to sector 63 */
-	ret = netxen_rom_fast_read_words(adapter, NETXEN_CRBINIT_START,
-					buffer, NETXEN_FLASH_SECTOR_SIZE);
-	if (ret != FLASH_SUCCESS)
-		goto out_kfree;
-
-	ret = netxen_rom_fast_write_words(adapter, NETXEN_FIXED_START,
-					buffer, NETXEN_FLASH_SECTOR_SIZE);
-	if (ret != FLASH_SUCCESS)
-		goto out_kfree;
-
-	/* lock sector 63 */
-	val = netxen_rom_rdsr(adapter);
-	if (!(val & 0x8)) {
-		val |= (0x1 << 2);
-		/* lock sector 63 */
-		if (netxen_rom_wrsr(adapter, val) == 0) {
-			ret = netxen_rom_wip_poll(adapter);
-			if (ret != FLASH_SUCCESS)
-				goto out_kfree;
-
-			/* lock SR writes */
-			ret = netxen_rom_wip_poll(adapter);
-			if (ret != FLASH_SUCCESS)
-				goto out_kfree;
-		}
-	}
-
-out_kfree:
-	kfree(buffer);
-	return ret;
-}
-
-static int netxen_do_rom_se(struct netxen_adapter *adapter, int addr)
-{
-	netxen_rom_wren(adapter);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
-			     M25P_INSTR_SE);
-	if (netxen_wait_rom_done(adapter)) {
-		netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-		return -1;
-	}
-	return netxen_rom_wip_poll(adapter);
-}
-
-static void check_erased_flash(struct netxen_adapter *adapter, int addr)
-{
-	int i;
-	int val;
-	int count = 0, erased_errors = 0;
-	int range;
-
-	range = (addr == NETXEN_USER_START) ?
-		NETXEN_FIXED_START : addr + NETXEN_FLASH_SECTOR_SIZE;
-
-	for (i = addr; i < range; i += 4) {
-		netxen_rom_fast_read(adapter, i, &val);
-		if (val != 0xffffffff)
-			erased_errors++;
-		count++;
-	}
-
-	if (erased_errors)
-		printk(KERN_INFO "0x%x out of 0x%x words fail to be erased "
-			"for sector address: %x\n", erased_errors, count, addr);
-}
-
-int netxen_rom_se(struct netxen_adapter *adapter, int addr)
-{
-	int ret = 0;
-	if (rom_lock(adapter) != 0) {
-		return -1;
-	}
-	ret = netxen_do_rom_se(adapter, addr);
-	netxen_rom_unlock(adapter);
-	msleep(30);
-	check_erased_flash(adapter, addr);
-
-	return ret;
-}
-
-static int netxen_flash_erase_sections(struct netxen_adapter *adapter,
-				       int start, int end)
-{
-	int ret = FLASH_SUCCESS;
-	int i;
-
-	for (i = start; i < end; i++) {
-		ret = netxen_rom_se(adapter, i * NETXEN_FLASH_SECTOR_SIZE);
-		if (ret)
-			break;
-		ret = netxen_rom_wip_poll(adapter);
-		if (ret < 0)
-			return ret;
-	}
-
-	return ret;
-}
-
-int
-netxen_flash_erase_secondary(struct netxen_adapter *adapter)
-{
-	int ret = FLASH_SUCCESS;
-	int start, end;
-
-	start = NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
-	end   = NETXEN_USER_START / NETXEN_FLASH_SECTOR_SIZE;
-	ret = netxen_flash_erase_sections(adapter, start, end);
-
-	return ret;
-}
-
-int
-netxen_flash_erase_primary(struct netxen_adapter *adapter)
-{
-	int ret = FLASH_SUCCESS;
-	int start, end;
-
-	start = NETXEN_PRIMARY_START / NETXEN_FLASH_SECTOR_SIZE;
-	end   = NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
-	ret = netxen_flash_erase_sections(adapter, start, end);
-
-	return ret;
-}
-
-void netxen_halt_pegs(struct netxen_adapter *adapter)
-{
-	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_0 + 0x3c, 1);
-	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_1 + 0x3c, 1);
-	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_2 + 0x3c, 1);
-	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_3 + 0x3c, 1);
-}
-
-int netxen_flash_unlock(struct netxen_adapter *adapter)
-{
-	int ret = 0;
-
-	ret = netxen_rom_wrsr(adapter, 0);
-	if (ret < 0)
-		return ret;
-
-	ret = netxen_rom_wren(adapter);
-	if (ret < 0)
-		return ret;
-
-	return ret;
-}
-#endif  /*  0  */
-
 #define NETXEN_BOARDTYPE		0x4008
 #define NETXEN_BOARDNUM 		0x400c
 #define NETXEN_CHIPNUM			0x4010
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index c3b9c83..3851a67 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -299,14 +299,6 @@ int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter)
 	return result;
 }
 
-#if 0
-int netxen_niu_xgbe_clear_phy_interrupts(struct netxen_adapter *adapter)
-{
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_ACTIVE_INT, -1);
-	return 0;
-}
-#endif  /*  0  */
-
 static int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter)
 {
 	int result = 0;
@@ -467,104 +459,6 @@ int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 	return 0;
 }
 
-#if 0
-/*
- * netxen_niu_gbe_handle_phy_interrupt - Handles GbE PHY interrupts
- * @param enable 0 means don't enable the port
- *		 1 means enable (or re-enable) the port
- */
-int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
-					int port, long enable)
-{
-	int result = 0;
-	__u32 int_src;
-
-	printk(KERN_INFO PFX "NETXEN: Handling PHY interrupt on port %d"
-	       " (device enable = %d)\n", (int)port, (int)enable);
-
-	/*
-	 * The read of the PHY INT status will clear the pending
-	 * interrupt status
-	 */
-	if (netxen_niu_gbe_phy_read(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
-				    &int_src) != 0)
-		result = -EINVAL;
-	else {
-		printk(KERN_INFO PFX "PHY Interrupt source = 0x%x \n", int_src);
-		if (netxen_get_phy_int_jabber(int_src))
-			printk(KERN_INFO PFX "jabber Interrupt ");
-		if (netxen_get_phy_int_polarity_changed(int_src))
-			printk(KERN_INFO PFX "polarity changed ");
-		if (netxen_get_phy_int_energy_detect(int_src))
-			printk(KERN_INFO PFX "energy detect \n");
-		if (netxen_get_phy_int_downshift(int_src))
-			printk(KERN_INFO PFX "downshift \n");
-		if (netxen_get_phy_int_mdi_xover_changed(int_src))
-			printk(KERN_INFO PFX "mdi_xover_changed ");
-		if (netxen_get_phy_int_fifo_over_underflow(int_src))
-			printk(KERN_INFO PFX "fifo_over_underflow ");
-		if (netxen_get_phy_int_false_carrier(int_src))
-			printk(KERN_INFO PFX "false_carrier ");
-		if (netxen_get_phy_int_symbol_error(int_src))
-			printk(KERN_INFO PFX "symbol_error ");
-		if (netxen_get_phy_int_autoneg_completed(int_src))
-			printk(KERN_INFO PFX "autoneg_completed ");
-		if (netxen_get_phy_int_page_received(int_src))
-			printk(KERN_INFO PFX "page_received ");
-		if (netxen_get_phy_int_duplex_changed(int_src))
-			printk(KERN_INFO PFX "duplex_changed ");
-		if (netxen_get_phy_int_autoneg_error(int_src))
-			printk(KERN_INFO PFX "autoneg_error ");
-		if ((netxen_get_phy_int_speed_changed(int_src))
-		    || (netxen_get_phy_int_link_status_changed(int_src))) {
-			__u32 status;
-
-			printk(KERN_INFO PFX
-			       "speed_changed or link status changed");
-			if (netxen_niu_gbe_phy_read
-			    (adapter,
-			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-			     &status) == 0) {
-				if (netxen_get_phy_speed(status) == 2) {
-					printk
-					    (KERN_INFO PFX "Link speed changed"
-					     " to 1000 Mbps\n");
-					netxen_niu_gbe_set_gmii_mode(adapter,
-								     port,
-								     enable);
-				} else if (netxen_get_phy_speed(status) == 1) {
-					printk
-					    (KERN_INFO PFX "Link speed changed"
-					     " to 100 Mbps\n");
-					netxen_niu_gbe_set_mii_mode(adapter,
-								    port,
-								    enable);
-				} else if (netxen_get_phy_speed(status) == 0) {
-					printk
-					    (KERN_INFO PFX "Link speed changed"
-					     " to 10 Mbps\n");
-					netxen_niu_gbe_set_mii_mode(adapter,
-								    port,
-								    enable);
-				} else {
-					printk(KERN_ERR PFX "ERROR reading "
-					       "PHY status. Invalid speed.\n");
-					result = -1;
-				}
-			} else {
-				printk(KERN_ERR PFX
-				       "ERROR reading PHY status.\n");
-				result = -1;
-			}
-
-		}
-		printk(KERN_INFO "\n");
-	}
-	return result;
-}
-#endif  /*  0  */
-
 /*
  * Return the current station MAC address.
  * Note that the passed-in value must already be in network byte order.
@@ -641,86 +535,6 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 	return 0;
 }
 
-#if 0
-/* Enable a GbE interface */
-int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
-			       int port, netxen_niu_gbe_ifmode_t mode)
-{
-	__u32 mac_cfg0;
-	__u32 mac_cfg1;
-	__u32 mii_cfg;
-
-	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
-		return -EINVAL;
-
-	mac_cfg0 = 0;
-	netxen_gb_soft_reset(mac_cfg0);
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				   &mac_cfg0, 4))
-		return -EIO;
-	mac_cfg0 = 0;
-	netxen_gb_enable_tx(mac_cfg0);
-	netxen_gb_enable_rx(mac_cfg0);
-	netxen_gb_unset_rx_flowctl(mac_cfg0);
-	netxen_gb_tx_reset_pb(mac_cfg0);
-	netxen_gb_rx_reset_pb(mac_cfg0);
-	netxen_gb_tx_reset_mac(mac_cfg0);
-	netxen_gb_rx_reset_mac(mac_cfg0);
-
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				   &mac_cfg0, 4))
-		return -EIO;
-	mac_cfg1 = 0;
-	netxen_gb_set_preamblelen(mac_cfg1, 0xf);
-	netxen_gb_set_duplex(mac_cfg1);
-	netxen_gb_set_crc_enable(mac_cfg1);
-	netxen_gb_set_padshort(mac_cfg1);
-	netxen_gb_set_checklength(mac_cfg1);
-	netxen_gb_set_hugeframes(mac_cfg1);
-
-	if (mode == NETXEN_NIU_10_100_MB) {
-		netxen_gb_set_intfmode(mac_cfg1, 1);
-		if (adapter->hw_write_wx(adapter,
-					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
-					   &mac_cfg1, 4))
-			return -EIO;
-
-		/* set mii mode */
-		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
-					    (port << 3), 0);
-		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
-					    (port << 3), 1);
-
-	} else if (mode == NETXEN_NIU_1000_MB) {
-		netxen_gb_set_intfmode(mac_cfg1, 2);
-		if (adapter->hw_write_wx(adapter,
-					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
-					   &mac_cfg1, 4))
-			return -EIO;
-		/* set gmii mode */
-		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
-					    (port << 3), 0);
-		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
-					    (port << 3), 1);
-	}
-	mii_cfg = 0;
-	netxen_gb_set_mii_mgmt_clockselect(mii_cfg, 7);
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port),
-				   &mii_cfg, 4))
-		return -EIO;
-	mac_cfg0 = 0;
-	netxen_gb_enable_tx(mac_cfg0);
-	netxen_gb_enable_rx(mac_cfg0);
-	netxen_gb_unset_rx_flowctl(mac_cfg0);
-	netxen_gb_unset_tx_flowctl(mac_cfg0);
-
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				   &mac_cfg0, 4))
-		return -EIO;
-	return 0;
-}
-#endif  /*  0  */
-
 /* Disable a GbE interface */
 int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 {
@@ -869,39 +683,6 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 	return 0;
 }
 
-#if 0
-/*
- * Return the current station MAC address.
- * Note that the passed-in value must already be in network byte order.
- */
-int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
-			      netxen_ethernet_macaddr_t * addr)
-{
-	int phy = adapter->physical_port;
-	u32 stationhigh;
-	u32 stationlow;
-	u8 val[8];
-
-	if (addr == NULL)
-		return -EINVAL;
-	if (phy != 0)
-		return -EINVAL;
-
-	if (adapter->hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
-				  &stationhigh, 4))
-		return -EIO;
-	if (adapter->hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
-				  &stationlow, 4))
-		return -EIO;
-	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
-	((__le32 *)val)[0] = cpu_to_le32(stationlow);
-
-	memcpy(addr, val + 2, 6);
-
-	return 0;
-}
-#endif  /*  0  */
-
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 		u32 mode)
 {
-- 
1.6.0.2

