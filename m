From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH 2/2] [sky2] Fix for interrupt handler
Date: Wed, 04 Jul 2012 11:38:46 +0200
Message-ID: <1341394726.14972.41.camel@mlindner-lin.skd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:44157 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933595Ab2GDJiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 05:38:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Re-enable interrupts if it is not our interrupt


Signed-off-by: Mirko Lindner <mlindner@marvell.com>
---
 drivers/net/ethernet/marvell/sky2.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index f1163b2..2b0748d 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3080,8 +3080,10 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
 
 	/* Reading this mask interrupts as side effect */
 	status = sky2_read32(hw, B0_Y2_SP_ISRC2);
-	if (status == 0 || status == ~0)
+	if (status == 0 || status == ~0) {
+		sky2_write32(hw, B0_Y2_SP_ICR, 2);
 		return IRQ_NONE;
+	}
 
 	prefetch(&hw->st_le[hw->st_idx]);
 
-- 
1.7.10.4
