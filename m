From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/7] qlge: Fix frame routing for multicast frames.
Date: Thu,  8 Oct 2009 12:54:39 -0700
Message-ID: <1255031683-3912-4-git-send-email-ron.mercer@qlogic.com>
References: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40572 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933236AbZJHUCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 16:02:18 -0400
In-Reply-To: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcast/multicast should always be routed to the default (zeroeth) rx
ring.  Broadcast frames are already routed correctly.  This fixes
routing for multicast frames.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d66ad8d..20c074c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -546,14 +546,14 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 		}
 	case RT_IDX_MCAST:	/* Pass up All Multicast frames. */
 		{
-			value = RT_IDX_DST_CAM_Q |	/* dest */
+			value = RT_IDX_DST_DFLT_Q |	/* dest */
 			    RT_IDX_TYPE_NICQ |	/* type */
 			    (RT_IDX_ALLMULTI_SLOT << RT_IDX_IDX_SHIFT);/* index */
 			break;
 		}
 	case RT_IDX_MCAST_MATCH:	/* Pass up matched Multicast frames. */
 		{
-			value = RT_IDX_DST_CAM_Q |	/* dest */
+			value = RT_IDX_DST_DFLT_Q |	/* dest */
 			    RT_IDX_TYPE_NICQ |	/* type */
 			    (RT_IDX_MCAST_MATCH_SLOT << RT_IDX_IDX_SHIFT);/* index */
 			break;
-- 
1.6.0.2

