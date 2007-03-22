From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] netxen: enum and #define cleanups
Date: Thu, 22 Mar 2007 10:48:01 -0400
Message-ID: <20070322144800.GA22651@gospo.rdu.redhat.com>
References: <20070321191622.GA18350@gospo.rdu.redhat.com> <200703221959.06071.amitkale@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Amit Kale <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933006AbXCVOsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 10:48:06 -0400
Content-Disposition: inline
In-Reply-To: <200703221959.06071.amitkale@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 07:59:05PM +0530, Amit Kale wrote:
> On Thursday 22 March 2007 00:46, Andy Gospodarek wrote:
> > This patch cleans up some rather generically named items in the netxen
> > driver.  It seems bad to use names like USER_START and FLASH_TOTAL_SIZE,
> > so I added a NETXEN_ to the front of them.
> >
> > This has been compile tested.
> >
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> > ---
> >
> >  netxen_nic.h         |   51
> > ++++++++++++++++++++++++++------------------------- netxen_nic_ethtool.c | 
> >   8 ++++----
> >  netxen_nic_hw.c      |   10 +++++-----
> >  netxen_nic_init.c    |   23 ++++++++++++-----------
> >  4 files changed, 47 insertions(+), 45 deletions(-)
> >
> > diff --git a/drivers/net/netxen/netxen_nic.h
> > b/drivers/net/netxen/netxen_nic.h index dd8ce35..8310584 100644
> > --- a/drivers/net/netxen/netxen_nic.h
> > +++ b/drivers/net/netxen/netxen_nic.h
> > @@ -65,12 +65,13 @@
> >
> >  #define _NETXEN_NIC_LINUX_MAJOR 3
> >  #define _NETXEN_NIC_LINUX_MINOR 3
> > -#define _NETXEN_NIC_LINUX_SUBVERSION 3
> > -#define NETXEN_NIC_LINUX_VERSIONID  "3.3.3"
> > +#define _NETXEN_NIC_LINUX_SUBVERSION 4
> > +#define NETXEN_NIC_LINUX_VERSIONID  "3.3.4"
> 
> This is the firmware identifier.  Shouldn't be changed.
> 
> Rest looks fine. Thanks.
> -Amit
> 

Thanks, Amit.  Here's a repost without thost bits.


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
