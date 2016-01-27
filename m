From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net 2/4] net-procfs: show rx_unhandled counters
Date: Wed, 27 Jan 2016 15:21:36 -0500
Message-ID: <1453926098-40181-3-git-send-email-jarod@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453926098-40181-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453926098-40181-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rx_unhandled counters get output here in a column after drop with
a heading name of unh. I'm not sure if perhaps /proc/net/dev should be
considered a stable interface that shouldn't be mucked with. If so,
this can certainly be dropped, without impacting the core functionality.

CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 net/core/net-procfs.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 2bf8329..9f88f34 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -79,11 +79,12 @@ static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 	struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *stats = dev_get_stats(dev, &temp);
 
-	seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %5llu %10llu %9llu "
-		   "%8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
+	seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %4llu %5llu %10llu "
+		   "%9llu %8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
 		   dev->name, stats->rx_bytes, stats->rx_packets,
 		   stats->rx_errors,
 		   stats->rx_dropped + stats->rx_missed_errors,
+		   stats->rx_unhandled,
 		   stats->rx_fifo_errors,
 		   stats->rx_length_errors + stats->rx_over_errors +
 		    stats->rx_crc_errors + stats->rx_frame_errors,
@@ -107,9 +108,9 @@ static int dev_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "Inter-|   Receive                            "
 			      "                    |  Transmit\n"
-			      " face |bytes    packets errs drop fifo frame "
-			      "compressed multicast|bytes    packets errs "
-			      "drop fifo colls carrier compressed\n");
+			      " face |bytes    packets errs drop  unh fifo "
+			      "frame compressed multicast|bytes    packets "
+			      "errs drop fifo colls carrier compressed\n");
 	else
 		dev_seq_printf_stats(seq, v);
 	return 0;
-- 
1.8.3.1
