From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/3] rfkill: Add support for ultrawideband
Date: Mon, 10 Sep 2007 19:55:25 +0200
Message-ID: <200709101955.26033.IvDoorn@gmail.com>
References: <200709101954.50852.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:52369 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884AbXIJRpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 13:45:14 -0400
Received: by ug-out-1314.google.com with SMTP id z38so507762ugc
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 10:45:13 -0700 (PDT)
In-Reply-To: <200709101954.50852.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch will add support for UWB keys to rfkill,
support for this has been requested by Inaky.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
Acked-by: Dmitry Torokhov <dtor@mail.ru>
---
 include/linux/input.h     |    1 +
 include/linux/rfkill.h    |    2 ++
 net/rfkill/rfkill-input.c |    9 +++++++++
 net/rfkill/rfkill.c       |    3 +++
 4 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/linux/input.h b/include/linux/input.h
index cf2b561..8e5828d 100644
--- a/include/linux/input.h
+++ b/include/linux/input.h
@@ -360,6 +360,7 @@ struct input_absinfo {
 
 #define KEY_BLUETOOTH		237
 #define KEY_WLAN		238
+#define KEY_UWB			239
 
 #define KEY_UNKNOWN		240
 
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index c4546e1..f9a50da 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -31,10 +31,12 @@
  * enum rfkill_type - type of rfkill switch.
  * RFKILL_TYPE_WLAN: switch is no a Wireless network devices.
  * RFKILL_TYPE_BlUETOOTH: switch is on a bluetooth device.
+ * RFKILL_TYPE_UWB: switch is on a Ultra wideband device.
  */
 enum rfkill_type {
 	RFKILL_TYPE_WLAN ,
 	RFKILL_TYPE_BLUETOOTH,
+	RFKILL_TYPE_UWB,
 	RFKILL_TYPE_MAX,
 };
 
diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
index 9f746be..8e4516a 100644
--- a/net/rfkill/rfkill-input.c
+++ b/net/rfkill/rfkill-input.c
@@ -81,6 +81,7 @@ static void rfkill_schedule_toggle(struct rfkill_task *task)
 
 static DEFINE_RFKILL_TASK(rfkill_wlan, RFKILL_TYPE_WLAN);
 static DEFINE_RFKILL_TASK(rfkill_bt, RFKILL_TYPE_BLUETOOTH);
+static DEFINE_RFKILL_TASK(rfkill_uwb, RFKILL_TYPE_UWB);
 
 static void rfkill_event(struct input_handle *handle, unsigned int type,
 			unsigned int code, int down)
@@ -93,6 +94,9 @@ static void rfkill_event(struct input_handle *handle, unsigned int type,
 		case KEY_BLUETOOTH:
 			rfkill_schedule_toggle(&rfkill_bt);
 			break;
+		case KEY_UWB:
+			rfkill_schedule_toggle(&rfkill_uwb);
+			break;
 		default:
 			break;
 		}
@@ -148,6 +152,11 @@ static const struct input_device_id rfkill_ids[] = {
 		.evbit = { BIT(EV_KEY) },
 		.keybit = { [LONG(KEY_BLUETOOTH)] = BIT(KEY_BLUETOOTH) },
 	},
+	{
+		.flags = INPUT_DEVICE_ID_MATCH_EVBIT | INPUT_DEVICE_ID_MATCH_KEYBIT,
+		.evbit = { BIT(EV_KEY) },
+		.keybit = { [LONG(KEY_UWB)] = BIT(KEY_UWB) },
+	},
 	{ }
 };
 
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 50e0102..03ed7fd 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -106,6 +106,9 @@ static ssize_t rfkill_type_show(struct device *dev,
 	case RFKILL_TYPE_BLUETOOTH:
 		type = "bluetooth";
 		break;
+	case RFKILL_TYPE_UWB:
+		type = "ultrawideband";
+		break;
 	default:
 		BUG();
 	}
-- 
1.5.3

