From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: RE: [PATCH] drivers: net: wimax: i2400m: i2400m-usb: Use time_after for time comparison
Date: Tue,  9 May 2017 02:06:50 +0200
Message-ID: <1494288410-19028-1-git-send-email-karim.eshapa@gmail.com>
References: <1494262682-5401-1-git-send-email-karim.eshapa@gmail.com>
Cc: linux-wimax@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Karim Eshapa <karim.eshapa@gmail.com>
To: inaky.perez-gonzalez@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494262682-5401-1-git-send-email-karim.eshapa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use time_after() for time comparison with the new fix.

Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>
---
 drivers/net/wimax/i2400m/i2400m-usb.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 649ecad..eff4f464 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -131,7 +131,7 @@ static inline int edc_inc(struct edc *edc, u16 max_err, u16 timeframe)
 	unsigned long now;
 
 	now = jiffies;
-	if (now - edc->timestart > timeframe) {
+	if (time_after(now, edc->timestart + timeframe)) {
 		edc->errorcount = 1;
 		edc->timestart = now;
 	} else if (++edc->errorcount > max_err) {
-- 
2.7.4
