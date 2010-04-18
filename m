From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Sun, 18 Apr 2010 18:13:21 -0500
Message-ID: <1271632401-2472-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54853 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab0DRXNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 19:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When gracefully stopping the controller, the driver was continuing if
*either* RX or TX had stopped.  We need to wait for both, or the
controller could get into an invalid state.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 032073d..6038397 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1571,8 +1571,9 @@ static void gfar_halt_nodisable(struct net_device *dev)
 		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
 		gfar_write(&regs->dmactrl, tempval);
 
-		while (!(gfar_read(&regs->ievent) &
-			 (IEVENT_GRSC | IEVENT_GTSC)))
+		while ((gfar_read(&regs->ievent) &
+			 (IEVENT_GRSC | IEVENT_GTSC)) !=
+			 (IEVENT_GRSC | IEVENT_GTSC))
 			cpu_relax();
 	}
 }
-- 
1.6.5.2.g6ff9a

