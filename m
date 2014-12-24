From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v1 0/3] net: fec: add Wake-on-LAN support
Date: Wed, 24 Dec 2014 17:30:38 +0800
Message-ID: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0135.outbound.protection.outlook.com ([65.55.169.135]:40608
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751751AbaLXKU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:20:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series enable FEC Wake-on-LAN feature for i.MX6q/dl and i.MX6SX SOCs.
FEC HW support sleep mode, when system in suspend status with FEC all clock gate
off, magic packet can wake up system. For different SOCs, there have special SOC
GPR register to let FEC enter sleep mode or exit sleep mode, add these to platform
callback for driver' call.

Patch#1: add WOL interface supports.
Patch#2: add SOC special sleep of/off operations for driver's sleep callback.
Patch#3: add magic pattern support for devicetree.

Fugang Duan (3):
  net: fec: add Wake-on-LAN support
  ARM: imx: add FEC sleep mode callback function
  ARM: dts: imx6qdl: enable FEC magic-packet feature

 Documentation/devicetree/bindings/net/fsl-fec.txt |    2 +
 arch/arm/boot/dts/imx6qdl-sabreauto.dtsi          |    1 +
 arch/arm/boot/dts/imx6qdl-sabresd.dtsi            |    1 +
 arch/arm/mach-imx/mach-imx6q.c                    |   41 ++++++++-
 arch/arm/mach-imx/mach-imx6sx.c                   |   50 ++++++++++
 drivers/net/ethernet/freescale/fec.h              |    2 +
 drivers/net/ethernet/freescale/fec_main.c         |  104 +++++++++++++++++++--
 include/linux/fec.h                               |    1 +
 8 files changed, 191 insertions(+), 11 deletions(-)

-- 
1.7.8
