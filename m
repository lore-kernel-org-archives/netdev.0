From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 0/4] cpsw: support for control module register
Date: Thu, 22 Aug 2013 13:37:24 +0200
Message-ID: <1377171448-27924-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to make the cpsw driver work in for example RMII mode with
external clock the driver needs to learn about the control module
register that is at least available on AM33xx SoCs. I'm not sure
whether other chips have similar or compatible bits in such a register,
hence I limited the code paths to that familiy only.

This series is necessary to make the cpsw driver work after resume on
my systems, because that control register is only written from the
bootloader at startup, and its content is altered after resume, so it
needs reprogramming.

The first patch is actually just a cleanup to make the additional
memory resource handling cleaner.

Patches 1-3 are for the net tree and apply to net-next. Patch 4/4 is
for the ARM/dts tree, but can be merged independently.

Thanks,
Daniel

Daniel Mack (4):
  net: ethernet: cpsw: switch to devres allocations
  net: ethernet: cpsw: add optional third memory region for CONTROL
    module
  net: ethernet: cpsw: add support for hardware interface mode config
  ARM: dts: am33xx: add third memory region to cpsw block

 Documentation/devicetree/bindings/net/cpsw.txt |   7 +-
 arch/arm/boot/dts/am33xx.dtsi                  |   3 +-
 drivers/net/ethernet/ti/cpsw.c                 | 218 ++++++++++++++-----------
 include/linux/platform_data/cpsw.h             |   1 +
 4 files changed, 132 insertions(+), 97 deletions(-)

-- 
1.8.3.1

