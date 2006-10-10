From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 10/21]: powerpc/cell spidernet  fix error interrupt print
Date: Tue, 10 Oct 2006 16:06:53 -0500
Message-ID: <20061010210653.GG4381@austin.ibm.com>
References: <20061010204946.GW4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:55190 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1030390AbWJJVGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 17:06:55 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20061010204946.GW4381@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



The print message associated with the descriptor chain end interrupt
prints a bogs value. Fix that.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.18-mm2/drivers/net/spider_net.c
===================================================================
--- linux-2.6.18-mm2.orig/drivers/net/spider_net.c	2006-10-10 12:52:42.000000000 -0500
+++ linux-2.6.18-mm2/drivers/net/spider_net.c	2006-10-10 12:58:08.000000000 -0500
@@ -1356,7 +1356,7 @@ spider_net_handle_error_irq(struct spide
 		if (netif_msg_intr(card))
 			pr_err("got descriptor chain end interrupt, "
 			       "restarting DMAC %c.\n",
-			       'D'+i-SPIDER_NET_GDDDCEINT);
+			       'D'-(i-SPIDER_NET_GDDDCEINT)/3);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		show_error = 0;
