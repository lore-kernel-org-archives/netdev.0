From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH] X25 fix dead unaccepted sockets
Date: Sun, 18 Apr 2010 10:17:32 +1000
Message-ID: <1271549852.2802.37.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:48443 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755954Ab0DRARh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 20:17:37 -0400
Received: by pva18 with SMTP id 18so2415461pva.19
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 17:17:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1, An X25 program binds and listens
2, calls arrive waiting to be accepted
3, Program exits without accepting
4, Sockets time out but don't get correctly cleaned up
5, cat /proc/net/x25/socket shows the dead sockets with bad inode fields.

This line borrowed from AX25 sets the dying socket so the timers clean up later.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index cbddd0c..36e84e1 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -402,6 +402,7 @@ static void __x25_destroy_socket(struct sock *sk)
 			/*
 			 * Queue the unaccepted socket for death
 			 */
+			skb->sk->sk_state = TCP_LISTEN;
 			sock_set_flag(skb->sk, SOCK_DEAD);
 			x25_start_heartbeat(skb->sk);
 			x25_sk(skb->sk)->state = X25_STATE_0;
-- 
1.5.6.5


