From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] fix skb leak in af_irda.c
Date: Sat, 1 Nov 2003 03:19:31 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101051931.GI3705@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@hpl.hp.com>,
        Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David, Jean,

	Please apply.

- Arnaldo

===== net/irda/af_irda.c 1.46 vs edited =====
--- 1.46/net/irda/af_irda.c	Sat Aug 30 23:15:30 2003
+++ edited/net/irda/af_irda.c	Sat Nov  1 03:18:02 2003
@@ -187,12 +187,12 @@
 
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
+	dev_kfree_skb(skb);
+	// Should be ??? skb_queue_tail(&sk->sk_receive_queue, skb);
+
 	sk = self->sk;
 	if (sk == NULL)
 		return;
-
-	dev_kfree_skb(skb);
-	// Should be ??? skb_queue_tail(&sk->sk_receive_queue, skb);
 
 	/* How much header space do we need to reserve */
 	self->max_header_size = max_header_size;
