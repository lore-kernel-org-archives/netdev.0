From: AceLan Kao <acelan.kao@canonical.com>
Subject: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Tue, 26 Sep 2017 14:41:35 +0800
Message-ID: <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some platform(BIOS) blocks legacy interrupts (INTx), and only allows MSI
for WLAN device. So adding a quirk to list those machines and set
use_msi automatically.
Adding Dell Inspiron 24-3460 to the quirk.

Signed-off-by: AceLan Kao <acelan.kao@canonical.com>
---
 drivers/net/wireless/ath/ath9k/init.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index b6b7a35..1667949 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -23,6 +23,7 @@
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/relay.h>
+#include <linux/dmi.h>
 #include <net/ieee80211_radiotap.h>
 
 #include "ath9k.h"
@@ -96,6 +97,24 @@ static const struct ieee80211_tpt_blink ath9k_tpt_blink[] = {
 };
 #endif
 
+static int __init set_use_msi(const struct dmi_system_id *dmi)
+{
+	ath9k_use_msi = 1;
+	return 1;
+}
+
+static const struct dmi_system_id ath9k_quirks[] __initconst = {
+	{
+		.callback = set_use_msi,
+		.ident = "Dell Inspiron 24-3460",
+		.matches = {
+			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+			DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 24-3460"),
+		},
+	},
+	{}
+};
+
 static void ath9k_deinit_softc(struct ath_softc *sc);
 
 static void ath9k_op_ps_wakeup(struct ath_common *common)
@@ -1104,6 +1123,8 @@ static int __init ath9k_init(void)
 		goto err_pci_exit;
 	}
 
+	dmi_check_system(ath9k_quirks);
+
 	return 0;
 
  err_pci_exit:
-- 
2.7.4
