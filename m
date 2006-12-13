From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 12/14] Spidernet Avoid possible RX chain corruption
Date: Wed, 13 Dec 2006 15:23:01 -0600
Message-ID: <20061213212301.GL1915@austin.ibm.com>
References: <20061213210010.GR4329@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Christoph Hellwig <hch@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53037 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbWLMVXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 16:23:08 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDLN3na009252
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:23:03 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDLN3ZA345650
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:23:03 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDLN1Pg028436
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:23:03 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061213210010.GR4329@austin.ibm.com>
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
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:28:23.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-13 14:28:25.000000000 -0600
@@ -513,7 +513,6 @@ spider_net_alloc_rx_skbs(struct spider_n
 	/* This will allocate the rest of the rx buffers;
 	 * if not, it's business as usual later on. */
 	spider_net_refill_rx_chain(card);
-	spider_net_enable_rxchtails(card);
 	spider_net_enable_rxdmac(card);
 	return 0;
 
