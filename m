From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3] irda: vlsi_ir: use %*ph specifier
Date: Tue,  9 Sep 2014 11:48:29 +0300
Message-ID: <1410252509-26242-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: netdev@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56583 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932223AbaIIIsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 04:48:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of looping in the code let's use kernel extension to dump small
buffers.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/irda/vlsi_ir.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index a04af9d..a2e5561 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -324,12 +324,8 @@ static void vlsi_proc_ring(struct seq_file *seq, struct vlsi_ring *r)
 		seq_printf(seq, "current: rd = %d / status = %02x / len = %u\n",
 				h, (unsigned)rd_get_status(rd), j);
 		if (j > 0) {
-			seq_printf(seq, "   data:");
-			if (j > 20)
-				j = 20;
-			for (i = 0; i < j; i++)
-				seq_printf(seq, " %02x", (unsigned)((unsigned char *)rd->buf)[i]);
-			seq_printf(seq, "\n");
+			seq_printf(seq, "   data: %*ph\n",
+				   min_t(unsigned, j, 20), rd->buf);
 		}
 	}
 	for (i = 0; i < r->size; i++) {
-- 
2.1.0
