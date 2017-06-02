From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] dccp: consistently use dccp_write_space()
Date: Fri, 02 Jun 2017 08:02:26 -0700
Message-ID: <1496415746.5031.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34513 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751172AbdFBPCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 11:02:31 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so12176417pfk.1
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 08:02:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

DCCP uses dccp_write_space() for sk->sk_write_space method.

Unfortunately a passive connection (as provided by accept())
is using the generic sk_stream_write_space() function.

Lets simply inherit sk->sk_write_space from the parent
instead of forcing the generic one.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv4/inet_connection_sock.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 82dec8825d28fe01f2dc4172e3e6d4d0d70fd785..a3fa1a5b6d98eb1502ada67bf5d63b12f199c640 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -790,7 +790,6 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 		inet_sk(newsk)->inet_dport = inet_rsk(req)->ir_rmt_port;
 		inet_sk(newsk)->inet_num = inet_rsk(req)->ir_num;
 		inet_sk(newsk)->inet_sport = htons(inet_rsk(req)->ir_num);
-		newsk->sk_write_space = sk_stream_write_space;
 
 		/* listeners have SOCK_RCU_FREE, not the children */
 		sock_reset_flag(newsk, SOCK_RCU_FREE);
