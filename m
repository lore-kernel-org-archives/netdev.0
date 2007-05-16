From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH 3/3] ibm_emac: fix link speed detection change
Date: Wed, 16 May 2007 12:01:05 -0700
Message-ID: <20070516190105.GC14704@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-embedded@ozlabs.org, Stefan Roese <sr@denx.de>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:50930 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561AbXEPTBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 15:01:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix link speed detection change.
Thanks to Stefan Roese <sr@denx.de> for finding this bug.

CC: Stefan Roese <sr@denx.de>
Signed-off-by: Eugene Surovegin <ebs@ebshome.net>

---
 drivers/net/ibm_emac/ibm_emac_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 50035eb..f752e5f 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -926,7 +926,7 @@ static int emac_link_differs(struct ocp_enet_private *dev)
 	int duplex = r & EMAC_MR1_FDE ? DUPLEX_FULL : DUPLEX_HALF;
 	int speed, pause, asym_pause;
 
-	if (r & (EMAC_MR1_MF_1000 | EMAC_MR1_MF_1000GPCS))
+	if (r & EMAC_MR1_MF_1000)
 		speed = SPEED_1000;
 	else if (r & EMAC_MR1_MF_100)
 		speed = SPEED_100;
