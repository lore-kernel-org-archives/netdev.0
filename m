From: Dave Jones <davej@redhat.com>
Subject: ath9k: remove self-assignment in ath9k_eeprom_request
Date: Tue, 17 Sep 2013 17:35:40 -0400
Message-ID: <20130917213540.GA32010@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcgrof@qca.qualcomm.com, linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371Ab3IQVf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 17:35:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assigning a variable to itself is pointless, moreso when it's overwritten immediately.

Introduced in ab5c4f71d8c7add173a2d32e5beefdaaf1b7cbbc
 ("ath9k: allow to load EEPROM content via firmware API")

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 9a1f349..0cb3f2d 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -572,7 +572,7 @@ static void ath9k_eeprom_request_cb(const struct firmware *eeprom_blob,
 static int ath9k_eeprom_request(struct ath_softc *sc, const char *name)
 {
 	struct ath9k_eeprom_ctx ec;
-	struct ath_hw *ah = ah = sc->sc_ah;
+	struct ath_hw *ah = sc->sc_ah;
 	int err;
 
 	/* try to load the EEPROM content asynchronously */
