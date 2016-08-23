From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH] ath10k: replace config_enabled() with IS_REACHABLE()
Date: Wed, 24 Aug 2016 01:27:26 +0900
Message-ID: <1471969646-13119-1-git-send-email-yamada.masahiro@socionext.com>
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 97f2645f358b ("tree-wide: replace config_enabled() with
IS_ENABLED()") mostly did away with config_enabled().

This is one of the postponed TODO items as config_enabled() is used
for a tristate option here.  Theoretically, config_enabled() is
equivalent to IS_BUILTIN(), but I guess IS_REACHABLE() is the best
fit for this case because both CONFIG_HWMON and CONFIG_ATH10K are
tristate.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 drivers/net/wireless/ath/ath10k/thermal.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/thermal.c b/drivers/net/wireless/ath/ath10k/thermal.c
index 444b52c..0a47269 100644
--- a/drivers/net/wireless/ath/ath10k/thermal.c
+++ b/drivers/net/wireless/ath/ath10k/thermal.c
@@ -192,7 +192,7 @@ int ath10k_thermal_register(struct ath10k *ar)
 
 	/* Avoid linking error on devm_hwmon_device_register_with_groups, I
 	 * guess linux/hwmon.h is missing proper stubs. */
-	if (!config_enabled(CONFIG_HWMON))
+	if (!IS_REACHABLE(CONFIG_HWMON))
 		return 0;
 
 	hwmon_dev = devm_hwmon_device_register_with_groups(ar->dev,
-- 
1.9.1
