From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/17] sfc: Move definition of struct falcon_nic_data into
	falcon.h
Date: Tue, 24 Nov 2009 02:05:28 +0000
Message-ID: <1259028328.14645.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34772 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbZKXCFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:05:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is preparation for moving Falcon-specific state required by other
Falcon-specific code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   11 -----------
 drivers/net/sfc/falcon.h |   11 +++++++++++
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 29e79f7..490bda0 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -14,7 +14,6 @@
 #include <linux/module.h>
 #include <linux/seq_file.h>
 #include <linux/i2c.h>
-#include <linux/i2c-algo-bit.h>
 #include <linux/mii.h>
 #include "net_driver.h"
 #include "bitfield.h"
@@ -33,16 +32,6 @@
  * present in SFE400X evaluation boards
  */
 
-/**
- * struct falcon_nic_data - Falcon NIC state
- * @pci_dev2: The secondary PCI device if present
- * @i2c_data: Operations and state for I2C bit-bashing algorithm
- */
-struct falcon_nic_data {
-	struct pci_dev *pci_dev2;
-	struct i2c_algo_bit_data i2c_data;
-};
-
 /**************************************************************************
  *
  * Configurable values
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 54dad2d..46dd43b 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -11,6 +11,7 @@
 #ifndef EFX_FALCON_H
 #define EFX_FALCON_H
 
+#include <linux/i2c-algo-bit.h>
 #include "net_driver.h"
 #include "efx.h"
 
@@ -29,6 +30,16 @@ static inline int falcon_rev(struct efx_nic *efx)
 	return efx->pci_dev->revision;
 }
 
+/**
+ * struct falcon_nic_data - Falcon NIC state
+ * @pci_dev2: The secondary PCI device if present
+ * @i2c_data: Operations and state for I2C bit-bashing algorithm
+ */
+struct falcon_nic_data {
+	struct pci_dev *pci_dev2;
+	struct i2c_algo_bit_data i2c_data;
+};
+
 static inline struct falcon_board *falcon_board(struct efx_nic *efx)
 {
 	return &efx->board_info;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

