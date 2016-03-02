From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/14] drivers: use __maybe_unused to hide pm functions
Date: Wed,  2 Mar 2016 16:58:52 +0100
Message-ID: <1456934350-1389172-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, herbert@gondor.apana.org.au,
	k.kozlowski@samsung.com, dan.j.williams@intel.com,
	vinod.koul@intel.com, baohua@kernel.org, dmitry.torokhov@gmail.com,
	tglx@linutronix.de, jason@lakedaemon.net, marc.zyngier@arm.com,
	laurent.pinchart@ideasonboard.com, mchehab@osg.samsung.com,
	lee.jones@linaro.org, kvalo@codeaurora.org,
	ludovic.desroches@atmel.com, linus.walleij@linaro.org,
	sre@kernel.org, dbaryshkov@gmail.com, JBottomley@odin.com,
	martin.petersen@oracle.com, broonie@kernel.org,
	linux-crypto@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org,
	linux-input@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-gpio@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-scsi@vger.kernel.org, alsa-devel@alsa-
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-media-owner@vger.kernel.org>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found many variations of the bug in these device drivers (and some
USB drivers I already send patches for in a separate series).

In each case, the power management operations structure conditionally
references suspend/resume functions, but the functions are hidden
in an incorrect #ifdef or not hidden at all.

We could try to correct the #ifdefs, but it seems easier to just
mark those functions as __maybe_unused, which has the same effect
but provides better compile-time test coverage and (subjectively)
looks a bit nicer.

I have a patch series that avoids all warnings in ARM randconfig
builds, and I have verified that all these patches fix a warning that
is still present in today's linux-next, and that they do not
introduce new warnings in any configuration I found.

Note that all these drivers are ARM specific, so I assume that
all portable drivers got fixed already when someone rand into
the problem on x86.

There are no dependencies between the patches, so I'd appreciate
subsystem maintainers to put them directly into their git trees.

	Arnd

Arnd Bergmann (14):
  pinctrl: at91: use __maybe_unused to hide pm functions
  irqchip: st: use __maybe_unused to hide st_irq_syscfg_resume
  power: ipaq-micro-battery: use __maybe_unused to hide pm functions
  power: pm2301-charger: use __maybe_unused to hide pm functions
  mfd: ipaq-micro: use __maybe_unused to hide pm functions
  dma: sirf: use __maybe_unused to hide pm functions
  hw_random: exynos: use __maybe_unused to hide pm functions
  scsi: mvumi: use __maybe_unused to hide pm functions
  amd-xgbe: use __maybe_unused to hide pm functions
  wireless: cw1200: use __maybe_unused to hide pm functions_
  input: spear-keyboard: use __maybe_unused to hide pm functions
  keyboard: snvs-pwrkey: use __maybe_unused to hide pm functions
  [media] omap3isp: use IS_ENABLED() to hide pm functions
  ASoC: rockchip: use __maybe_unused to hide st_irq_syscfg_resume

 drivers/char/hw_random/exynos-rng.c         | 10 ++++------
 drivers/dma/sirf-dma.c                      | 10 ++++------
 drivers/input/keyboard/snvs_pwrkey.c        |  4 ++--
 drivers/input/keyboard/spear-keyboard.c     |  6 ++----
 drivers/irqchip/irq-st.c                    |  2 +-
 drivers/media/platform/omap3isp/isp.c       | 13 +------------
 drivers/mfd/ipaq-micro.c                    |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c   |  6 ++----
 drivers/net/wireless/st/cw1200/cw1200_spi.c |  9 ++-------
 drivers/net/wireless/st/cw1200/pm.h         |  9 +++++++--
 drivers/pinctrl/pinctrl-at91-pio4.c         |  4 ++--
 drivers/power/ipaq_micro_battery.c          |  4 ++--
 drivers/power/pm2301_charger.c              | 22 ++++++----------------
 drivers/scsi/mvumi.c                        |  4 ++--
 sound/soc/rockchip/rockchip_spdif.c         |  4 ++--
 15 files changed, 40 insertions(+), 69 deletions(-)

-- 
2.7.0
Cc: herbert@gondor.apana.org.au
Cc: k.kozlowski@samsung.com
Cc: dan.j.williams@intel.com
Cc: vinod.koul@intel.com
Cc: baohua@kernel.org
Cc: dmitry.torokhov@gmail.com
Cc: tglx@linutronix.de
Cc: jason@lakedaemon.net
Cc: marc.zyngier@arm.com
Cc: laurent.pinchart@ideasonboard.com
Cc: mchehab@osg.samsung.com
Cc: lee.jones@linaro.org
Cc: kvalo@codeaurora.org
Cc: ludovic.desroches@atmel.com
Cc: linus.walleij@linaro.org
Cc: sre@kernel.org
Cc: dbaryshkov@gmail.com
Cc: JBottomley@odin.com
Cc: martin.petersen@oracle.com
Cc: broonie@kernel.org
Cc: linux-crypto@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-samsung-soc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: dmaengine@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: linux-media@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: linux-gpio@vger.kernel.org
Cc: linux-pm@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: alsa-devel@alsa-project.org
Cc: linux-rockchip@lists.infradead.org
