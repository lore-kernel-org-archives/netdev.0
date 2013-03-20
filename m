From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v2] chelsio: use netdev_alloc_skb_ip_align
Date: Wed, 20 Mar 2013 12:02:41 -0700
Message-ID: <20130320120241.19314ab6@nehalam.linuxnetplumber.net>
References: <1363797199.3333.18.camel@edumazet-glaptop>
	<20130320113024.00377b99@nehalam.linuxnetplumber.net>
	<1363804952.3333.29.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:42468 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755297Ab3CTTCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 15:02:47 -0400
Received: by mail-da0-f42.google.com with SMTP id n15so1158346dad.29
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 12:02:47 -0700 (PDT)
In-Reply-To: <1363804952.3333.29.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_sk_ip_align in the case where packet is copied.
This handles case where NET_IP_ALIGN == 0 as well as adding required header
padding.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/chelsio/cxgb/sge.c	2013-03-20 11:13:47.950986878 -0700
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c	2013-03-20 12:00:01.551115729 -0700
@@ -1046,11 +1046,10 @@ static inline struct sk_buff *get_packet
 	const struct freelQ_ce *ce = &fl->centries[fl->cidx];
 
 	if (len < copybreak) {
-		skb = alloc_skb(len + 2, GFP_ATOMIC);
+		skb = netdev_alloc_skb_ip_align(NULL, len);
 		if (!skb)
 			goto use_orig_buf;
 
-		skb_reserve(skb, 2);	/* align IP header */
 		skb_put(skb, len);
 		pci_dma_sync_single_for_cpu(pdev,
 					    dma_unmap_addr(ce, dma_addr),
