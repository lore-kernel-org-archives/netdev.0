From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 5/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:31:57 -0500
Message-ID: <1289147517.3090.142.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57433 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693Ab0KGQcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:32:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

--- linux-2.6.37-rc1.orig/net/key/af_key.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/key/af_key.c	2010-11-07 11:28:13.000000000 -0500
@@ -99,7 +99,8 @@ static void pfkey_sock_destruct(struct s
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		pr_err("Attempt to release alive pfkey socket: %p\n", sk);
+		pr_err("Attempt to release alive pfkey socket: %lu\n",
+			sock_i_ino(sk));
 		return;
 	}
 
@@ -3643,8 +3644,8 @@ static int pfkey_seq_show(struct seq_fil
 	if (v == SEQ_START_TOKEN)
 		seq_printf(f ,"sk       RefCnt Rmem   Wmem   User   Inode\n");
 	else
-		seq_printf(f ,"%p %-6d %-6u %-6u %-6u %-6lu\n",
-			       s,
+		seq_printf(f ,"%d %-6d %-6u %-6u %-6u %-6lu\n",
+			       0,
 			       atomic_read(&s->sk_refcnt),
 			       sk_rmem_alloc_get(s),
 			       sk_wmem_alloc_get(s),



