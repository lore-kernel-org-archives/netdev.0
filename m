From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 5/9] bnx2x: Fix VF MAC removal
Date: Thu, 25 Jun 2015 15:19:25 +0300
Message-ID: <1435234769-5625-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Shahed Shaikh <Shahed.Shaikh@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:21109 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751973AbbFYMUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:09 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <Shahed.Shaikh@qlogic.com>

There's a bug in today's driver where VF requests to add/remove MAC filters
always reach the Hypervisor as add requests.
This prevents the VF from changing its MAC address, as it cannot remove the
previously configured MAC and runs out of MAC credits.

Signed-off-by: Shahed Shaikh <Shahed.Shaikh@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9628595..c1033a5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8435,7 +8435,7 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 					 BNX2X_ETH_MAC, &ramrod_flags);
 	} else { /* vf */
 		return bnx2x_vfpf_config_mac(bp, bp->dev->dev_addr,
-					     bp->fp->index, true);
+					     bp->fp->index, set);
 	}
 }
 
-- 
1.9.3
