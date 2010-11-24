From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 12/17 v2] can: EG20T PCH: Fix bit timing calculation
 issue
Date: Wed, 24 Nov 2010 16:38:16 +0900
Message-ID: <4CECC0E8.60806__4583.63946895606$1290584452$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11841 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751488Ab0KXHim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 02:38:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix bit timing calculation issue
Modify like use calculated value directly passed by CAN core module.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 7342030..466f011 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -800,17 +800,15 @@ static int pch_set_bittiming(struct net_device *ndev)
 	const struct can_bittiming *bt = &priv->can.bittiming;
 	u32 canbit;
 	u32 bepe;
-	u32 brp;
  	/* Setting the CCE bit for accessing the Can Timing register. */
 	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_CCE);
 -	brp = (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
-	canbit = brp & PCH_MSK_BITT_BRP;
+	canbit = (bt->brp - 1) & PCH_MSK_BITT_BRP;
 	canbit |= (bt->sjw - 1) << PCH_BIT_SJW_SHIFT;
 	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1_SHIFT;
 	canbit |= (bt->phase_seg2 - 1) << PCH_BIT_TSEG2_SHIFT;
-	bepe = (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHIFT;
+	bepe = ((bt->brp - 1) & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHIFT;
 	iowrite32(canbit, &priv->regs->bitt);
 	iowrite32(bepe, &priv->regs->brpe);
 	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);
-- 
1.6.0.6

