From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 2/2] l2tp: don't overwrite source address in l2tp_ip_bind()
Date: Tue, 10 Apr 2012 11:10:43 +0100
Message-ID: <1334052643-10910-3-git-send-email-jchapman@katalix.com>
References: <1334052643-10910-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53108 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941Ab2DJKLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 06:11:05 -0400
In-Reply-To: <1334052643-10910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications using L2TP/IP sockets want to be able to bind() an L2TP/IP
socket to set the local tunnel id while leaving the auto-assigned source
address alone. So if no source address is supplied, don't overwrite
the address already stored in the socket.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index b56be14..585d93e 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -271,7 +271,8 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
 		goto out;
 
-	inet->inet_rcv_saddr = inet->inet_saddr = addr->l2tp_addr.s_addr;
+	if (addr->l2tp_addr.s_addr)
+		inet->inet_rcv_saddr = inet->inet_saddr = addr->l2tp_addr.s_addr;
 	if (chk_addr_ret == RTN_MULTICAST || chk_addr_ret == RTN_BROADCAST)
 		inet->inet_saddr = 0;  /* Use device */
 	sk_dst_reset(sk);
-- 
1.7.0.4
