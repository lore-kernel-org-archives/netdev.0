From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 1/3 v4] rfkill: Remove IRDA
Date: Wed, 12 Sep 2007 20:14:26 +0200
Message-ID: <200709122014.26660.IvDoorn@gmail.com>
References: <200709101954.50852.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:40478 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757625AbXILSDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 14:03:00 -0400
Received: by ug-out-1314.google.com with SMTP id z38so267442ugc
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:02:59 -0700 (PDT)
In-Reply-To: <200709101954.50852.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As Dmitry pointed out earlier, rfkill-input.c
doesn't support irda because there are no users
and we shouldn't add unrequired KEY_ defines.

However, RFKILL_TYPE_IRDA was defined in the
rfkill.h header file and would confuse people
about whether it is implemented or not.

This patch removes IRDA support completely,
so it can be added whenever a driver wants the
feature.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
CC: Dmitry Torokhov <dmitry.torokhov@gmail.com>
CC: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 include/linux/rfkill.h |    8 +++-----
 net/rfkill/Kconfig     |    2 +-
 net/rfkill/rfkill.c    |    5 +----
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index a8a6ea8..c4546e1 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -31,13 +31,11 @@
  * enum rfkill_type - type of rfkill switch.
  * RFKILL_TYPE_WLAN: switch is no a Wireless network devices.
  * RFKILL_TYPE_BlUETOOTH: switch is on a bluetooth device.
- * RFKILL_TYPE_IRDA: switch is on an infrared devices.
  */
 enum rfkill_type {
-	RFKILL_TYPE_WLAN = 0,
-	RFKILL_TYPE_BLUETOOTH = 1,
-	RFKILL_TYPE_IRDA = 2,
-	RFKILL_TYPE_MAX = 3,
+	RFKILL_TYPE_WLAN ,
+	RFKILL_TYPE_BLUETOOTH,
+	RFKILL_TYPE_MAX,
 };
 
 enum rfkill_state {
diff --git a/net/rfkill/Kconfig b/net/rfkill/Kconfig
index 8b31759..d28a6d9 100644
--- a/net/rfkill/Kconfig
+++ b/net/rfkill/Kconfig
@@ -5,7 +5,7 @@ menuconfig RFKILL
 	tristate "RF switch subsystem support"
 	help
 	  Say Y here if you want to have control over RF switches
-	  found on many WiFi, Bluetooth and IRDA cards.
+	  found on many WiFi and Bluetooth cards.
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called rfkill.
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index db3395b..50e0102 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -106,9 +106,6 @@ static ssize_t rfkill_type_show(struct device *dev,
 	case RFKILL_TYPE_BLUETOOTH:
 		type = "bluetooth";
 		break;
-	case RFKILL_TYPE_IRDA:
-		type = "irda";
-		break;
 	default:
 		BUG();
 	}
@@ -281,7 +278,7 @@ static void rfkill_remove_switch(struct rfkill *rfkill)
 /**
  * rfkill_allocate - allocate memory for rfkill structure.
  * @parent: device that has rf switch on it
- * @type: type of the switch (wlan, bluetooth, irda)
+ * @type: type of the switch (RFKILL_TYPE_*)
  *
  * This function should be called by the network driver when it needs
  * rfkill structure. Once the structure is allocated the driver shoud
-- 
1.5.3

