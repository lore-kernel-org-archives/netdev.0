From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 6/8] mwifiex: check if mwifiex_sdio_probe_of() fails and return error
Date: Fri, 27 May 2016 10:18:20 -0400
Message-ID: <1464358702-19083-7-git-send-email-javier@osg.samsung.com>
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

The function can fail so the returned value should be checked
and the error propagated to the caller in case of a failure.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 1ffbb972318f..1c17e624547a 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -187,8 +187,13 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 	}
 
 	/* device tree node parsing and platform specific configuration*/
-	if (func->dev.of_node)
-		mwifiex_sdio_probe_of(&func->dev, card);
+	if (func->dev.of_node) {
+		ret = mwifiex_sdio_probe_of(&func->dev, card);
+		if (ret) {
+			dev_err(&func->dev, "SDIO dt node parse failed\n");
+			goto err_disable;
+		}
+	}
 
 	ret = mwifiex_add_card(card, &add_remove_card_sem, &sdio_ops,
 			       MWIFIEX_SDIO);
-- 
2.5.5
