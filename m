From: Stefan Roese <sr@denx.de>
Subject: [PATCH] ibm_newemac: Fix problem with jumbo frame support and EMAC V4
Date: Thu,  3 Apr 2008 16:16:56 +0200
Message-ID: <1207232216-21053-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:58719 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbYDCORI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 10:17:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the jumbo frame support on EMAC V4 systems. Now the correct
bit is set depending on the EMAC version configured.

Tested on Kilauea (405EX) and Canyonlands (460EX).

Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/core.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 0789802..486901f 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -524,7 +524,10 @@ static int emac_configure(struct emac_instance *dev)
 		rx_size = dev->rx_fifo_size_gige;
 
 		if (dev->ndev->mtu > ETH_DATA_LEN) {
-			mr1 |= EMAC_MR1_JPSM;
+			if (emac_has_feature(dev, EMAC_FTR_EMAC4))
+				mr1 |= EMAC4_MR1_JPSM;
+			else
+				mr1 |= EMAC_MR1_JPSM;
 			dev->stop_timeout = STOP_TIMEOUT_1000_JUMBO;
 		} else
 			dev->stop_timeout = STOP_TIMEOUT_1000;
-- 
1.5.4.5

