From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v2 0/3] net: can: Use syscon regmap for TI specific RAMINIT register
Date: Tue, 9 Sep 2014 17:31:07 +0300
Message-ID: <1410273070-22485-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tony@atomide.com>, <tglx@linutronix.de>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<nm@ti.com>, <sergei.shtylyov@cogentembedded.com>,
	<linux-omap@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
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
git@github.com:rogerq/linux.git	[for-v3.18/can]

Changelog:

v2:
- added "ti" vendor prefix to TI specific raminit properties.
- split DTS changes into a separate series

cheers,
-roger
---

Roger Quadros (3):
  can: c_can_platform: Fix c_can_hw_raminit_ti() and add timeout
  net: can: c_can: Add syscon/regmap RAMINIT mechanism
  net: can: c_can: Add support for START pulse in RAMINIT sequence

 .../devicetree/bindings/net/can/c_can.txt          |  10 ++
 drivers/net/can/c_can/c_can.h                      |  12 +-
 drivers/net/can/c_can/c_can_platform.c             | 123 ++++++++++++++++-----
 3 files changed, 114 insertions(+), 31 deletions(-)

-- 
1.8.3.2

