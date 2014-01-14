From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 7/7] staging,lpc32xx_adc: Add dependency on HAS_IOMEM
Date: Tue, 14 Jan 2014 16:45:45 +0100
Message-ID: <1389714345-20165-7-git-send-email-richard@nod.at>
References: <1389714345-20165-1-git-send-email-richard@nod.at>
Cc: sebastian.hesselbarth@gmail.com, florian@openwrt.org,
	thomas.petazzoni@free-electrons.com, lars@metafoo.de,
	marex@denx.de, acourbot@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, devel@driverdev.osuosl.org,
	linux-iio@vger.kernel.org, Richard Weinberger <richard@nod.at>
To: kishon@ti.com, anton@enomsg.org, dwmw2@infradead.org,
	richardcochran@gmail.com, lidza.louina@gmail.com,
	gregkh@linuxfoundation.org, jic23@kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389714345-20165-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On archs like S390 or um this driver cannot build nor work.
Make it depend on HAS_IOMEM to bypass build failures.

drivers/built-in.o: In function `lpc32xx_adc_probe':
drivers/staging/iio/adc/lpc32xx_adc.c:149: undefined reference to `devm_ioremap'

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/staging/iio/adc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/iio/adc/Kconfig b/drivers/staging/iio/adc/Kconfig
index 7d5d675..3633298 100644
--- a/drivers/staging/iio/adc/Kconfig
+++ b/drivers/staging/iio/adc/Kconfig
@@ -103,6 +103,7 @@ config AD7280
 config LPC32XX_ADC
 	tristate "NXP LPC32XX ADC"
 	depends on ARCH_LPC32XX || COMPILE_TEST
+	depends on HAS_IOMEM
 	help
 	  Say yes here to build support for the integrated ADC inside the
 	  LPC32XX SoC. Note that this feature uses the same hardware as the
-- 
1.8.1.4
