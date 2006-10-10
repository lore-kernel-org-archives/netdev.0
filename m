From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 16/21]: powerpc/cell spidernet
Date: Tue, 10 Oct 2006 16:15:29 -0500
Message-ID: <20061010211528.GM4381@austin.ibm.com>
References: <20061010204946.GW4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:18909 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030408AbWJJVPa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 17:15:30 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20061010204946.GW4381@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove a dummy register read that is not needed.
This reduces CPU usage notably during transmit.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: James K Lewis <jklewis@us.ibm.com>

----
 drivers/net/spider_net.c |    2 --
 1 file changed, 2 deletions(-)

Index: linux-2.6.18-mm2/drivers/net/spider_net.c
===================================================================
--- linux-2.6.18-mm2.orig/drivers/net/spider_net.c	2006-10-10 13:20:08.000000000 -0500
+++ linux-2.6.18-mm2/drivers/net/spider_net.c	2006-10-10 13:21:41.000000000 -0500
@@ -759,8 +759,6 @@ spider_net_release_tx_chain(struct spide
 	unsigned long flags;
 	int status;
 
-	spider_net_read_reg(card, SPIDER_NET_GDTDMACCNTR);
-
 	while (chain->tail != chain->head) {
 		spin_lock_irqsave(&chain->lock, flags);
 		descr = chain->tail;
