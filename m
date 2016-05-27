From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 5/8] mwifiex: use dev_err() instead of pr_err() in mwifiex_sdio_probe()
Date: Fri, 27 May 2016 10:18:19 -0400
Message-ID: <1464358702-19083-6-git-send-email-javier@osg.samsung.com>
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

It's better to have the device name prefixed in the error message.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 7aeee88b858f..1ffbb972318f 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -182,7 +182,7 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 	sdio_release_host(func);
 
 	if (ret) {
-		pr_err("%s: failed to enable function\n", __func__);
+		dev_err(&func->dev, "failed to enable function\n");
 		goto err_free;
 	}
 
@@ -193,7 +193,7 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 	ret = mwifiex_add_card(card, &add_remove_card_sem, &sdio_ops,
 			       MWIFIEX_SDIO);
 	if (ret) {
-		pr_err("%s: add card failed\n", __func__);
+		dev_err(&func->dev, "add card failed\n");
 		goto err_disable;
 	}
 
-- 
2.5.5
