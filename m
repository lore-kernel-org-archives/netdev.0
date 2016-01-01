From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/3] net-iwlegacy: One check less in il_eeprom_init() after
 error detection
Date: Fri, 1 Jan 2016 21:31:26 +0100
Message-ID: <5686E21E.4090901@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5686E13F.2010309@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:50717 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbcAAUbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jan 2016 15:31:35 -0500
In-Reply-To: <5686E13F.2010309@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 21:12:29 +0100

This issue was detected by using the Coccinelle software.

Adjust a jump target to avoid a check repetition before the function
call "il_eeprom_free".

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/intel/iwlegacy/common.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlegacy/common.c b/drivers/net/wireless/intel/iwlegacy/common.c
index c3afaf7..ae45fd3 100644
--- a/drivers/net/wireless/intel/iwlegacy/common.c
+++ b/drivers/net/wireless/intel/iwlegacy/common.c
@@ -734,7 +734,7 @@ il_eeprom_init(struct il_priv *il)
 	if (ret < 0) {
 		IL_ERR("EEPROM not found, EEPROM_GP=0x%08x\n", gp);
 		ret = -ENOENT;
-		goto err;
+		goto free_eeprom;
 	}
 
 	/* Make sure driver (instead of uCode) is allowed to read EEPROM */
@@ -742,7 +742,7 @@ il_eeprom_init(struct il_priv *il)
 	if (ret < 0) {
 		IL_ERR("Failed to acquire EEPROM semaphore.\n");
 		ret = -ENOENT;
-		goto err;
+		goto free_eeprom;
 	}
 
 	/* eeprom is an array of 16bit values */
@@ -772,9 +772,11 @@ il_eeprom_init(struct il_priv *il)
 done:
 	il->ops->eeprom_release_semaphore(il);
 
-err:
-	if (ret)
+	if (ret) {
+free_eeprom:
 		il_eeprom_free(il);
+	}
+
 	/* Reset chip to save power until we load uCode during "up". */
 	il_apm_stop(il);
 	return ret;
-- 
2.6.3
