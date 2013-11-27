From: Laurent Pinchart <laurent.pinchart+renesas-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: [PATCH 00/15] Enable compilation of various Renesas drivers with
	COMPILE_TEST
Date: Wed, 27 Nov 2013 02:18:22 +0100
Message-ID: <1385515117-23664-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>,
	Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>, Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
To: linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

This patch series enables driver compilation with COMPILE_TEST for various
Renesas drivers. The approach taken here is to split the Kconfig depends line
in two, with compile dependencies (if any) on one line and runtime
dependencies (as a list of the platforms on which the hardware can be found)
on another line. The runtime dependencies line is extended with
|| COMPILE_TEST to enable test compilation. This clearly identifies compile
dependencies, and allow test compilation while not clobbering the
configuration menu with useless options in the normal case.

The patches are based on top of v3.13-rc1. To avoid build warnings or errors
during bisection the following patches sent to linux-sh and appropriate
mailing lists should be applied first:

serial: sh-sci: Fix warnings due to improper casts and printk formats
DMA: shdma: Fix warnings due to improper casts and printk formats
DMA: shdma: Fix warnings due to declared but unused symbols
DMA: shdma: Make sh_dmae_pm static
v4l: sh_vou: Fix warnings due to improper casts and printk formats
mmc: sh_mmcif: Factorize DMA channel request and configuration code
mmc: sh_mmcif: Fix compilation warning on 64-bit platforms
mtd: sh_flctl: Fix warnings due to improper casts
fbdev: sh_mobile_lcdcfb: Don't use plain 0 as NULL pointer
spi: sh-msiof: Fix warnings due to improper casts
spi: rcar: Fix uninitialized variable warning
spi: rcar: Fix pointer cast in the remove function

For convenience I've pushed the whole series and its prerequisites to my git
tree at

	git://linuxtv.org/pinchartl/fbdev.git clocks/ccf/multiarch-drivers

The patches will need to go through their respective subsystem's trees. To
help me tracking the mainlining state I'd appreciate if the respective
maintainers could notify me when applying the patches to their trees. Before
doing so I'd like to get an ack from Mark Brown and/or Russell King on the
approach.

Cc: dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Guennadi Liakhovetski <g.liakhovetski-Mmb7MZpHnFY@public.gmane.org>
Cc: Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>
Cc: Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
Cc: Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>
Cc: Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Mauro Carvalho Chehab <m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Cc: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Cc: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>
Cc: Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>
Cc: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Laurent Pinchart (15):
  i2c: shmobile/rcar: Restrict non-COMPILE_TEST compilation
  input: sh_keysc: Restrict non-COMPILE_TEST compilation
  serial: sh-sci: Restrict non-COMPILE_TEST compilation
  iommu: shmobile: Enable driver compilation with COMPILE_TEST
  DMA: shdma: Enable driver compilation with COMPILE_TEST
  v4l: sh_vou: Enable driver compilation with COMPILE_TEST
  mmc: sdhi: Enable driver compilation with COMPILE_TEST
  mmc: sh_mmcif: Enable driver compilation with COMPILE_TEST
  mtd: sh_flctl: Enable driver compilation with COMPILE_TEST
  irda: sh_irda: Enable driver compilation with COMPILE_TEST
  pwm: pwm-renesas-tpu: Enable driver compilation with COMPILE_TEST
  thermal: rcar-thermal: Enable driver compilation with COMPILE_TEST
  fbdev: sh-mobile-lcdcfb: Enable driver compilation with COMPILE_TEST
  spi: sh-msiof: Enable driver compilation with COMPILE_TEST
  sh: intc: Enable driver compilation with COMPILE_TEST

 drivers/dma/sh/Kconfig         | 2 +-
 drivers/i2c/busses/Kconfig     | 4 ++--
 drivers/input/keyboard/Kconfig | 2 +-
 drivers/iommu/Kconfig          | 1 +
 drivers/media/platform/Kconfig | 3 ++-
 drivers/mmc/host/Kconfig       | 6 ++++--
 drivers/mtd/nand/Kconfig       | 2 +-
 drivers/net/irda/Kconfig       | 3 ++-
 drivers/pwm/Kconfig            | 2 +-
 drivers/sh/intc/Kconfig        | 2 +-
 drivers/spi/Kconfig            | 3 ++-
 drivers/thermal/Kconfig        | 2 +-
 drivers/tty/serial/Kconfig     | 3 ++-
 drivers/video/Kconfig          | 8 +++++---
 14 files changed, 26 insertions(+), 17 deletions(-)

-- 
Regards,

Laurent Pinchart
