From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH 3/6] zd1211rw: Fix software encryption/decryption
Date: Tue, 01 Aug 2006 23:43:32 +0200
Message-ID: <11544686163487-git-send-email-kune@deine-taler.de>
References: <1154468615618-git-send-email-kune@deine-taler.de>
Reply-To: Ulrich Kunitz <kune@deine-taler.de>
Cc: netdev@vger.kernel.org, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:27332 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751072AbWHAVng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:43:36 -0400
To: linville@tuxdriver.com
In-Reply-To: <1154468615618-git-send-email-kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Drake <dsd@gentoo.org>

Apparently the ZD1211 doesn't mind, but the ZD1211B absolutely must be
told that encryption is happening in software.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 drivers/net/wireless/zd1211rw/zd_mac.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 1cf1fda..a66625c 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -108,7 +108,9 @@ int zd_mac_init_hw(struct zd_mac *mac, u
 	if (r)
 		goto disable_int;
 
-	r = zd_set_encryption_type(chip, NO_WEP);
+	/* We must inform the device that we are doing encryption/decryption in
+	 * software at the moment. */
+	r = zd_set_encryption_type(chip, ENC_SNIFFER);
 	if (r)
 		goto disable_int;
 
@@ -141,7 +143,6 @@ static int reset_mode(struct zd_mac *mac
 				RX_FILTER_REASSOC_RESPONSE |
 				RX_FILTER_DISASSOC },
 		{ CR_SNIFFER_ON, 0U },
-		{ CR_ENCRYPTION_TYPE, NO_WEP },
 	};
 
 	if (ieee->iw_mode == IW_MODE_MONITOR) {
-- 
1.4.1

