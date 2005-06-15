From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [-mm PATCH][2/4] net: signed vs unsigned cleanup in net/ipv4/raw.c
Date: Wed, 15 Jun 2005 23:30:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506152239500.3842@dragon.hyggekrogen.localhost>
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

This patch gets rid of the following gcc -W warning in net/ipv4/raw.c :

net/ipv4/raw.c:387: warning: comparison of unsigned expression < 0 is always false

Since 'len' is of type size_t it is unsigned and can thus never be <0, and 
since this is obvious from the function declaration just a few lines above 
I think it's ok to remove the pointless check for len<0.


Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
---

 net/ipv4/raw.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.12-rc6-mm1/net/ipv4/raw.c.with_patch-1	2005-06-15 22:39:17.000000000 +0200
+++ linux-2.6.12-rc6-mm1/net/ipv4/raw.c	2005-06-15 22:39:36.000000000 +0200
@@ -384,7 +384,7 @@ static int raw_sendmsg(struct kiocb *ioc
 	int err;
 
 	err = -EMSGSIZE;
-	if (len < 0 || len > 0xFFFF)
+	if (len > 0xFFFF)
 		goto out;
 
 	/*
