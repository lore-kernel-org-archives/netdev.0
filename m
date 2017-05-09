From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/4] net: stmmac: Replace five seq_printf() calls by
 seq_puts()
Date: Tue, 9 May 2017 13:53:52 +0200
Message-ID: <aaddd3eb-0659-3aed-7e42-5fae0f823ea3@users.sourceforge.net>
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
Date: Tue, 9 May 2017 13:20:03 +0200

Five strings which did not contain data format specifications should be put
into a sequence. Thus use the corresponding function "seq_puts".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 2949c9fc18fa..1f7022ce78b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3748,11 +3748,11 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 		seq_printf(seq, "RX Queue %d:\n", queue);
 
 		if (priv->extend_desc) {
-			seq_printf(seq, "Extended descriptor ring:\n");
+			seq_puts(seq, "Extended descriptor ring:\n");
 			sysfs_display_ring((void *)rx_q->dma_erx,
 					   DMA_RX_SIZE, 1, seq);
 		} else {
-			seq_printf(seq, "Descriptor ring:\n");
+			seq_puts(seq, "Descriptor ring:\n");
 			sysfs_display_ring((void *)rx_q->dma_rx,
 					   DMA_RX_SIZE, 0, seq);
 		}
@@ -3764,11 +3764,11 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 		seq_printf(seq, "TX Queue %d:\n", queue);
 
 		if (priv->extend_desc) {
-			seq_printf(seq, "Extended descriptor ring:\n");
+			seq_puts(seq, "Extended descriptor ring:\n");
 			sysfs_display_ring((void *)tx_q->dma_etx,
 					   DMA_TX_SIZE, 1, seq);
 		} else {
-			seq_printf(seq, "Descriptor ring:\n");
+			seq_puts(seq, "Descriptor ring:\n");
 			sysfs_display_ring((void *)tx_q->dma_tx,
 					   DMA_TX_SIZE, 0, seq);
 		}
@@ -3798,7 +3798,7 @@ static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	if (!priv->hw_cap_support) {
-		seq_printf(seq, "DMA HW features not supported\n");
+		seq_puts(seq, "DMA HW features not supported\n");
 		return 0;
 	}
 
-- 
2.12.2
