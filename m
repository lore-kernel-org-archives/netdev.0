From: Heiko Schocher <hs@denx.de>
Subject: [PATCH] [net, 83xx] ucc_geth.c: Fix upsmr setting in RMII mode
Date: Tue, 21 Apr 2009 10:36:43 +0200
Message-ID: <49ED859B.30904@denx.de>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Shlomi Gridish <gridish@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:39239 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbZDUJeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 05:34:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If using the UCC on a MPC8360 in RMII mode, don;t set
UCC_GETH_UPSMR_RPM bit in the upsmr register.

Signed-off-by: Heiko Schocher <hs@denx.de>
---
 drivers/net/ucc_geth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index d3f39e8..44f8392 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1394,7 +1394,8 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
-		upsmr |= UCC_GETH_UPSMR_RPM;
+		if (ugeth->phy_interface != PHY_INTERFACE_MODE_RMII)
+			upsmr |= UCC_GETH_UPSMR_RPM;
 		switch (ugeth->max_speed) {
 		case SPEED_10:
 			upsmr |= UCC_GETH_UPSMR_R10M;
-- 
1.6.0.6

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
