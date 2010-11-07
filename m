From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 7/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:32:59 -0500
Message-ID: <1289147579.3090.144.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57472 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862Ab0KGQdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:33:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp linux-2.6.37-rc1.orig/net/packet/af_packet.c linux-2.6.37-rc1/net/packet/af_packet.c
--- linux-2.6.37-rc1.orig/net/packet/af_packet.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/packet/af_packet.c	2010-11-07 10:32:01.000000000 -0500
@@ -324,7 +324,8 @@ static void packet_sock_destruct(struct 
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		pr_err("Attempt to release alive packet socket: %p\n", sk);
+		pr_err("Attempt to release alive packet socket: %lu\n",
+			sock_i_ino(sk));
 		return;
 	}
 
@@ -2636,8 +2637,8 @@ static int packet_seq_show(struct seq_fi
 		const struct packet_sock *po = pkt_sk(s);
 
 		seq_printf(seq,
-			   "%p %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",
-			   s,
+			   "%d %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",
+			   0,
 			   atomic_read(&s->sk_refcnt),
 			   s->sk_type,
 			   ntohs(po->num),



