From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.33-rc2] axnet_cs: remove unnecessary
 spin_unlock_irqrestore
Date: Tue, 29 Dec 2009 10:17:24 +0900
Message-ID: <20091229101724.7a077507.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg508.nifty.com ([202.248.238.88]:26650 "EHLO
	userg508.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbZL2BR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 20:17:57 -0500
Received: from localhost.localdomain (eaoska169128.adsl.ppp.infoweb.ne.jp [219.116.18.128])by userg508.nifty.com with SMTP id nBT1HhiG018121
	for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 10:17:43 +0900
In-Reply-To: <20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


axnet_cs:
    remove unnecessary spin_unlock_irqrestore,spin_lock_irqsave.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.33-rc2/drivers/net/pcmcia/axnet_cs.c.orig	2009-12-27 18:21:59.000000000 +0900
+++ linux-2.6.33-rc2/drivers/net/pcmcia/axnet_cs.c	2009-12-27 18:22:38.000000000 +0900
@@ -1065,14 +1065,11 @@ static netdev_tx_t axnet_start_xmit(stru
 	   
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 	outb_p(0x00, e8390_base + EN0_IMR);
-	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 	
 	/*
 	 *	Slow phase with lock held.
 	 */
 	 
-	spin_lock_irqsave(&ei_local->page_lock, flags);
-	
 	ei_local->irqlock = 1;
 
 	send_length = max(length, ETH_ZLEN);
