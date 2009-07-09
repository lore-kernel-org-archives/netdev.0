From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 3/5] udpv6: Fix gso_size setting in
 ip6_ufo_append_data
Date: Thu, 09 Jul 2009 11:09:58 -0700
Message-ID: <1247162998.8649.92.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:35448 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178AbZGISKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 14:10:00 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n69I4rlH023569
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:04:53 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69I9xIo243612
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n69I9xj4001173
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6 3/5] udpv6: Fix gso_size setting in ip6_ufo_append_data

- fix gso_size setting for ipv6 fragment to be a multiple of 8 bytes.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/ipv6/ip6_output.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7c76e3d..1c6f0fc 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1087,9 +1087,11 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	if (!err) {
 		struct frag_hdr fhdr;
 
-		/* specify the length of each IP datagram fragment*/
-		skb_shinfo(skb)->gso_size = mtu - fragheaderlen -
-					    sizeof(struct frag_hdr);
+		/* Specify the length of each IPv6 datagram fragment.
+		 * It has to be a multiple of 8.
+		 */
+		skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
+					     sizeof(struct frag_hdr)) & ~7;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 		ipv6_select_ident(skb, &fhdr);
 		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;


