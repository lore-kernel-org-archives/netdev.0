From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/24] ARM: readl/writel conversion fallout
Date: Fri, 14 Sep 2012 23:34:28 +0200
Message-ID: <1347658492-11608-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, linux-sh@vger.kernel.org,
 Tony Lindgren <tony@atomide.com>, Linus Walleij <linus.walleij@linaro.org>,
 Will Deacon <will.deacon@arm.com>, Wolfram Sang <w.sang@pengutronix.de>,
 Roland Stigge <stigge@antcom.de>, Kukjin Kim <kgene.kim@samsung.com>,
 linux-scsi@vger.kernel.org, Nicolas Pitre <nico@linaro.org>,
 Magnus Damm <magnus.damm@gmail.com>, linux-input@vger.kernel.org,
 Russell King <rmk+kernel@arm.linux.org.uk>,
 David Brown <davidb@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>,
 Nicolas Ferre <nicolas.ferre@atmel.com>, spear-devel@list.st.com,
 Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
 Shiraz Hashim <shiraz.hashim@st.com>, Simon Horman <horms@verge.net.au>,
 Shawn Guo <shawn.guo@linaro.org>, Ryan Mallon <rmallon@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-kernel@vge
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Linux-next currently contains 195bbcac "ARM: 7500/1: io: avoid writeback
addressing modes for __raw_ accessors" from Will Deacon. While this
patch does a number of very useful things, it also causes a lot of
new build warnings in ARM specific code that was passing an integer
as the address into readl/writel or similar functions.

Most architectures have never allowed this, and my feeling is that
it's time for ARM to do the same, so instead of changing the
readl/writel behavior back, we should fix all code that uses
incorrect addressing.

A few people have already posted platform specific patches, this
should take care of the rest that is needed for all defconfig
builds. The majority of the warnings was in the shmobile platform,
so those patches are by far the largest.

I'm happy to have these patches go through individual subsystem
maintainers, especially for the device drivers and those that
have conflicts with other changes (ixp4xx, integrator, shmobile),
but I can carry the reamining ones in one branch for arm-soc.

Right now, the whole set is available in the testing/__iomem
branch.

	Arnd

Cc: "David S. Miller" <davem@davemloft.net>
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: David Brown <davidb@codeaurora.org>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Florian Tobias Schandinat <FlorianSchandinat@gmx.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Imre Kaloz <kaloz@openwrt.org>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Cc: Kukjin Kim <kgene.kim@samsung.com>
Cc: Linus Walleij <linus.walleij@linaro.org>
Cc: Magnus Damm <magnus.damm@gmail.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Roland Stigge <stigge@antcom.de>
Cc: Ryan Mallon <rmallon@gmail.com>
Cc: Sascha Hauer <kernel@pengutronix.de>
Cc: Shawn Guo <shawn.guo@linaro.org>
Cc: Shiraz Hashim <shiraz.hashim@st.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: Tony Lindgren <tony@atomide.com>
Cc: Wolfram Sang <w.sang@pengutronix.de>
Cc: STEricsson_nomadik_linux@list.st.com>
Cc: linux-fbdev@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: spear-devel@list.st.com

Arnd Bergmann (24):
  ARM: shmobile: use __iomem pointers for MMIO
  ARM: at91: use __iomem pointers for MMIO
  ARM: ebsa: use __iomem pointers for MMIO
  ARM: ep93xx: use _iomem pointers for MMIO
  ARM: imx: use __iomem pointers for MMIO
  ARM: integrator: use __iomem pointers for MMIO
  ARM: iop13xx: use __iomem pointers for MMIO
  ARM: iop32x: use __iomem pointers for MMIO
  ARM: ixp4xx: use __iomem pointers for MMIO
  ARM: ks8695: use __iomem pointers for MMIO
  ARM: lpc32xx: use __iomem pointers for MMIO
  ARM: msm: use __iomem pointers for MMIO
  ARM: nomadik: use __iomem pointers for MMIO
  ARM: prima2: use __iomem pointers for MMIO
  ARM: sa1100: use __iomem pointers for MMIO
  ARM: spear13xx: use __iomem pointers for MMIO
  ARM: OMAP: use __iomem pointers for MMIO
  ARM: samsung: use __iomem pointers for MMIO
  sh: use __iomem pointers for MMIO
  input: rpcmouse: use __iomem pointers for MMIO
  serial: ks8695: use __iomem pointers for MMIO
  scsi: eesox: use __iomem pointers for MMIO
  video: da8xx-fb: use __iomem pointers for MMIO
  net: seeq: use __iomem pointers for MMIO

 arch/arm/mach-at91/at91x40.c                    |    2 +-
 arch/arm/mach-at91/at91x40_time.c               |    4 +-
 arch/arm/mach-at91/include/mach/hardware.h      |    4 +-
 arch/arm/mach-at91/include/mach/uncompress.h    |    6 +-
 arch/arm/mach-at91/setup.c                      |    4 +-
 arch/arm/mach-ebsa110/core.c                    |    8 +--
 arch/arm/mach-ebsa110/core.h                    |   12 ++--
 arch/arm/mach-ep93xx/include/mach/ts72xx.h      |   10 ++--
 arch/arm/mach-ep93xx/ts72xx.c                   |   10 ++--
 arch/arm/mach-imx/mach-armadillo5x0.c           |    2 +-
 arch/arm/mach-imx/mach-kzm_arm11_01.c           |    4 +-
 arch/arm/mach-imx/mach-mx31ads.c                |    2 +-
 arch/arm/mach-imx/mach-mx31lite.c               |    2 +-
 arch/arm/mach-integrator/core.c                 |    4 +-
 arch/arm/mach-integrator/cpu.c                  |    8 +--
 arch/arm/mach-integrator/integrator_ap.c        |   12 ++--
 arch/arm/mach-integrator/integrator_cp.c        |    6 +-
 arch/arm/mach-integrator/pci_v3.c               |   12 ++--
 arch/arm/mach-iop13xx/include/mach/iop13xx.h    |   20 +++----
 arch/arm/mach-iop13xx/include/mach/memory.h     |   14 ++---
 arch/arm/mach-iop13xx/io.c                      |   12 ++--
 arch/arm/mach-iop13xx/pci.c                     |   16 +++---
 arch/arm/mach-iop13xx/pci.h                     |    4 +-
 arch/arm/mach-iop13xx/setup.c                   |   10 ++--
 arch/arm/mach-iop32x/glantank.c                 |    2 +-
 arch/arm/mach-ixp4xx/common.c                   |    8 +--
 arch/arm/mach-ixp4xx/include/mach/cpu.h         |    5 +-
 arch/arm/mach-ixp4xx/include/mach/ixp4xx-regs.h |   10 ++--
 arch/arm/mach-ks8695/cpu.c                      |    2 +-
 arch/arm/mach-ks8695/include/mach/hardware.h    |    2 +-
 arch/arm/mach-ks8695/include/mach/uncompress.h  |    6 +-
 arch/arm/mach-lpc32xx/common.c                  |    8 +--
 arch/arm/mach-lpc32xx/include/mach/hardware.h   |    2 +-
 arch/arm/mach-msm/smd.c                         |   19 +++---
 arch/arm/mach-nomadik/board-nhk8815.c           |    3 +-
 arch/arm/mach-nomadik/include/mach/hardware.h   |    2 +-
 arch/arm/mach-nomadik/include/mach/uncompress.h |    8 +--
 arch/arm/mach-prima2/include/mach/uncompress.h  |    4 +-
 arch/arm/mach-sa1100/include/mach/simpad.h      |    2 +-
 arch/arm/mach-sa1100/simpad.c                   |    2 +-
 arch/arm/mach-shmobile/board-ap4evb.c           |   12 ++--
 arch/arm/mach-shmobile/board-armadillo800eva.c  |    6 +-
 arch/arm/mach-shmobile/board-bonito.c           |    8 +--
 arch/arm/mach-shmobile/board-g3evm.c            |   12 ++--
 arch/arm/mach-shmobile/board-g4evm.c            |   30 +++++-----
 arch/arm/mach-shmobile/board-kzm9g.c            |    8 +--
 arch/arm/mach-shmobile/board-mackerel.c         |   22 +++----
 arch/arm/mach-shmobile/clock-r8a7740.c          |   46 +++++++--------
 arch/arm/mach-shmobile/clock-sh7367.c           |   44 +++++++-------
 arch/arm/mach-shmobile/clock-sh7372.c           |   60 +++++++++----------
 arch/arm/mach-shmobile/clock-sh7377.c           |   50 ++++++++--------
 arch/arm/mach-shmobile/clock-sh73a0.c           |   70 +++++++++++------------
 arch/arm/mach-shmobile/include/mach/gpio.h      |    6 +-
 arch/arm/mach-shmobile/intc-r8a7779.c           |   14 ++---
 arch/arm/mach-shmobile/intc-sh7372.c            |   27 +++++----
 arch/arm/mach-shmobile/intc-sh73a0.c            |   20 ++++---
 arch/arm/mach-shmobile/pm-rmobile.c             |    6 +-
 arch/arm/mach-shmobile/pm-sh7372.c              |   57 +++++++++---------
 arch/arm/mach-shmobile/setup-sh7367.c           |    2 +-
 arch/arm/mach-shmobile/setup-sh7377.c           |    2 +-
 arch/arm/mach-shmobile/setup-sh73a0.c           |    2 +-
 arch/arm/mach-spear13xx/include/mach/spear.h    |   14 ++---
 arch/arm/mach-spear13xx/spear13xx.c             |    6 +-
 arch/arm/plat-mxc/include/mach/mx31.h           |    6 +-
 arch/arm/plat-omap/include/plat/hardware.h      |   18 +++---
 arch/arm/plat-samsung/s5p-irq-gpioint.c         |    4 +-
 drivers/input/mouse/rpcmouse.c                  |    2 +-
 drivers/net/ethernet/seeq/ether3.c              |    4 +-
 drivers/scsi/arm/eesox.c                        |    2 +-
 drivers/sh/intc/access.c                        |   56 +++++++++---------
 drivers/sh/intc/chip.c                          |    8 +--
 drivers/sh/intc/core.c                          |    6 +-
 drivers/sh/intc/handle.c                        |    6 +-
 drivers/sh/intc/internals.h                     |   18 +++---
 drivers/sh/intc/virq.c                          |    3 +-
 drivers/tty/serial/serial_ks8695.c              |    4 +-
 drivers/video/da8xx-fb.c                        |    8 +--
 include/linux/serial_sci.h                      |    2 +-
 include/linux/sh_clk.h                          |    4 +-
 79 files changed, 477 insertions(+), 471 deletions(-)

-- 
1.7.10
