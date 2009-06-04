From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: virtio_net: Set correct gso->hdr_len
Date: Thu, 4 Jun 2009 20:59:18 +1000
Message-ID: <20090604105917.GA28273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57602 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752946AbZFDK7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 06:59:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

virtio_net: Set correct gso->hdr_len

Through a bug in the tun driver, I noticed that virtio_net is
producing bogus hdr_len values.  In particular, it only includes
the IP header in the linear area, and excludes the entire TCP
header.  This causes the TCP header to be copied twice for each
packet.  (The bug omitted the second copy :)

This patch corrects this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4d1d479..1c9cedd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -470,7 +470,7 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 	}
 
 	if (skb_is_gso(skb)) {
-		hdr->hdr_len = skb_transport_header(skb) - skb->data;
+		hdr->hdr_len = skb_headlen(skb);
 		hdr->gso_size = skb_shinfo(skb)->gso_size;
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
