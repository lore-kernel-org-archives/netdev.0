From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.38rc2-git7] axnet_cs: reduce delay time at
 ei_rx_overrun
Date: Mon, 31 Jan 2011 06:16:16 +0900
Message-ID: <20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	<20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	<20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
	<20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
	<20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
	<20110111205558.98fcab01.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg507.nifty.com ([202.248.238.87]:58924 "EHLO
	userg507.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab1A3VQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 16:16:31 -0500
Received: from localhost.localdomain (eaoska084016.adsl.ppp.infoweb.ne.jp [218.217.191.16])by userg507.nifty.com with SMTP id p0ULGMhp018727
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 06:16:22 +0900
In-Reply-To: <20110111205558.98fcab01.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


axnet_cs:
    mdelay of 10ms is too long at ei_rx_overrun.
    It should be reduced to 2ms.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.38-rc2-git7/drivers/net/pcmcia/axnet_cs.c.orig	2011-01-29 19:56:56.261560045 +0900
+++ linux-2.6.38-rc2-git7/drivers/net/pcmcia/axnet_cs.c	2011-01-30 11:00:12.500397574 +0900
@@ -1488,12 +1488,10 @@ static void ei_rx_overrun(struct net_dev
     
 	/* 
 	 * Wait a full Tx time (1.2ms) + some guard time, NS says 1.6ms total.
-	 * Early datasheets said to poll the reset bit, but now they say that
-	 * it "is not a reliable indicator and subsequently should be ignored."
-	 * We wait at least 10ms.
+	 * We wait at least 2ms.
 	 */
 
-	mdelay(10);
+	mdelay(2);
 
 	/*
 	 * Reset RBCR[01] back to zero as per magic incantation.
