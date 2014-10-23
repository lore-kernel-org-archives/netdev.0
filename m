From: Matei Pavaluca <matei.pavaluca@freescale.com>
Subject: [PATCH net-next 2/3] gianfar: Fix the way the local advertising flow options are determined
Date: Thu, 23 Oct 2014 10:57:56 +0300
Message-ID: <1414051077-4330-2-git-send-email-matei.pavaluca@freescale.com>
References: <1414051077-4330-1-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Pavaluca Matei <matei.pavaluca@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0124.outbound.protection.outlook.com ([65.55.169.124]:42816
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752745AbaJWINN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 04:13:13 -0400
In-Reply-To: <1414051077-4330-1-git-send-email-matei.pavaluca@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavaluca Matei <matei.pavaluca@freescale.com>

Local flow control options needed in order to resolve the negotiation
are incorrectly calculated.

Previously 'mii_advertise_flowctrl' was called to determine the local advertising
options, but these were determined based on FLOW_CTRL_RX/TX flags which are
never set through ethtool.
The patch simply translates from ethtool flow options to mii flow options.

Signed-off-by: Pavaluca Matei <matei.pavaluca@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2485b74..329efca 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3373,7 +3373,11 @@ static u32 gfar_get_flowctrl_cfg(struct gfar_private *priv)
 		if (phydev->asym_pause)
 			rmt_adv |= LPA_PAUSE_ASYM;
 
-		lcl_adv = mii_advertise_flowctrl(phydev->advertising);
+		lcl_adv = 0;
+		if (phydev->advertising & ADVERTISED_Pause)
+			lcl_adv |= ADVERTISE_PAUSE_CAP;
+		if (phydev->advertising & ADVERTISED_Asym_Pause)
+			lcl_adv |= ADVERTISE_PAUSE_ASYM;
 
 		flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
 		if (flowctrl & FLOW_CTRL_TX)
-- 
1.7.11.7
