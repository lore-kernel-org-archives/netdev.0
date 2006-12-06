From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 14/16] Spidernet Avoid possible RX chain corruption
Date: Wed, 6 Dec 2006 17:46:28 -0600
Message-ID: <20061206234628.GN4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:60196 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937812AbWLFXqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 18:46:30 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NkTaY012215
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:46:29 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NkTsx340124
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:46:29 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NkSWu002620
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:46:29 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Delete possible source of chain corruption; the hardware
already knows the location of the tail, and writing it
again is likely to mess it up.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----

 drivers/net/spider_net.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:03:16.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:03:18.000000000 -0600
@@ -1195,7 +1195,6 @@ spider_net_handle_rxram_full(struct spid
 	while (spider_net_decode_one_descr(card, 0));
 
 	spider_net_refill_rx_chain(card);
-	spider_net_enable_rxchtails(card);
 	spider_net_enable_rxdmac(card);
 	netif_rx_schedule(card->netdev);
 	spider_net_rx_irq_on(card);
