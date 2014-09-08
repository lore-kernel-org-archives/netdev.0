From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 00/13] net: can: Add can support for TI platforms
Date: Mon, 8 Sep 2014 17:10:29 +0300
Message-ID: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>, Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:50112 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbaIHOLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 10:11:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Some hardware (TI am43xx) has a buggy RAMINIT DONE mechanism and it might
not always set the DONE bit. This will result in a lockup in c_can_hw_raminit_wait_ti(),
so patch 1 adds a timeout mechanism there.

There is a non compliancy within TI platforms with respect to the
layout of the RAMINIT register. The patches 2 and 3 address this issue
and make a flexible but standard way of defining the RAMINIT hardware register
layout in the device tree. The RAMINIT register is accessed using the syscon
regmap framework.

The patches 4 to 13 add adaptation details for am43xx and dra7x Socs and
EVMs.

cheers,
-roger

---

Afzal Mohammed (1):
  arm: dts: am4372: Add dcan nodes

Dave Gerlach (1):
  ARM: dts: am437x-gp-evm: Add pinctrl sleep states for dcan pins

Mugunthan V N (1):
  arm: dts: am437x-gp: Add dcan support

Roger Quadros (10):
  can: c_can_platform: Fix c_can_hw_raminit_ti() and add timeout
  net: can: c_can: Add syscon/regmap RAMINIT mechanism
  net: can: c_can: Add support for START pulse in RAMINIT sequence
  ARM: dts: dra7: Add syscon regmap for CORE CONTROL area
  ARM: dts: DRA7: Add DCAN nodes
  ARM: dts: dra7-evm: Add CAN support
  ARM: dts: dra72-evm: Add CAN support
  ARM: dts: AM43xx: Add aliases to d_can nodes
  ARM: dts: am4372: Add control module syscon node
  ARM: dts: am4372: Add dcan raminit bits

 .../devicetree/bindings/net/can/c_can.txt          |  10 ++
 arch/arm/boot/dts/am4372.dtsi                      |  35 ++++++
 arch/arm/boot/dts/am437x-gp-evm.dts                |  42 ++++++++
 arch/arm/boot/dts/dra7-evm.dts                     |  21 ++++
 arch/arm/boot/dts/dra7.dtsi                        |  35 ++++++
 arch/arm/boot/dts/dra72-evm.dts                    |  23 ++++
 drivers/net/can/c_can/c_can.h                      |  12 ++-
 drivers/net/can/c_can/c_can_platform.c             | 120 ++++++++++++++++-----
 8 files changed, 270 insertions(+), 28 deletions(-)

-- 
1.8.3.2
