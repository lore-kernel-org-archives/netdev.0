From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/21] more arm build fixes
Date: Thu, 25 Apr 2013 19:28:43 +0200
Message-ID: <1366910944-3033663-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Airlie <airlied@linux.ie>, Felipe Balbi <balbi@ti.com>,
	Grant Likely <grant.likely@linaro.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Inki Dae <inki.dae@samsung.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Joerg Roedel <joro@8bytes.org>,
	Nicolas Pitre <nico@linaro.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Rob Herring <robherring2@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Simon Horman <horms+renesas@verge.net.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Will Deacon <will.deacon@arm.com>, alsa-devel@alsa-project.org,
	dri-devel@lists.freedesktop.org,
	linux-atm-general@lists.sourceforge.net,
	linux-scsi@vger.kernel.org, linux-usb@
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi subsystem maintainers,

Here is another set of patches that resulted from build testing on
linux-next. Please apply directly into your trees if you agree,
or let me know if I made a mistake.

I can take whatever remains through the arm-soc tree if you prefer
that or I don't hear back.

	Arnd


Arnd Bergmann (21):
  ARM: topology: export cpu_topology
  ARM: default machine descriptor for multiplatform
  ARM: shmobile: don't call irqchip_init unconditionally
  ARM: orion5x: include linux/cpu.h
  atm: he: use mdelay instead of large udelay constants
  ALSA: ali5451: use mdelay instead of large udelay constants
  oss/dmabuf: use dma_map_single
  drm/nouveau: use mdelay instead of large udelay constants
  drm: export drm_vm_open_locked
  [SCSI] nsp32: use mdelay instead of large udelay constants
  irqdomain: export irq_domain_add_simple
  irqchip: s3c24xx: add missing __init annotations
  iommu: tegra: print dma_addr_t using %lld
  cpufreq: pxa2xx: initialize variables
  thermal: cooling: avoid uninitialied used gcc warning
  OF: remove #ifdef from linux/of_platform.h
  X.509: do not emit any informational output
  USB: ehci-msm: USB_MSM_OTG needs USB_PHY
  USB: lpc32xx: ISP1301 needs USB_PHY
  USB: OMAP: ISP1301 needs USB_PHY
  USB: OHCI: avoid conflicting platform drivers

 arch/arm/Kconfig                                   |   1 -
 arch/arm/configs/lpc32xx_defconfig                 |   1 +
 arch/arm/configs/msm_defconfig                     |   1 +
 arch/arm/configs/omap1_defconfig                   |   1 +
 arch/arm/kernel/devtree.c                          |   7 ++
 arch/arm/kernel/setup.c                            |  11 +-
 arch/arm/kernel/topology.c                         |   1 +
 arch/arm/mach-orion5x/common.c                     |   1 +
 arch/arm/mach-shmobile/intc-r8a7740.c              |  13 +-
 drivers/atm/he.c                                   |   2 +-
 drivers/cpufreq/pxa2xx-cpufreq.c                   |   5 +-
 drivers/gpu/drm/drm_vm.c                           |   1 +
 drivers/gpu/drm/nouveau/core/engine/disp/dacnv50.c |   3 +-
 drivers/iommu/tegra-gart.c                         |   3 +-
 drivers/iommu/tegra-smmu.c                         |   2 +-
 drivers/irqchip/irq-s3c24xx.c                      |   4 +-
 drivers/scsi/nsp32.c                               |   2 +-
 drivers/thermal/cpu_cooling.c                      |  17 +--
 drivers/usb/gadget/Kconfig                         |   2 +
 drivers/usb/host/Kconfig                           |   1 +
 drivers/usb/host/ohci-hcd.c                        | 136 ++++++++++++++++++---
 drivers/usb/phy/Makefile                           |   2 +-
 include/linux/of_platform.h                        |  13 +-
 kernel/irq/irqdomain.c                             |   1 +
 lib/build_OID_registry                             |   2 -
 sound/oss/dmabuf.c                                 |   3 +-
 sound/pci/ali5451/ali5451.c                        |   8 +-
 27 files changed, 187 insertions(+), 57 deletions(-)

-- 
1.8.1.2

Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: David Airlie <airlied@linux.ie>
Cc: Felipe Balbi <balbi@ti.com>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Inki Dae <inki.dae@samsung.com>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: Nicolas Pitre <nico@linaro.org>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Rob Herring <robherring2@gmail.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Simon Horman <horms+renesas@verge.net.au>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: alsa-devel@alsa-project.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-atm-general@lists.sourceforge.net
Cc: linux-scsi@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: netdev@vger.kernel.org
