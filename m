From: Dave Jones <davej@redhat.com>
Subject: Too late check in af_packet.c
Date: Fri, 3 Sep 2004 21:52:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903205206.GT26419@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Using the automated source checker at coverity.com, they picked up
on some code in packet_release() where a NULL check was done
after dereferencing.  Patch below.

Signed-off-by: Dave Jones <davej@redhat.com>

		Dave

--- linux-2.6.8/net/packet/af_packet.c~	2004-09-03 21:48:14.653433072 +0100
+++ linux-2.6.8/net/packet/af_packet.c	2004-09-03 21:49:23.652943552 +0100
@@ -785,11 +785,13 @@
 static int packet_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_opt *po;
 
 	if (!sk)
 		return 0;
 
+	po = pkt_sk(sk);
+
 	write_lock_bh(&packet_sklist_lock);
 	sk_del_node_init(sk);
 	write_unlock_bh(&packet_sklist_lock);
