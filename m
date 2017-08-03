From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: moved console_bitmask module param to
 lio_main.c
Date: Thu, 3 Aug 2017 15:10:17 -0700
Message-ID: <20170803221017.GA2469@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0042.outbound.protection.outlook.com ([104.47.34.42]:10464
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751891AbdHCWKW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 18:10:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving PF module param console_bitmask to lio_main.c for consistency.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c       | 15 +++++++++++++++
 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 14 --------------
 drivers/net/ethernet/cavium/liquidio/octeon_device.h  |  2 ++
 3 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 39a8dca..8c2cd80 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -59,6 +59,21 @@ static char fw_type[LIO_MAX_FW_TYPE_LEN];
 module_param_string(fw_type, fw_type, sizeof(fw_type), 0000);
 MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\"");
 
+static u32 console_bitmask;
+module_param(console_bitmask, int, 0644);
+MODULE_PARM_DESC(console_bitmask,
+		 "Bitmask indicating which consoles have debug output redirected to syslog.");
+
+/**
+ * \brief determines if a given console has debug enabled.
+ * @param console console to check
+ * @returns  1 = enabled. 0 otherwise
+ */
+int octeon_console_debug_enabled(u32 console)
+{
+	return (console_bitmask >> (console)) & 0x1;
+}
+
 static int ptp_enable = 1;
 
 /* Polling interval for determining when NIC application is alive */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 15ad1ab..dd0efc9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -37,10 +37,6 @@ static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
 					     u32 flags);
 static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 			       char *buffer, u32 buf_size);
-static u32 console_bitmask;
-module_param(console_bitmask, int, 0644);
-MODULE_PARM_DESC(console_bitmask,
-		 "Bitmask indicating which consoles have debug output redirected to syslog.");
 
 #define BOOTLOADER_PCI_READ_BUFFER_DATA_ADDR    0x0006c008
 #define BOOTLOADER_PCI_READ_BUFFER_LEN_ADDR     0x0006c004
@@ -136,16 +132,6 @@ struct octeon_pci_console_desc {
 };
 
 /**
- * \brief determines if a given console has debug enabled.
- * @param console console to check
- * @returns  1 = enabled. 0 otherwise
- */
-static int octeon_console_debug_enabled(u32 console)
-{
-	return (console_bitmask >> (console)) & 0x1;
-}
-
-/**
  * This function is the implementation of the get macros defined
  * for individual structure members. The argument are generated
  * by the macros inorder to read only the needed memory.
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index ad46478..31efdef 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -739,6 +739,8 @@ int octeon_wait_for_bootloader(struct octeon_device *oct,
  */
 int octeon_init_consoles(struct octeon_device *oct);
 
+int octeon_console_debug_enabled(u32 console);
+
 /**
  * Adds access to a console to the device.
  *
