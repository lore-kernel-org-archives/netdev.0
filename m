From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] ssb: Add CHIPCO IRQ access functions
Date: Fri, 22 Feb 2008 16:14:58 +0100
Message-ID: <200802221614.59119.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Aurelien Jarno <aurelien@aurel32.net>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:56126 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264AbYBVPPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 10:15:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aurelien Jarno <aurelien@aurel32.net>

This patch adds functions to setup and read the CHIPCO IRQ.

Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

For 2.6.26.

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
Greetings Michael.
