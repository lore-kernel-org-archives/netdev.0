From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Mon, 15 Sep 2008 19:24:45 -0500
Message-ID: <1221524685-25968-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:56481 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228AbYIPAYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 20:24:49 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m8G0OkPV017248
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 17:24:46 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m8G0OkT2029123
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 19:24:46 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Creating a VLAN interface on top of ucc_geth adds 4 bytes
to the frame and the HW controller is not prepared to
TX a frame bigger than 1518 bytes which is 4 bytes too
small for a full VLAN frame. Also add 4 extra bytes for future
expansion.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 8f944e5..8fed4bb 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -113,10 +113,10 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.maxGroupAddrInHash = 4,
 	.maxIndAddrInHash = 4,
 	.prel = 7,
-	.maxFrameLength = 1518,
+	.maxFrameLength = 1518+8, /* Add 4 bytes for VLAN tags and 4 extra bytes */
 	.minFrameLength = 64,
-	.maxD1Length = 1520,
-	.maxD2Length = 1520,
+	.maxD1Length = 1520+8,
+	.maxD2Length = 1520+8,
 	.vlantype = 0x8100,
 	.ecamptr = ((uint32_t) NULL),
 	.eventRegMask = UCCE_OTHER,
-- 
1.5.4.GIT

