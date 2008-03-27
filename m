From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/6 net-2.6.26] [UDP]: Remove owner from udp_seq_afinfo.
Date: Thu, 27 Mar 2008 17:11:38 +0300
Message-ID: <1206627098-2456-6-git-send-email-den@openvz.org>
References: <1206627041.2109.15.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36434 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbYC0OLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:11:09 -0400
In-Reply-To: <1206627041.2109.15.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move it to udp_seq_afinfo->seq_fops as should be.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/udp.h  |    1 -
 net/ipv4/udp.c     |    5 +++--
 net/ipv4/udplite.c |    4 +++-
 net/ipv6/udp.c     |    4 +++-
 net/ipv6/udplite.c |    4 +++-
 5 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 5cf0e59..24a41fa 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -185,7 +185,6 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 
 /* /proc */
 struct udp_seq_afinfo {
-	struct module		*owner;
 	char			*name;
 	sa_family_t		family;
 	struct hlist_head	*hashtable;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3f5ad77..954bd6d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1599,7 +1599,6 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 	struct proc_dir_entry *p;
 	int rc = 0;
 
-	afinfo->seq_fops.owner		= afinfo->owner;
 	afinfo->seq_fops.open		= udp_seq_open;
 	afinfo->seq_fops.read		= seq_read;
 	afinfo->seq_fops.llseek		= seq_lseek;
@@ -1659,10 +1658,12 @@ int udp4_seq_show(struct seq_file *seq, void *v)
 
 /* ------------------------------------------------------------------------ */
 static struct udp_seq_afinfo udp4_seq_afinfo = {
-	.owner		= THIS_MODULE,
 	.name		= "udp",
 	.family		= AF_INET,
 	.hashtable	= udp_hash,
+	.seq_fops	= {
+		.owner	=	THIS_MODULE,
+	},
 	.seq_ops	= {
 		.show		= udp4_seq_show,
 	},
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index f73bb17..1a4f2d4 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -75,10 +75,12 @@ static struct inet_protosw udplite4_protosw = {
 
 #ifdef CONFIG_PROC_FS
 static struct udp_seq_afinfo udplite4_seq_afinfo = {
-	.owner		= THIS_MODULE,
 	.name		= "udplite",
 	.family		= AF_INET,
 	.hashtable	= udplite_hash,
+	.seq_fops	= {
+		.owner	=	THIS_MODULE,
+	},
 	.seq_ops	= {
 		.show		= udp4_seq_show,
 	},
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 475f2aa..5279bb2 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -978,10 +978,12 @@ int udp6_seq_show(struct seq_file *seq, void *v)
 }
 
 static struct udp_seq_afinfo udp6_seq_afinfo = {
-	.owner		= THIS_MODULE,
 	.name		= "udp6",
 	.family		= AF_INET6,
 	.hashtable	= udp_hash,
+	.seq_fops	= {
+		.owner	=	THIS_MODULE,
+	},
 	.seq_ops	= {
 		.show		= udp6_seq_show,
 	},
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 5a9e646..2fd1334 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -100,10 +100,12 @@ void udplitev6_exit(void)
 
 #ifdef CONFIG_PROC_FS
 static struct udp_seq_afinfo udplite6_seq_afinfo = {
-	.owner		= THIS_MODULE,
 	.name		= "udplite6",
 	.family		= AF_INET6,
 	.hashtable	= udplite_hash,
+	.seq_fops	= {
+		.owner	=	THIS_MODULE,
+	},
 	.seq_ops	= {
 		.show		= udp6_seq_show,
 	},
-- 
1.5.3.rc5

