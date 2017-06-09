From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] wireless: wlcore: spi: remove unnecessary variable
Date: Thu, 8 Jun 2017 22:24:30 -0500
Message-ID: <20170609032430.GA7432@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary variable and refactor the code.

Addresses-Coverity-ID: 1365000
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/wireless/ti/wlcore/spi.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index fa3547e..d2d899a 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -366,17 +366,14 @@ static int __wl12xx_spi_raw_write(struct device *child, int addr,
 static int __must_check wl12xx_spi_raw_write(struct device *child, int addr,
 					     void *buf, size_t len, bool fixed)
 {
-	int ret;
-
 	/* The ELP wakeup write may fail the first time due to internal
 	 * hardware latency. It is safer to send the wakeup command twice to
 	 * avoid unexpected failures.
 	 */
 	if (addr == HW_ACCESS_ELP_CTRL_REG)
-		ret = __wl12xx_spi_raw_write(child, addr, buf, len, fixed);
-	ret = __wl12xx_spi_raw_write(child, addr, buf, len, fixed);
+		__wl12xx_spi_raw_write(child, addr, buf, len, fixed);
 
-	return ret;
+	return __wl12xx_spi_raw_write(child, addr, buf, len, fixed);
 }
 
 /**
-- 
2.5.0
