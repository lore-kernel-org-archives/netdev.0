From: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net: wireless: wl1251: Remove unnecessary free_irq
Date: Sat, 2 Aug 2014 16:51:30 +0530
Message-ID: <20140802112130.GA3193@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall-L2FTfq7BK8M@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch does away with free_irq in the remove function as the irq is
allocated with a devm_request_irq.

Signed-off-by: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
I'm not sure that devm_request_irq should be used in
the first place, as it will move the stopping of the interrupt over
wl1251_free_hw. Should I use request_irq?
 drivers/net/wireless/ti/wl1251/spi.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index a0aa8fa..735be53 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -345,7 +345,6 @@ static int wl1251_spi_remove(struct spi_device *spi)
 {
 	struct wl1251 *wl = spi_get_drvdata(spi);
 
-	free_irq(wl->irq, wl);
 	wl1251_free_hw(wl);
 	regulator_disable(wl->vio);
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
