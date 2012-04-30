From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 2/2] ucc_geth: Add 16 bytes to max TX frame for VLANs
Date: Mon, 30 Apr 2012 10:36:55 +0200
Message-ID: <1335775015-14718-2-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1335775015-14718-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:54650 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877Ab2D3IhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 04:37:11 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id A2793258135
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 10:37:10 +0200 (CEST)
In-Reply-To: <1335775015-14718-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating a VLAN interface on top of ucc_geth adds 4 bytes
to the frame and the HW controller is not prepared to
TX a frame bigger than 1518 bytes which is 4 bytes too
small for a full VLAN frame. Add 16 bytes which will handle
the a simple VLAN and leaves 12 bytes for future expansion.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index ba2dc08..638c8cb 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -116,10 +116,10 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.maxGroupAddrInHash = 4,
 	.maxIndAddrInHash = 4,
 	.prel = 7,
-	.maxFrameLength = 1518,
+	.maxFrameLength = 1518+16, /* Add extra bytes for VLANs etc. */
 	.minFrameLength = 64,
-	.maxD1Length = 1520,
-	.maxD2Length = 1520,
+	.maxD1Length = 1520+16, /* Add extra bytes for VLANs etc. */
+	.maxD2Length = 1520+16, /* Add extra bytes for VLANs etc. */
 	.vlantype = 0x8100,
 	.ecamptr = ((uint32_t) NULL),
 	.eventRegMask = UCCE_OTHER,
-- 
1.7.3.4
