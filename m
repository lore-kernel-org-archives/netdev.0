From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 2/10] spidernet: beautify error messages
Date: Wed, 16 May 2007 17:00:12 -0500
Message-ID: <20070516220011.GB4997@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:55881 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239AbXEPWAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 18:00:13 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GM0D6D009887
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:00:13 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GM0DWo203528
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 16:00:13 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GM0CGL013436
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 16:00:13 -0600
Content-Disposition: inline
In-Reply-To: <20070516215605.GA4325@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Make error messages print which interface they apply to.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   10 ++++++----
 drivers/net/spider_net.h |    2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-14 17:05:03.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-15 14:47:38.000000000 -0500
@@ -433,7 +433,8 @@ spider_net_prepare_rx_descr(struct spide
 	descr->skb = dev_alloc_skb(bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
-			pr_err("Not enough memory to allocate rx buffer\n");
+			pr_err("%s: Not enough memory to allocate rx buffer\n",
+			    card->netdev->name);
 		card->spider_stats.alloc_rx_skb_error++;
 		return -ENOMEM;
 	}
@@ -454,7 +455,8 @@ spider_net_prepare_rx_descr(struct spide
 		dev_kfree_skb_any(descr->skb);
 		descr->skb = NULL;
 		if (netif_msg_rx_err(card) && net_ratelimit())
-			pr_err("Could not iommu-map rx buffer\n");
+			pr_err("%s: Could not iommu-map rx buffer\n",
+			      card->netdev->name);
 		card->spider_stats.rx_iommu_map_error++;
 		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
@@ -1454,8 +1456,8 @@ spider_net_handle_error_irq(struct spide
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
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-05-15 14:47:33.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-05-15 14:47:58.000000000 -0500
@@ -25,7 +25,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "2.0 A"
+#define VERSION "2.0 B"
 
 #include "sungem_phy.h"
 
