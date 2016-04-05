From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 6/7] sctp: merge the seq_start/next/exits in remaddrs and assocs
Date: Tue,  5 Apr 2016 12:06:31 +0800
Message-ID: <90be0ff11d9675b484c5354ba0bec95b30bf269d.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1459829123.git.lucien.xin@gmail.com>
 <c99aafbc687328f783c0777e10df3e207004db10.1459829123.git.lucien.xin@gmail.com>
 <d16e3f12f689f28d8c3b62c7c2a15916177bd7c0.1459829123.git.lucien.xin@gmail.com>
 <123695bf6a49412e15b79049d088903a36538c53.1459829123.git.lucien.xin@gmail.com>
 <cdc77cc7b894aab62dad372f0018c571e33cf16e.1459829123.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36720 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbcDEEHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:07:12 -0400
In-Reply-To: <cdc77cc7b894aab62dad372f0018c571e33cf16e.1459829123.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
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
