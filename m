From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] fix:rtl8xxxu_core: mark symbols static where possible
Date: Sun, 28 Aug 2016 00:14:36 +0800
Message-ID: <1472314476-23351-1-git-send-email-baoyou.xie@linaro.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@linaro.org,
        baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: Jes.Sorensen@redhat.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning about global functions without a declaration
in the rtl8xxxu rtl8xxxu_core.c when building with W=1:
drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c:898:1: warning: no previous prototype for 'rtl8xxxu_gen1_h2c_cmd' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is declared
and don't need a declaration, but can be made static.
so this patch marks it 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index 77048db..95b54b8 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -894,7 +894,7 @@ int rtl8xxxu_write_rfreg(struct rtl8xxxu_priv *priv,
 	return retval;
 }
 
-int
+static int
 rtl8xxxu_gen1_h2c_cmd(struct rtl8xxxu_priv *priv, struct h2c_cmd *h2c, int len)
 {
 	struct device *dev = &priv->udev->dev;
-- 
2.7.4
