From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [RFC 0/3] arm: mxs: sanitize enet_out clock handling
Date: Tue, 29 Jan 2013 15:46:10 +0100
Message-ID: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Cc: netdev@vger.kernel.org, Shawn Guo <shawn.guo@freescale.com>,
	Wolfram Sang <w.sang@pengutronix.de>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59047 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756569Ab3A2Oq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 09:46:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handling enet_out on MX28 is cumbersome at the moment. Most boards need it
enabled and for that, they have to add code to mach-mxs.c (see sps1 as an
example). Since this is board specific, we better encode it in the devicetree,
that is the reason it was made for.

My proposal will overwrite the generic "clock" and "clock-names" properties
from imx28.dtsi in the board file. The original one has 2 entries, and boards
needing enet_out will overload it with three entries. The network driver will
enable the clock if it was specified. The old code enabling the clock will be
backward compatible but print a WARN if the legacy mode needs to be used.

This will make adding new board easier, since we don't have to touch mach-mxs.c
for this case. It scales much better.

Tested on a MX28EVK. Please review, comment, apply(?)

Thanks,

   Wolfram


Wolfram Sang (3):
  net: freescale: fec: add support for optional enet_out clk
  arm: mxs: add enet_out clock to devicetree
  arm: mach-mxs: make enabling enet_out a legacy function

 arch/arm/boot/dts/imx28-apf28.dts      |    3 +++
 arch/arm/boot/dts/imx28-apx4devkit.dts |    3 +++
 arch/arm/boot/dts/imx28-cfa10049.dts   |    3 +++
 arch/arm/boot/dts/imx28-evk.dts        |    3 +++
 arch/arm/boot/dts/imx28-sps1.dts       |    3 +++
 arch/arm/boot/dts/imx28-tx28.dts       |    3 +++
 arch/arm/mach-mxs/mach-mxs.c           |   24 ++++++++++++++++--------
 drivers/net/ethernet/freescale/fec.c   |   10 ++++++++++
 drivers/net/ethernet/freescale/fec.h   |    1 +
 9 files changed, 45 insertions(+), 8 deletions(-)

-- 
1.7.10.4
