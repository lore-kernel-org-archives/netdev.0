From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 8/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:33:05 -0500
Message-ID: <1289147585.3090.146.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57488 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab0KGQdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:33:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp linux-2.6.37-rc1.orig/net/rxrpc/af_rxrpc.c linux-2.6.37-rc1/net/rxrpc/af_rxrpc.c
--- linux-2.6.37-rc1.orig/net/rxrpc/af_rxrpc.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/rxrpc/af_rxrpc.c	2010-11-07 10:47:34.000000000 -0500
@@ -670,7 +670,8 @@ static void rxrpc_sock_destructor(struct
 	WARN_ON(sk->sk_socket);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk("Attempt to release alive rxrpc socket: %p\n", sk);
+		printk(KERN_ERR "Attempt to release alive rxrpc socket: %lu\n",
+			sock_i_ino(sk));
 		return;
 	}
 }



