From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/2] skge: bad checksums on big-endian platforms
Date: Mon, 15 May 2006 16:30:25 -0700
Message-ID: <20060515163025.1b81ecbb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17640 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750776AbWEOXcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 19:32:48 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Skge driver always causes  bad checksums on big-endian.
The checksum in the receive control block was being swapped
when it doesn't need to be.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -2717,8 +2717,7 @@ static int skge_poll(struct net_device *
 		if (control & BMU_OWN)
 			break;
 
-		skb = skge_rx_get(skge, e, control, rd->status,
-				  le16_to_cpu(rd->csum2));
+		skb = skge_rx_get(skge, e, control, rd->status, rd->csum2);
 		if (likely(skb)) {
 			dev->last_rx = jiffies;
 			netif_receive_skb(skb);
