From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio_net: Fix IP alignment on non-mergeable RX path
Date: Fri, 12 Jun 2009 08:29:22 +0930
Message-ID: <200906120829.23999.rusty@rustcorp.com.au>
References: <OF1B881599.F1B4A2EF-ON802575BB.0036EA40-802575BC.0041BFB5@au1.ibm.com> <1244743266.9669.64.camel@w-sridhar.beaverton.ibm.com> <20090611205003.GA8677@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Mark McLoughlin <markmc@redhat.com>,
	Danielius Kudinskas <kudinskas@uk.ibm.com>,
	aliguori@linux.vnet.ibm.com, Paul T Knowles <pablo@uk.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37895 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760644AbZFKW72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 18:59:28 -0400
In-Reply-To: <20090611205003.GA8677@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

We need to enforce the IP alignment on the non-mergeable RX path just
like the other RX path.  Not doing so results in misaligned IP
headers.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4d1d479..52fba8e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -283,10 +283,11 @@ static void try_fill_recv_maxbufs(struct virtnet_info *vi)
 	for (;;) {
 		struct virtio_net_hdr *hdr;
 
-		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN);
+		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN + NET_IP_ALIGN);
 		if (unlikely(!skb))
 			break;
 
+		skb_reserve(skb, NET_IP_ALIGN);
 		skb_put(skb, MAX_PACKET_LEN);
 
 		hdr = skb_vnet_hdr(skb);

