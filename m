From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Detect more AL2230S radios
Date: Sun,  1 Jul 2007 18:22:04 +0100 (BST)
Message-ID: <20070701172205.280957B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Zen Kato has a device which reports the 0xa RF type. The vendor driver
treats this as AL2230S, the same as devices with the AL2230S bit in the POD.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_rf.c        |    3 ++-
 zd_rf.h        |    2 +-
 zd_rf_al2230.c |   10 ++++++----
 3 files changed, 9 insertions(+), 6 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_rf.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_rf.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -34,7 +34,7 @@ static const char * const rfs[] = {
 	[AL2210_RF]	= "AL2210_RF",
 	[MAXIM_NEW_RF]	= "MAXIM_NEW_RF",
 	[UW2453_RF]	= "UW2453_RF",
-	[UNKNOWN_A_RF]	= "UNKNOWN_A_RF",
+	[AL2230S_RF]	= "AL2230S_RF",
 	[RALINK_RF]	= "RALINK_RF",
 	[INTERSIL_RF]	= "INTERSIL_RF",
 	[RF2959_RF]	= "RF2959_RF",
@@ -77,6 +77,7 @@ int zd_rf_init_hw(struct zd_rf *rf, u8 t
 		r = zd_rf_init_rf2959(rf);
 		break;
 	case AL2230_RF:
+	case AL2230S_RF:
 		r = zd_rf_init_al2230(rf);
 		break;
 	case AL7230B_RF:
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_rf.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_rf.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -26,7 +26,7 @@
 #define AL2210_RF			0x7
 #define MAXIM_NEW_RF			0x8
 #define UW2453_RF			0x9
-#define UNKNOWN_A_RF			0xa
+#define AL2230S_RF			0xa
 #define RALINK_RF			0xb
 #define INTERSIL_RF			0xc
 #define RF2959_RF			0xd
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -21,6 +21,8 @@
 #include "zd_usb.h"
 #include "zd_chip.h"
 
+#define IS_AL2230S(chip) ((chip)->al2230s_bit || (chip)->rf.type == AL2230S_RF)
+
 static const u32 zd1211_al2230_table[][3] = {
 	RF_CHANNEL( 1) = { 0x03f790, 0x033331, 0x00000d, },
 	RF_CHANNEL( 2) = { 0x03f790, 0x0b3331, 0x00000d, },
@@ -176,7 +178,7 @@ static int zd1211_al2230_init_hw(struct 
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit) {
+	if (IS_AL2230S(chip)) {
 		r = zd_iowrite16a_locked(chip, ioreqs_init_al2230s,
 			ARRAY_SIZE(ioreqs_init_al2230s));
 		if (r)
@@ -188,7 +190,7 @@ static int zd1211_al2230_init_hw(struct 
 		return r;
 
 	/* improve band edge for AL2230S */
-	if (chip->al2230s_bit)
+	if (IS_AL2230S(chip))
 		r = zd_rfwrite_locked(chip, 0x000824, RF_RV_BITS);
 	else
 		r = zd_rfwrite_locked(chip, 0x0005a4, RF_RV_BITS);
@@ -314,7 +316,7 @@ static int zd1211b_al2230_init_hw(struct
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit) {
+	if (IS_AL2230S(chip)) {
 		r = zd_iowrite16a_locked(chip, ioreqs_init_al2230s,
 			ARRAY_SIZE(ioreqs_init_al2230s));
 		if (r)
@@ -328,7 +330,7 @@ static int zd1211b_al2230_init_hw(struct
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit)
+	if (IS_AL2230S(chip))
 		r = zd_rfwrite_locked(chip, 0x241000, RF_RV_BITS);
 	else
 		r = zd_rfwrite_locked(chip, 0x25a000, RF_RV_BITS);
