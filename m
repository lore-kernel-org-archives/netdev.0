From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/7] net1080: Use netdev stats structure
Date: Tue, 30 Jun 2009 10:51:40 +0800
Message-ID: <20090630025140.GB14773@gondor.apana.org.au>
References: <200906300045.n5U0j2To004168@rs49.luxsci.com> <20090630024940.GA14707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>
To: Ben Kibbey <bjk@luxsci.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35267 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752826AbZF3Cvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:51:41 -0400
Content-Disposition: inline
In-Reply-To: <20090630024940.GA14707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net1080: Use netdev stats structure

Now that netdev has its own stats structure we should use that
instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 034e8a7..aeb1ab0 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -433,7 +433,7 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		dbg("rx framesize %d range %d..%d mtu %d", skb->len,
 			net->hard_header_len, dev->hard_mtu, net->mtu);
 #endif
-		dev->stats.rx_frame_errors++;
+		dev->net->stats.rx_frame_errors++;
 		nc_ensure_sync(dev);
 		return 0;
 	}
@@ -442,12 +442,12 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	hdr_len = le16_to_cpup(&header->hdr_len);
 	packet_len = le16_to_cpup(&header->packet_len);
 	if (FRAMED_SIZE(packet_len) > NC_MAX_PACKET) {
-		dev->stats.rx_frame_errors++;
+		dev->net->stats.rx_frame_errors++;
 		dbg("packet too big, %d", packet_len);
 		nc_ensure_sync(dev);
 		return 0;
 	} else if (hdr_len < MIN_HEADER) {
-		dev->stats.rx_frame_errors++;
+		dev->net->stats.rx_frame_errors++;
 		dbg("header too short, %d", hdr_len);
 		nc_ensure_sync(dev);
 		return 0;
@@ -465,21 +465,21 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 	if ((packet_len & 0x01) == 0) {
 		if (skb->data [packet_len] != PAD_BYTE) {
-			dev->stats.rx_frame_errors++;
+			dev->net->stats.rx_frame_errors++;
 			dbg("bad pad");
 			return 0;
 		}
 		skb_trim(skb, skb->len - 1);
 	}
 	if (skb->len != packet_len) {
-		dev->stats.rx_frame_errors++;
+		dev->net->stats.rx_frame_errors++;
 		dbg("bad packet len %d (expected %d)",
 			skb->len, packet_len);
 		nc_ensure_sync(dev);
 		return 0;
 	}
 	if (header->packet_id != get_unaligned(&trailer->packet_id)) {
-		dev->stats.rx_fifo_errors++;
+		dev->net->stats.rx_fifo_errors++;
 		dbg("(2+ dropped) rx packet_id mismatch 0x%x 0x%x",
 			le16_to_cpu(header->packet_id),
 			le16_to_cpu(trailer->packet_id));
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
