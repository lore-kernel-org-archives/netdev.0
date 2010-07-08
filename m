From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v4 9/9] usb/atm/ueagle-atm.c: call atm_dev_signal_change() when signal changes.
Date: Thu,  8 Jul 2010 10:34:55 +0200
Message-ID: <1278578095-25324-10-git-send-email-karl@hiramoto.org>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcbbj.dreamhost.com ([208.97.132.119]:57535 "EHLO
	homiemail-a36.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755441Ab0GHIf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 04:35:27 -0400
In-Reply-To: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate signal changes to upper atm layer.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/usb/atm/ueagle-atm.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/usb/atm/ueagle-atm.c b/drivers/usb/atm/ueagle-atm.c
index e213d3f..ebae944 100644
--- a/drivers/usb/atm/ueagle-atm.c
+++ b/drivers/usb/atm/ueagle-atm.c
@@ -575,6 +575,13 @@ MODULE_PARM_DESC(annex,
 			sc->usbatm->atm_dev->type = val; \
 	} while (0)
 
+#define UPDATE_ATM_SIGNAL(val) \
+	do { \
+		if (sc->usbatm->atm_dev) \
+			atm_dev_signal_change(sc->usbatm->atm_dev, val); \
+	} while (0)
+
+
 /* Firmware loading */
 #define LOAD_INTERNAL     0xA0
 #define F8051_USBCS       0x7f92
@@ -1359,7 +1366,7 @@ static int uea_stat_e1(struct uea_softc *sc)
 	/* always update it as atm layer could not be init when we switch to
 	 * operational state
 	 */
-	UPDATE_ATM_STAT(signal, ATM_PHY_SIG_FOUND);
+	UPDATE_ATM_SIGNAL(ATM_PHY_SIG_FOUND);
 
 	/* wake up processes waiting for synchronization */
 	wake_up(&sc->sync_q);
@@ -1498,7 +1505,7 @@ static int uea_stat_e4(struct uea_softc *sc)
 	/* always update it as atm layer could not be init when we switch to
 	 * operational state
 	 */
-	UPDATE_ATM_STAT(signal, ATM_PHY_SIG_FOUND);
+	UPDATE_ATM_SIGNAL(ATM_PHY_SIG_FOUND);
 
 	/* wake up processes waiting for synchronization */
 	wake_up(&sc->sync_q);
@@ -1825,7 +1832,7 @@ static int uea_start_reset(struct uea_softc *sc)
 	 * So we will failed to wait Ready CMV.
 	 */
 	sc->cmv_ack = 0;
-	UPDATE_ATM_STAT(signal, ATM_PHY_SIG_LOST);
+	UPDATE_ATM_SIGNAL(ATM_PHY_SIG_LOST);
 
 	/* reset statistics */
 	memset(&sc->stats, 0, sizeof(struct uea_stats));
-- 
1.7.1

