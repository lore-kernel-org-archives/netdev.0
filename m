From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] via-rhine: NAPI poll enable
Date: Wed, 26 Jul 2006 11:51:02 -0700
Message-ID: <20060726115102.68e6adf0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:41915 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751737AbWGZSvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:51:05 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k6QIp3nW017370
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:51:03 -0700
To: akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The poll_enable should be in init_registers before enabling interrupts,
not in tx_timeout. Thanks for spotting it Roger.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/via-rhine.c	2006-07-25 13:43:19.000000000 -0700
+++ sky2/drivers/net/via-rhine.c	2006-07-25 13:43:10.000000000 -0700
@@ -1048,6 +1048,8 @@
 
 	rhine_set_rx_mode(dev);
 
+	netif_poll_enable(dev);
+
 	/* Enable interrupts by setting the interrupt mask. */
 	iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
 	       IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
@@ -1199,7 +1201,6 @@
 	dev->trans_start = jiffies;
 	rp->stats.tx_errors++;
 	netif_wake_queue(dev);
-	netif_poll_enable(dev);
 }
 
 static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)

