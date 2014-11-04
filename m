From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v3 0/8] net: can: Use syscon regmap for TI specific RAMINIT register
Date: Tue, 4 Nov 2014 12:20:53 +0200
Message-ID: <1415096461-25576-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Some hardware (TI am43xx) has a buggy RAMINIT DONE mechanism and it might
not always set the DONE bit. This will result in a lockup in c_can_hw_raminit_wait_ti(),
so patch 1 adds a timeout mechanism there.

There is a non compliancy within TI platforms with respect to the
layout of the RAMINIT register. The patches 2 and 3 address this issue
and make a flexible but standard way of defining the RAMINIT hardware register
layout in the device tree. The RAMINIT register is accessed using the syscon
regmap framework.

Patches available at
git@github.com:rogerq/linux.git	[for-v3.19/can]

Patches are tested on am335x-evm, am437x-gp-evm and dra7-evm.
Board support files to allow CAN testing on these boards are available at
git@github.com:rogerq/linux.git	[for-v3.19/omap-dts-dcan]

Changelog:

v3:
- allow driver data to be more than just CAN_ID
- RAMINIT register data moved to driver data instead of device tree file.

v2:
- added "ti" vendor prefix to TI specific raminit properties.
- split DTS changes into a separate series

cheers,
-roger
---

Roger Quadros (8):
  net: can: c_can: Add timeout to c_can_hw_raminit_ti()
  net: can: c_can: Introduce c_can_driver_data structure
  net: can: c_can: Add RAMINIT register information to driver data
  net: can: c_can: Add syscon/regmap RAMINIT mechanism
  net: can: c_can: Add support for START pulse in RAMINIT sequence
  net: can: c_can: Disable pins when CAN interface is down
  net: can: c_can: Add support for TI DRA7 DCAN
  net: can: c_can: Add support for TI am3352 DCAN

 .../devicetree/bindings/net/can/c_can.txt          |   5 +
 drivers/net/can/c_can/c_can.c                      |  20 ++
 drivers/net/can/c_can/c_can.h                      |  20 +-
 drivers/net/can/c_can/c_can_platform.c             | 207 +++++++++++++++------
 4 files changed, 191 insertions(+), 61 deletions(-)

-- 
1.8.3.2

