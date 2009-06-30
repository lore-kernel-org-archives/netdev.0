From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [5/7] smsc95xx: Use netdev stats structure
Date: Tue, 30 Jun 2009 10:53:00 +0800
Message-ID: <20090630025300.GD14773@gondor.apana.org.au>
References: <200906300045.n5U0j2To004168@rs49.luxsci.com> <20090630024940.GA14707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>
To: Ben Kibbey <bjk@luxsci.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42766 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755025AbZF3CxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:53:01 -0400
Content-Disposition: inline
In-Reply-To: <20090630024940.GA14707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc95xx: Use netdev stats structure

Now that netdev has its own stats structure we should use that
instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 5a72833..fc7f640 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1108,18 +1108,18 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		if (unlikely(header & RX_STS_ES_)) {
 			if (netif_msg_rx_err(dev))
 				devdbg(dev, "Error header=0x%08x", header);
-			dev->stats.rx_errors++;
-			dev->stats.rx_dropped++;
+			dev->net->stats.rx_errors++;
+			dev->net->stats.rx_dropped++;
 
 			if (header & RX_STS_CRC_) {
-				dev->stats.rx_crc_errors++;
+				dev->net->stats.rx_crc_errors++;
 			} else {
 				if (header & (RX_STS_TL_ | RX_STS_RF_))
-					dev->stats.rx_frame_errors++;
+					dev->net->stats.rx_frame_errors++;
 
 				if ((header & RX_STS_LE_) &&
 					(!(header & RX_STS_FT_)))
-					dev->stats.rx_length_errors++;
+					dev->net->stats.rx_length_errors++;
 			}
 		} else {
 			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
