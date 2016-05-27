From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 7/8] mwifiex: don't print an error if an optional DT property is missing
Date: Fri, 27 May 2016 10:18:21 -0400
Message-ID: <1464358702-19083-8-git-send-email-javier@osg.samsung.com>
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

The Documentation/devicetree/bindings/net/wireless/marvell-sd8xxx.txt DT
binding document say that the "interrupts" property in the child node is
optional. So the property being missed shouldn't be treated as an error.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 1c17e624547a..8b3292eaecb2 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -114,7 +114,7 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
 	if (cfg && card->plt_of_node) {
 		cfg->irq_wifi = irq_of_parse_and_map(card->plt_of_node, 0);
 		if (!cfg->irq_wifi) {
-			dev_err(dev,
+			dev_dbg(dev,
 				"fail to parse irq_wifi from device tree\n");
 		} else {
 			ret = devm_request_irq(dev, cfg->irq_wifi,
-- 
2.5.5
