From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] irda: vlsi_ir: use %*ph specifier
Date: Mon,  8 Sep 2014 10:38:43 +0300
Message-ID: <1410161923-24783-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23150 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752780AbaIHHjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 03:39:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of looping in the code let's use kernel extension to dump small
buffers.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/irda/vlsi_ir.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index a04af9d..78e00ad 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -323,14 +323,8 @@ static void vlsi_proc_ring(struct seq_file *seq, struct vlsi_ring *r)
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
+			seq_printf(seq, "   data: %*ph\n", min(j, 20), rd->buf);
 	}
 	for (i = 0; i < r->size; i++) {
 		rd = &r->rd[i];
-- 
2.1.0
