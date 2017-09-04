From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: [net v2] gianfar: Fix Tx flow control deactivation
Date: Mon, 4 Sep 2017 10:45:28 +0300
Message-ID: <1504511128-25294-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0075.outbound.protection.outlook.com ([104.47.32.75]:21920
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753259AbdIDHpe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 03:45:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The wrong register is checked for the Tx flow control bit,
it should have been maccfg1 not maccfg2.
This went unnoticed for so long probably because the impact is
hardly visible, not to mention the tangled code from adjust_link().
First, link flow control (i.e. handling of Rx/Tx link level pause frames)
is disabled by default (needs to be enabled via 'ethtool -A').
Secondly, maccfg2 always returns 0 for tx_flow_oldval (except for a few
old boards), which results in Tx flow control remaining always on
once activated.

Should be queued for -stable, thanks.

Fixes: 45b679c9a3ccd9e34f28e6ec677b812a860eb8eb ("gianfar: Implement PAUSE frame generation support")

Signed-off-by: Claudiu Manoil <claudiu.manoil@nxp.com>
---
v2: "Fixes" tag formatting and removed CC: stable from comments.

 drivers/net/ethernet/freescale/gianfar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index c4b4b0a..5be52d8 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3687,7 +3687,7 @@ static noinline void gfar_update_link_state(struct gfar_private *priv)
 		u32 tempval1 = gfar_read(&regs->maccfg1);
 		u32 tempval = gfar_read(&regs->maccfg2);
 		u32 ecntrl = gfar_read(&regs->ecntrl);
-		u32 tx_flow_oldval = (tempval & MACCFG1_TX_FLOW);
+		u32 tx_flow_oldval = (tempval1 & MACCFG1_TX_FLOW);
 
 		if (phydev->duplex != priv->oldduplex) {
 			if (!(phydev->duplex))
-- 
2.7.4
