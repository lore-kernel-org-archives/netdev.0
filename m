From: John Levon <levon@movementarian.org>
Subject: [PATCH] SEQ_START_TOKEN for af_netlink.c
Date: Thu, 18 Sep 2003 22:25:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918212518.GA86845@compsoc.man.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Seems this got missed in the sweep.

regards
john

diff -Naurp -X dontdiff linux-cvs/net/netlink/af_netlink.c linux-fixes/net/netlink/af_netlink.c
--- linux-cvs/net/netlink/af_netlink.c	2003-09-05 18:48:00.000000000 +0100
+++ linux-fixes/net/netlink/af_netlink.c	2003-09-18 22:45:19.000000000 +0100
@@ -988,7 +988,7 @@ static struct sock *netlink_seq_socket_i
 static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&nl_table_lock);
-	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : (void *) 1;
+	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -997,7 +997,7 @@ static void *netlink_seq_next(struct seq
 
 	++*pos;
 
-	if (v == (void *) 1) 
+	if (v == SEQ_START_TOKEN)
 		return netlink_seq_socket_idx(seq, 0);
 		
 	s = sk_next(v);
@@ -1023,7 +1023,7 @@ static void netlink_seq_stop(struct seq_
 
 static int netlink_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == (void *)1) 
+	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
 			 "sk       Eth Pid    Groups   "
 			 "Rmem     Wmem     Dump     Locks\n");
