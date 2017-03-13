From: Alban <albeu@free.fr>
Subject: [PATCH 5/7] ath9k: of: Use the clk API to get the reference clock rate
Date: Mon, 13 Mar 2017 22:05:13 +0100
Message-ID: <1489439116-4233-5-git-send-email-albeu@free.fr>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
Cc: John Crispin <john@phrozen.org>, Alban <albeu@free.fr>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:4215 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932260AbdCMVHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 17:07:09 -0400
In-Reply-To: <1489439116-4233-1-git-send-email-albeu@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a clock named "ref" exists use it to get the reference clock rate.

Signed-off-by: Alban <albeu@free.fr>
---
 drivers/net/wireless/ath/ath9k/init.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 36b51a5..5cb9c61 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -24,6 +24,7 @@
 #include <linux/of_net.h>
 #include <linux/nvmem-consumer.h>
 #include <linux/relay.h>
+#include <linux/clk.h>
 #include <net/ieee80211_radiotap.h>
 
 #include "ath9k.h"
@@ -564,6 +565,7 @@ static int ath9k_of_init(struct ath_softc *sc)
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 	enum ath_bus_type bus_type = common->bus_ops->ath_bus_type;
+	struct clk *clk;
 	const char *mac;
 	char eeprom_name[100];
 	int ret;
@@ -573,6 +575,12 @@ static int ath9k_of_init(struct ath_softc *sc)
 
 	ath_dbg(common, CONFIG, "parsing configuration from OF node\n");
 
+	clk = clk_get(sc->dev, "ref");
+	if (!IS_ERR(clk)) {
+		ah->is_clk_25mhz = (clk_get_rate(clk) == 25000000);
+		clk_put(clk);
+	}
+
 	if (of_property_read_bool(np, "qca,no-eeprom")) {
 		/* ath9k-eeprom-<bus>-<id>.bin */
 		scnprintf(eeprom_name, sizeof(eeprom_name),
-- 
2.7.4
