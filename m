From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/3] ath9k: Reduce function calls for sequence output in
 read_file_dma()
Date: Tue, 9 May 2017 09:26:49 +0200
Message-ID: <2bae9fbe-a5a7-f2bb-0769-0d035738650c@users.sourceforge.net>
References: <03575993-754d-924c-9736-2a8d19e98fa5@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: ath9k-devel@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:52911 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752559AbdEIH07 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 03:26:59 -0400
In-Reply-To: <03575993-754d-924c-9736-2a8d19e98fa5@users.sourceforge.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 8 May 2017 21:55:09 +0200

Some data were put into a sequence by separate function calls.
Print the same data with two function calls less.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ath/ath9k/debug.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 2e64977a8ab6..981b38a1e352 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -427,9 +427,7 @@ static int read_file_dma(struct seq_file *file, void *data)
 		seq_printf(file, "%d: %08x ", i, val[i]);
 	}
 
-	seq_puts(file, "\n\n");
-	seq_puts(file, "Num QCU: chain_st fsp_ok fsp_st DCU: chain_st\n");
-
+	seq_puts(file, "\n\nNum QCU: chain_st fsp_ok fsp_st DCU: chain_st\n");
 	for (i = 0; i < ATH9K_NUM_QUEUES; i++, qcuOffset += 4, dcuOffset += 5) {
 		if (i == 8) {
 			qcuOffset = 0;
@@ -448,9 +446,8 @@ static int read_file_dma(struct seq_file *file, void *data)
 			   (*dcuBase & (0x1f << dcuOffset)) >> dcuOffset);
 	}
 
-	seq_puts(file, "\n");
-
-	seq_printf(file, "qcu_stitch state:   %2x    qcu_fetch state:        %2x\n",
+	seq_printf(file,
+		   "\nqcu_stitch state:   %2x    qcu_fetch state:        %2x\n",
 		   (val[3] & 0x003c0000) >> 18, (val[3] & 0x03c00000) >> 22);
 	seq_printf(file, "qcu_complete state: %2x    dcu_complete state:     %2x\n",
 		   (val[3] & 0x1c000000) >> 26, (val[6] & 0x3));
-- 
2.12.2
