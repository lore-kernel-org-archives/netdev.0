From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 3/5] NetXen: Add NETXEN prefix to macros
Date: Mon, 4 Jun 2007 14:58:37 -0400
Message-ID: <20070604185836.GC7056@gospo.rdu.redhat.com>
References: <200706011115.l51BFahX004752@dut39.unminc.com> <4662E345.3070908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mithlesh Thukral <mithlesh@netxen.com>, netdev@vger.kernel.org,
	amitkale@netxen.com, netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758990AbXFDS7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 14:59:05 -0400
Content-Disposition: inline
In-Reply-To: <4662E345.3070908@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 03, 2007 at 11:50:29AM -0400, Jeff Garzik wrote:
> Mithlesh Thukral wrote:
> >NetXen: Add NETXEN prefix to a macro
> >This patch will add the "NETXEN" prefix to "USER_START" macro.
> >
> >Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> >Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> >---
> >
> > drivers/net/netxen/netxen_nic.h         |    4 ++--
> > drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
> > drivers/net/netxen/netxen_nic_hw.c      |    4 ++--
> > drivers/net/netxen/netxen_nic_init.c    |    4 ++--
> > 4 files changed, 7 insertions(+), 7 deletions(-)
> 
> Your patch description is useless.  Clearly we know -what- it does, 
> simply by reading the patch.
> 
> But it does not answer the simple question:  why?  why is this needed in 
> a bug fix Release Candidate series?
> 

I can't see why this is needed in an RC branch, but the use of
generically named macros/variables has been problematic with this driver
on more 'obscure' arches.  

I submitted a bigger cleanup patch a in March that never got taken so
this is still a problem.  Here is that patch:

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 netxen_nic.h         |   47 ++++++++++++++++++++++++-----------------------
 netxen_nic_ethtool.c |    8 ++++----
 netxen_nic_hw.c      |   10 +++++-----
 netxen_nic_init.c    |   23 ++++++++++++-----------
 4 files changed, 45 insertions(+), 43 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index dd8ce35..d5f0c06 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -68,9 +68,10 @@
 #define _NETXEN_NIC_LINUX_SUBVERSION 3
 #define NETXEN_NIC_LINUX_VERSIONID  "3.3.3"
 
-#define NUM_FLASH_SECTORS (64)
-#define FLASH_SECTOR_SIZE (64 * 1024)
-#define FLASH_TOTAL_SIZE  (NUM_FLASH_SECTORS * FLASH_SECTOR_SIZE)
+#define NETXEN_NUM_FLASH_SECTORS (64)
+#define NETXEN_FLASH_SECTOR_SIZE (64 * 1024)
+#define NETXEN_FLASH_TOTAL_SIZE  (NETXEN_NUM_FLASH_SECTORS \
+					* NETXEN_FLASH_SECTOR_SIZE)
 
 #define PHAN_VENDOR_ID 0x4040
 
@@ -671,28 +672,28 @@ struct netxen_new_user_info {
 
 /* Flash memory map */
 typedef enum {
-	CRBINIT_START = 0,	/* Crbinit section */
-	BRDCFG_START = 0x4000,	/* board config */
-	INITCODE_START = 0x6000,	/* pegtune code */
-	BOOTLD_START = 0x10000,	/* bootld */
-	IMAGE_START = 0x43000,	/* compressed image */
-	SECONDARY_START = 0x200000,	/* backup images */
-	PXE_START = 0x3E0000,	/* user defined region */
-	USER_START = 0x3E8000,	/* User defined region for new boards */
-	FIXED_START = 0x3F0000	/* backup of crbinit */
+	NETXEN_CRBINIT_START = 0,	/* Crbinit section */
+	NETXEN_BRDCFG_START = 0x4000,	/* board config */
+	NETXEN_INITCODE_START = 0x6000,	/* pegtune code */
+	NETXEN_BOOTLD_START = 0x10000,	/* bootld */
+	NETXEN_IMAGE_START = 0x43000,	/* compressed image */
+	NETXEN_SECONDARY_START = 0x200000,	/* backup images */
+	NETXEN_PXE_START = 0x3E0000,	/* user defined region */
+	NETXEN_USER_START = 0x3E8000,	/* User defined region for new boards */
+	NETXEN_FIXED_START = 0x3F0000	/* backup of crbinit */
 } netxen_flash_map_t;
 
-#define USER_START_OLD PXE_START	/* for backward compatibility */
-
-#define FLASH_START		(CRBINIT_START)
-#define INIT_SECTOR		(0)
-#define PRIMARY_START 		(BOOTLD_START)
-#define FLASH_CRBINIT_SIZE 	(0x4000)
-#define FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
-#define FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
-#define FLASH_SECONDARY_SIZE 	(USER_START-SECONDARY_START)
-#define NUM_PRIMARY_SECTORS	(0x20)
-#define NUM_CONFIG_SECTORS 	(1)
+#define NETXEN_USER_START_OLD NETXEN_PXE_START	/* for backward compatibility */
+
+#define NETXEN_FLASH_START		(NETXEN_CRBINIT_START)
+#define NETXEN_INIT_SECTOR		(0)
+#define NETXEN_PRIMARY_START 		(NETXEN_BOOTLD_START)
+#define NETXEN_FLASH_CRBINIT_SIZE 	(0x4000)
+#define NETXEN_FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
+#define NETXEN_FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
+#define NETXEN_FLASH_SECONDARY_SIZE 	(NETXEN_USER_START-NETXEN_SECONDARY_START)
+#define NETXEN_NUM_PRIMARY_SECTORS	(0x20)
+#define NETXEN_NUM_CONFIG_SECTORS 	(1)
 #define PFX "NetXen: "
 extern char netxen_nic_driver_name[];
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index ee1b5a2..4dfa76b 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -94,7 +94,7 @@ static const char netxen_nic_gstrings_test[][ETH_GSTRING_LEN] = {
 
 static int netxen_nic_get_eeprom_len(struct net_device *dev)
 {
-	return FLASH_TOTAL_SIZE;
+	return NETXEN_FLASH_TOTAL_SIZE;
 }
 
 static void
@@ -475,7 +475,7 @@ netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		return 0;
 	}
 
-	if (offset == BOOTLD_START) {
+	if (offset == NETXEN_BOOTLD_START) {
 		ret = netxen_flash_erase_primary(adapter);
 		if (ret != FLASH_SUCCESS) {
 			printk(KERN_ERR "%s: Flash erase failed.\n", 
@@ -483,10 +483,10 @@ netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 			return ret;
 		}
 
-		ret = netxen_rom_se(adapter, USER_START);
+		ret = netxen_rom_se(adapter, NETXEN_USER_START);
 		if (ret != FLASH_SUCCESS)
 			return ret;
-		ret = netxen_rom_se(adapter, FIXED_START);
+		ret = netxen_rom_se(adapter, NETXEN_FIXED_START);
 		if (ret != FLASH_SUCCESS)
 			return ret;
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 6537574..2fe7a3f 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -40,7 +40,7 @@
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) <= (high)) && ((addr) >= (low)))
 
-#define NETXEN_FLASH_BASE	(BOOTLD_START)
+#define NETXEN_FLASH_BASE	(NETXEN_BOOTLD_START)
 #define NETXEN_PHANTOM_MEM_BASE	(NETXEN_FLASH_BASE)
 #define NETXEN_MAX_MTU		8000 + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE
 #define NETXEN_MIN_MTU		64
@@ -443,7 +443,7 @@ int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[])
 	u32 *pmac = (u32 *) & mac[0];
 
 	if (netxen_get_flash_block(adapter,
-				   USER_START +
+				   NETXEN_USER_START +
 				   offsetof(struct netxen_new_user_info,
 					    mac_addr),
 				   FLASH_NUM_PORTS * sizeof(u64), pmac) == -1) {
@@ -451,7 +451,7 @@ int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[])
 	}
 	if (*mac == ~0ULL) {
 		if (netxen_get_flash_block(adapter,
-					   USER_START_OLD +
+					   NETXEN_USER_START_OLD +
 					   offsetof(struct netxen_user_old_info,
 						    mac_addr),
 					   FLASH_NUM_PORTS * sizeof(u64),
@@ -751,7 +751,7 @@ netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 {
 	int rv = 0;
-	int addr = BRDCFG_START;
+	int addr = NETXEN_BRDCFG_START;
 	struct netxen_board_info *boardinfo;
 	int index;
 	u32 *ptr32;
@@ -928,7 +928,7 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 	u32 fw_build = 0;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	struct netxen_new_user_info user_info;
-	int i, addr = USER_START;
+	int i, addr = NETXEN_USER_START;
 	u32 *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 229aa1c..abdc04b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -586,7 +586,7 @@ int netxen_backup_crbinit(struct netxen_adapter *adapter)
 {
 	int ret = FLASH_SUCCESS;
 	int val;
-	char *buffer = kmalloc(FLASH_SECTOR_SIZE, GFP_KERNEL);
+	char *buffer = kmalloc(NETXEN_FLASH_SECTOR_SIZE, GFP_KERNEL);
 
 	if (!buffer)
 		return -ENOMEM;	
@@ -602,13 +602,13 @@ int netxen_backup_crbinit(struct netxen_adapter *adapter)
 		goto out_kfree;
 
 	/* copy  sector 0 to sector 63 */
-	ret = netxen_rom_fast_read_words(adapter, CRBINIT_START, 
-						buffer, FLASH_SECTOR_SIZE);
+	ret = netxen_rom_fast_read_words(adapter, NETXEN_CRBINIT_START, 
+					buffer, NETXEN_FLASH_SECTOR_SIZE);
 	if (ret != FLASH_SUCCESS)
 		goto out_kfree;
 
-	ret = netxen_rom_fast_write_words(adapter, FIXED_START, 
-						buffer, FLASH_SECTOR_SIZE);
+	ret = netxen_rom_fast_write_words(adapter, NETXEN_FIXED_START, 
+					buffer, NETXEN_FLASH_SECTOR_SIZE);
 	if (ret != FLASH_SUCCESS)
 		goto out_kfree;
 
@@ -655,7 +655,8 @@ void check_erased_flash(struct netxen_adapter *adapter, int addr)
 	int count = 0, erased_errors = 0;
 	int range;
 
-	range = (addr == USER_START) ? FIXED_START : addr + FLASH_SECTOR_SIZE;
+	range = (addr == NETXEN_USER_START) ? 
+		NETXEN_FIXED_START : addr + NETXEN_FLASH_SECTOR_SIZE;
 	
 	for (i = addr; i < range; i += 4) {
 		netxen_rom_fast_read(adapter, i, &val);
@@ -690,7 +691,7 @@ netxen_flash_erase_sections(struct netxen_adapter *adapter, int start, int end)
 	int i;
 
 	for (i = start; i < end; i++) {
-		ret = netxen_rom_se(adapter, i * FLASH_SECTOR_SIZE);
+		ret = netxen_rom_se(adapter, i * NETXEN_FLASH_SECTOR_SIZE);
 		if (ret)
 			break;
 		ret = netxen_rom_wip_poll(adapter);
@@ -707,8 +708,8 @@ netxen_flash_erase_secondary(struct netxen_adapter *adapter)
 	int ret = FLASH_SUCCESS;
 	int start, end;
 
-	start = SECONDARY_START / FLASH_SECTOR_SIZE;
-	end   = USER_START / FLASH_SECTOR_SIZE;
+	start = NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
+	end   = NETXEN_USER_START / NETXEN_FLASH_SECTOR_SIZE;
 	ret = netxen_flash_erase_sections(adapter, start, end);
 
 	return ret;
@@ -720,8 +721,8 @@ netxen_flash_erase_primary(struct netxen_adapter *adapter)
 	int ret = FLASH_SUCCESS;
 	int start, end;
 
-	start = PRIMARY_START / FLASH_SECTOR_SIZE;
-	end   = SECONDARY_START / FLASH_SECTOR_SIZE;
+	start = NETXEN_PRIMARY_START / NETXEN_FLASH_SECTOR_SIZE;
+	end   = NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
 	ret = netxen_flash_erase_sections(adapter, start, end);
 
 	return ret;

