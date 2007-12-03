From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 2/5] [IrDA] mcs7780 needs to free allocated rx buffer
Date: Mon, 03 Dec 2007 10:28:33 +0100
Message-ID: <20071203093053.368759253@sortiz.org>
References: <20071203092831.724254969@sortiz.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Hinko Kocevar <hinko.kocevar@cetrtapot.si>
To: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.17]:34705 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbXLCB3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 20:29:07 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf1908.orange.fr (SMTP Server) with ESMTP id 631351C00094
	for <netdev@vger.kernel.org>; Mon,  3 Dec 2007 02:29:04 +0100 (CET)
Content-Disposition: inline; filename=mcs7780-free-rx_buff.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing the mcs7780 based IrDA USB dongle I've stumbled upon
memory leak in mcs_net_close(). Patch below fixes it.

Signed-off-by: Hinko Kocevar <hinko.kocevar@cetrtapot.si>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 drivers/net/irda/mcs7780.c |    2 ++
 1 file changed, 2 insertions(+)

Index: net-2.6/drivers/net/irda/mcs7780.c
===================================================================
--- net-2.6.orig/drivers/net/irda/mcs7780.c	2007-11-25 05:53:43.000000000 +0100
+++ net-2.6/drivers/net/irda/mcs7780.c	2007-11-25 07:12:11.000000000 +0100
@@ -677,6 +677,8 @@
 	/* Stop transmit processing */
 	netif_stop_queue(netdev);
 
+	kfree_skb(mcs->rx_buff.skb);
+
 	/* kill and free the receive and transmit URBs */
 	usb_kill_urb(mcs->rx_urb);
 	usb_free_urb(mcs->rx_urb);

-- 

