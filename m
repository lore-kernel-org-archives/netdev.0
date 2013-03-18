From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 0/4] ARM: mxs: sanitize enet_out clock handling
Date: Mon, 18 Mar 2013 16:26:21 +0800
Message-ID: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:44038
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181Ab3CRI0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 04:26:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handling enet_out on MX28 is cumbersome at the moment. Most boards need
it enabled and for that, they have to add code to mach-mxs.c (see sps1
as an example). Since this is board specific, we better encode it in
the devicetree, that is the reason it was made for.

The seres propose to have enet_out clock defined in device tree and
have fec driver to enable the clock if found.  This will make adding
new board easier, since we don't have to touch mach-mxs.c for this
case. It scales much better.

Changes since v1:
 * Rebased on v3.9-rc1
 * Add a patch to have clk_ptp handled in the same way that enet_out
   is done
 * Add enet_out into imx28.dtsi and overwrite clocks and clock-names
   for m28evk board where the clock is absent
 * Remove unneeded enet_out clk initialization from board code

David,

If the series looks good to you, I hope I can have your ACK on the
first 2 patches to have the series go via arm-soc tree for sake of
git bisect.  Alternatively, please apply the first 2 on your tree
for 3.10 and we will queue the platform patches for 3.11.

Shawn

Shawn Guo (2):
  net: fec: handle optional clk_ptp more gracefully
  ARM: mxs: remove unneeded enet_out clk initialization

Wolfram Sang (2):
  net: freescale: fec: add support for optional enet_out clk
  ARM: dts: mxs: add enet_out clock to devicetree

 arch/arm/boot/dts/imx28-m28evk.dts   |    2 ++
 arch/arm/boot/dts/imx28.dtsi         |    4 ++--
 arch/arm/mach-mxs/mach-mxs.c         |   12 ------------
 drivers/net/ethernet/freescale/fec.c |   18 +++++++++++++-----
 drivers/net/ethernet/freescale/fec.h |    1 +
 5 files changed, 18 insertions(+), 19 deletions(-)

-- 
1.7.9.5
