From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH mac80211-next] rfkill: hide unused goto label
Date: Fri, 16 Dec 2016 09:44:08 +0100
Message-ID: <20161216084425.1692828-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@gmail.com>,
        =?UTF-8?q?Micha=C5=82=20K=C4=99pie=C5=84?= <kernel@kempniu.pl>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:54677 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756882AbcLPIop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 03:44:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A cleanup introduced a harmless warning in some configurations:

net/rfkill/core.c: In function 'rfkill_init':
net/rfkill/core.c:1350:1: warning: label 'error_input' defined but not used [-Wunused-label]

This adds another #ifdef around the label to match that around the
caller.

Fixes: 6124c53edeea ("rfkill: Cleanup error handling in rfkill_init()")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/rfkill/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index f6b01f3616e5..b7adaee69756 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -1347,8 +1347,10 @@ static int __init rfkill_init(void)
 
 	return 0;
 
+#ifdef CONFIG_RFKILL_INPUT
 error_input:
 	rfkill_any_led_trigger_unregister();
+#endif
 error_led_trigger:
 	misc_deregister(&rfkill_miscdev);
 error_misc:
-- 
2.9.0
