From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: avoid to double release dst in tcp_v4_connect
Date: Thu, 17 Nov 2011 16:33:48 +0800
Message-ID: <1321518828-4288-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56558 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab1KQIdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:33:54 -0500
Received: by iage36 with SMTP id e36so1788993iag.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 00:33:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com> 

When tcp_connect failed in tcp_v4_connect, the dst will be
released in error handler of tcp_v4_connect, but dst has been
set to sk->sk_dst_cache which will be released again when
destroy this sk.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a744315..adc2992 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -263,8 +263,10 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	err = tcp_connect(sk);
 	rt = NULL;
-	if (err)
+	if (err) {
+		sk->sk_dst_cache = NULL;
 		goto failure;
+	}
 
 	return 0;
 
-- 
1.7.1
