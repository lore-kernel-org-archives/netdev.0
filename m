From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: [RFC PATCH 0/7] ARM: davinci: add support for the am1808 based enbw_cmc board
Date: Mon, 23 Jan 2012 09:56:00 +0100
Message-ID: <1327308967-8092-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, Kevin Hilman <khilman-l0cyMroinI0@public.gmane.org>,
	Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>
To: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

add support for the davinci am1808 based enbw_cmc board.

This is thought as a RFC patchserie, as this patches
surely have to be discussed:

- ARM: davinci: configure davinci aemif chipselects through OF
  not moved to mfd, as mentioned in this discussion:
  http://davinci-linux-open-source.1494791.n2.nabble.com/PATCH-arm-davinci-configure-davinci-aemif-chipselects-through-OF-td7059739.html
  instead use a phandle in the DTS, so drivers which
  uses the davinci aemif, can call davinci_aemif_setup_timing_of()

  This is just thought as an RFC ... The enbw_cmc board
  support not really need to setup this bus timings, as
  they are setup in U-Boot ... but I want to post this,
  as I think, it is a nice to have, and I am not really
  sure, if this has to be a MFD device (If so, all bus
  interfaces for other SoCs should be converted also to
  MFD devices) ... as an example how this can be used
  I add this to the davinci nand controller OF support
  patch, in this patchserie.

- ARM: davinci: mux: add OF support
  I want to get rid of the pin setup code in board code ...
  This patch introduces a davinci_cfg_reg_of() function,
  which davinci drivers can call, if they found a
  "pinmux-handle", so used in the following drivers in
  this patchserie:

  drivers/net/ethernet/ti/davinci_emac
  drivers/i2c/busses/i2c-davinci.c
  drivers/mtd/nand/davinci_nand.c

- post this board support with USB support, even though
  USB is only working with the 10 ms "workaround", posted here:
  http://comments.gmane.org/gmane.linux.usb.general/54505
  I see this issue also on the AM1808 TMDXEXP1808L evalboard.

- MMC and USB are not using OF support yet, ideas how to port
  this are welcome. I need for USB and MMC board specific
  callbacks, how to solve this with OF support?

Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>
Cc: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Cc: Kevin Hilman <khilman-l0cyMroinI0@public.gmane.org>
Cc: Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>

Heiko Schocher (7):
  ARM: davinci, intc: Add OF support for TI interrupt controller
  ARM: davinci: configure davinci aemif chipselects through OF
  ARM: davinci: mux: add OF support
  ARM: davinci: net: davinci_emac: add OF support
  ARM: davinci: i2c: add OF support
  ARM: mtd: nand: davinci: add OF support for davinci nand controller
  ARM: davinci: add support for the am1808 based enbw_cmc board

 .../devicetree/bindings/arm/davinci/aemif.txt      |  119 ++++++
 .../bindings/arm/davinci/davinci_emac.txt          |   46 +++
 .../devicetree/bindings/arm/davinci/i2c.txt        |   39 ++
 .../devicetree/bindings/arm/davinci/intc.txt       |   26 ++
 .../devicetree/bindings/arm/davinci/mux.txt        |   40 ++
 .../devicetree/bindings/arm/davinci/nand.txt       |   72 ++++
 arch/arm/boot/dts/enbw_cmc.dts                     |  286 +++++++++++++++
 arch/arm/configs/enbw_cmc_defconfig                |  125 +++++++
 arch/arm/mach-davinci/Kconfig                      |    8 +
 arch/arm/mach-davinci/Makefile                     |    1 +
 arch/arm/mach-davinci/aemif.c                      |   86 +++++-
 arch/arm/mach-davinci/board-enbw-cmc.c             |  384 ++++++++++++++++++++
 arch/arm/mach-davinci/cp_intc.c                    |   51 +++
 arch/arm/mach-davinci/include/mach/aemif.h         |    1 +
 arch/arm/mach-davinci/include/mach/cp_intc.h       |    1 +
 arch/arm/mach-davinci/include/mach/mux.h           |    2 +
 arch/arm/mach-davinci/include/mach/uncompress.h    |    1 +
 arch/arm/mach-davinci/mux.c                        |   73 ++++-
 drivers/i2c/busses/i2c-davinci.c                   |   43 +++
 drivers/mtd/nand/davinci_nand.c                    |   78 ++++-
 drivers/net/ethernet/ti/davinci_emac.c             |  111 ++++++-
 21 files changed, 1588 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/aemif.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/i2c.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/intc.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/mux.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/nand.txt
 create mode 100644 arch/arm/boot/dts/enbw_cmc.dts
 create mode 100644 arch/arm/configs/enbw_cmc_defconfig
 create mode 100644 arch/arm/mach-davinci/board-enbw-cmc.c

-- 
1.7.7.5
