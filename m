From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/11) netrom - drop buffers in write queue on close
Date: Wed, 13 Aug 2003 15:39:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813153929.3fe71b60.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Jeroen Vreeken <pe1rxq@amsat.org>

Free buffers in write queue on socket destroy

diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 11:58:59 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 11:58:59 2003
@@ -264,6 +264,9 @@
 
 		kfree_skb(skb);
 	}
+	while ((skb = skb_dequeue(&sk->sk_write_queue)) != NULL) {
+		kfree_skb(skb);
+	}
 
 	if (atomic_read(&sk->sk_wmem_alloc) ||
 	    atomic_read(&sk->sk_rmem_alloc)) {
