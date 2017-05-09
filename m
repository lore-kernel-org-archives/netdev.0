From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/4] net: stmmac: Combine three seq_printf() calls into a
 seq_puts() in stmmac_sysfs_dma_cap_read()
Date: Tue, 9 May 2017 13:52:54 +0200
Message-ID: <22603603-758e-ed97-6d39-0af8c2ce9cd6@users.sourceforge.net>
References: <aa58027a-a39c-963e-4376-a4d5312ee118@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <aa58027a-a39c-963e-4376-a4d5312ee118@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 9 May 2017 13:10:28 +0200

A bit of text was put into a sequence by three separate function calls.
Print the same data by a single function call instead.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index cd8c60132390..2949c9fc18fa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3802,10 +3802,10 @@ static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
 		return 0;
 	}
 
-	seq_printf(seq, "==============================\n");
-	seq_printf(seq, "\tDMA HW features\n");
-	seq_printf(seq, "==============================\n");
-
+	seq_puts(seq,
+		 "==============================\n"
+		 "\tDMA HW features\n"
+		 "==============================\n");
 	seq_printf(seq, "\t10/100 Mbps: %s\n",
 		   (priv->dma_cap.mbps_10_100) ? "Y" : "N");
 	seq_printf(seq, "\t1000 Mbps: %s\n",
-- 
2.12.2
