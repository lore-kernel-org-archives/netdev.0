From: <gregkh@linuxfoundation.org>
Subject: patch "wireless: ipw2x00: convert to use DRIVER_ATTR_RW" added to driver-core-next
Date: Tue, 13 Jun 2017 07:58:56 +0200
Message-ID: <1497333536150221@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: gregkh@linuxfoundation.org, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        stas.yakovlev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:43374 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752357AbdFMF7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 01:59:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    wireless: ipw2x00: convert to use DRIVER_ATTR_RW

to my driver-core git tree which can be found at
    git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git
in the driver-core-next branch.

The patch will show up in the next release of the linux-next tree
(usually sometime within the next 24 hours during the week.)

The patch will also be merged in the next major kernel release
during the merge window.

If you have any questions about this process, please let me know.


>From 0457e1ae0f4b88676b0cea30ef6acff24febbbc0 Mon Sep 17 00:00:00 2001
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 9 Jun 2017 11:03:10 +0200
Subject: wireless: ipw2x00: convert to use DRIVER_ATTR_RW

We are trying to get rid of DRIVER_ATTR(), and the ipw2x00 driver's
attributes can be trivially changed to use DRIVER_ATTR_RW().

Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: <linux-wireless@vger.kernel.org>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/wireless/intel/ipw2x00/ipw2100.c | 8 +++-----
 drivers/net/wireless/intel/ipw2x00/ipw2200.c | 8 +++-----
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index f922859acf40..aaaca4d08e2b 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -4160,12 +4160,12 @@ static ssize_t show_bssinfo(struct device *d, struct device_attribute *attr,
 static DEVICE_ATTR(bssinfo, S_IRUGO, show_bssinfo, NULL);
 
 #ifdef CONFIG_IPW2100_DEBUG
-static ssize_t show_debug_level(struct device_driver *d, char *buf)
+static ssize_t debug_level_show(struct device_driver *d, char *buf)
 {
 	return sprintf(buf, "0x%08X\n", ipw2100_debug_level);
 }
 
-static ssize_t store_debug_level(struct device_driver *d,
+static ssize_t debug_level_store(struct device_driver *d,
 				 const char *buf, size_t count)
 {
 	u32 val;
@@ -4179,9 +4179,7 @@ static ssize_t store_debug_level(struct device_driver *d,
 
 	return strnlen(buf, count);
 }
-
-static DRIVER_ATTR(debug_level, S_IWUSR | S_IRUGO, show_debug_level,
-		   store_debug_level);
+static DRIVER_ATTR_RW(debug_level);
 #endif				/* CONFIG_IPW2100_DEBUG */
 
 static ssize_t show_fatal_error(struct device *d,
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index bbc579b647b6..5b79e2ec3a16 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -1195,12 +1195,12 @@ static void ipw_led_shutdown(struct ipw_priv *priv)
  *
  * See the level definitions in ipw for details.
  */
-static ssize_t show_debug_level(struct device_driver *d, char *buf)
+static ssize_t debug_level_show(struct device_driver *d, char *buf)
 {
 	return sprintf(buf, "0x%08X\n", ipw_debug_level);
 }
 
-static ssize_t store_debug_level(struct device_driver *d, const char *buf,
+static ssize_t debug_level_store(struct device_driver *d, const char *buf,
 				 size_t count)
 {
 	char *p = (char *)buf;
@@ -1221,9 +1221,7 @@ static ssize_t store_debug_level(struct device_driver *d, const char *buf,
 
 	return strnlen(buf, count);
 }
-
-static DRIVER_ATTR(debug_level, S_IWUSR | S_IRUGO,
-		   show_debug_level, store_debug_level);
+static DRIVER_ATTR_RW(debug_level);
 
 static inline u32 ipw_get_event_log_len(struct ipw_priv *priv)
 {
-- 
2.13.1
