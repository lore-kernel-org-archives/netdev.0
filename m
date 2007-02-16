From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 2/2] B44: increase wait loop
Date: Fri, 16 Feb 2007 13:27:27 -0800
Message-ID: <1171661247.20573.27.camel@dhcp-10-7-81-58.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lourdas_v@yahoo.gr,
	akpm@linux-foundation.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4946 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932269AbXBPVmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 16:42:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The b44 Enet control disable bit may take longer to clear on some
systems, so the loop count is increased with this patch. Functionality
is not compromised, but a debug message can be seen when the bit is not
cleared within the count value.
Thanks to Vasileios Lourdas who reported the problem.

Signed-off by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 9332f4c..aaada57 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1288,7 +1288,7 @@ static void b44_chip_reset(struct b44 *b
 	if (ssb_is_core_up(bp)) {
 		bw32(bp, B44_RCV_LAZY, 0);
 		bw32(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE);
-		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 100, 1);
+		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 200, 1);
 		bw32(bp, B44_DMATX_CTRL, 0);
 		bp->tx_prod = bp->tx_cons = 0;
 		if (br32(bp, B44_DMARX_STAT) & DMARX_STAT_EMASK) {


