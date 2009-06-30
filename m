From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/7] rndis_host: Use netdev stats structure
Date: Tue, 30 Jun 2009 10:52:26 +0800
Message-ID: <20090630025226.GC14773@gondor.apana.org.au>
References: <200906300045.n5U0j2To004168@rs49.luxsci.com> <20090630024940.GA14707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>
To: Ben Kibbey <bjk@luxsci.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753779AbZF3Cw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:52:27 -0400
Content-Disposition: inline
In-Reply-To: <20090630024940.GA14707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rndis_host: Use netdev stats structure

Now that netdev has its own stats structure we should use that
instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 1bf243e..2232232 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -487,7 +487,7 @@ int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		if (unlikely(hdr->msg_type != RNDIS_MSG_PACKET
 				|| skb->len < msg_len
 				|| (data_offset + data_len + 8) > msg_len)) {
-			dev->stats.rx_frame_errors++;
+			dev->net->stats.rx_frame_errors++;
 			devdbg(dev, "bad rndis message %d/%d/%d/%d, len %d",
 				le32_to_cpu(hdr->msg_type),
 				msg_len, data_offset, data_len, skb->len);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
