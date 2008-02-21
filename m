From: Aurelien Jarno <aurelien@aurel32.net>
Subject: [PATCH] [SSB] Add CHIPCO IRQ access functions
Date: Fri, 22 Feb 2008 00:17:13 +0100
Message-ID: <20080221231713.GA12041@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:51619 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbYBVAFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 19:05:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds functions to setup and read the CHIPCO IRQ.

Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
---
 drivers/ssb/driver_chipcommon.c           |   10 ++++++++++
 include/linux/ssb/ssb_driver_chipcommon.h |    4 ++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/ssb/driver_chipcommon.c b/drivers/ssb/driver_chipcommon.c
index e586321..45b672a 100644
--- a/drivers/ssb/driver_chipcommon.c
+++ b/drivers/ssb/driver_chipcommon.c
@@ -353,6 +353,16 @@ void ssb_chipco_watchdog_timer_set(struct ssb_chipcommon *cc, u32 ticks)
 	chipco_write32(cc, SSB_CHIPCO_WATCHDOG, ticks);
 }
 
+void ssb_chipco_irq_mask(struct ssb_chipcommon *cc, u32 mask, u32 value)
+{
+	chipco_write32_masked(cc, SSB_CHIPCO_IRQMASK, mask, value);
+}
+
+u32 ssb_chipco_irq_status(struct ssb_chipcommon *cc, u32 mask)
+{
+	return chipco_read32(cc, SSB_CHIPCO_IRQSTAT) & mask;
+}
+
 u32 ssb_chipco_gpio_in(struct ssb_chipcommon *cc, u32 mask)
 {
 	return chipco_read32(cc, SSB_CHIPCO_GPIOIN) & mask;
diff --git a/include/linux/ssb/ssb_driver_chipcommon.h b/include/linux/ssb/ssb_driver_chipcommon.h
index 536851b..b548a54 100644
--- a/include/linux/ssb/ssb_driver_chipcommon.h
+++ b/include/linux/ssb/ssb_driver_chipcommon.h
@@ -390,6 +390,10 @@ extern void ssb_chipco_set_clockmode(struct ssb_chipcommon *cc,
 extern void ssb_chipco_watchdog_timer_set(struct ssb_chipcommon *cc,
 					  u32 ticks);
 
+void ssb_chipco_irq_mask(struct ssb_chipcommon *cc, u32 mask, u32 value);
+
+u32 ssb_chipco_irq_status(struct ssb_chipcommon *cc, u32 mask);
+
 /* Chipcommon GPIO pin access. */
 u32 ssb_chipco_gpio_in(struct ssb_chipcommon *cc, u32 mask);
 u32 ssb_chipco_gpio_out(struct ssb_chipcommon *cc, u32 mask, u32 value);
-- 
1.5.4.1


-- 
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
