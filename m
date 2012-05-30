From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: [PATCH v5 0/7] ARM: davinci: add support for the am1808 based enbw_cmc board
Date: Wed, 30 May 2012 12:18:56 +0200
Message-ID: <1338373143-7467-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, Kevin Hilman <khilman-l0cyMroinI0@public.gmane.org>,
	Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>,
	Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
To: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

this patchserie add support for the davinci am1808 based
enbw_cmc board.

changes for v2:
Post this patchserie now as v2, as reworked in the
comments I got for the RFC serie.

changes for v3:
- Interrupt Controller:
  - comment from Sergei Shtylyov:
    - rename compatible" prop to "ti,cp_intc"
    - cp_intc_init() is now also for the of case
      the name of the init function (it calls the
      "new" __cp_intc_init() function, which was
      the "old" cp_intc_init()). Through this
      rework the changes for OF is better visible.
      As the OF case uses the irq_domain rework from
      Grant Likely, maybe the none OF case can use
      this also, but this should be tested on a hw ...

changes for v4:
- Interrupt Controller:
  - split in two patches as Nori Sekhar suggested
    one for the irq_domain change
    one for DT support
  - add comment from Grant Likely for the DT part:
    remove if/else clause, not needed.
    Make use of DT runtime configurable
    The non OF case is not tested!

changes for v5:
- Interrupt Controller:
  add comments from Sergei Shtylyov:
  - s/intc/cp_intc in commit subject
  - Codingstyle fixes
  add comment from Grant Likely:
  - rename compatible" prop to "ti,cp-intc"
  - call irq_domain_add also in the non DT case
    (was fixed in v4)
  - switched from using d->irq to d->hwirq for the hardware
    irq number in irq_chip hooks
- I2C DT support:
  add comments from Grant Likely:
  - do not change value of dev->dev->platform_data, instead
    hold a copy in davinci_i2c_dev.
      
Got no comments to the following points, I noted in the
RFC series, so posting this patchseries with them:

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

  This is removed for v4 serie, as Nori Sekhar suggested.

- post this board support with USB support, even though
  USB is only working with the 10 ms "workaround", posted here:
  http://comments.gmane.org/gmane.linux.usb.general/54505
  I see this issue also on the AM1808 TMDXEXP1808L evalboard.

  change for v4:
  The 10 ms delay is no longer needed, see discussion here:

  http://www.spinics.net/lists/linux-usb/msg64232.html

  shows the way to go ...

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
Cc: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>

Heiko Schocher (7):
  ARM: davinci, cp_intc: Add irq domain support
  ARM: davinci, cp_intc: Add OF support for TI interrupt controller
  ARM: davinci: configure davinci aemif chipselects through OF
  ARM: davinci: net: davinci_emac: add OF support
  ARM: davinci: i2c: add OF support
  ARM: mtd: nand: davinci: add OF support for davinci nand controller
  ARM: davinci: add support for the am1808 based enbw_cmc board

 .../devicetree/bindings/arm/davinci/aemif.txt      |  119 +++++++
 .../devicetree/bindings/arm/davinci/i2c.txt        |   31 ++
 .../devicetree/bindings/arm/davinci/intc.txt       |   27 ++
 .../devicetree/bindings/arm/davinci/nand.txt       |   72 ++++
 .../devicetree/bindings/net/davinci_emac.txt       |   41 +++
 arch/arm/boot/dts/enbw_cmc.dts                     |  172 +++++++++
 arch/arm/configs/enbw_cmc_defconfig                |  123 +++++++
 arch/arm/mach-davinci/Kconfig                      |    9 +
 arch/arm/mach-davinci/Makefile                     |    1 +
 arch/arm/mach-davinci/aemif.c                      |   86 +++++-
 arch/arm/mach-davinci/board-enbw-cmc.c             |  374 ++++++++++++++++++++
 arch/arm/mach-davinci/cp_intc.c                    |   83 ++++-
 arch/arm/mach-davinci/include/mach/aemif.h         |    1 +
 arch/arm/mach-davinci/include/mach/uncompress.h    |    1 +
 drivers/i2c/busses/i2c-davinci.c                   |   49 +++-
 drivers/mtd/nand/davinci_nand.c                    |   80 ++++-
 drivers/net/ethernet/ti/davinci_emac.c             |   87 +++++-
 17 files changed, 1335 insertions(+), 21 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/aemif.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/i2c.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/intc.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/nand.txt
 create mode 100644 Documentation/devicetree/bindings/net/davinci_emac.txt
 create mode 100644 arch/arm/boot/dts/enbw_cmc.dts
 create mode 100644 arch/arm/configs/enbw_cmc_defconfig
 create mode 100644 arch/arm/mach-davinci/board-enbw-cmc.c

-- 
1.7.7.6
