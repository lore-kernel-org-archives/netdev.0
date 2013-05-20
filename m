From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Mon, 20 May 2013 09:54:43 -0700
Message-ID: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:48525 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755596Ab3ETQyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:54:50 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so1262147pbc.31
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 09:54:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cures transmit timeout's with DHCP observed
while running under KVM. When the transmit ring is cleaned out,
the Byte Queue Limit values need to be reset.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/realtek/8139cp.c	2013-05-20 09:29:49.689900862 -0700
+++ b/drivers/net/ethernet/realtek/8139cp.c	2013-05-20 09:29:50.857880563 -0700
@@ -1141,6 +1141,7 @@ static void cp_clean_rings (struct cp_pr
 			cp->dev->stats.tx_dropped++;
 		}
 	}
+	netdev_reset_queue(cp->dev);
 
 	memset(cp->rx_ring, 0, sizeof(struct cp_desc) * CP_RX_RING_SIZE);
 	memset(cp->tx_ring, 0, sizeof(struct cp_desc) * CP_TX_RING_SIZE);
