From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 2/8] mwifiex: propagate sdio_enable_func() errno code in mwifiex_sdio_probe()
Date: Fri, 27 May 2016 10:18:16 -0400
Message-ID: <1464358702-19083-3-git-send-email-javier@osg.samsung.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Cc: Xinming Hu <huxm@marvell.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the sdio_enable_func() function fails on .probe, the -EIO errno code
is always returned but that could make more difficult to debug and find
the cause of why the function actually failed.

Since the driver/device core prints the value returned by .probe in its
error message propagate what was returned by sdio_enable_func() at fail.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 285b1b68f7e9..ab64507c84e1 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -184,7 +184,7 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 	if (ret) {
 		pr_err("%s: failed to enable function\n", __func__);
 		kfree(card);
-		return -EIO;
+		return ret;
 	}
 
 	/* device tree node parsing and platform specific configuration*/
-- 
2.5.5
