From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Q] LL_RESERVED_SPACE(dev) vs
 HH_DATA_ALIGN(dev->hard_header_len)
Date: Sun, 8 Feb 2004 13:03:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208130304.5df8e2c3.davem@redhat.com>
References: <20040208.203930.36073978.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040208.203930.36073978.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 08 Feb 2004 20:39:30 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Question: 
>   How do you think about the following patch?
>   Or, is it okay to simply use LL_RESERVED_SPACE(dev) in both places?

LL_RESERVED_SPACE() is what should be used in both spots.

I checked in the following patch, thanks for noticing this.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/02/08 12:58:29-08:00 davem@nuts.davemloft.net 
#   [ECONET]: Use LL_RESERVED_SPACE() where applicable.  Noticed by yoshfuji.
# 
# net/econet/af_econet.c
#   2004/02/08 12:58:13-08:00 davem@nuts.davemloft.net +2 -2
#   [ECONET]: Use LL_RESERVED_SPACE() where applicable.  Noticed by yoshfuji.
# 
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Sun Feb  8 12:59:08 2004
+++ b/net/econet/af_econet.c	Sun Feb  8 12:59:08 2004
@@ -318,12 +318,12 @@
 #ifdef CONFIG_ECONET_NATIVE
 		dev_hold(dev);
 		
-		skb = sock_alloc_send_skb(sk, len+dev->hard_header_len+15, 
+		skb = sock_alloc_send_skb(sk, len+LL_RESERVED_SPACE(dev), 
 					  msg->msg_flags & MSG_DONTWAIT, &err);
 		if (skb==NULL)
 			goto out_unlock;
 		
-		skb_reserve(skb, (dev->hard_header_len+15)&~15);
+		skb_reserve(skb, LL_RESERVED_SPACE(dev));
 		skb->nh.raw = skb->data;
 		
 		eb = (struct ec_cb *)&skb->cb;
