From: Willem de Bruijn <willemb@google.com>
Subject: [net-next 2/4] vxge: remove deprecated syststamp timestamp
Date: Fri, 25 Jul 2014 18:01:30 -0400
Message-ID: <1406325692-616-3-git-send-email-willemb@google.com>
References: <1406325692-616-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	kreese@caviumnetworks.com, ddaney@caviumnetworks.com,
	dborkman@redhat.com, jdmason@kudzu.us,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:51915 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbaGYWBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:01:45 -0400
Received: by mail-yh0-f74.google.com with SMTP id 29so827280yhl.1
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:01:44 -0700 (PDT)
In-Reply-To: <1406325692-616-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver explicitly clears a field that is unused and about to be
removed. Remove the initialization.

All fields in skb_shared_info before dataref are cleared in
__alloc_skb, so the removal is safe even while syststamp exists.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 7a0dead..2eda153 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -503,7 +503,6 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 
 			skb_hwts = skb_hwtstamps(skb);
 			skb_hwts->hwtstamp = ns_to_ktime(ns);
-			skb_hwts->syststamp.tv64 = 0;
 		}
 
 		/* rth_hash_type and rth_it_hit are non-zero regardless of
-- 
2.0.0.526.g5318336
