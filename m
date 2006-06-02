From: akpm@osdl.org
Subject: [patch 15/17] pppoe: missing result check in __pppoe_xmit()
Date: Thu, 01 Jun 2006 20:32:38 -0700
Message-ID: <200606020328.k523SJMZ028857@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, fmalita@gmail.com,
	mostrows@speakeasy.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8373 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751208AbWFBD22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:28 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Florin Malita <fmalita@gmail.com>

skb_clone() may fail, we should check the result.

Coverity CID: 1215.

Signed-off-by: Florin Malita <fmalita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <mostrows@speakeasy.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/pppoe.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN drivers/net/pppoe.c~pppoe-missing-result-check-in-__pppoe_xmit drivers/net/pppoe.c
--- devel/drivers/net/pppoe.c~pppoe-missing-result-check-in-__pppoe_xmit	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/drivers/net/pppoe.c	2006-06-01 20:31:50.000000000 -0700
@@ -861,6 +861,9 @@ static int __pppoe_xmit(struct sock *sk,
 		 * give dev_queue_xmit something it can free.
 		 */
 		skb2 = skb_clone(skb, GFP_ATOMIC);
+
+		if (skb2 == NULL)
+			goto abort;
 	}
 
 	ph = (struct pppoe_hdr *) skb_push(skb2, sizeof(struct pppoe_hdr));
_
