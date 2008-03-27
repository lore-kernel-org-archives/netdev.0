From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/6 net-2.6.26] [UDP]: Replace struct net on udp_iter_state with seq_net_private.
Date: Thu, 27 Mar 2008 17:11:33 +0300
Message-ID: <1206627098-2456-1-git-send-email-den@openvz.org>
References: <1206627041.2109.15.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:41688 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755704AbYC0OLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:11:09 -0400
In-Reply-To: <1206627041.2109.15.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/udp.h |    2 +-
 net/ipv4/udp.c    |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 635940d..77af7d4 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -194,7 +194,7 @@ struct udp_seq_afinfo {
 };
 
 struct udp_iter_state {
-	struct net              *net;
+	struct seq_net_private  p;
 	sa_family_t		family;
 	struct hlist_head	*hashtable;
 	int			bucket;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 80007c7..6d740ad 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1506,7 +1506,7 @@ static struct sock *udp_get_first(struct seq_file *seq)
 {
 	struct sock *sk;
 	struct udp_iter_state *state = seq->private;
-	struct net *net = state->net;
+	struct net *net = seq_file_net(seq);
 
 	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
 		struct hlist_node *node;
@@ -1525,7 +1525,7 @@ found:
 static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 {
 	struct udp_iter_state *state = seq->private;
-	struct net *net = state->net;
+	struct net *net = seq_file_net(seq);
 
 	do {
 		sk = sk_next(sk);
@@ -1598,7 +1598,7 @@ static int udp_seq_open(struct inode *inode, struct file *file)
 	s->seq_ops.next		= udp_seq_next;
 	s->seq_ops.show		= afinfo->seq_show;
 	s->seq_ops.stop		= udp_seq_stop;
-	s->net                  = net;
+	s->p.net                = net;
 
 	rc = seq_open(file, &s->seq_ops);
 	if (rc)
@@ -1620,7 +1620,7 @@ static int udp_seq_release(struct inode *inode, struct file *file)
 	struct seq_file *seq = file->private_data;
 	struct udp_iter_state *s = seq->private;
 
-	put_net(s->net);
+	put_net(s->p.net);
 	seq_release_private(inode, file);
 	return 0;
 }
-- 
1.5.3.rc5

