From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/7] cdc_eem: Use netdev stats structure
Date: Tue, 30 Jun 2009 10:49:40 +0800
Message-ID: <20090630024940.GA14707@gondor.apana.org.au>
References: <200906300045.n5U0j2To004168@rs49.luxsci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>
To: Ben Kibbey <bjk@luxsci.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35253 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752761AbZF3Ctt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:49:49 -0400
Content-Disposition: inline
In-Reply-To: <200906300045.n5U0j2To004168@rs49.luxsci.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series should fix the problem:

cdc_eem: Use netdev stats structure

Now that netdev has its own stats structure we should use that
instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 80e0177..cd35d50 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -319,7 +319,7 @@ static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 				return crc == crc2;
 
 			if (unlikely(crc != crc2)) {
-				dev->stats.rx_errors++;
+				dev->net->stats.rx_errors++;
 				dev_kfree_skb_any(skb2);
 			} else
 				usbnet_skb_return(dev, skb2);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
