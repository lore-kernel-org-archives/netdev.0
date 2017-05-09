From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] wil6210: Replace five seq_puts() calls by seq_putc()
Date: Tue, 9 May 2017 09:50:34 +0200
Message-ID: <64747f85-e373-a0ff-b6dc-70cdfe35f71a@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: wil6210@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
        Maya Erez <qca_merez@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 8 May 2017 22:22:04 +0200

Five single characters (line breaks) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ath/wil6210/debugfs.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/wil6210/debugfs.c b/drivers/net/wireless/ath/wil6210/debugfs.c
index 5648ebbd0e16..90118d286fb9 100644
--- a/drivers/net/wireless/ath/wil6210/debugfs.c
+++ b/drivers/net/wireless/ath/wil6210/debugfs.c
@@ -76,11 +76,11 @@ static void wil_print_vring(struct seq_file *s, struct wil6210_priv *wil,
 			volatile struct vring_tx_desc *d = &vring->va[i].tx;
 
 			if ((i % 128) == 0 && (i != 0))
-				seq_puts(s, "\n");
+				seq_putc(s, '\n');
 			seq_printf(s, "%c", (d->dma.status & BIT(0)) ?
 					_s : (vring->ctx[i].skb ? _h : 'h'));
 		}
-		seq_puts(s, "\n");
+		seq_putc(s, '\n');
 	}
 	seq_puts(s, "}\n");
 }
@@ -233,7 +233,7 @@ static void wil_print_ring(struct seq_file *s, const char *prefix,
 				wil_seq_hexdump(s, databuf, len, "      : ");
 			}
 		} else {
-			seq_puts(s, "\n");
+			seq_putc(s, '\n');
 		}
 	}
  out:
@@ -1366,7 +1366,7 @@ static void wil_print_rxtid_crypto(struct seq_file *s, int tid,
 		seq_printf(s, " [%i%s]%6phN", i, cc->key_set ? "+" : "-",
 			   cc->pn);
 	}
-	seq_puts(s, "\n");
+	seq_putc(s, '\n');
 }
 
 static int wil_sta_debugfs_show(struct seq_file *s, void *data)
@@ -1423,7 +1423,7 @@ __acquires(&p->tid_rx_lock) __releases(&p->tid_rx_lock)
 			     mcs++)
 				seq_printf(s, " %lld",
 					   p->stats.rx_per_mcs[mcs]);
-			seq_puts(s, "\n");
+			seq_putc(s, '\n');
 		}
 	}
 
-- 
2.12.2
