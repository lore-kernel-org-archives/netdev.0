From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/19] ARM: common warning fixes
Date: Fri, 25 Jan 2013 14:14:17 +0000
Message-ID: <1359123276-15833-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ingo Molnar <mingo@redhat.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Russell King <linux@arm.linux.org.uk>,
	Samuel Ortiz <sameo@linux.intel.com>, netdev@vger.kernel.org
To: linux-arm-kernel@list.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone,

This series fixes all the known build warnings on
ARM with any of the defconfig files. Most of these
patches are regressions and warn about code that
changed in linux-3.8, so it would be nice to
fix those before the release.

The patch for the ARM_UNWIND warning is added
here for completeness: The warning is old and
particularly annoying, but the patch is not ready
for inclusion.

I have more patches like these for less important
issues, in four classes:

1. warnings and errors that are only present in linux-next
2. warnings about allyesconfig/allnoconfig/allmodconfig
   builds.
3. warnings and errors for various randconfig combinations
4. 'maybe-uninitialized' gcc warnings that only appear
   with gcc-3.7 or 3.8. There are quite a lot of them.

I will get to those once this series is sorted out.
Since there are no interdepencies between the patches,
my preference is to have them applied by the individual
subsystem maintainers. Anything that has not at
least made it into linux-next by the next merge window
and has not received a 'NAK' or been obsoleted by
another patch, I plan to submit as part of an arm-soc
branch for 3.9.

	Arnd

Arnd Bergmann (18):
  ARM: shmobile: fix defconfig warning on CONFIG_USB
  ARM: disable virt_to_bus/virt_to_bus almost everywhere
  ARM: msm: proc_comm_boot_wait should not be __init
  oss/dmabuf: use dma_map_single
  sched: warnings in kernel/sched/fair.c
  sched/debug: fix format string for 32 bit platforms
  scripts/sortextable: silence script output
  lockdep: avoid warning about unused variables
  mfd/twl4030: don't warn about uninitialized return code
  watchdog: at91sam9: at91_wdt_dt_ids cannot be __init
  regmap: avoid undefined return from regmap_read_debugfs
  pinctrl: exynos: don't mark probing functions as __init
  pinctrl: nomadik: nmk_prcm_gpiocr_get_mode may be unused
  spi/atmel: remove incorrect __exit_p()
  sunrpc: don't warn for unused variable 'buf'
  mac80211: avoid a build warning
  input/joystick: use get_cycles on ARM
  ARM: at91: suspend both memory controllers on at91sam9263

sahara (1):
  [INCOMPLETE] ARM: make return_address available for ARM_UNWIND

 arch/arm/Kconfig                     |  4 ++++
 arch/arm/configs/marzen_defconfig    |  1 -
 arch/arm/configs/shark_defconfig     |  1 -
 arch/arm/include/asm/dma.h           |  2 +-
 arch/arm/include/asm/ftrace.h        |  6 ++----
 arch/arm/include/asm/memory.h        |  2 ++
 arch/arm/kernel/Makefile             | 12 +++++-------
 arch/arm/kernel/return_address.c     | 10 +++-------
 arch/arm/kernel/stacktrace.c         |  3 +++
 arch/arm/mach-at91/cpuidle.c         |  2 +-
 arch/arm/mach-at91/pm.c              |  2 +-
 arch/arm/mach-at91/pm.h              |  8 --------
 arch/arm/mach-msm/proc_comm.h        |  2 +-
 drivers/base/regmap/regmap-debugfs.c |  2 +-
 drivers/input/joystick/analog.c      |  8 ++------
 drivers/mfd/twl4030-power.c          |  2 +-
 drivers/pinctrl/pinctrl-exynos5440.c | 10 +++++-----
 drivers/pinctrl/pinctrl-nomadik.c    |  2 +-
 drivers/spi/spi-atmel.c              |  2 +-
 drivers/watchdog/at91sam9_wdt.c      |  2 +-
 include/linux/lockdep.h              |  2 +-
 kernel/sched/debug.c                 |  4 ++--
 kernel/sched/fair.c                  |  2 +-
 kernel/trace/trace_irqsoff.c         | 26 ++++++++++++--------------
 net/mac80211/tx.c                    |  8 ++++----
 net/sunrpc/svc.c                     |  2 +-
 scripts/sortextable.h                |  2 +-
 sound/oss/dmabuf.c                   |  3 ++-
 28 files changed, 59 insertions(+), 73 deletions(-)

-- 
1.8.0

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Linus Walleij <linus.walleij@linaro.org>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: netdev@vger.kernel.org
