From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH] Use skb_queue_purge
Date: Wed, 16 Mar 2005 08:34:46 +0000
Message-ID: <20050316083446.GA20392@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_queue_purge exists so why not using it ;-)

Index: bk-afu/net/ax25/af_ax25.c
===================================================================
--- bk-afu.orig/net/ax25/af_ax25.c	2005-03-15 23:26:35.678081272 +0000
+++ bk-afu/net/ax25/af_ax25.c	2005-03-15 23:38:31.979186952 +0000
@@ -306,9 +306,7 @@
 
 			kfree_skb(skb);
 		}
-		while ((skb = skb_dequeue(&ax25->sk->sk_write_queue)) != NULL) {
-			kfree_skb(skb);
-		}
+		skb_queue_purge(&ax25->sk->sk_write_queue);
 	}
 
 	if (ax25->sk != NULL) {
