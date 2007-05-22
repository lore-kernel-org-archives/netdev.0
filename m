From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 2/10] spidernet: beautify error messages
Date: Tue, 22 May 2007 18:13:54 -0500
Message-ID: <20070522231354.GA2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:54554 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757359AbXEVXN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:13:57 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MNDt5w006519
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:13:55 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNDtg9180570
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:13:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNDsOK015593
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:13:55 -0600
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Make error messages print which interface they apply to.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   10 ++++++----
 drivers/net/spider_net.h |    2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-22 18:03:16.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:24.000000000 -0500
@@ -434,7 +434,8 @@ spider_net_prepare_rx_descr(struct spide
 				      bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
-			pr_err("Not enough memory to allocate rx buffer\n");
+			pr_err("%s: Not enough memory to allocate rx buffer\n",
+			    card->netdev->name);
 		card->spider_stats.alloc_rx_skb_error++;
 		return -ENOMEM;
 	}
@@ -455,7 +456,8 @@ spider_net_prepare_rx_descr(struct spide
 		dev_kfree_skb_any(descr->skb);
 		descr->skb = NULL;
 		if (netif_msg_rx_err(card) && net_ratelimit())
-			pr_err("Could not iommu-map rx buffer\n");
+			pr_err("%s: Could not iommu-map rx buffer\n",
+			      card->netdev->name);
 		card->spider_stats.rx_iommu_map_error++;
 		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
@@ -1455,8 +1457,8 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
 		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("Spider RX RAM full, incoming packets "
-			       "might be discarded!\n");
+			pr_err("%s: Spider RX RAM full, incoming packets "
+			       "might be discarded!\n", card->netdev->name);
 		spider_net_rx_irq_off(card);
 		netif_rx_schedule(card->netdev);
 		show_error = 0;
Index: netdev-2.6/drivers/net/spider_net.h
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.h	2007-05-21 17:40:49.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.h	2007-05-22 18:03:24.000000000 -0500
@@ -25,7 +25,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "2.0 A"
+#define VERSION "2.0 B"
 
 #include "sungem_phy.h"
 
