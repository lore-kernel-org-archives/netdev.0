From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 5/6] sctp: merge the seq_start/next/exits in remaddrs and assocs
Date: Thu, 14 Apr 2016 15:35:34 +0800
Message-ID: <68aad242e3999a51e2c742bc3672ffb9bd5fc292.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
 <cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com>
 <d3fc80db41935f6b22d9fffc5854de63fb842899.1460618169.git.lucien.xin@gmail.com>
 <c771f8320e007cd5d1801a820f0cca8f7ed7235c.1460618169.git.lucien.xin@gmail.com>
 <c48759e983ae5f9cefdd1805025abb7f57299886.1460618169.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35111 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcDNHgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 03:36:03 -0400
In-Reply-To: <c48759e983ae5f9cefdd1805025abb7f57299886.1460618169.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp proc, these three functions in remaddrs and assocs are the
same. we should merge them into one.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/proc.c | 45 +++++++++------------------------------------
 1 file changed, 9 insertions(+), 36 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index dd8492f..9fe1393 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -282,7 +282,7 @@ struct sctp_ht_iter {
 	struct rhashtable_iter hti;
 };
 
-static void *sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
+static void *sctp_transport_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct sctp_ht_iter *iter = seq->private;
 	int err = sctp_transport_walk_start(&iter->hti);
@@ -293,14 +293,14 @@ static void *sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
 	return sctp_transport_get_idx(seq_file_net(seq), &iter->hti, *pos);
 }
 
-static void sctp_assocs_seq_stop(struct seq_file *seq, void *v)
+static void sctp_transport_seq_stop(struct seq_file *seq, void *v)
 {
 	struct sctp_ht_iter *iter = seq->private;
 
 	sctp_transport_walk_stop(&iter->hti);
 }
 
-static void *sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *sctp_transport_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sctp_ht_iter *iter = seq->private;
 
@@ -367,9 +367,9 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 }
 
 static const struct seq_operations sctp_assoc_ops = {
-	.start = sctp_assocs_seq_start,
-	.next  = sctp_assocs_seq_next,
-	.stop  = sctp_assocs_seq_stop,
+	.start = sctp_transport_seq_start,
+	.next  = sctp_transport_seq_next,
+	.stop  = sctp_transport_seq_stop,
 	.show  = sctp_assocs_seq_show,
 };
 
@@ -406,33 +406,6 @@ void sctp_assocs_proc_exit(struct net *net)
 	remove_proc_entry("assocs", net->sctp.proc_net_sctp);
 }
 
-static void *sctp_remaddr_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	struct sctp_ht_iter *iter = seq->private;
-	int err = sctp_transport_walk_start(&iter->hti);
-
-	if (err)
-		return ERR_PTR(err);
-
-	return sctp_transport_get_idx(seq_file_net(seq), &iter->hti, *pos);
-}
-
-static void *sctp_remaddr_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct sctp_ht_iter *iter = seq->private;
-
-	++*pos;
-
-	return sctp_transport_get_next(seq_file_net(seq), &iter->hti);
-}
-
-static void sctp_remaddr_seq_stop(struct seq_file *seq, void *v)
-{
-	struct sctp_ht_iter *iter = seq->private;
-
-	sctp_transport_walk_stop(&iter->hti);
-}
-
 static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 {
 	struct sctp_association *assoc;
@@ -506,9 +479,9 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 }
 
 static const struct seq_operations sctp_remaddr_ops = {
-	.start = sctp_remaddr_seq_start,
-	.next  = sctp_remaddr_seq_next,
-	.stop  = sctp_remaddr_seq_stop,
+	.start = sctp_transport_seq_start,
+	.next  = sctp_transport_seq_next,
+	.stop  = sctp_transport_seq_stop,
 	.show  = sctp_remaddr_seq_show,
 };
 
-- 
2.1.0
