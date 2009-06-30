From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/7] dm9601: Use netdev stats structure
Date: Tue, 30 Jun 2009 10:50:51 +0800
Message-ID: <20090630025051.GA14773@gondor.apana.org.au>
References: <200906300045.n5U0j2To004168@rs49.luxsci.com> <20090630024940.GA14707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>
To: Ben Kibbey <bjk@luxsci.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35260 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753130AbZF3Cux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:50:53 -0400
Content-Disposition: inline
In-Reply-To: <20090630024940.GA14707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dm9601: Use netdev stats structure

Now that netdev has its own stats structure we should use that
instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 6fc4f82..9acd574 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -513,11 +513,11 @@ static int dm9601_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	len = (skb->data[1] | (skb->data[2] << 8)) - 4;
 
 	if (unlikely(status & 0xbf)) {
-		if (status & 0x01) dev->stats.rx_fifo_errors++;
-		if (status & 0x02) dev->stats.rx_crc_errors++;
-		if (status & 0x04) dev->stats.rx_frame_errors++;
-		if (status & 0x20) dev->stats.rx_missed_errors++;
-		if (status & 0x90) dev->stats.rx_length_errors++;
+		if (status & 0x01) dev->net->stats.rx_fifo_errors++;
+		if (status & 0x02) dev->net->stats.rx_crc_errors++;
+		if (status & 0x04) dev->net->stats.rx_frame_errors++;
+		if (status & 0x20) dev->net->stats.rx_missed_errors++;
+		if (status & 0x90) dev->net->stats.rx_length_errors++;
 		return 0;
 	}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
