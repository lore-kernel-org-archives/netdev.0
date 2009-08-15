From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] WAN: bit and/or confusion
Date: Sat, 15 Aug 2009 15:41:07 +0200
Message-ID: <4A86BAF3.5060609@gmail.com>
References: <4A855DE2.2000907@gmail.com>	<20090814163644.0cc8974f.akpm@linux-foundation.org>	<20090814.164123.36875657.davem@davemloft.net> <20090814165852.7338461e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:13891 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbZHONgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2009 09:36:54 -0400
Received: by ey-out-2122.google.com with SMTP id 22so451600eye.37
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2009 06:36:54 -0700 (PDT)
In-Reply-To: <20090814165852.7338461e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the tests that check whether Frame* bits are not set

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
> we need
> 
> 	else if (!(skb->data[pkt_len] & FrameCrc))

> vfr is "valid frame".  0 is invalid.
> 
> rab is "receive message aborted".  The data sheet doesn't actually say
> if the bit is active-high or active-low (grr).  

Maybe someone could test this?

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 8face5d..b686050 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -663,9 +663,9 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 	} else {
 		if (skb->data[pkt_len] & FrameRdo)
 			dev->stats.rx_fifo_errors++;
-		else if (!(skb->data[pkt_len] | ~FrameCrc))
+		else if (!(skb->data[pkt_len] & FrameCrc))
 			dev->stats.rx_crc_errors++;
-		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
+		else if (!(skb->data[pkt_len] & (FrameVfr | FrameRab)))
 			dev->stats.rx_length_errors++;
 		else
 			dev->stats.rx_errors++;

