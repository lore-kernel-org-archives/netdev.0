From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 04/11] fjes: Add debugfs entry for statistics
Date: Mon, 11 Apr 2016 14:01:50 +0200
Message-ID: <20160411120150.GC2175@nanopsycho.orion>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1460362216-15165-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37547 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcDKMBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 08:01:53 -0400
Received: by mail-wm0-f42.google.com with SMTP id n3so101310260wmn.0
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 05:01:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460362216-15165-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 11, 2016 at 10:10:16AM CEST, izumi.taku@jp.fujitsu.com wrote:
>This patch introduces debugfs entry named "statistics"
>for statistics information.
>You can get net_stats information by reading
>/sys/kernel/debug/fjes/fjes.N/statistics file.
>This is useful for debugging.
>
>Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
>---
> drivers/net/fjes/fjes_debugfs.c | 72 +++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 72 insertions(+)
>
>diff --git a/drivers/net/fjes/fjes_debugfs.c b/drivers/net/fjes/fjes_debugfs.c
>index d2fd892..b0807c2 100644
>--- a/drivers/net/fjes/fjes_debugfs.c
>+++ b/drivers/net/fjes/fjes_debugfs.c
>@@ -31,6 +31,72 @@
> 
> static struct dentry *fjes_debug_root;
> 
>+static int fjes_dbg_stats_show(struct seq_file *m, void *v)
>+{
>+	struct fjes_adapter *adapter = m->private;
>+	struct fjes_hw *hw = &adapter->hw;
>+	int max_epid = hw->max_epid;
>+	int my_epid = hw->my_epid;
>+	int epidx;
>+
>+	seq_printf(m, "%41s", " ");
>+	for (epidx = 0; epidx < max_epid; epidx++)
>+		seq_printf(m, "%10s%d",
>+			   my_epid == epidx ? "(self)EP#" : "EP#", epidx);
>+	seq_printf(m, "\n");
>+
>+#define FJES_DEBUGFS_NET_STATS_ENTRY(X) do {				\
>+	seq_printf(m, "%-41s", #X);					\
>+	for (epidx = 0; epidx < max_epid; epidx++) {			\
>+		if (epidx == my_epid)					\
>+			seq_printf(m, "          -");			\
>+		else							\
>+			seq_printf(m, " %10llu",			\
>+				   hw->ep_shm_info[epidx].net_stats.X); \
>+	}								\
>+	seq_printf(m, "\n");						\
>+} while (0)
>+
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_packets);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_packets);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_bytes);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_bytes);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_dropped);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_dropped);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(multicast);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(collisions);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_length_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_over_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_crc_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_frame_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_fifo_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_missed_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_aborted_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_carrier_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_fifo_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_heartbeat_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_window_errors);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_compressed);
>+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_compressed);

This patch is certainly wrong. You should use existing well defined
stats API to expose this and not custom debufs blob.
