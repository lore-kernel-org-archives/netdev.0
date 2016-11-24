From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/5] ath10k: Removed unused 'dev' in ath10k_ahb_resource_init
Date: Thu, 24 Nov 2016 00:02:43 -0800
Message-ID: <7d837ab7846f83add2f5e289ece94d0dbeb82eed.1479974100.git.kirtika@chromium.org>
References: <cover.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Raja Mani <rmani-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1479974100.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 704dc4e36769 introduced ath10k_ahb_resource_init() which
defines and sets 'struct device* dev' but does not use it.
Compiling with W=1 gives the following warning, fix it.

drivers/net/wireless/ath/ath10k/ahb.c: In function ‘ath10k_ahb_resource_init’:
drivers/net/wireless/ath/ath10k/ahb.c:449:17: warning: variable ‘dev’ set but not used [-Wunused-but-set-variable]

This is a harmless warning, and is only being fixed to reduce the
noise with W=1 in the kernel.

Fixes: 704dc4e36769 ("ath10k: add resource init and deinit in ahb")
Cc: Raja Mani <rmani-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>
Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/wireless/ath/ath10k/ahb.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/ahb.c b/drivers/net/wireless/ath/ath10k/ahb.c
index 8078d64..19507fe 100644
--- a/drivers/net/wireless/ath/ath10k/ahb.c
+++ b/drivers/net/wireless/ath/ath10k/ahb.c
@@ -443,12 +443,10 @@ static int ath10k_ahb_resource_init(struct ath10k *ar)
 {
	struct ath10k_ahb *ar_ahb = ath10k_ahb_priv(ar);
	struct platform_device *pdev;
-	struct device *dev;
	struct resource *res;
	int ret;

	pdev = ar_ahb->pdev;
-	dev = &pdev->dev;

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!res) {
--
2.8.0.rc3.226.g39d4020
