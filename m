From: Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH] irda: Fix likely typo in output format string
Date: Fri, 26 Aug 2016 23:14:06 -0400
Message-ID: <1472267646-810675-1-git-send-email-green@linuxhacker.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

%ul would print an unsigned with a letter l at the end which does
not seem to be desired here, on the other hand the value being printed
is u32 so just drop the l instead of converting to %lu

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/net/irda/vlsi_ir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index a0849f4..98308bd 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -279,7 +279,7 @@ static void vlsi_proc_ndev(struct seq_file *seq, struct net_device *ndev)
 		(idev->mode==IFF_SIR)?"SIR":((idev->mode==IFF_MIR)?"MIR":"FIR"));
 	sec = div_s64_rem(ktime_us_delta(ktime_get(), idev->last_rx),
 			  USEC_PER_SEC, &usec);
-	seq_printf(seq, "last rx: %ul.%06u sec\n", sec, usec);
+	seq_printf(seq, "last rx: %u.%06u sec\n", sec, usec);
 
 	seq_printf(seq, "RX: packets=%lu / bytes=%lu / errors=%lu / dropped=%lu",
 		ndev->stats.rx_packets, ndev->stats.rx_bytes, ndev->stats.rx_errors,
-- 
2.7.4
