From: Karoly Kemeny <karoly.kemeny@gmail.com>
Subject: [PATCH] clean up cast warning in do_ip_getsockopt
Date: Sun, 20 Jul 2014 17:03:06 +0200
Message-ID: <1405868586-15508-1-git-send-email-karoly.kemeny@gmail.com>
Cc: Karoly Kemeny <karoly.kemeny@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55359 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbaGTPEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 11:04:13 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so5329008wgh.27
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 08:04:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse warns because of implicit pointer cast.

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
+		msg.msg_control = (__force void*) optval;
 		msg.msg_controllen = len;
 		msg.msg_flags = flags;
 
-- 
1.9.1
