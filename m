From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 1/3] e1000e: NIC goes up and immediately goes down
Date: Tue,  7 Aug 2012 01:04:15 -0700
Message-ID: <1344326657-9376-2-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, ffutigam@redhat.com,
	mleitner@redhat.com, stable@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49719 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab2HGIFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 04:05:44 -0400
In-Reply-To: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

Found that commit d478eb44 was a bad commit.
If the link partner is transmitting codeword (even if NULL codeword),
then the RXCW.C bit will be set so check for RXCW.CW is unnecessary.
Ref: RH BZ 840642

Reported-by: Fabio Futigami <ffutigam@redhat.com>
Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
CC: Marcelo Ricardo Leitner <mleitner@redhat.com>
CC: stable <stable@vger.kernel.org> [2.6.38+]
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 0b3bade..2a4ded2 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1601,10 +1601,8 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 			 * auto-negotiation in the TXCW register and disable
 			 * forced link in the Device Control register in an
 			 * attempt to auto-negotiate with our link partner.
-			 * If the partner code word is null, stop forcing
-			 * and restart auto negotiation.
 			 */
-			if ((rxcw & E1000_RXCW_C) || !(rxcw & E1000_RXCW_CW))  {
+			if (rxcw & E1000_RXCW_C) {
 				/* Enable autoneg, and unforce link up */
 				ew32(TXCW, mac->txcw);
 				ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
-- 
1.7.11.2
