From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] get_stats: collapse conditionals
Date: Sat, 24 Jan 2004 22:19:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124221928.16f4c708.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.current.

Thanks,
--
~Randy


From: Domen Puncer <domen@coderock.org>



Hi.

Get rid of one comparison, improve readability.

diff -puN net/core/dev.c~netdev_get_stats net/core/dev.c


 linux-262-rc1-bk1-rddunlap/net/core/dev.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff -puN net/core/dev.c~netdev_get_stats net/core/dev.c
--- linux-262-rc1-bk1/net/core/dev.c~netdev_get_stats	2004-01-23 15:52:33.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/core/dev.c	2004-01-23 15:52:33.000000000 -0800
@@ -1940,9 +1940,9 @@ void dev_seq_stop(struct seq_file *seq, 
 
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 {
-	struct net_device_stats *stats = dev->get_stats ? dev->get_stats(dev) :
-							  NULL;
-	if (stats)
+	if (dev->get_stats) {
+		struct net_device_stats *stats = dev->get_stats(dev);
+
 		seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
 				"%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
 			   dev->name, stats->rx_bytes, stats->rx_packets,
@@ -1960,6 +1960,7 @@ static void dev_seq_printf_stats(struct 
 			     stats->tx_window_errors +
 			     stats->tx_heartbeat_errors,
 			   stats->tx_compressed);
+	}
 	else
 		seq_printf(seq, "%6s: No statistics available.\n", dev->name);
 }

_
