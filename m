From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 13/16] Spidernet Memory barrier
Date: Wed, 6 Dec 2006 17:45:09 -0600
Message-ID: <20061206234509.GM4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:42254 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937815AbWLFXpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 18:45:11 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NjbJR027772
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:45:37 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NjBf9195334
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:45:11 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6Nj9jb013171
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:45:10 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add memory barrier to make sure that the rest of the 
RX descriptor state is flushed to memory before we tell 
the hardware that its ready to go.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:03:15.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:03:16.000000000 -0600
@@ -389,6 +389,7 @@ spider_net_prepare_rx_descr(struct spide
 		card->spider_stats.rx_iommu_map_error++;
 		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
+		wmb();
 		descr->dmac_cmd_status = SPIDER_NET_DESCR_CARDOWNED |
 					 SPIDER_NET_DMAC_NOINTR_COMPLETE;
 	}
