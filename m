From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] qca_debug: Reduce function calls for sequence output in
 qcaspi_info_show()
Date: Mon, 8 May 2017 19:29:12 +0200
Message-ID: <9932ee63-f766-49ce-d760-9a0bd06f0657@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 8 May 2017 19:21:27 +0200

A bit of data was put into a sequence by separate function calls.
Print the same data together with adjusted seq_printf() calls instead.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/qualcomm/qca_debug.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_debug.c b/drivers/net/ethernet/qualcomm/qca_debug.c
index d145df98feff..27b5c1dd27d0 100644
--- a/drivers/net/ethernet/qualcomm/qca_debug.c
+++ b/drivers/net/ethernet/qualcomm/qca_debug.c
@@ -81,11 +81,7 @@ qcaspi_info_show(struct seq_file *s, void *what)
 	else
 		seq_puts(s, "in use");
 
-	seq_puts(s, "\n");
-
-	seq_printf(s, "TX ring size     : %u\n",
-		   qca->txr.size);
-
+	seq_printf(s, "\nTX ring size     : %u\n", qca->txr.size);
 	seq_printf(s, "Sync state       : %u (",
 		   (unsigned int)qca->sync);
 	switch (qca->sync) {
@@ -102,10 +98,8 @@ qcaspi_info_show(struct seq_file *s, void *what)
 		seq_puts(s, "INVALID");
 		break;
 	}
-	seq_puts(s, ")\n");
 
-	seq_printf(s, "IRQ              : %d\n",
-		   qca->spi_dev->irq);
+	seq_printf(s, ")\nIRQ              : %d\n", qca->spi_dev->irq);
 	seq_printf(s, "INTR REQ         : %u\n",
 		   qca->intr_req);
 	seq_printf(s, "INTR SVC         : %u\n",
-- 
2.12.2
