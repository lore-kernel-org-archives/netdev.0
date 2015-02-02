From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/8] cxgb4: Add support to display TP module tcp stats in debugfs
Date: Mon,  2 Feb 2015 20:23:07 +0530
Message-ID: <1422888789-12016-7-git-send-email-hariprasad@chelsio.com>
References: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25655 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751955AbbBBOrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 09:47:51 -0500
In-Reply-To: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   28 ++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 5341a00..904f36d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1244,6 +1244,33 @@ static int lb_stats_show(struct seq_file *seq, void *v)
 
 DEFINE_SIMPLE_DEBUGFS_FILE(lb_stats);
 
+static int tp_tcp_stats_show(struct seq_file *seq, void *v)
+{
+	struct tp_tcp_stats v4, v6;
+	struct adapter *adap = seq->private;
+
+	spin_lock(&adap->stats_lock);
+	t4_tp_get_tcp_stats(adap, &v4, &v6);
+	spin_unlock(&adap->stats_lock);
+
+	seq_puts(seq,
+		 "                                IP                 IPv6\n");
+	seq_printf(seq, "OutRsts:      %20u %20u\n",
+		   v4.tcpOutRsts, v6.tcpOutRsts);
+	seq_printf(seq, "InSegs:       %20llu %20llu\n",
+		   (unsigned long long)v4.tcpInSegs,
+		   (unsigned long long)v6.tcpInSegs);
+	seq_printf(seq, "OutSegs:      %20llu %20llu\n",
+		   (unsigned long long)v4.tcpOutSegs,
+		   (unsigned long long)v6.tcpOutSegs);
+	seq_printf(seq, "RetransSegs:  %20llu %20llu\n",
+		   (unsigned long long)v4.tcpRetransSegs,
+		   (unsigned long long)v6.tcpRetransSegs);
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(tp_tcp_stats);
+
 #if IS_ENABLED(CONFIG_IPV6)
 static int clip_tbl_open(struct inode *inode, struct file *file)
 {
@@ -2024,6 +2051,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "obq_sge",  &cim_obq_fops, S_IRUSR, 4 },
 		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
 		{ "tp_la", &tp_la_fops, S_IRUSR, 0 },
+		{ "tp_tcp_stats", &tp_tcp_stats_debugfs_fops, S_IRUSR, 0 },
 		{ "ulprx_la", &ulprx_la_fops, S_IRUSR, 0 },
 		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
 		{ "lb_stats", &lb_stats_debugfs_fops, S_IRUSR, 0 },
-- 
1.7.1
