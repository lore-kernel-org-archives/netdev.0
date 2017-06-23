From: Ivan Delalande <colona@arista.com>
Subject: [PATCH 1/2] tcp: add mode parameter to tcp_proc_register
Date: Thu, 22 Jun 2017 18:40:27 -0700
Message-ID: <20170623014028.28257-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will be used to create a proc file that regular users cannot read.

Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/net/tcp.h   | 3 ++-
 net/ipv4/tcp_ipv4.c | 7 ++++---
 net/ipv6/tcp_ipv6.c | 2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 575f95cb8275..5d78f9af309e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1753,7 +1753,8 @@ struct tcp_iter_state {
 	loff_t			last_pos;
 };
 
-int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo);
+int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo,
+		      umode_t mode);
 void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo);
 
 extern struct request_sock_ops tcp_request_sock_ops;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 81d6c16aecdc..0ae3d7cd59a3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2221,7 +2221,8 @@ int tcp_seq_open(struct inode *inode, struct file *file)
 }
 EXPORT_SYMBOL(tcp_seq_open);
 
-int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
+int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo,
+		      umode_t mode)
 {
 	int rc = 0;
 	struct proc_dir_entry *p;
@@ -2230,7 +2231,7 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 	afinfo->seq_ops.next		= tcp_seq_next;
 	afinfo->seq_ops.stop		= tcp_seq_stop;
 
-	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
+	p = proc_create_data(afinfo->name, mode, net->proc_net,
 			     afinfo->seq_fops, afinfo);
 	if (!p)
 		rc = -ENOMEM;
@@ -2396,7 +2397,7 @@ static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 
 static int __net_init tcp4_proc_init_net(struct net *net)
 {
-	return tcp_proc_register(net, &tcp4_seq_afinfo);
+	return tcp_proc_register(net, &tcp4_seq_afinfo, S_IRUGO);
 }
 
 static void __net_exit tcp4_proc_exit_net(struct net *net)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ae36442786ec..d97d6627666f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1888,7 +1888,7 @@ static struct tcp_seq_afinfo tcp6_seq_afinfo = {
 
 int __net_init tcp6_proc_init(struct net *net)
 {
-	return tcp_proc_register(net, &tcp6_seq_afinfo);
+	return tcp_proc_register(net, &tcp6_seq_afinfo, S_IRUGO);
 }
 
 void tcp6_proc_exit(struct net *net)
-- 
2.13.1
