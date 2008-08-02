From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 7/10] drivers/net/wan: Use DIV_ROUND_UP
Date: Sat, 2 Aug 2008 17:15:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808021714220.20095@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:49392 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbYHBPPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Aug 2008 11:15:07 -0400
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

---
 drivers/net/wan/sbni.c     |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -856,7 +856,7 @@ prepare_to_send( struct sk_buff  *skb,  
 		len = SBNI_MIN_LEN;
 
 	nl->tx_buf_p	= skb;
-	nl->tx_frameno	= (len + nl->maxframe - 1) / nl->maxframe;
+	nl->tx_frameno	= DIV_ROUND_UP(len, nl->maxframe);
 	nl->framelen	= len < nl->maxframe  ?  len  :  nl->maxframe;
 
 	outb( inb( dev->base_addr + CSR0 ) | TR_REQ,  dev->base_addr + CSR0 );
