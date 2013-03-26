From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH 2/2] sky2: Threshold for Pause Packet is set wrong
Date: Tue, 26 Mar 2013 17:38:42 +0100
Message-ID: <1567731.Oea6BC09CI@mlindner-lin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:50295 "EHLO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754414Ab3CZQlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:41:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sky2 driver sets the Rx Upper Threshold for Pause Packet generation to a
wrong value which leads to only 2kB of RAM remaining space. This can lead to
Rx overflow errors even with activated flow-control.

Fix: We should increase the value to 8192/8

Signed-off-by: Mirko Lindner <mlindner@marvell.com>
---
 drivers/net/ethernet/marvell/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index fc07ca3..6a0e671 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1067,7 +1067,7 @@ static void sky2_ramset(struct sky2_hw *hw, u16 q, u32 start, u32 space)
 		sky2_write32(hw, RB_ADDR(q, RB_RX_UTHP), tp);
 		sky2_write32(hw, RB_ADDR(q, RB_RX_LTHP), space/2);
 
-		tp = space - 2048/8;
+		tp = space - 8192/8;
 		sky2_write32(hw, RB_ADDR(q, RB_RX_UTPP), tp);
 		sky2_write32(hw, RB_ADDR(q, RB_RX_LTPP), space/4);
 	} else {
-- 
1.7.10.4
