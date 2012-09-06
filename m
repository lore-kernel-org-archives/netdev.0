From: Jean Delvare <khali@linux-fr.org>
Subject: |PATCH] seeq: Add missing spinlock init
Date: Thu, 6 Sep 2012 12:47:05 +0200
Message-ID: <20120906124705.2631ae01@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zoneX.GCU-Squad.org ([194.213.125.0]:41305 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758228Ab2IFKrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 06:47:15 -0400
Received: from jdelvare.pck.nerim.net ([62.212.121.182] helo=endymion.delvare)
	by services.gcu-squad.org (GCU Mailer Daemon) with esmtpsa id 1T9Zc8-0000x9-KG
	(TLSv1:AES128-SHA:128)
	(envelope-from <khali@linux-fr.org>)
	for netdev@vger.kernel.org; Thu, 06 Sep 2012 12:47:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't seem this spinlock was properly initialized.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
---
I can't even build-test this.

 drivers/net/ethernet/seeq/sgiseeq.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-3.6-rc4.orig/drivers/net/ethernet/seeq/sgiseeq.c	2012-07-21 22:58:29.000000000 +0200
+++ linux-3.6-rc4/drivers/net/ethernet/seeq/sgiseeq.c	2012-09-06 12:40:30.092144722 +0200
@@ -751,6 +751,7 @@ static int __devinit sgiseeq_probe(struc
 	sp->srings = sr;
 	sp->rx_desc = sp->srings->rxvector;
 	sp->tx_desc = sp->srings->txvector;
+	spin_lock_init(&sp->tx_lock);
 
 	/* A couple calculations now, saves many cycles later. */
 	setup_rx_ring(dev, sp->rx_desc, SEEQ_RX_BUFFERS);


-- 
Jean Delvare
