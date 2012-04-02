From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH v2 0/8]: arm: lpc32xx: Device tree support
Date: Mon,  2 Apr 2012 20:32:59 +0200
Message-ID: <1333391587-26290-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>
To: arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-i2c@vger.kernel.org, linux-kernel@vger.kernel.org,
 w.sang@pengutronix.de, srinivas.bakki@nxp.com, kevin.wells@nxp.com,
 gregkh@linuxfoundation.org, netdev@vger.kernel.org,
 rtc-linux@googlegroups.com, a.zummo@towertech.it,
 linux-watchdog@vger.kernel.org, wim@iguana.be, jonsmirl@gmail.com
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

This is the first series of patches to introduce device tree support for the
LPC32xx SoC. This series includes patches for the various subsystems to support
device tree to be used later by the machine's initialization.

The patches apply to various subsystems:

 * staging/iio/adc (1)
 * rtc (1)
 * net (1)
 * wdt (1)
 * i2c (4)
 * arm-soc (i2c related in the former, to be merged via i2c, as suggested by
	    Arnd Bergmann)

Based on v3.4-rc1

You can also pull from

  git://git.antcom.de/linux-2.6 lpc32xx/dt

I'm CC'ing the various subsystem maintainers and lists who can each see what's
going on and please pick their respective subsystem's changes. - Thanks!

Changes since patch v1:
 * Reorganized the changes for i2c (#5-8), fixes bisecting
 * Fixed device tree Documentation
 * Init .of_match_table via of_match_ptr() instead of #ifdef

Thanks to Arnd Bergmenn for reviewing!

Signed-off-by: Roland Stigge <stigge@antcom.de>

--

Roland Stigge (8):
 iio: Add device tree support to LPC32xx ADC
 rtc: Add device tree support for LPC32xx
 net: Add device tree support to LPC32xx
 wdt: Device tree support for pnx4008-wdt
 i2c-pnx.c: Fix suspend
 i2c-pnx.c: Use resources in platforms
 i2c-pnx.c: Remove duplicated i2c.h
 i2c: Add device tree support to i2c-pnx.c

 Documentation/devicetree/bindings/i2c/pnx.txt                     |   40 ++
 Documentation/devicetree/bindings/net/lpc-eth.txt                 |   24 +
 Documentation/devicetree/bindings/rtc/lpc32xx-rtc.txt             |   15 
 Documentation/devicetree/bindings/staging/iio/adc/lpc32xx-adc.txt |   16 
 Documentation/devicetree/bindings/watchdog/pnx4008-wdt.txt        |   13 
 arch/arm/mach-lpc32xx/common.c                                    |   75 ++--
 arch/arm/mach-lpc32xx/include/mach/i2c.h                          |   63 ---
 arch/arm/mach-pnx4008/i2c.c                                       |   70 ++--
 arch/arm/mach-pnx4008/include/mach/i2c.h                          |   64 ---
 drivers/i2c/busses/i2c-pnx.c                                      |  161 +++++++---
 drivers/net/ethernet/nxp/lpc_eth.c                                |   77 ++--
 drivers/rtc/rtc-lpc32xx.c                                         |   12 
 drivers/staging/iio/adc/lpc32xx_adc.c                             |   10 
 drivers/watchdog/pnx4008_wdt.c                                    |   10 
 include/linux/i2c-pnx.h                                           |   10 
 15 files changed, 394 insertions(+), 266 deletions(-)
