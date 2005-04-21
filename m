From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] Add missing newline for skb_*_panic
Date: Fri, 22 Apr 2005 00:11:51 +0200
Message-ID: <42682527.3000709@trash.net>
References: <20050421050815.GA23133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010406000205090409080507"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050421050815.GA23133@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010406000205090409080507
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Here is a trivial patch to make the skb_under_panic/skb_over_panic
> messages to look nicer.  As it is their printk is joined onto the
> first line of the BUG output because of a missing newline.

How about this one instead? Besides the missing newlines, it adds
head/data/tail/end to the output, which can give valuable hints
about what happend before.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------010406000205090409080507
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/core/skbuff.c 1.44 vs edited =====
--- 1.44/net/core/skbuff.c	2005-03-11 21:32:26 +01:00
+++ edited/net/core/skbuff.c	2005-04-22 00:08:09 +02:00
@@ -86,8 +86,10 @@
  */
 void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_INFO "skput:over: %p:%d put:%d dev:%s",
-		here, skb->len, sz, skb->dev ? skb->dev->name : "<NULL>");
+	printk(KERN_INFO "skb_over_panic: text:%p len:%d put:%d head:%p "
+	                 "data:%p tail:%p end:%p dev:%s\n",
+	       here, skb->len, sz, skb->head, skb->data, skb->tail, skb->end,
+	       skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
 
@@ -102,8 +104,10 @@
 
 void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_INFO "skput:under: %p:%d put:%d dev:%s",
-               here, skb->len, sz, skb->dev ? skb->dev->name : "<NULL>");
+	printk(KERN_INFO "skb_under_panic: text:%p len:%d put:%d head:%p "
+	                 "data:%p tail:%p end:%p dev:%s\n",
+	       here, skb->len, sz, skb->head, skb->data, skb->tail, skb->end,
+	       skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
 

--------------010406000205090409080507--
