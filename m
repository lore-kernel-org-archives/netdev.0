From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [-mm PATCH][1/4] net: signed vs unsigned cleanup in net/ipv4/raw.c
Date: Wed, 15 Jun 2005 23:30:06 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506152202560.3842@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>, Ross Biro <ross.biro@gmail.com>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch silences these two gcc -W warnings in net/ipv4/raw.c :

net/ipv4/raw.c:517: warning: signed and unsigned type in conditional expression
net/ipv4/raw.c:613: warning: signed and unsigned type in conditional expression

It doesn't change the behaviour of the code, simply writes the conditional 
expression with plain 'if()' syntax instead of '? :' , but since this 
breaks it into sepperate statements gcc no longer complains about having 
both a signed and unsigned value in the same conditional expression.

--- linux-2.6.12-rc6-mm1-orig/net/ipv4/raw.c	2005-06-12 15:58:58.000000000 +0200
+++ linux-2.6.12-rc6-mm1/net/ipv4/raw.c	2005-06-15 22:22:44.000000000 +0200
@@ -514,7 +514,10 @@ done:
 		kfree(ipc.opt);
 	ip_rt_put(rt);
 
-out:	return err < 0 ? err : len;
+out:
+	if (err < 0)
+		return err;
+	return len;
 
 do_confirm:
 	dst_confirm(&rt->u.dst);
@@ -610,7 +613,10 @@ static int raw_recvmsg(struct kiocb *ioc
 		copied = skb->len;
 done:
 	skb_free_datagram(sk, skb);
-out:	return err ? err : copied;
+out:
+	if (err)
+		return err;
+	return copied;
 }
 
 static int raw_init(struct sock *sk)
