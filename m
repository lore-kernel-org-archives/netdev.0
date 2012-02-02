From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2] eicon: fix -Warray-bounds warning
Date: Thu,  2 Feb 2012 14:20:28 +0100
Message-ID: <1328188830-28133-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Laight <David.Laight@aculab.com>
To: Armin Schindler <mac@melware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:36041 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753014Ab2BBNU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 08:20:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix for a -Warray-bounds warning. mixer_notify_update() tries to
write to ((CAPI_MSG *) msg)->info.facility_req.structs[3] while
structs is defined as byte structs[1]. Set all 'structs' which are
part of the typdefs in the info union to 'byte structs[0]'.

v2: set all info.*.structs to byte structs[0]

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/isdn/hardware/eicon/capi20.h |   60 +++++++++++++++++-----------------
 1 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/capi20.h b/drivers/isdn/hardware/eicon/capi20.h
index 7ebcccd..27ecd61 100644
--- a/drivers/isdn/hardware/eicon/capi20.h
+++ b/drivers/isdn/hardware/eicon/capi20.h
@@ -117,7 +117,7 @@ typedef struct api_profile_s {
 /*------------------------------------------------------------------*/
         /* ALERT-REQUEST                                            */
 typedef struct {
-  byte structs[1];      /* Additional Info */
+  byte structs[0];      /* Additional Info */
 } _ALT_REQP;
         /* ALERT-CONFIRM                                            */
 typedef struct {
@@ -126,7 +126,7 @@ typedef struct {
         /* CONNECT-REQUEST                                          */
 typedef struct {
   word CIP_Value;
-  byte structs[1];      /* Called party number,
+  byte structs[0];      /* Called party number,
                            Called party subaddress,
                            Calling party number,
                            Calling party subaddress,
@@ -143,7 +143,7 @@ typedef struct {
         /* CONNECT-INDICATION                                       */
 typedef struct {
   word CIP_Value;
-  byte structs[1];      /* Called party number,
+  byte structs[0];      /* Called party number,
                            Called party subaddress,
                            Calling party number,
                            Calling party subaddress,
@@ -155,24 +155,24 @@ typedef struct {
         /* CONNECT-RESPONSE                                         */
 typedef struct {
   word Accept;
-  byte structs[1];      /* B_protocol,
+  byte structs[0];      /* B_protocol,
                            Connected party number,
                            Connected party subaddress,
                            LLC */
 } _CON_RESP;
         /* CONNECT-ACTIVE-INDICATION                                */
 typedef struct {
-  byte structs[1];      /* Connected party number,
+  byte structs[0];      /* Connected party number,
                            Connected party subaddress,
                            LLC */
 } _CON_A_INDP;
         /* CONNECT-ACTIVE-RESPONSE                                  */
 typedef struct {
-  byte structs[1];      /* empty */
+  byte structs[0];      /* empty */
 } _CON_A_RESP;
         /* DISCONNECT-REQUEST                                       */
 typedef struct {
-  byte structs[1];      /* Additional Info */
+  byte structs[0];      /* Additional Info */
 } _DIS_REQP;
         /* DISCONNECT-CONFIRM                                       */
 typedef struct {
@@ -184,13 +184,13 @@ typedef struct {
 } _DIS_INDP;
         /* DISCONNECT-RESPONSE                                      */
 typedef struct {
-  byte structs[1];      /* empty */
+  byte structs[0];      /* empty */
 } _DIS_RESP;
         /* LISTEN-REQUEST                                           */
 typedef struct {
   dword Info_Mask;
   dword CIP_Mask;
-  byte structs[1];      /* Calling party number,
+  byte structs[0];      /* Calling party number,
                            Calling party subaddress */
 } _LIS_REQP;
         /* LISTEN-CONFIRM                                           */
@@ -199,7 +199,7 @@ typedef struct {
 } _LIS_CONP;
         /* INFO-REQUEST                                             */
 typedef struct {
-  byte structs[1];      /* Called party number,
+  byte structs[0];      /* Called party number,
                            Additional Info */
 } _INF_REQP;
         /* INFO-CONFIRM                                             */
@@ -209,15 +209,15 @@ typedef struct {
         /* INFO-INDICATION                                          */
 typedef struct {
   word Number;
-  byte structs[1];      /* Info element */
+  byte structs[0];      /* Info element */
 } _INF_INDP;
         /* INFO-RESPONSE                                            */
 typedef struct {
-  byte structs[1];      /* empty */
+  byte structs[0];      /* empty */
 } _INF_RESP;
         /* SELECT-B-REQUEST                                         */
 typedef struct {
-  byte structs[1];      /* B-protocol */
+  byte structs[0];      /* B-protocol */
 } _SEL_B_REQP;
         /* SELECT-B-CONFIRM                                         */
 typedef struct {
@@ -226,7 +226,7 @@ typedef struct {
         /* FACILITY-REQUEST */
 typedef struct {
   word Selector;
-  byte structs[1];      /* Facility parameters */
+  byte structs[0];      /* Facility parameters */
 } _FAC_REQP;
         /* FACILITY-CONFIRM STRUCT FOR SUPPLEMENT. SERVICES */
 typedef struct {
@@ -240,21 +240,21 @@ typedef struct {
 typedef struct {
   word Info;
   word Selector;
-  byte structs[1];      /* Facility parameters */
+  byte structs[0];      /* Facility parameters */
 } _FAC_CONP;
         /* FACILITY-INDICATION */
 typedef struct {
   word Selector;
-  byte structs[1];      /* Facility parameters */
+  byte structs[0];      /* Facility parameters */
 } _FAC_INDP;
         /* FACILITY-RESPONSE */
 typedef struct {
   word Selector;
-  byte structs[1];      /* Facility parameters */
+  byte structs[0];      /* Facility parameters */
 } _FAC_RESP;
         /* CONNECT-B3-REQUEST                                       */
 typedef struct {
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _CON_B3_REQP;
         /* CONNECT-B3-CONFIRM                                       */
 typedef struct {
@@ -262,24 +262,24 @@ typedef struct {
 } _CON_B3_CONP;
         /* CONNECT-B3-INDICATION                                    */
 typedef struct {
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _CON_B3_INDP;
         /* CONNECT-B3-RESPONSE                                      */
 typedef struct {
   word Accept;
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _CON_B3_RESP;
         /* CONNECT-B3-ACTIVE-INDICATION                             */
 typedef struct {
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _CON_B3_A_INDP;
         /* CONNECT-B3-ACTIVE-RESPONSE                               */
 typedef struct {
-  byte structs[1];      /* empty */
+  byte structs[0];      /* empty */
 } _CON_B3_A_RESP;
         /* DISCONNECT-B3-REQUEST                                    */
 typedef struct {
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _DIS_B3_REQP;
         /* DISCONNECT-B3-CONFIRM                                    */
 typedef struct {
@@ -288,11 +288,11 @@ typedef struct {
         /* DISCONNECT-B3-INDICATION                                 */
 typedef struct {
   word Info;
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _DIS_B3_INDP;
         /* DISCONNECT-B3-RESPONSE                                   */
 typedef struct {
-  byte structs[1];      /* empty */
+  byte structs[0];      /* empty */
 } _DIS_B3_RESP;
         /* DATA-B3-REQUEST                                          */
 typedef struct {
@@ -335,7 +335,7 @@ typedef struct {
 } _DAT_B3_RESP;
         /* RESET-B3-REQUEST                                         */
 typedef struct {
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _RES_B3_REQP;
         /* RESET-B3-CONFIRM                                         */
 typedef struct {
@@ -343,20 +343,20 @@ typedef struct {
 } _RES_B3_CONP;
         /* RESET-B3-INDICATION                                      */
 typedef struct {
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _RES_B3_INDP;
         /* RESET-B3-RESPONSE                                        */
 typedef struct {
-  byte structs[1];      /* empty */
+  byte structs[0];      /* empty */
 } _RES_B3_RESP;
         /* CONNECT-B3-T90-ACTIVE-INDICATION                         */
 typedef struct {
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _CON_B3_T90_A_INDP;
         /* CONNECT-B3-T90-ACTIVE-RESPONSE                           */
 typedef struct {
   word Reject;
-  byte structs[1];      /* NCPI */
+  byte structs[0];      /* NCPI */
 } _CON_B3_T90_A_RESP;
 /*------------------------------------------------------------------*/
 /* message structure                                                */
-- 
1.7.7.3
