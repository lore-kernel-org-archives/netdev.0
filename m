From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 9/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:33:08 -0500
Message-ID: <1289147588.3090.147.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57502 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab0KGQdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:33:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp linux-2.6.37-rc1.orig/net/unix/af_unix.c linux-2.6.37-rc1/net/unix/af_unix.c
--- linux-2.6.37-rc1.orig/net/unix/af_unix.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/unix/af_unix.c	2010-11-07 10:46:27.000000000 -0500
@@ -353,7 +353,8 @@ static void unix_sock_destructor(struct 
 	WARN_ON(!sk_unhashed(sk));
 	WARN_ON(sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk(KERN_INFO "Attempt to release alive unix socket: %p\n", sk);
+		printk(KERN_INFO "Attempt to release alive unix socket: %lu\n",
+			sock_i_ino(sk));
 		return;
 	}
 
@@ -2198,8 +2199,8 @@ static int unix_seq_show(struct seq_file
 		struct unix_sock *u = unix_sk(s);
 		unix_state_lock(s);
 
-		seq_printf(seq, "%p: %08X %08X %08X %04X %02X %5lu",
-			s,
+		seq_printf(seq, "%d: %08X %08X %08X %04X %02X %5lu",
+			0,
 			atomic_read(&s->sk_refcnt),
 			0,
 			s->sk_state == TCP_LISTEN ? __SO_ACCEPTCON : 0,



