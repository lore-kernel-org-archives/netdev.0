From: Srikanth Thokala <srikanth.thokala@xilinx.com>
Subject: [PATCH 2/2] net: emaclite: add barriers to support Xilinx Zynq platform
Date: Thu, 28 Nov 2013 12:59:57 +0530
Message-ID: <9045da6f-88e5-4a20-be68-477790588131@TX2EHSMHS023.ehs.local>
References: <1385623797-26034-1-git-send-email-sthokal@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Michal Simek <michal.simek@xilinx.com>,
	Srikanth Thokala <sthokal@xilinx.com>
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:12027 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750741Ab3K1Hdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 02:33:37 -0500
In-Reply-To: <1385623797-26034-1-git-send-email-sthokal@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds barriers at appropriate places to ensure the driver
works on Xilinx Zynq ARM-based SoC platform.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 3a693a1..31b8b6c 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -220,6 +220,7 @@ static void xemaclite_aligned_write(void *src_ptr, u32 *dest_ptr,
 		to_u16_ptr = (u16 *)&align_buffer;
 		*to_u16_ptr++ = *from_u16_ptr++;
 		*to_u16_ptr++ = *from_u16_ptr++;
+		wmb();
 
 		/* Output a word */
 		*to_u32_ptr++ = align_buffer;
@@ -236,6 +237,7 @@ static void xemaclite_aligned_write(void *src_ptr, u32 *dest_ptr,
 		for (; length > 0; length--)
 			*to_u8_ptr++ = *from_u8_ptr++;
 
+		wmb();
 		*to_u32_ptr = align_buffer;
 	}
 }
-- 
1.8.2.GIT
