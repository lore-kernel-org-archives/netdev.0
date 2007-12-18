From: "John W. Linville" <linville@tuxdriver.com>
Subject: iwlwifi: fix-up merge fall-out after namespace separation
Date: Mon, 17 Dec 2007 21:25:40 -0500
Message-ID: <20071218022540.GB3640@tuxdriver.com>
References: <20071216043419.GF3096@tuxdriver.com> <47670514.4030204@garzik.org> <476708EF.10403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4478 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbXLRC6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 21:58:37 -0500
Content-Disposition: inline
In-Reply-To: <476708EF.10403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> drivers/net/wireless/iwlwifi/iwl3945-base.c: In function=20
> =E2=80=98iwl3945_alive_start=E2=80=99:
> drivers/net/wireless/iwlwifi/iwl3945-base.c:6285: error: implicit=20
> declaration of function =E2=80=98iwl_rate_control_unregister=E2=80=99
> make[4]: *** [drivers/net/wireless/iwlwifi/iwl3945-base.o] Error 1
> make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
> make[2]: *** [drivers/net/wireless] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/=
wireless/iwlwifi/iwl3945-base.c
index 42f6623..88cf035 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4859,7 +4859,7 @@ static void iwl3945_irq_tasklet(struct iwl3945_pr=
iv *priv)
 		/* Queue restart only if RF_KILL switch was set to "kill"
 		 *   when we loaded driver, and is now set to "enable".
 		 * After we're Alive, RF_KILL gets handled by
-		 *   iwl_rx_card_state_notif() */
+		 *   iwl3945_rx_card_state_notif() */
 		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status)) {
 			clear_bit(STATUS_RF_KILL_HW, &priv->status);
 			queue_work(priv->workqueue, &priv->restart);
@@ -6282,7 +6282,7 @@ static void iwl3945_alive_start(struct iwl3945_pr=
iv *priv)
 		mutex_lock(&priv->mutex);
=20
 		if (rc) {
-			iwl_rate_control_unregister(priv->hw);
+			iwl3945_rate_control_unregister(priv->hw);
 			IWL_ERROR("Failed to register network "
 				  "device (error %d)\n", rc);
 			return;
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/=
wireless/iwlwifi/iwl4965-base.c
index 0dfc1ac..df6f3b1 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -5229,7 +5229,7 @@ static void iwl4965_irq_tasklet(struct iwl4965_pr=
iv *priv)
 		/* Queue restart only if RF_KILL switch was set to "kill"
 		 *   when we loaded driver, and is now set to "enable".
 		 * After we're Alive, RF_KILL gets handled by
-		 *   iwl_rx_card_state_notif() */
+		 *   iwl4965_rx_card_state_notif() */
 		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status)) {
 			clear_bit(STATUS_RF_KILL_HW, &priv->status);
 			queue_work(priv->workqueue, &priv->restart);
@@ -6695,7 +6695,7 @@ static void iwl4965_alive_start(struct iwl4965_pr=
iv *priv)
 		mutex_lock(&priv->mutex);
=20
 		if (rc) {
-			iwl_rate_control_unregister(priv->hw);
+			iwl4965_rate_control_unregister(priv->hw);
 			IWL_ERROR("Failed to register network "
 				  "device (error %d)\n", rc);
 			return;
--=20
John W. Linville
linville@tuxdriver.com
