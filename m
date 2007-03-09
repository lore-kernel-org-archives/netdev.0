From: Amit Choudhary <amit2030@gmail.com>
Subject: [PATCH] drivers/char/synclink.c: check kmalloc() return value.
Date: Thu, 8 Mar 2007 23:22:39 -0800
Message-ID: <20070308232239.8db0f42b.amit2030@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2993053AbXCIHW6@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Description: Check the return value of kmalloc() in function mgsl_alloc_intermediate_txbuffer_memory(), in file drivers/char/synclink.c.

Signed-off-by: Amit Choudhary <amit2030@gmail.com>

diff --git a/drivers/char/synclink.c b/drivers/char/synclink.c
index 06784ad..24f99bc 100644
--- a/drivers/char/synclink.c
+++ b/drivers/char/synclink.c
@@ -4012,8 +4012,13 @@ static int mgsl_alloc_intermediate_txbuf
 	for ( i=0; i<info->num_tx_holding_buffers; ++i) {
 		info->tx_holding_buffers[i].buffer =
 			kmalloc(info->max_frame_size, GFP_KERNEL);
-		if ( info->tx_holding_buffers[i].buffer == NULL )
+		if (info->tx_holding_buffers[i].buffer == NULL) {
+			for (--i; i >= 0; i--) {
+				kfree(info->tx_holding_buffers[i].buffer);
+				info->tx_holding_buffers[i].buffer = NULL;
+			}
 			return -ENOMEM;
+		}
 	}
 
 	return 0;
