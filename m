From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] net: wl12xx: do not use kfree'd memory
Date: Sat, 31 Jul 2010 20:33:59 +0400
Message-ID: <1280594039-3246-1-git-send-email-segooon@gmail.com>
Cc: Luciano Coelho <luciano.coelho@nokia.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Juuso Oikarinen <juuso.oikarinen@nokia.com>,
	Teemu Paasikivi <ext-teemu.3.paasikivi@nokia.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:40053 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978Ab0GaQeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 12:34:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wl1271_dump() uses cmd after kfree(cmd). Move kfree() just after
wl1271_dump().

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/wireless/wl12xx/wl1271_spi.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/wl1271_spi.c b/drivers/net/wireless/wl12xx/wl1271_spi.c
index 96d25fb..4cb99c5 100644
--- a/drivers/net/wireless/wl12xx/wl1271_spi.c
+++ b/drivers/net/wireless/wl12xx/wl1271_spi.c
@@ -160,9 +160,8 @@ static void wl1271_spi_init(struct wl1271 *wl)
 	spi_message_add_tail(&t, &m);
 
 	spi_sync(wl_to_spi(wl), &m);
-	kfree(cmd);
-
 	wl1271_dump(DEBUG_SPI, "spi init -> ", cmd, WSPI_INIT_CMD_LEN);
+	kfree(cmd);
 }
 
 #define WL1271_BUSY_WORD_TIMEOUT 1000
-- 
1.7.0.4

