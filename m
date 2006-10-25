From: Amit Choudhary <amit2030@gmail.com>
Subject: [PATCH 2.6.19-rc3] drivers/char/synclink.c: check kmalloc() return
 value.
Date: Tue, 24 Oct 2006 20:56:44 -0700
Message-ID: <20061024205644.5ce58504.amit2030@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:46020 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161339AbWJYD4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 23:56:52 -0400
Received: by ug-out-1314.google.com with SMTP id 32so14907ugm
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 20:56:51 -0700 (PDT)
To: Linux Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
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
