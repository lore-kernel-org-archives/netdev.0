From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net 1/3] cpsw/netcp: cpts depends on posix_timers
Date: Fri, 16 Dec 2016 10:19:57 +0100
Message-ID: <20161216092017.2560717-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>, WingMan Kwok <w-kwok2@ti.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:63334 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754763AbcLPJUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 04:20:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With posix timers having become optional, we get a build error with
the cpts time sync option of the CPSW driver:

drivers/net/ethernet/ti/cpts.c: In function 'cpts_find_ts':
drivers/net/ethernet/ti/cpts.c:291:23: error: implicit declaration of function 'ptp_classify_raw';did you mean 'ptp_classifier_init'? [-Werror=implicit-function-declaration]

It really makes no sense to build this driver if we can't use PTP,
so it's better to go back to 'select PTP_1588_CLOCK' but instead
add a dependency on POSIX_TIMERS.

Fixes: baa73d9e478f ("posix-timers: Make them configurable")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 296c8efd0038..366e29ff8605 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -76,7 +76,8 @@ config TI_CPSW
 config TI_CPTS
 	tristate "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW || TI_KEYSTONE_NETCP
-	imply PTP_1588_CLOCK
+	depends on POSIX_TIMERS
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
 	  the CPSW Ethernet Switch and Keystone 2 1g/10g Switch Subsystem.
-- 
2.9.0
