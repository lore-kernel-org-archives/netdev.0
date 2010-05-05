From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 1/3] bnx2: Add GRO support.
Date: Tue, 4 May 2010 22:21:44 -0700
Message-ID: <1273036906-29162-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2313 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754259Ab0EEFKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 01:10:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ab26bbc..6ad3184 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3207,10 +3207,10 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 #ifdef BCM_VLAN
 		if (hw_vlan)
-			vlan_hwaccel_receive_skb(skb, bp->vlgrp, vtag);
+			vlan_gro_receive(&bnapi->napi, bp->vlgrp, vtag, skb);
 		else
 #endif
-			netif_receive_skb(skb);
+			napi_gro_receive(&bnapi->napi, skb);
 
 		rx_pkt++;
 
-- 
1.6.4.GIT


