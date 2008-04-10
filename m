From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.26] net/unix/af_unix.c - Use SEQ_START_TOKEN
Date: Thu, 10 Apr 2008 14:43:10 -0700
Message-ID: <1207863790.1020.199.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David S Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:3692 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1758039AbYDJVnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 17:43:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

 net/unix/af_unix.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 50bbf6b..2851d0d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2037,7 +2037,7 @@ static void *unix_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(unix_table_lock)
 {
 	spin_lock(&unix_table_lock);
-	return *pos ? unix_seq_idx(seq, *pos - 1) : ((void *) 1);
+	return *pos ? unix_seq_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -2046,7 +2046,7 @@ static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct sock *sk = v;
 	++*pos;
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		sk = first_unix_socket(&iter->i);
 	else
 		sk = next_unix_socket(&iter->i, sk);
@@ -2064,7 +2064,7 @@ static void unix_seq_stop(struct seq_file *seq, void *v)
 static int unix_seq_show(struct seq_file *seq, void *v)
 {
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "Num       RefCount Protocol Flags    Type St "
 			 "Inode Path\n");
 	else {


