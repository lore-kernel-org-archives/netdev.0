From: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH V2 01/14] clk: add helper functions clk_prepare_enable and clk_disable_unprepare
Date: Fri, 11 Nov 2011 09:10:16 +0800
Message-ID: <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, <amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	<kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>, <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	<alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, <eric.miao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1320973829-4388-1-git-send-email-richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 include/linux/clk.h |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/clk.h b/include/linux/clk.h
index 7213b52..63985f7 100644
--- a/include/linux/clk.h
+++ b/include/linux/clk.h
@@ -107,6 +107,25 @@ static inline void clk_unprepare(struct clk *clk)
 }
 #endif
 
+static inline int clk_prepare_enable(struct clk *clk)
+{
+	int ret;
+
+	ret = clk_prepare(clk);
+	if (!ret)
+		ret = clk_enable(clk);
+	if (ret)
+		clk_unprepare(clk);
+
+	return ret;
+}
+
+static inline void clk_disable_unprepare(struct clk *clk)
+{
+	clk_disable(clk);
+	clk_unprepare(clk);
+}
+
 /**
  * clk_get_rate - obtain the current clock rate (in Hz) for a clock source.
  *		  This is only valid once the clock source has been enabled.
-- 
1.7.5.4
