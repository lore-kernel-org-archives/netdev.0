From: Masatake YAMATO <yamato@redhat.com>
Subject: Adding inode field to /proc/net/netlink
Date: Sun, 28 Feb 2010 14:45:37 +0900 (JST)
Message-ID: <20100228.144537.445518512048328806.yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280Ab0B1FkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 00:40:17 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1S5eGTx032014
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 00:40:16 -0500
Received: from localhost (beach.nrt.redhat.com [10.64.200.71])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o1S5eEtY006878
	for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 00:40:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Inode field in /proc/net/{tcp,udp,packet,raw,...} is useful to know the types of 
file descriptors associated to a process. Actually lsof utility uses the field.
Unfortunately, unlike /proc/net/{tcp,udp,packet,raw,...}, /proc/net/netlink doesn't have the field.
This patch adds the field to /proc/net/netlink.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4c5972b..320d042 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1978,12 +1978,12 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
 			 "sk       Eth Pid    Groups   "
-			 "Rmem     Wmem     Dump     Locks     Drops\n");
+			 "Rmem     Wmem     Dump     Locks     Drops     Inode\n");
 	else {
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %-8d %-8d\n",
+		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %-8d %-8d %-8lu\n",
 			   s,
 			   s->sk_protocol,
 			   nlk->pid,
@@ -1992,7 +1992,8 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 			   sk_wmem_alloc_get(s),
 			   nlk->cb,
 			   atomic_read(&s->sk_refcnt),
-			   atomic_read(&s->sk_drops)
+			   atomic_read(&s->sk_drops),
+			   sock_i_ino(s)
 			);
 
 	}
