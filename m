From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] irda: vlsi_ir: use %*ph specifier
Date: Fri,  5 Sep 2014 17:37:20 +0300
Message-ID: <1409927840-28791-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19993 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757040AbaIEOhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 10:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of looping in the code let's use kernel extension to dump small
buffers.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/irda/vlsi_ir.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index a04af9d..0319eba 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -323,14 +323,9 @@ static void vlsi_proc_ring(struct seq_file *seq, struct vlsi_ring *r)
 		j = (unsigned) rd_get_count(rd);
 		seq_printf(seq, "current: rd = %d / status = %02x / len = %u\n",
 				h, (unsigned)rd_get_status(rd), j);
-		if (j > 0) {
-			seq_printf(seq, "   data:");
-			if (j > 20)
-				j = 20;
-			for (i = 0; i < j; i++)
-				seq_printf(seq, " %02x", (unsigned)((unsigned char *)rd->buf)[i]);
-			seq_printf(seq, "\n");
-		}
+		if (j > 0)
+			seq_printf(seq, "   data: %*ph\n", j > 20 ? 20 : j,
+				   rd->buf);
 	}
 	for (i = 0; i < r->size; i++) {
 		rd = &r->rd[i];
-- 
2.1.0
