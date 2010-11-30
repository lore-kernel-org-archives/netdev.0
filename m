From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: PATCH: fix hang in dmfe driver on sending of big packet
 (linux-2.6.35)
Date: Tue, 30 Nov 2010 16:38:04 +0300
Message-ID: <20101130133804.GA1835@lw.yar.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
To: netdev@vger.kernel.org, tori@unhappy.mine.nu
Return-path: <netdev-owner@vger.kernel.org>
Received: from lav-w.yar.ru ([193.233.48.101]:43136 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751233Ab0K3OVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 09:21:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello!

This patch fixes hang in dmfe driver on attempt of sending a big packet.
Without this patch the code stops the queue and never wakes it again.

-- 
   Alexander.

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmfe.patch"

--- dmfe.c.1	2010-11-30 16:21:52.758465207 +0300
+++ dmfe.c	2010-11-30 16:24:45.301468601 +0300
@@ -687,18 +687,18 @@
 	unsigned long flags;
 
 	DMFE_DBUG(0, "dmfe_start_xmit", 0);
 
-	/* Resource flag check */
-	netif_stop_queue(dev);
-
 	/* Too large packet check */
 	if (skb->len > MAX_PACKET_SIZE) {
 		pr_err("big packet = %d\n", (u16)skb->len);
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
+	/* Resource flag check */
+	netif_stop_queue(dev);
+
 	spin_lock_irqsave(&db->lock, flags);
 
 	/* No Tx resource check, it never happen nromally */
 	if (db->tx_queue_cnt >= TX_FREE_DESC_CNT) {

--fUYQa+Pmc3FrFX/N--
