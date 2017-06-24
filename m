From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: standardization: use min_t instead of
 custom macro
Date: Sat, 24 Jun 2017 04:31:56 -0700
Message-ID: <20170624113156.GA1313@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0077.outbound.protection.outlook.com ([104.47.38.77]:22704
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751296AbdFXLcE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Jun 2017 07:32:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Replaced custom MIN macro with use of standard 'min_t'.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 53f38d0..2dc0e30 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -42,7 +42,6 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 MODULE_PARM_DESC(console_bitmask,
 		 "Bitmask indicating which consoles have debug output redirected to syslog.");
 
-#define MIN(a, b) min((a), (b))
 #define CAST_ULL(v) ((u64)(v))
 
 #define BOOTLOADER_PCI_READ_BUFFER_DATA_ADDR    0x0006c008
@@ -704,7 +703,7 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 	if (bytes_to_read <= 0)
 		return bytes_to_read;
 
-	bytes_to_read = MIN(bytes_to_read, (s32)buf_size);
+	bytes_to_read = min_t(s32, bytes_to_read, buf_size);
 
 	/* Check to see if what we want to read is not contiguous, and limit
 	 * ourselves to the contiguous block
-- 
1.8.3.1
