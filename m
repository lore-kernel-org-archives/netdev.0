From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/6] cxgb4: Replace seven seq_puts() calls by seq_putc()
Date: Thu, 4 May 2017 22:34:14 +0200
Message-ID: <d5af6439-f6a7-7bdb-a660-9ca3dd267875@users.sourceforge.net>
References: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 May 2017 21:40:54 +0200

Seven single characters (line breaks) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 24 +++++++---------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 1fa34b009891..2bc40d89f874 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -278,7 +278,7 @@ static int cim_ma_la_show(struct seq_file *seq, void *v, int idx)
 	const u32 *p = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_puts(seq, "\n");
+		seq_putc(seq, '\n');
 	} else if (idx < CIM_MALA_SIZE) {
 		seq_printf(seq, "%02x%08x%08x%08x%08x\n",
 			   p[4], p[3], p[2], p[1], p[0]);
@@ -1196,7 +1196,7 @@ static int mboxlog_show(struct seq_file *seq, void *v)
 
 		seq_printf(seq, "  %08x %08x", hi, lo);
 	}
-	seq_puts(seq, "\n");
+	seq_putc(seq, '\n');
 	return 0;
 }
 
@@ -2112,9 +2112,7 @@ static int rss_config_show(struct seq_file *seq, void *v)
 							HASHTOEPLITZ_F));
 	seq_printf(seq, "  Udp4En:        %3s\n", yesno(rssconf & UDPENABLE_F));
 	seq_printf(seq, "  Disable:       %3s\n", yesno(rssconf & DISABLE_F));
-
-	seq_puts(seq, "\n");
-
+	seq_putc(seq, '\n');
 	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_TNL_A);
 	seq_printf(seq, "TP_RSS_CONFIG_TNL: %#x\n", rssconf);
 	seq_printf(seq, "  MaskSize:      %3d\n", MASKSIZE_G(rssconf));
@@ -2126,25 +2124,19 @@ static int rss_config_show(struct seq_file *seq, void *v)
 			   yesno(rssconf & HASHETH_F));
 	}
 	seq_printf(seq, "  UseWireCh:     %3s\n", yesno(rssconf & USEWIRECH_F));
-
-	seq_puts(seq, "\n");
-
+	seq_putc(seq, '\n');
 	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_OFD_A);
 	seq_printf(seq, "TP_RSS_CONFIG_OFD: %#x\n", rssconf);
 	seq_printf(seq, "  MaskSize:      %3d\n", MASKSIZE_G(rssconf));
 	seq_printf(seq, "  RRCplMapEn:    %3s\n", yesno(rssconf &
 							RRCPLMAPEN_F));
 	seq_printf(seq, "  RRCplQueWidth: %3d\n", RRCPLQUEWIDTH_G(rssconf));
-
-	seq_puts(seq, "\n");
-
+	seq_putc(seq, '\n');
 	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_SYN_A);
 	seq_printf(seq, "TP_RSS_CONFIG_SYN: %#x\n", rssconf);
 	seq_printf(seq, "  MaskSize:      %3d\n", MASKSIZE_G(rssconf));
 	seq_printf(seq, "  UseWireCh:     %3s\n", yesno(rssconf & USEWIRECH_F));
-
-	seq_puts(seq, "\n");
-
+	seq_putc(seq, '\n');
 	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_VRT_A);
 	seq_printf(seq, "TP_RSS_CONFIG_VRT: %#x\n", rssconf);
 	if (CHELSIO_CHIP_VERSION(adapter->params.chip) > CHELSIO_T5) {
@@ -2170,9 +2162,7 @@ static int rss_config_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "  VfWrEn:        %3s\n", yesno(rssconf & VFWREN_F));
 	seq_printf(seq, "  KeyWrEn:       %3s\n", yesno(rssconf & KEYWREN_F));
 	seq_printf(seq, "  KeyWrAddr:     %3d\n", KEYWRADDR_G(rssconf));
-
-	seq_puts(seq, "\n");
-
+	seq_putc(seq, '\n');
 	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_CNG_A);
 	seq_printf(seq, "TP_RSS_CONFIG_CNG: %#x\n", rssconf);
 	seq_printf(seq, "  ChnCount3:     %3s\n", yesno(rssconf & CHNCOUNT3_F));
-- 
2.12.2
