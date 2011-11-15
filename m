From: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH V4 04/14] ARM: mxc: pwm: add clk_prepare/clk_unprepare
Date: Tue, 15 Nov 2011 14:47:59 +0800
Message-ID: <1321339689-25256-5-git-send-email-richard.zhao@linaro.org>
References: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, <amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	<kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>, <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	<alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, <eric.miao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1321339689-25256-1-git-send-email-richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It's for migrating to generic clk framework API.

Signed-off-by: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 arch/arm/plat-mxc/pwm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/plat-mxc/pwm.c b/arch/arm/plat-mxc/pwm.c
index 42d74ea..68c7199b 100644
--- a/arch/arm/plat-mxc/pwm.c
+++ b/arch/arm/plat-mxc/pwm.c
@@ -118,7 +118,7 @@ int pwm_enable(struct pwm_device *pwm)
 	int rc = 0;
 
 	if (!pwm->clk_enabled) {
-		rc = clk_enable(pwm->clk);
+		rc = clk_prepare_enable(pwm->clk);
 		if (!rc)
 			pwm->clk_enabled = 1;
 	}
@@ -131,7 +131,7 @@ void pwm_disable(struct pwm_device *pwm)
 	writel(0, pwm->mmio_base + MX3_PWMCR);
 
 	if (pwm->clk_enabled) {
-		clk_disable(pwm->clk);
+		clk_disable_unprepare(pwm->clk);
 		pwm->clk_enabled = 0;
 	}
 }
-- 
1.7.5.4
