From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: decnet: dn_nsp_out: use swap macro in dn_mk_ack_header
Date: Sat, 28 Oct 2017 15:39:48 -0500
Message-ID: <20171028203948.GA6173@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway24.websitewelcome.com ([192.185.50.93]:26933 "EHLO
        gateway24.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751663AbdJ1Uju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 16:39:50 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway24.websitewelcome.com (Postfix) with ESMTP id 952279F59
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 15:39:49 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the swap macro and remove unnecessary variable tmp.
This makes the code easier to read and maintain.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/decnet/dn_nsp_out.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index e50a4ad..56a52a0 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -313,11 +313,8 @@ static __le16 *dn_mk_ack_header(struct sock *sk, struct sk_buff *skb, unsigned c
 	ackcrs |= 0x8000;
 
 	/* If this is an "other data/ack" message, swap acknum and ackcrs */
-	if (other) {
-		unsigned short tmp = acknum;
-		acknum = ackcrs;
-		ackcrs = tmp;
-	}
+	if (other)
+		swap(acknum, ackcrs);
 
 	/* Set "cross subchannel" bit in ackcrs */
 	ackcrs |= 0x2000;
-- 
2.7.4
