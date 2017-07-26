From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v3 net-next 1/2] liquidio: standardization: use min_t instead
 of custom macro
Date: Wed, 26 Jul 2017 12:10:48 -0700
Message-ID: <20170726191048.GA1168@felix-thinkpad.cavium.com>
References: <20170726190945.GA1152@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0063.outbound.protection.outlook.com ([104.47.37.63]:28576
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751078AbdGZTKy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 15:10:54 -0400
Content-Disposition: inline
In-Reply-To: <20170726190945.GA1152@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index e08f760..501ad95 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -42,7 +42,6 @@ module_param(console_bitmask, int, 0644);
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
2.9.0
