From: Srikanth Thokala <sthokal@xilinx.com>
Subject: [PATCH v2 2/2] net: emaclite: add barriers to support Xilinx Zynq platform
Date: Sat,  7 Dec 2013 13:40:49 +0530
Message-ID: <1386403849-3153-2-git-send-email-sthokal@xilinx.com>
References: <1386403849-3153-1-git-send-email-sthokal@xilinx.com>
Cc: davem@davemloft.net, michal.simek@xilinx.com,
	Srikanth Thokala <sthokal@xilinx.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:45433 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab3LGILN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 03:11:13 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so2280239pde.34
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 00:11:13 -0800 (PST)
In-Reply-To: <1386403849-3153-1-git-send-email-sthokal@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds barriers at appropriate places to ensure the driver
works on Xilinx Zynq ARM-based SoC platform.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
---
Changes in v2:
	rebased on v3.13.0-rc3.
        added comments for memory barrier.
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index b2850fd..fefb8cd 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -220,6 +220,13 @@ static void xemaclite_aligned_write(void *src_ptr, u32 *dest_ptr,
 		*to_u16_ptr++ = *from_u16_ptr++;
 		*to_u16_ptr++ = *from_u16_ptr++;
 
+		/* This barrier resolves occasional issues seen around
+		 * cases where the data is not properly flushed out
+		 * from the processor store buffers to the destination
+		 * memory locations.
+		 */
+		wmb();
+
 		/* Output a word */
 		*to_u32_ptr++ = align_buffer;
 	}
@@ -235,6 +242,12 @@ static void xemaclite_aligned_write(void *src_ptr, u32 *dest_ptr,
 		for (; length > 0; length--)
 			*to_u8_ptr++ = *from_u8_ptr++;
 
+		/* This barrier resolves occasional issues seen around
+		 * cases where the data is not properly flushed out
+		 * from the processor store buffers to the destination
+		 * memory locations.
+		 */
+		wmb();
 		*to_u32_ptr = align_buffer;
 	}
 }
-- 
1.7.9.5
