From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/4] netlink: Annotate RCU locking for seq_file walker
Date: Wed, 13 Aug 2014 16:38:32 +0200
Message-ID: <2e10a91c76740d06bad47adf4e36f21e6a62fd4b.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54742 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaHMOik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 10:38:40 -0400
Received: from 77-56-195-25.dclient.hispeed.ch ([77.56.195.25] helo=lsx.localdomain)
	by bombadil.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XHZhI-00056M-4B
	for netdev@vger.kernel.org; Wed, 13 Aug 2014 14:38:40 +0000
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Silences the following sparse warnings:
net/netlink/af_netlink.c:2926:21: warning: context imbalance in 'netlink_seq_start' - wrong count at exit
net/netlink/af_netlink.c:2972:13: warning: context imbalance in 'netlink_seq_stop' - unexpected unlock

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/netlink/af_netlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2e152e5..c416725 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2921,6 +2921,7 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
 {
 	rcu_read_lock();
 	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -2970,6 +2971,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void netlink_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
 {
 	rcu_read_unlock();
 }
-- 
1.9.3
