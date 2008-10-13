From: Grant Grundler <grundler@parisc-linux.org>
Subject: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit
	compile failure
Date: Mon, 13 Oct 2008 00:06:15 -0600
Message-ID: <20081013060615.GB29358@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	linux-ia64@vger.kernel.org
To: linux-driver@qlogic.com
Return-path: <linux-ia64-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QLGE driver only supports 4k, 8k, and 64k pages.
Default page size on ia64 is 16k. Compile fails with:
drivers/net/qlge/qlge.h:1118: error: 'TX_DESC_PER_OAL' undeclared here (not in a function)

Patch below makes the cause of the compile failure obvious.
(Better would be to support 16k pages but I don't have the HW or interest.)

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>


diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index c37ea43..cf68503 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -60,6 +60,8 @@
 #define TX_DESC_PER_OAL ((MAX_SKB_FRAGS - TX_DESC_PER_IOCB) + 2)
 #elif (PAGE_SHIFT == 16)	/* 64k pages */
 #define TX_DESC_PER_OAL 0
+#else
+#error QLGE Driver only supports 4k, 8k, or 64k CPU page size.
 #endif
 
 #define DB_PAGE_SIZE 4096
