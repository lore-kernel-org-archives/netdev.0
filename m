From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] 8139cp: reset BQL when ring tx ring cleared
Date: Sat, 11 May 2013 17:09:23 -0700
Message-ID: <20130511170923.52673453@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:45758 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab3ELAJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 20:09:27 -0400
Received: by mail-pd0-f175.google.com with SMTP id y14so3581272pdi.34
        for <netdev@vger.kernel.org>; Sat, 11 May 2013 17:09:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking for other problem found this potential issue.
When the transmit ring is cleaned out, the Byte Queue Limit values
need to be reset.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/realtek/8139cp.c	2013-05-02 14:30:52.182573290 -0700
+++ b/drivers/net/ethernet/realtek/8139cp.c	2013-05-11 17:06:51.163362372 -0700
@@ -1136,6 +1136,7 @@ static void cp_clean_rings (struct cp_pr
 			cp->dev->stats.tx_dropped++;
 		}
 	}
+	netdev_tx_reset_queue(cp->dev);
 
 	memset(cp->rx_ring, 0, sizeof(struct cp_desc) * CP_RX_RING_SIZE);
 	memset(cp->tx_ring, 0, sizeof(struct cp_desc) * CP_TX_RING_SIZE);
