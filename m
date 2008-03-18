From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Tue, 18 Mar 2008 16:11:28 +0100
Message-ID: <1205853088-30171-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Netdev <netdev@vger.kernel.org>, Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:60061 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753172AbYCSTgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:36:55 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 348892b..038ec75 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -114,10 +114,10 @@ static struct ucc_geth_info ugeth_primary_info = {
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
1.5.4.3

