From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] enc28j60: use netif_rx_ni() to deliver RX packets
Date: Tue, 16 Dec 2008 08:18:52 +0200
Message-ID: <20081216061851.GA4773@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:34566 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332AbYLPGTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 01:19:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The enc28j60 driver reads incoming packets in the process (workqueue) context, 
not in a tasklet or the interrupt context.  Thus, we should use netif_rx_ni() 
to deliver those packets to the networking layer, instead of netif_rx(). This 
way incoming packets don't wait in the incoming queue for the next IRQ to be 
serviced.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---

--- drivers/net/enc28j60.c-git	2008-12-16 08:06:53.000000000 +0200
+++ drivers/net/enc28j60.c	2008-12-16 08:08:32.000000000 +0200
@@ -959,7 +959,7 @@ static void enc28j60_hw_rx(struct net_de
 			ndev->stats.rx_packets++;
 			ndev->stats.rx_bytes += len;
 			ndev->last_rx = jiffies;
-			netif_rx(skb);
+			netif_rx_ni(skb);
 		}
 	}
 	/*

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
