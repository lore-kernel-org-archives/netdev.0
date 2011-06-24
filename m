From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 0/5] Add basic device support for imx51 babbage
Date: Sat, 25 Jun 2011 02:04:31 +0800
Message-ID: <1308938676-31121-1-git-send-email-shawn.guo@linaro.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	patches@linaro.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-serial-owner@vger.kernel.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds the basic device tree support for imx51 babbage
board.  With uart and fec dt support added, the dt kernel can boot
into console with nfs root on babbage, so that we get a good base
to start playing dt and converting further drivers to use dt on
imx51.

It creates the platform imx51-dt for using the device tree, and
leaves existing board support files alone, so nothing should be
broken.  The plan is to add stuff step by step into imx51-dt to
get it support every existing imx51 boards, and then remove the
existing board files.

It works against Linus tree plus the dt infrastructure patches
recently posted by Grant Likely.

Changes since v1:
 * Add functions dealing with aliases node
 * Add one patch to remove the use of cpu_is_mx1 in serial driver
 * Address comments on v1 given by Grant and Arnd

Shawn Guo (5):
      dt: add of_alias_scan and of_alias_get_id
      serial/imx: get rid of the use of cpu_is_mx1()
      serial/imx: add device tree support
      net/fec: add device tree support
      ARM: mx5: add basic device tree support for imx51 babbage

Documentation/devicetree/bindings/net/fsl-fec.txt  |   22 +++
 .../bindings/tty/serial/fsl-imx-uart.txt           |   20 +++
 arch/arm/boot/dts/imx51-babbage.dts                |   93 ++++++++++
 arch/arm/mach-imx/clock-imx1.c                     |    6 +-
 arch/arm/mach-mx5/Kconfig                          |    8 +
 arch/arm/mach-mx5/Makefile                         |    1 +
 arch/arm/mach-mx5/imx51-dt.c                       |   70 ++++++++
 arch/arm/plat-mxc/devices/platform-imx-uart.c      |    2 +-
 drivers/net/fec.c                                  |   81 ++++++++-
 drivers/of/base.c                                  |  181 ++++++++++++++++++++
 drivers/of/fdt.c                                   |    6 +
 drivers/tty/serial/imx.c                           |  132 +++++++++++++--
 include/linux/of.h                                 |    7 +
 13 files changed, 606 insertions(+), 23 deletions(-)
