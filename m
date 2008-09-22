From: akpm@linux-foundation.org
Subject: [patch 6/8] drivers/net/wan: Use DIV_ROUND_UP
Date: Mon, 22 Sep 2008 14:50:42 -0700
Message-ID: <200809222150.m8MLogbY031872@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34596 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753929AbYIVV5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The kernel.h macro DIV_ROUND_UP performs the computation (((n) + (d) - 1) /
(d)) but is perhaps more readable.

An extract of the semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@haskernel@
@@

#include <linux/kernel.h>

@depends on haskernel@
expression n,d;
@@

(
- (n + d - 1) / d
+ DIV_ROUND_UP(n,d)
|
- (n + (d - 1)) / d
+ DIV_ROUND_UP(n,d)
)

@depends on haskernel@
expression n,d;
@@

- DIV_ROUND_UP((n),d)
+ DIV_ROUND_UP(n,d)

@depends on haskernel@
expression n,d;
@@

- DIV_ROUND_UP(n,(d))
+ DIV_ROUND_UP(n,d)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/sbni.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wan/sbni.c~drivers-net-wan-use-div_round_up drivers/net/wan/sbni.c
--- a/drivers/net/wan/sbni.c~drivers-net-wan-use-div_round_up
+++ a/drivers/net/wan/sbni.c
@@ -856,7 +856,7 @@ prepare_to_send( struct sk_buff  *skb,  
 		len = SBNI_MIN_LEN;
 
 	nl->tx_buf_p	= skb;
-	nl->tx_frameno	= (len + nl->maxframe - 1) / nl->maxframe;
+	nl->tx_frameno	= DIV_ROUND_UP(len, nl->maxframe);
 	nl->framelen	= len < nl->maxframe  ?  len  :  nl->maxframe;
 
 	outb( inb( dev->base_addr + CSR0 ) | TR_REQ,  dev->base_addr + CSR0 );
_
