From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: fix sparse checker warnings
Date: Sat, 26 Jun 2004 19:04:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406262304.i5QN4eQN009653@ginger.cmf.nrl.navy.mil>
References: <cw@f00f.org>
Cc: Chris Wedgwood <cw@f00f.org>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: Message from Chris Wedgwood <cw@f00f.org>
   of "Sat, 26 Jun 2004 15:52:30 PDT." <20040626225230.GA12698@taniwha.stupidest.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040626225230.GA12698@taniwha.stupidest.org>,Chris Wedgwood writes
:
>forwarding mangled the patch

a bit of brillant work on my part.  here it is again but undamaged.

[PATCH][ATM]: fix sparse checker warnings (by Stephen Hemminger <shemminger@osdl.org>)

diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	2004-06-22 14:04:02 -07:00
+++ b/net/atm/br2684.c	2004-06-22 14:04:02 -07:00
@@ -562,7 +562,7 @@
 	atmvcc->push = br2684_push;
 	skb_queue_head_init(&copy);
 	skb_migrate(&atmvcc->sk->sk_receive_queue, &copy);
-	while ((skb = skb_dequeue(&copy))) {
+	while ((skb = skb_dequeue(&copy)) != NULL) {
 		BRPRIV(skb->dev)->stats.rx_bytes -= skb->len;
 		BRPRIV(skb->dev)->stats.rx_packets--;
 		br2684_push(atmvcc, skb);
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2004-06-22 14:04:02 -07:00
+++ b/net/atm/clip.c	2004-06-22 14:04:02 -07:00
@@ -503,7 +503,7 @@
 	skb_queue_head_init(&copy);
 	skb_migrate(&vcc->sk->sk_receive_queue, &copy);
 	/* re-process everything received between connection setup and MKIP */
-	while ((skb = skb_dequeue(&copy)))
+	while ((skb = skb_dequeue(&copy)) != NULL)
 		if (!clip_devs) {
 			atm_return(vcc,skb->truesize);
 			kfree_skb(skb);
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2004-06-22 14:04:02 -07:00
+++ b/net/atm/common.c	2004-06-22 14:04:02 -07:00
@@ -187,7 +187,7 @@
 
 		vcc_remove_socket(sk);	/* no more receive */
 
-		while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue))) {
+		while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue)) != NULL) {
 			atm_return(vcc,skb->truesize);
 			kfree_skb(skb);
 		}
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	2004-06-22 14:04:02 -07:00
+++ b/net/atm/lec.c	2004-06-22 14:04:02 -07:00
@@ -567,7 +567,7 @@
         if (skb_peek(&vcc->sk->sk_receive_queue))
 		printk("%s lec_atm_close: closing with messages pending\n",
                        dev->name);
-        while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue))) {
+        while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue)) != NULL) {
                 atm_return(vcc, skb->truesize);
 		dev_kfree_skb(skb);
         }
@@ -1940,7 +1940,7 @@
                                            priv->path_switching_delay)) {
 			                        struct sk_buff *skb;
 
- 				                while ((skb = skb_dequeue(&entry->tx_wait)))
+ 				                while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
 					                lec_send(entry->vcc, skb, entry->priv);
                                                 entry->last_used = jiffies;
                                                 entry->status = 
@@ -2337,7 +2337,7 @@
                             entry->status == ESI_FLUSH_PENDING) {
 			        struct sk_buff *skb;
 
- 				while ((skb = skb_dequeue(&entry->tx_wait)))
+ 				while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
 					lec_send(entry->vcc, skb, entry->priv);
                                 entry->status = ESI_FORWARD_DIRECT;
                                 DPRINTK("LEC_ARP: Flushed\n");
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	2004-06-22 14:04:02 -07:00
+++ b/net/atm/svc.c	2004-06-22 14:04:02 -07:00
@@ -66,7 +66,7 @@
 	}
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
-	while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue))) {
+	while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue)) != NULL) {
 		DPRINTK("LISTEN REL\n");
 		sigd_enq2(NULL,as_reject,vcc,NULL,NULL,&vcc->qos,0);
 		dev_kfree_skb(skb);
