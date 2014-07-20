From: Karoly Kemeny <karoly.kemeny@gmail.com>
Subject: [PATCH] clean up sparse cast warning in do_ip_getsockopt
Date: Sun, 20 Jul 2014 13:30:17 +0200
Message-ID: <20140720113017.GA8878@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jmorris@namei.org, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:44711 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbaGTLaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 07:30:30 -0400
Received: by mail-wi0-f175.google.com with SMTP id ho1so2780580wib.14
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 04:30:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a sparse warning because of the implicit pointer cast in
do_ip_getsockopt.

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
