From: Karoly Kemeny <karoly.kemeny@gmail.com>
Subject: [PATCH v2 net] ipv4: clean up cast warning in do_ip_getsockopt
Date: Sun, 27 Jul 2014 12:29:07 +0200
Message-ID: <1406456947-3226-1-git-send-email-karoly.kemeny@gmail.com>
Cc: Karoly Kemeny <karoly.kemeny@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:49706 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbaG0K33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2014 06:29:29 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so3001261wiv.17
        for <netdev@vger.kernel.org>; Sun, 27 Jul 2014 03:29:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse warns because of implicit pointer cast.

v2: subject line correction, space between "void" and "*"

Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
---
 net/ipv4/ip_sockglue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 64741b9..3e4af06 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1319,7 +1319,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		if (sk->sk_type != SOCK_STREAM)
 			return -ENOPROTOOPT;
 
-		msg.msg_control = optval;
+		msg.msg_control = (__force void *) optval;
 		msg.msg_controllen = len;
 		msg.msg_flags = flags;
 
-- 
1.9.1
