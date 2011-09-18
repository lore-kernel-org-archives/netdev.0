From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 1/4] net/fec: change phy-reset-gpio request warning to debug message
Date: Sun, 18 Sep 2011 19:54:09 +0800
Message-ID: <1316346852-17090-2-git-send-email-shawn.guo@linaro.org>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org,
	Shawn Guo <shawn.guo@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:48130 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab1IRLw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 07:52:27 -0400
Received: by mail-pz0-f42.google.com with SMTP id 1so7732480pzk.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 04:52:27 -0700 (PDT)
In-Reply-To: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC can work without a phy reset on some platforms, which means not
very platform necessarily have a phy-reset gpio encoded in device tree.
So it makes more sense to have the phy-reset-gpio request failure as
a debug message rather than a warning.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index e8266cc..6a638e9 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1422,7 +1422,7 @@ static int __devinit fec_reset_phy(struct platform_device *pdev)
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
 	err = gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
-		pr_warn("FEC: failed to get gpio phy-reset: %d\n", err);
+		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
 		return err;
 	}
 	msleep(1);
-- 
1.7.4.1
