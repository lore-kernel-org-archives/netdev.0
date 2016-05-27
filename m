From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 8/8] mwifiex: use better message and error code when OF node doesn't match
Date: Fri, 27 May 2016 10:18:22 -0400
Message-ID: <1464358702-19083-9-git-send-email-javier@osg.samsung.com>
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
binding document lists the possible compatible strings that a SDIO child
node can have, so the driver checks if the defined in the node matches.

But the error message when that's not the case is misleading, so change
for one that makes clear what the error really is. Also, returning a -1
as errno code is not correct since that's -EPERM. A -EINVAL seems to be
a more appropriate one.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 8b3292eaecb2..e6d56be04e08 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -103,8 +103,8 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
 	int ret;
 
 	if (!of_match_node(mwifiex_sdio_of_match_table, dev->of_node)) {
-		dev_err(dev, "sdio platform data not available\n");
-		return -1;
+		dev_err(dev, "required compatible string missing\n");
+		return -EINVAL;
 	}
 
 	card->plt_of_node = dev->of_node;
-- 
2.5.5
