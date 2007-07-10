From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] QE Ethernet driver writes to wrong register to mask interrupts
Date: Tue, 10 Jul 2007 07:51:11 -0500
Message-ID: <11840718711477-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:61884 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbXGJMvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 08:51:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The QE Ethernet driver was writing to the wrong register to mask interrupts.
In ucc_geth_stop(), it was clearing UCCE instead of UCCM.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 18b731b..e4736a3 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2276,7 +2276,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	phy_stop(phydev);
 
 	/* Mask all interrupts */
-	out_be32(ugeth->uccf->p_ucce, 0x00000000);
+	out_be32(ugeth->uccf->p_uccm, 0x00000000);
 
 	/* Clear all interrupts */
 	out_be32(ugeth->uccf->p_ucce, 0xffffffff);
-- 
1.5.0.2.260.g2eb065

