From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] skge: don't allow transmit ring to be too small
Date: Mon, 15 May 2006 16:32:39 -0700
Message-ID: <20060515163239.6a52fca5@localhost.localdomain>
References: <20060515163025.1b81ecbb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18408 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750780AbWEOXcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 19:32:48 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060515163025.1b81ecbb@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver will get stuck (permanent transmit timeout), if the transmit
ring size is set too small.  It needs to have enough ring elements to
hold one maximum size transmit.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -402,7 +402,7 @@ static int skge_set_ring_param(struct ne
 	int err;
 
 	if (p->rx_pending == 0 || p->rx_pending > MAX_RX_RING_SIZE ||
-	    p->tx_pending == 0 || p->tx_pending > MAX_TX_RING_SIZE)
+	    p->tx_pending < MAX_SKB_FRAGS+1 || p->tx_pending > MAX_TX_RING_SIZE)
 		return -EINVAL;
 
 	skge->rx_ring.count = p->rx_pending;
