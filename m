From: akpm@linux-foundation.org
Subject: [patch 06/15] ROUND_UP macro cleanup in drivers/net/ppp_generic.c
Date: Thu, 26 Apr 2007 00:27:25 -0700
Message-ID: <200704260727.l3Q7RP04023958@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	milindchoudhary@gmail.com, paulus@samba.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:55959 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933153AbXDZH2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:28:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milind Arun Choudhary <milindchoudhary@gmail.com>

ROUND_UP macro cleanup use DIV_ROUND_UP

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Acked-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ppp_generic.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -puN drivers/net/ppp_generic.c~round_up-macro-cleanup-in-drivers-net-ppp_genericc drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c~round_up-macro-cleanup-in-drivers-net-ppp_genericc
+++ a/drivers/net/ppp_generic.c
@@ -88,8 +88,6 @@ struct ppp_file {
 #define PF_TO_PPP(pf)		PF_TO_X(pf, struct ppp)
 #define PF_TO_CHANNEL(pf)	PF_TO_X(pf, struct channel)
 
-#define ROUNDUP(n, x)		(((n) + (x) - 1) / (x))
-
 /*
  * Data structure describing one ppp unit.
  * A ppp unit corresponds to a ppp network interface device
@@ -1297,7 +1295,7 @@ static int ppp_mp_explode(struct ppp *pp
 	 */
 	fragsize = len;
 	if (nfree > 1)
-		fragsize = ROUNDUP(fragsize, nfree);
+		fragsize = DIV_ROUND_UP(fragsize, nfree);
 	/* nbigger channels get fragsize bytes, the rest get fragsize-1,
 	   except if nbigger==0, then they all get fragsize. */
 	nbigger = len % nfree;
_
