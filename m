From: <Frank.Li@freescale.com>
Subject: [Patch v4 net-next 00/12] net: fec: imx6sx multiqueue support
Date: Sat, 13 Sep 2014 05:00:45 +0800
Message-ID: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0115.outbound.protection.outlook.com ([157.56.110.115]:56201
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751056AbaILWFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 18:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>

These patches enable i.MX6SX multi queue support.
i.MX6SX support 3 queue and AVB feature.

Change from v3 to v4
 - use "unsigned int" instead of "unsigned"

Change from v2 to v3
 - fixed alignment requirement for ARM and NO-ARM platform

Change from v1 to v2.
 - Change num_tx_queue to unsigned int
 - Avoid block non-dt platform
 - remove call netif_set_real_num_rx_queues
 - seperate multi queue patch two part, one is tx and rx handle, with fixed queue 0
   then other one is initilized multiqueue
 - use two difference alignment for tx and rx path

Frank Li (4):
  net: fec: init multi queue date structure
  net: fec: add enet-avb IP support
  ARM: Documentation: Update fec dts binding doc
  ARM: dts: imx6sx: add multi-queue support enet

Fugang Duan (8):
  net:fec: add enet refrence clock for i.MX 6SX chip
  net:fec: add enet AVB feature macro define for imx6sx
  net: fec: change data structure to support multiqueue
  net: fec: parser max queue number from dt file
  net:fec: Disable enet-avb MAC instead of reset MAC
  net:fec: Add fsl,imx6sx-fec  compatible strings
  net: fec: change FEC alignment according to i.mx6 sx requirement
  net: fec: init complete variable in early to avoid kernel dump

 Documentation/devicetree/bindings/net/fsl-fec.txt |   6 +
 arch/arm/boot/dts/imx6sx.dtsi                     |   2 +
 drivers/net/ethernet/freescale/fec.h              | 154 +++-
 drivers/net/ethernet/freescale/fec_main.c         | 853 ++++++++++++++++------
 4 files changed, 756 insertions(+), 259 deletions(-)

-- 
1.9.1
