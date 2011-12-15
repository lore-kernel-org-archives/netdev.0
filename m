From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] tcp_memcontrol: fix reversed if condition
Date: Thu, 15 Dec 2011 14:05:10 +0300
Message-ID: <20111215110510.GA2674@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:18923 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753Ab1LOLGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 06:06:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should only dereference the pointer if it's valid, not the other way
round.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 171d7b6..7fed04f 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -44,7 +44,7 @@ static inline struct tcp_memcontrol *tcp_from_cgproto(struct cg_proto *cg_proto)
 
 static void memcg_tcp_enter_memory_pressure(struct sock *sk)
 {
-	if (!sk->sk_cgrp->memory_pressure)
+	if (sk->sk_cgrp->memory_pressure)
 		*sk->sk_cgrp->memory_pressure = 1;
 }
 EXPORT_SYMBOL(memcg_tcp_enter_memory_pressure);
