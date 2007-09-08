From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC 2/3] rfkill: Add support for ultrawideband
Date: Sat, 8 Sep 2007 17:11:50 +0200
Message-ID: <200709081711.50344.IvDoorn@gmail.com>
References: <200709081710.56744.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200709081710.56744.IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch will add support for UWB keys to rfkill,
support for this has been requested by Inaky.

Signed-off-by: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
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
