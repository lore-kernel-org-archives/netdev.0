From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH] 2.4.18+ minor nit in tcp_delack_timer()
Date: Mon, 20 May 2002 13:58:21 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0205201353420.7881-100000@w-nivedita2.des.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

On the assumption that we want to save a cycle wherever
possible. Since we've just done an unconditional 
tcp_mem_reclaim(), we can save the repeat check(?)..


thanks,
Nivedita


diff -urN linux-2.4.18/net/ipv4/tcp_timer.c linux-2.4.18tmr1/net/ipv4/tcp_timer.c
--- linux-2.4.18/net/ipv4/tcp_timer.c	Mon Oct  1 09:19:57 2001
+++ linux-2.4.18tmr1/net/ipv4/tcp_timer.c	Sun May 19 11:23:40 2002
@@ -225,12 +225,12 @@
 	tcp_mem_reclaim(sk);
 
 	if (sk->state == TCP_CLOSE || !(tp->ack.pending&TCP_ACK_TIMER))
-		goto out;
+		goto out_unlock;
 
 	if ((long)(tp->ack.timeout - jiffies) > 0) {
 		if (!mod_timer(&tp->delack_timer, tp->ack.timeout))
 			sock_hold(sk);
-		goto out;
+		goto out_unlock;
 	}
 	tp->ack.pending &= ~TCP_ACK_TIMER;
 
