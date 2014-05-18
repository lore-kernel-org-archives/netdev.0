From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/4] isdn/capi: move capi_info2str to capidrv.c
Date: Sun, 18 May 2014 23:26:08 +0200
Message-ID: <365e4f40e1aace19c3233305085ed929b30387b8.1400448370.git.tilman@imap.cc>
References: <cover.1400448368.git.tilman@imap.cc>
Cc: Paul Bolle <pebolle@tiscali.nl>, isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:43908 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbaERWnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2014 18:43:20 -0400
In-Reply-To: <cover.1400448368.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

capi_info2str() is apparently meant to be of general utility. It is
actually only used in capidrv.c. So move it from capiutil.c to
capidrv.c and (obviously) stop exporting it.

And, since we're touching this, merge the two versions of this
function.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capidrv.c   | 195 ++++++++++++++++++++++++++++++++++++++++
 drivers/isdn/capi/capiutil.c  | 200 ------------------------------------------
 include/linux/isdn/capiutil.h |   5 --
 3 files changed, 195 insertions(+), 205 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index cc9f192..70e67f6 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -763,6 +763,201 @@ static inline int new_bchan(capidrv_contr *card)
 }
 
 /* ------------------------------------------------------------------- */
+static char *capi_info2str(u16 reason)
+{
+#ifndef CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON
+	return "..";
+#else
+	switch (reason) {
+
+/*-- informative values (corresponding message was processed) -----*/
+	case 0x0001:
+		return "NCPI not supported by current protocol, NCPI ignored";
+	case 0x0002:
+		return "Flags not supported by current protocol, flags ignored";
+	case 0x0003:
+		return "Alert already sent by another application";
+
+/*-- error information concerning CAPI_REGISTER -----*/
+	case 0x1001:
+		return "Too many applications";
+	case 0x1002:
+		return "Logical block size too small, must be at least 128 Bytes";
+	case 0x1003:
+		return "Buffer exceeds 64 kByte";
+	case 0x1004:
+		return "Message buffer size too small, must be at least 1024 Bytes";
+	case 0x1005:
+		return "Max. number of logical connections not supported";
+	case 0x1006:
+		return "Reserved";
+	case 0x1007:
+		return "The message could not be accepted because of an internal busy condition";
+	case 0x1008:
+		return "OS resource error (no memory ?)";
+	case 0x1009:
+		return "CAPI not installed";
+	case 0x100A:
+		return "Controller does not support external equipment";
+	case 0x100B:
+		return "Controller does only support external equipment";
+
+/*-- error information concerning message exchange functions -----*/
+	case 0x1101:
+		return "Illegal application number";
+	case 0x1102:
+		return "Illegal command or subcommand or message length less than 12 bytes";
+	case 0x1103:
+		return "The message could not be accepted because of a queue full condition !! The error code does not imply that CAPI cannot receive messages directed to another controller, PLCI or NCCI";
+	case 0x1104:
+		return "Queue is empty";
+	case 0x1105:
+		return "Queue overflow, a message was lost !! This indicates a configuration error. The only recovery from this error is to perform a CAPI_RELEASE";
+	case 0x1106:
+		return "Unknown notification parameter";
+	case 0x1107:
+		return "The Message could not be accepted because of an internal busy condition";
+	case 0x1108:
+		return "OS Resource error (no memory ?)";
+	case 0x1109:
+		return "CAPI not installed";
+	case 0x110A:
+		return "Controller does not support external equipment";
+	case 0x110B:
+		return "Controller does only support external equipment";
+
+/*-- error information concerning resource / coding problems -----*/
+	case 0x2001:
+		return "Message not supported in current state";
+	case 0x2002:
+		return "Illegal Controller / PLCI / NCCI";
+	case 0x2003:
+		return "Out of PLCI";
+	case 0x2004:
+		return "Out of NCCI";
+	case 0x2005:
+		return "Out of LISTEN";
+	case 0x2006:
+		return "Out of FAX resources (protocol T.30)";
+	case 0x2007:
+		return "Illegal message parameter coding";
+
+/*-- error information concerning requested services  -----*/
+	case 0x3001:
+		return "B1 protocol not supported";
+	case 0x3002:
+		return "B2 protocol not supported";
+	case 0x3003:
+		return "B3 protocol not supported";
+	case 0x3004:
+		return "B1 protocol parameter not supported";
+	case 0x3005:
+		return "B2 protocol parameter not supported";
+	case 0x3006:
+		return "B3 protocol parameter not supported";
+	case 0x3007:
+		return "B protocol combination not supported";
+	case 0x3008:
+		return "NCPI not supported";
+	case 0x3009:
+		return "CIP Value unknown";
+	case 0x300A:
+		return "Flags not supported (reserved bits)";
+	case 0x300B:
+		return "Facility not supported";
+	case 0x300C:
+		return "Data length not supported by current protocol";
+	case 0x300D:
+		return "Reset procedure not supported by current protocol";
+
+/*-- informations about the clearing of a physical connection -----*/
+	case 0x3301:
+		return "Protocol error layer 1 (broken line or B-channel removed by signalling protocol)";
+	case 0x3302:
+		return "Protocol error layer 2";
+	case 0x3303:
+		return "Protocol error layer 3";
+	case 0x3304:
+		return "Another application got that call";
+/*-- T.30 specific reasons -----*/
+	case 0x3311:
+		return "Connecting not successful (remote station is no FAX G3 machine)";
+	case 0x3312:
+		return "Connecting not successful (training error)";
+	case 0x3313:
+		return "Disconnected before transfer (remote station does not support transfer mode, e.g. resolution)";
+	case 0x3314:
+		return "Disconnected during transfer (remote abort)";
+	case 0x3315:
+		return "Disconnected during transfer (remote procedure error, e.g. unsuccessful repetition of T.30 commands)";
+	case 0x3316:
+		return "Disconnected during transfer (local tx data underrun)";
+	case 0x3317:
+		return "Disconnected during transfer (local rx data overflow)";
+	case 0x3318:
+		return "Disconnected during transfer (local abort)";
+	case 0x3319:
+		return "Illegal parameter coding (e.g. SFF coding error)";
+
+/*-- disconnect causes from the network according to ETS 300 102-1/Q.931 -----*/
+	case 0x3481: return "Unallocated (unassigned) number";
+	case 0x3482: return "No route to specified transit network";
+	case 0x3483: return "No route to destination";
+	case 0x3486: return "Channel unacceptable";
+	case 0x3487:
+		return "Call awarded and being delivered in an established channel";
+	case 0x3490: return "Normal call clearing";
+	case 0x3491: return "User busy";
+	case 0x3492: return "No user responding";
+	case 0x3493: return "No answer from user (user alerted)";
+	case 0x3495: return "Call rejected";
+	case 0x3496: return "Number changed";
+	case 0x349A: return "Non-selected user clearing";
+	case 0x349B: return "Destination out of order";
+	case 0x349C: return "Invalid number format";
+	case 0x349D: return "Facility rejected";
+	case 0x349E: return "Response to STATUS ENQUIRY";
+	case 0x349F: return "Normal, unspecified";
+	case 0x34A2: return "No circuit / channel available";
+	case 0x34A6: return "Network out of order";
+	case 0x34A9: return "Temporary failure";
+	case 0x34AA: return "Switching equipment congestion";
+	case 0x34AB: return "Access information discarded";
+	case 0x34AC: return "Requested circuit / channel not available";
+	case 0x34AF: return "Resources unavailable, unspecified";
+	case 0x34B1: return "Quality of service unavailable";
+	case 0x34B2: return "Requested facility not subscribed";
+	case 0x34B9: return "Bearer capability not authorized";
+	case 0x34BA: return "Bearer capability not presently available";
+	case 0x34BF: return "Service or option not available, unspecified";
+	case 0x34C1: return "Bearer capability not implemented";
+	case 0x34C2: return "Channel type not implemented";
+	case 0x34C5: return "Requested facility not implemented";
+	case 0x34C6: return "Only restricted digital information bearer capability is available";
+	case 0x34CF: return "Service or option not implemented, unspecified";
+	case 0x34D1: return "Invalid call reference value";
+	case 0x34D2: return "Identified channel does not exist";
+	case 0x34D3: return "A suspended call exists, but this call identity does not";
+	case 0x34D4: return "Call identity in use";
+	case 0x34D5: return "No call suspended";
+	case 0x34D6: return "Call having the requested call identity has been cleared";
+	case 0x34D8: return "Incompatible destination";
+	case 0x34DB: return "Invalid transit network selection";
+	case 0x34DF: return "Invalid message, unspecified";
+	case 0x34E0: return "Mandatory information element is missing";
+	case 0x34E1: return "Message type non-existent or not implemented";
+	case 0x34E2: return "Message not compatible with call state or message type non-existent or not implemented";
+	case 0x34E3: return "Information element non-existent or not implemented";
+	case 0x34E4: return "Invalid information element contents";
+	case 0x34E5: return "Message not compatible with call state";
+	case 0x34E6: return "Recovery on timer expiry";
+	case 0x34EF: return "Protocol error, unspecified";
+	case 0x34FF: return "Interworking, unspecified";
+
+	default: return "No additional information";
+	}
+#endif
+}
 
 static void handle_controller(_cmsg *cmsg)
 {
diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index d26f170..6e797e5 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -22,205 +22,6 @@
 
 /* from CAPI2.0 DDK AVM Berlin GmbH */
 
-#ifndef CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON
-char *capi_info2str(u16 reason)
-{
-	return "..";
-}
-#else
-char *capi_info2str(u16 reason)
-{
-	switch (reason) {
-
-/*-- informative values (corresponding message was processed) -----*/
-	case 0x0001:
-		return "NCPI not supported by current protocol, NCPI ignored";
-	case 0x0002:
-		return "Flags not supported by current protocol, flags ignored";
-	case 0x0003:
-		return "Alert already sent by another application";
-
-/*-- error information concerning CAPI_REGISTER -----*/
-	case 0x1001:
-		return "Too many applications";
-	case 0x1002:
-		return "Logical block size too small, must be at least 128 Bytes";
-	case 0x1003:
-		return "Buffer exceeds 64 kByte";
-	case 0x1004:
-		return "Message buffer size too small, must be at least 1024 Bytes";
-	case 0x1005:
-		return "Max. number of logical connections not supported";
-	case 0x1006:
-		return "Reserved";
-	case 0x1007:
-		return "The message could not be accepted because of an internal busy condition";
-	case 0x1008:
-		return "OS resource error (no memory ?)";
-	case 0x1009:
-		return "CAPI not installed";
-	case 0x100A:
-		return "Controller does not support external equipment";
-	case 0x100B:
-		return "Controller does only support external equipment";
-
-/*-- error information concerning message exchange functions -----*/
-	case 0x1101:
-		return "Illegal application number";
-	case 0x1102:
-		return "Illegal command or subcommand or message length less than 12 bytes";
-	case 0x1103:
-		return "The message could not be accepted because of a queue full condition !! The error code does not imply that CAPI cannot receive messages directed to another controller, PLCI or NCCI";
-	case 0x1104:
-		return "Queue is empty";
-	case 0x1105:
-		return "Queue overflow, a message was lost !! This indicates a configuration error. The only recovery from this error is to perform a CAPI_RELEASE";
-	case 0x1106:
-		return "Unknown notification parameter";
-	case 0x1107:
-		return "The Message could not be accepted because of an internal busy condition";
-	case 0x1108:
-		return "OS Resource error (no memory ?)";
-	case 0x1109:
-		return "CAPI not installed";
-	case 0x110A:
-		return "Controller does not support external equipment";
-	case 0x110B:
-		return "Controller does only support external equipment";
-
-/*-- error information concerning resource / coding problems -----*/
-	case 0x2001:
-		return "Message not supported in current state";
-	case 0x2002:
-		return "Illegal Controller / PLCI / NCCI";
-	case 0x2003:
-		return "Out of PLCI";
-	case 0x2004:
-		return "Out of NCCI";
-	case 0x2005:
-		return "Out of LISTEN";
-	case 0x2006:
-		return "Out of FAX resources (protocol T.30)";
-	case 0x2007:
-		return "Illegal message parameter coding";
-
-/*-- error information concerning requested services  -----*/
-	case 0x3001:
-		return "B1 protocol not supported";
-	case 0x3002:
-		return "B2 protocol not supported";
-	case 0x3003:
-		return "B3 protocol not supported";
-	case 0x3004:
-		return "B1 protocol parameter not supported";
-	case 0x3005:
-		return "B2 protocol parameter not supported";
-	case 0x3006:
-		return "B3 protocol parameter not supported";
-	case 0x3007:
-		return "B protocol combination not supported";
-	case 0x3008:
-		return "NCPI not supported";
-	case 0x3009:
-		return "CIP Value unknown";
-	case 0x300A:
-		return "Flags not supported (reserved bits)";
-	case 0x300B:
-		return "Facility not supported";
-	case 0x300C:
-		return "Data length not supported by current protocol";
-	case 0x300D:
-		return "Reset procedure not supported by current protocol";
-
-/*-- informations about the clearing of a physical connection -----*/
-	case 0x3301:
-		return "Protocol error layer 1 (broken line or B-channel removed by signalling protocol)";
-	case 0x3302:
-		return "Protocol error layer 2";
-	case 0x3303:
-		return "Protocol error layer 3";
-	case 0x3304:
-		return "Another application got that call";
-/*-- T.30 specific reasons -----*/
-	case 0x3311:
-		return "Connecting not successful (remote station is no FAX G3 machine)";
-	case 0x3312:
-		return "Connecting not successful (training error)";
-	case 0x3313:
-		return "Disconnected before transfer (remote station does not support transfer mode, e.g. resolution)";
-	case 0x3314:
-		return "Disconnected during transfer (remote abort)";
-	case 0x3315:
-		return "Disconnected during transfer (remote procedure error, e.g. unsuccessful repetition of T.30 commands)";
-	case 0x3316:
-		return "Disconnected during transfer (local tx data underrun)";
-	case 0x3317:
-		return "Disconnected during transfer (local rx data overflow)";
-	case 0x3318:
-		return "Disconnected during transfer (local abort)";
-	case 0x3319:
-		return "Illegal parameter coding (e.g. SFF coding error)";
-
-/*-- disconnect causes from the network according to ETS 300 102-1/Q.931 -----*/
-	case 0x3481: return "Unallocated (unassigned) number";
-	case 0x3482: return "No route to specified transit network";
-	case 0x3483: return "No route to destination";
-	case 0x3486: return "Channel unacceptable";
-	case 0x3487:
-		return "Call awarded and being delivered in an established channel";
-	case 0x3490: return "Normal call clearing";
-	case 0x3491: return "User busy";
-	case 0x3492: return "No user responding";
-	case 0x3493: return "No answer from user (user alerted)";
-	case 0x3495: return "Call rejected";
-	case 0x3496: return "Number changed";
-	case 0x349A: return "Non-selected user clearing";
-	case 0x349B: return "Destination out of order";
-	case 0x349C: return "Invalid number format";
-	case 0x349D: return "Facility rejected";
-	case 0x349E: return "Response to STATUS ENQUIRY";
-	case 0x349F: return "Normal, unspecified";
-	case 0x34A2: return "No circuit / channel available";
-	case 0x34A6: return "Network out of order";
-	case 0x34A9: return "Temporary failure";
-	case 0x34AA: return "Switching equipment congestion";
-	case 0x34AB: return "Access information discarded";
-	case 0x34AC: return "Requested circuit / channel not available";
-	case 0x34AF: return "Resources unavailable, unspecified";
-	case 0x34B1: return "Quality of service unavailable";
-	case 0x34B2: return "Requested facility not subscribed";
-	case 0x34B9: return "Bearer capability not authorized";
-	case 0x34BA: return "Bearer capability not presently available";
-	case 0x34BF: return "Service or option not available, unspecified";
-	case 0x34C1: return "Bearer capability not implemented";
-	case 0x34C2: return "Channel type not implemented";
-	case 0x34C5: return "Requested facility not implemented";
-	case 0x34C6: return "Only restricted digital information bearer capability is available";
-	case 0x34CF: return "Service or option not implemented, unspecified";
-	case 0x34D1: return "Invalid call reference value";
-	case 0x34D2: return "Identified channel does not exist";
-	case 0x34D3: return "A suspended call exists, but this call identity does not";
-	case 0x34D4: return "Call identity in use";
-	case 0x34D5: return "No call suspended";
-	case 0x34D6: return "Call having the requested call identity has been cleared";
-	case 0x34D8: return "Incompatible destination";
-	case 0x34DB: return "Invalid transit network selection";
-	case 0x34DF: return "Invalid message, unspecified";
-	case 0x34E0: return "Mandatory information element is missing";
-	case 0x34E1: return "Message type non-existent or not implemented";
-	case 0x34E2: return "Message not compatible with call state or message type non-existent or not implemented";
-	case 0x34E3: return "Information element non-existent or not implemented";
-	case 0x34E4: return "Invalid information element contents";
-	case 0x34E5: return "Message not compatible with call state";
-	case 0x34E6: return "Recovery on timer expiry";
-	case 0x34EF: return "Protocol error, unspecified";
-	case 0x34FF: return "Interworking, unspecified";
-
-	default: return "No additional information";
-	}
-}
-#endif
-
 typedef struct {
 	int typ;
 	size_t off;
@@ -1073,4 +874,3 @@ EXPORT_SYMBOL(capi_cmsg_header);
 EXPORT_SYMBOL(capi_cmd2str);
 EXPORT_SYMBOL(capi_cmsg2str);
 EXPORT_SYMBOL(capi_message2str);
-EXPORT_SYMBOL(capi_info2str);
diff --git a/include/linux/isdn/capiutil.h b/include/linux/isdn/capiutil.h
index 5a52f2c..44bd604 100644
--- a/include/linux/isdn/capiutil.h
+++ b/include/linux/isdn/capiutil.h
@@ -164,11 +164,6 @@ unsigned capi_cmsg_header(_cmsg * cmsg, __u16 _ApplId,
 			  __u8 _Command, __u8 _Subcommand,
 			  __u16 _Messagenumber, __u32 _Controller);
 
-/*
- * capi_info2str generated a readable string for Capi2.0 reasons.
- */
-char *capi_info2str(__u16 reason);
-
 /*-----------------------------------------------------------------------*/
 
 /*
-- 
1.9.2.459.g68773ac
