From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH] be2net: Remove code that stops further access to BE NIC
 based on UE bits
Date: Mon, 8 Oct 2012 23:18:21 -0500
Message-ID: <20121009041821.GA16595@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:29375 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab2JIESW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 00:18:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On certain platforms, BE hardware could  falsely indicate UE.
For BE family of NICs, do not set hw_error based on the UE bits.
If there was a real fatal error, the corresponding h/w block will
automatically go offline and stop traffic.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index eb3f2cb..d1b6cc5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2129,8 +2129,11 @@ void be_detect_error(struct be_adapter *adapter)
 		ue_hi = (ue_hi & ~ue_hi_mask);
 	}
 
-	if (ue_lo || ue_hi ||
-		sliport_status & SLIPORT_STATUS_ERR_MASK) {
+	/* On certain platforms BE hardware can indicate spurious UEs.
+	 * Allow the h/w to stop working completely in case of a real UE.
+	 * Hence not setting the hw_error for UE detection.
+	 */
+	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
 		adapter->hw_error = true;
 		dev_err(&adapter->pdev->dev,
 			"Error detected in the card\n");
-- 
1.7.9.5
