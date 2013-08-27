From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/16] sfc: Rename SPI stuff to show that it is
 Falcon-specific
Date: Tue, 27 Aug 2013 21:50:36 +0100
Message-ID: <1377636636.13272.89.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6211 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064Ab3H0Uuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:50:40 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c | 30 ++++++++++++++--------------
 drivers/net/ethernet/sfc/mtd.c    | 42 +++++++++++++++++++--------------------
 drivers/net/ethernet/sfc/nic.h    |  4 ++--
 drivers/net/ethernet/sfc/spi.h    | 18 ++++++++---------
 4 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 983e7f5..304131b 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -434,7 +434,7 @@ static int falcon_spi_wait(struct efx_nic *efx)
 	}
 }
 
-int falcon_spi_cmd(struct efx_nic *efx, const struct efx_spi_device *spi,
+int falcon_spi_cmd(struct efx_nic *efx, const struct falcon_spi_device *spi,
 		   unsigned int command, int address,
 		   const void *in, void *out, size_t len)
 {
@@ -491,22 +491,22 @@ int falcon_spi_cmd(struct efx_nic *efx, const struct efx_spi_device *spi,
 }
 
 static size_t
-falcon_spi_write_limit(const struct efx_spi_device *spi, size_t start)
+falcon_spi_write_limit(const struct falcon_spi_device *spi, size_t start)
 {
 	return min(FALCON_SPI_MAX_LEN,
 		   (spi->block_size - (start & (spi->block_size - 1))));
 }
 
 static inline u8
-efx_spi_munge_command(const struct efx_spi_device *spi,
-		      const u8 command, const unsigned int address)
+falcon_spi_munge_command(const struct falcon_spi_device *spi,
+			 const u8 command, const unsigned int address)
 {
 	return command | (((address >> 8) & spi->munge_address) << 3);
 }
 
 /* Wait up to 10 ms for buffered write completion */
 int
-falcon_spi_wait_write(struct efx_nic *efx, const struct efx_spi_device *spi)
+falcon_spi_wait_write(struct efx_nic *efx, const struct falcon_spi_device *spi)
 {
 	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 100);
 	u8 status;
@@ -530,7 +530,7 @@ falcon_spi_wait_write(struct efx_nic *efx, const struct efx_spi_device *spi)
 	}
 }
 
-int falcon_spi_read(struct efx_nic *efx, const struct efx_spi_device *spi,
+int falcon_spi_read(struct efx_nic *efx, const struct falcon_spi_device *spi,
 		    loff_t start, size_t len, size_t *retlen, u8 *buffer)
 {
 	size_t block_len, pos = 0;
@@ -540,7 +540,7 @@ int falcon_spi_read(struct efx_nic *efx, const struct efx_spi_device *spi,
 	while (pos < len) {
 		block_len = min(len - pos, FALCON_SPI_MAX_LEN);
 
-		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
+		command = falcon_spi_munge_command(spi, SPI_READ, start + pos);
 		rc = falcon_spi_cmd(efx, spi, command, start + pos, NULL,
 				    buffer + pos, block_len);
 		if (rc)
@@ -561,7 +561,7 @@ int falcon_spi_read(struct efx_nic *efx, const struct efx_spi_device *spi,
 }
 
 int
-falcon_spi_write(struct efx_nic *efx, const struct efx_spi_device *spi,
+falcon_spi_write(struct efx_nic *efx, const struct falcon_spi_device *spi,
 		 loff_t start, size_t len, size_t *retlen, const u8 *buffer)
 {
 	u8 verify_buffer[FALCON_SPI_MAX_LEN];
@@ -576,7 +576,7 @@ falcon_spi_write(struct efx_nic *efx, const struct efx_spi_device *spi,
 
 		block_len = min(len - pos,
 				falcon_spi_write_limit(spi, start + pos));
-		command = efx_spi_munge_command(spi, SPI_WRITE, start + pos);
+		command = falcon_spi_munge_command(spi, SPI_WRITE, start + pos);
 		rc = falcon_spi_cmd(efx, spi, command, start + pos,
 				    buffer + pos, NULL, block_len);
 		if (rc)
@@ -586,7 +586,7 @@ falcon_spi_write(struct efx_nic *efx, const struct efx_spi_device *spi,
 		if (rc)
 			break;
 
-		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
+		command = falcon_spi_munge_command(spi, SPI_READ, start + pos);
 		rc = falcon_spi_cmd(efx, spi, command, start + pos,
 				    NULL, verify_buffer, block_len);
 		if (memcmp(verify_buffer, buffer + pos, block_len)) {
@@ -1481,15 +1481,15 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	struct falcon_nvconfig *nvconfig;
-	struct efx_spi_device *spi;
+	struct falcon_spi_device *spi;
 	void *region;
 	int rc, magic_num, struct_ver;
 	__le16 *word, *limit;
 	u32 csum;
 
-	if (efx_spi_present(&nic_data->spi_flash))
+	if (falcon_spi_present(&nic_data->spi_flash))
 		spi = &nic_data->spi_flash;
-	else if (efx_spi_present(&nic_data->spi_eeprom))
+	else if (falcon_spi_present(&nic_data->spi_eeprom))
 		spi = &nic_data->spi_eeprom;
 	else
 		return -EINVAL;
@@ -1504,7 +1504,7 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	mutex_unlock(&nic_data->spi_lock);
 	if (rc) {
 		netif_err(efx, hw, efx->net_dev, "Failed to read %s\n",
-			  efx_spi_present(&nic_data->spi_flash) ?
+			  falcon_spi_present(&nic_data->spi_flash) ?
 			  "flash" : "EEPROM");
 		rc = -EIO;
 		goto out;
@@ -1849,7 +1849,7 @@ static int falcon_reset_sram(struct efx_nic *efx)
 }
 
 static void falcon_spi_device_init(struct efx_nic *efx,
-				  struct efx_spi_device *spi_device,
+				  struct falcon_spi_device *spi_device,
 				  unsigned int device_id, u32 device_type)
 {
 	if (device_type != 0) {
diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index 08f825b..e4b35c6 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -22,7 +22,7 @@
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 
-#define EFX_SPI_VERIFY_BUF_LEN 16
+#define FALCON_SPI_VERIFY_BUF_LEN 16
 
 struct efx_mtd_partition {
 	struct mtd_info mtd;
@@ -50,7 +50,7 @@ struct efx_mtd_ops {
 struct efx_mtd {
 	struct list_head node;
 	struct efx_nic *efx;
-	const struct efx_spi_device *spi;
+	const struct falcon_spi_device *spi;
 	const char *name;
 	const struct efx_mtd_ops *ops;
 	size_t n_parts;
@@ -71,10 +71,10 @@ static int siena_mtd_probe(struct efx_nic *efx);
 /* SPI utilities */
 
 static int
-efx_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
+falcon_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
 {
 	struct efx_mtd *efx_mtd = part->mtd.priv;
-	const struct efx_spi_device *spi = efx_mtd->spi;
+	const struct falcon_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
 	u8 status;
 	int rc, i;
@@ -98,7 +98,7 @@ efx_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
 }
 
 static int
-efx_spi_unlock(struct efx_nic *efx, const struct efx_spi_device *spi)
+falcon_spi_unlock(struct efx_nic *efx, const struct falcon_spi_device *spi)
 {
 	const u8 unlock_mask = (SPI_STATUS_BP2 | SPI_STATUS_BP1 |
 				SPI_STATUS_BP0);
@@ -133,14 +133,14 @@ efx_spi_unlock(struct efx_nic *efx, const struct efx_spi_device *spi)
 }
 
 static int
-efx_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
+falcon_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
 {
 	struct efx_mtd *efx_mtd = part->mtd.priv;
-	const struct efx_spi_device *spi = efx_mtd->spi;
+	const struct falcon_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
 	unsigned pos, block_len;
-	u8 empty[EFX_SPI_VERIFY_BUF_LEN];
-	u8 buffer[EFX_SPI_VERIFY_BUF_LEN];
+	u8 empty[FALCON_SPI_VERIFY_BUF_LEN];
+	u8 buffer[FALCON_SPI_VERIFY_BUF_LEN];
 	int rc;
 
 	if (len != spi->erase_size)
@@ -149,7 +149,7 @@ efx_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
 	if (spi->erase_command == 0)
 		return -EOPNOTSUPP;
 
-	rc = efx_spi_unlock(efx, spi);
+	rc = falcon_spi_unlock(efx, spi);
 	if (rc)
 		return rc;
 	rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
@@ -159,7 +159,7 @@ efx_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
 			    NULL, 0);
 	if (rc)
 		return rc;
-	rc = efx_spi_slow_wait(part, false);
+	rc = falcon_spi_slow_wait(part, false);
 
 	/* Verify the entire region has been wiped */
 	memset(empty, 0xff, sizeof(empty));
@@ -319,7 +319,7 @@ static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
-	const struct efx_spi_device *spi = efx_mtd->spi;
+	const struct falcon_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -344,7 +344,7 @@ static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
-	rc = efx_spi_erase(part, part->offset + start, len);
+	rc = falcon_spi_erase(part, part->offset + start, len);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
@@ -354,7 +354,7 @@ static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
-	const struct efx_spi_device *spi = efx_mtd->spi;
+	const struct falcon_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -377,7 +377,7 @@ static int falcon_mtd_sync(struct mtd_info *mtd)
 	int rc;
 
 	mutex_lock(&nic_data->spi_lock);
-	rc = efx_spi_slow_wait(part, true);
+	rc = falcon_spi_slow_wait(part, true);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
@@ -392,14 +392,14 @@ static const struct efx_mtd_ops falcon_mtd_ops = {
 static int falcon_mtd_probe(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
-	struct efx_spi_device *spi;
+	struct falcon_spi_device *spi;
 	struct efx_mtd *efx_mtd;
 	int rc = -ENODEV;
 
 	ASSERT_RTNL();
 
 	spi = &nic_data->spi_flash;
-	if (efx_spi_present(spi) && spi->size > FALCON_FLASH_BOOTCODE_START) {
+	if (falcon_spi_present(spi) && spi->size > FALCON_FLASH_BOOTCODE_START) {
 		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
 				  GFP_KERNEL);
 		if (!efx_mtd)
@@ -425,7 +425,7 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 	}
 
 	spi = &nic_data->spi_eeprom;
-	if (efx_spi_present(spi) && spi->size > EFX_EEPROM_BOOTCONFIG_START) {
+	if (falcon_spi_present(spi) && spi->size > FALCON_EEPROM_BOOTCONFIG_START) {
 		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
 				  GFP_KERNEL);
 		if (!efx_mtd)
@@ -439,10 +439,10 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 		efx_mtd->part[0].mtd.type = MTD_RAM;
 		efx_mtd->part[0].mtd.flags = MTD_CAP_RAM;
 		efx_mtd->part[0].mtd.size =
-			min(spi->size, EFX_EEPROM_BOOTCONFIG_END) -
-			EFX_EEPROM_BOOTCONFIG_START;
+			min(spi->size, FALCON_EEPROM_BOOTCONFIG_END) -
+			FALCON_EEPROM_BOOTCONFIG_START;
 		efx_mtd->part[0].mtd.erasesize = spi->erase_size;
-		efx_mtd->part[0].offset = EFX_EEPROM_BOOTCONFIG_START;
+		efx_mtd->part[0].offset = FALCON_EEPROM_BOOTCONFIG_START;
 		efx_mtd->part[0].type_name = "sfc_bootconfig";
 
 		rc = efx_mtd_probe_device(efx, efx_mtd);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 8baf6a1..b90dc8a 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -184,8 +184,8 @@ struct falcon_nic_data {
 	bool stats_pending;
 	struct timer_list stats_timer;
 	u32 *stats_dma_done;
-	struct efx_spi_device spi_flash;
-	struct efx_spi_device spi_eeprom;
+	struct falcon_spi_device spi_flash;
+	struct falcon_spi_device spi_eeprom;
 	struct mutex spi_lock;
 	struct mutex mdio_lock;
 	bool xmac_poll_required;
diff --git a/drivers/net/ethernet/sfc/spi.h b/drivers/net/ethernet/sfc/spi.h
index 5431a1b..ee951feb 100644
--- a/drivers/net/ethernet/sfc/spi.h
+++ b/drivers/net/ethernet/sfc/spi.h
@@ -35,7 +35,7 @@
 #define SPI_STATUS_NRDY 0x01	/* Device busy flag */
 
 /**
- * struct efx_spi_device - an Efx SPI (Serial Peripheral Interface) device
+ * struct falcon_spi_device - a Falcon SPI (Serial Peripheral Interface) device
  * @device_id:		Controller's id for the device
  * @size:		Size (in bytes)
  * @addr_len:		Number of address bytes in read/write commands
@@ -51,7 +51,7 @@
  * @block_size:		Write block size (in bytes).
  *	Write commands are limited to blocks with this size and alignment.
  */
-struct efx_spi_device {
+struct falcon_spi_device {
 	int device_id;
 	unsigned int size;
 	unsigned int addr_len;
@@ -61,21 +61,21 @@ struct efx_spi_device {
 	unsigned int block_size;
 };
 
-static inline bool efx_spi_present(const struct efx_spi_device *spi)
+static inline bool falcon_spi_present(const struct falcon_spi_device *spi)
 {
 	return spi->size != 0;
 }
 
 int falcon_spi_cmd(struct efx_nic *efx,
-		   const struct efx_spi_device *spi, unsigned int command,
+		   const struct falcon_spi_device *spi, unsigned int command,
 		   int address, const void *in, void *out, size_t len);
 int falcon_spi_wait_write(struct efx_nic *efx,
-			  const struct efx_spi_device *spi);
+			  const struct falcon_spi_device *spi);
 int falcon_spi_read(struct efx_nic *efx,
-		    const struct efx_spi_device *spi, loff_t start,
+		    const struct falcon_spi_device *spi, loff_t start,
 		    size_t len, size_t *retlen, u8 *buffer);
 int falcon_spi_write(struct efx_nic *efx,
-		     const struct efx_spi_device *spi, loff_t start,
+		     const struct falcon_spi_device *spi, loff_t start,
 		     size_t len, size_t *retlen, const u8 *buffer);
 
 /*
@@ -93,7 +93,7 @@ int falcon_spi_write(struct efx_nic *efx,
  */
 #define FALCON_NVCONFIG_END 0x400U
 #define FALCON_FLASH_BOOTCODE_START 0x8000U
-#define EFX_EEPROM_BOOTCONFIG_START 0x800U
-#define EFX_EEPROM_BOOTCONFIG_END 0x1800U
+#define FALCON_EEPROM_BOOTCONFIG_START 0x800U
+#define FALCON_EEPROM_BOOTCONFIG_END 0x1800U
 
 #endif /* EFX_SPI_H */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
