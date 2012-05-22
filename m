From: Jiajun Wu <b06378@freescale.com>
Subject: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Tue, 22 May 2012 17:00:48 +0800
Message-ID: <1337677248-27792-1-git-send-email-b06378@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, Jiajun Wu <b06378@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:45603 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756863Ab2EVJRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 05:17:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FCB(Frame Control Block) isn't the part of netdev hard header.
Add FCB to hard_header_len will make GRO fail at MAC comparision stage.

Signed-off-by: Jiajun Wu <b06378@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 1adb024..0741ade 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1082,7 +1082,7 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	if (dev->features & NETIF_F_IP_CSUM ||
 			priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
-		dev->hard_header_len += GMAC_FCB_LEN;
+		dev->needed_headroom = GMAC_FCB_LEN;
 
 	/* Program the isrg regs only if number of grps > 1 */
 	if (priv->num_grps > 1) {
-- 
1.5.6.5
