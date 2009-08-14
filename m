From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] WAN: bit and/or confusion
Date: Fri, 14 Aug 2009 14:51:46 +0200
Message-ID: <4A855DE2.2000907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:54798 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437AbZHNMrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 08:47:36 -0400
Received: by ewy10 with SMTP id 10so1471729ewy.37
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 05:47:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the tests that check whether Frame* bits are not set

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
// vi drivers/net/wan/dscc4.c +307
#define FrameVfr	0x80
#define FrameRdo        0x40
#define FrameCrc	0x20
#define FrameRab	0x10

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 8face5d..dd3c64a 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -663,9 +663,9 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 	} else {
 		if (skb->data[pkt_len] & FrameRdo)
 			dev->stats.rx_fifo_errors++;
-		else if (!(skb->data[pkt_len] | ~FrameCrc))
+		else if (!(skb->data[pkt_len] & ~FrameCrc))
 			dev->stats.rx_crc_errors++;
-		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
+		else if (!(skb->data[pkt_len] & ~(FrameVfr | FrameRab)))
 			dev->stats.rx_length_errors++;
 		else
 			dev->stats.rx_errors++;
