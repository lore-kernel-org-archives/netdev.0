From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [net-next PATCH] net: Make it easier to parse /proc/net/dev contents.
Date: Tue, 05 Jan 2010 16:50:52 +0100
Message-ID: <20100105155052.13309.1197.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49657 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab0AEQXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 11:23:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The contents of /proc/net/dev is annoying to parse, because
it changes whether there is a space after the "ethX:" or not.
It depends upon the size of the "Receive bytes" counter,
if the number is below 7 digits, then there is whitespaces
else if the number is 8 digits or above there is no space
between the ":" and the number.

This patch changes the output to assure there is always a space
between the ":" and the number.  Given that all existing userspace
application already need to handle the whitespaces, I see
no breakage of existing tools.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f9aa699..3a86252 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3207,7 +3207,7 @@ static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 {
 	const struct net_device_stats *stats = dev_get_stats(dev);
 
-	seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
+	seq_printf(seq, "%6s: %7lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
 		   "%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
 		   dev->name, stats->rx_bytes, stats->rx_packets,
 		   stats->rx_errors,

