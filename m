From: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH V4 07/14] ARM: mxc: audmux-v2: add clk_prepare/clk_unprepare
Date: Tue, 15 Nov 2011 14:48:02 +0800
Message-ID: <1321339689-25256-8-git-send-email-richard.zhao@linaro.org>
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
 arch/arm/plat-mxc/audmux-v2.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/plat-mxc/audmux-v2.c b/arch/arm/plat-mxc/audmux-v2.c
index 8cced35..0e51fc3 100644
--- a/arch/arm/plat-mxc/audmux-v2.c
+++ b/arch/arm/plat-mxc/audmux-v2.c
@@ -73,13 +73,13 @@ static ssize_t audmux_read_file(struct file *file, char __user *user_buf,
 		return -ENOMEM;
 
 	if (audmux_clk)
-		clk_enable(audmux_clk);
+		clk_prepare_enable(audmux_clk);
 
 	ptcr = readl(audmux_base + MXC_AUDMUX_V2_PTCR(port));
 	pdcr = readl(audmux_base + MXC_AUDMUX_V2_PDCR(port));
 
 	if (audmux_clk)
-		clk_disable(audmux_clk);
+		clk_disable_unprepare(audmux_clk);
 
 	ret = snprintf(buf, PAGE_SIZE, "PDCR: %08x\nPTCR: %08x\n",
 		       pdcr, ptcr);
@@ -172,13 +172,13 @@ int mxc_audmux_v2_configure_port(unsigned int port, unsigned int ptcr,
 		return -ENOSYS;
 
 	if (audmux_clk)
-		clk_enable(audmux_clk);
+		clk_prepare_enable(audmux_clk);
 
 	writel(ptcr, audmux_base + MXC_AUDMUX_V2_PTCR(port));
 	writel(pdcr, audmux_base + MXC_AUDMUX_V2_PDCR(port));
 
 	if (audmux_clk)
-		clk_disable(audmux_clk);
+		clk_disable_unprepare(audmux_clk);
 
 	return 0;
 }
-- 
1.7.5.4
