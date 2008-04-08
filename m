From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [TCP]: Remove owner from tcp_seq_afinfo.
Date: Tue,  8 Apr 2008 17:29:52 +0400
Message-ID: <1207661392-13570-6-git-send-email-den@openvz.org>
References: <1207661318.7171.22.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32645 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017AbYDHN3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 09:29:33 -0400
In-Reply-To: <1207661318.7171.22.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move it to tcp_seq_afinfo->seq_fops as should be.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/tcp.h   |    1 -
 net/ipv4/tcp_ipv4.c |    5 +++--
 net/ipv6/tcp_ipv6.c |    4 +++-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 23915f3..2b273c0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1321,7 +1321,6 @@ enum tcp_seq_states {
 };
 
 struct tcp_seq_afinfo {
-	struct module		*owner;
 	char			*name;
 	sa_family_t		family;
 	struct file_operations	seq_fops;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ebef394..5d11d25 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2233,7 +2233,6 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 	int rc = 0;
 	struct proc_dir_entry *p;
 
-	afinfo->seq_fops.owner		= afinfo->owner;
 	afinfo->seq_fops.open		= tcp_seq_open;
 	afinfo->seq_fops.read		= seq_read;
 	afinfo->seq_fops.llseek		= seq_lseek;
@@ -2383,9 +2382,11 @@ out:
 }
 
 static struct tcp_seq_afinfo tcp4_seq_afinfo = {
-	.owner		= THIS_MODULE,
 	.name		= "tcp",
 	.family		= AF_INET,
+	.seq_fops	= {
+		.owner		= THIS_MODULE,
+	},
 	.seq_ops	= {
 		.show		= tcp4_seq_show,
 	},
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 15c7044..9044e50 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2122,9 +2122,11 @@ out:
 }
 
 static struct tcp_seq_afinfo tcp6_seq_afinfo = {
-	.owner		= THIS_MODULE,
 	.name		= "tcp6",
 	.family		= AF_INET6,
+	.seq_fops	= {
+		.owner		= THIS_MODULE,
+	},
 	.seq_ops	= {
 		.show		= tcp6_seq_show,
 	},
-- 
1.5.3.rc5

