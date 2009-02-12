From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 08/41]bnx2x: Moving skb_record_rx_queue
Date: Thu, 12 Feb 2009 20:36:37 +0200
Message-ID: <1234463797.1863.139.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2939 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759338AbZBLSpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 08/41]bnx2x: Moving skb_record_rx_queue
Should be called for all incoming packets and not just for GRO packets

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 19865d5..891a3fb 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1336,7 +1336,6 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		skb_record_rx_queue(skb, queue);
 
 		{
 			struct iphdr *iph;
@@ -1599,6 +1598,7 @@ reuse_rx:
 			}
 		}
 
+		skb_record_rx_queue(skb, fp->index);
 #ifdef BCM_VLAN
 		if ((bp->vlgrp != NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
 		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
-- 
1.5.4.3




