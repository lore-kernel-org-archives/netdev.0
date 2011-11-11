From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V2 04/14] ARM: mxc: pwm: add clk_prepare/clk_unprepare
Date: Fri, 11 Nov 2011 09:10:19 +0800
Message-ID: <1320973829-4388-5-git-send-email-richard.zhao@linaro.org>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amit.kucheria@canonical.com, linux@arm.linux.org.uk, kernel@pengutronix.de,
 eric.miao@linaro.org, ben-linux@fluff.org, cjb@laptop.org,
 Richard Zhao <richard.zhao@linaro.org>, alan@linux.intel.com
To: <linux-arm-kernel@lists.infradead.org>, <linux-i2c@vger.kernel.org>,
 <linux-mmc@vger.kernel.org>, <netdev@vger.kernel.org>,
 <linux-serial@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
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

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
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
