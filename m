From: akpm@linux-foundation.org
Subject: [patch 1/5] bluetooth: hidp_process_hid_control remove unnecessary parameter dealing
Date: Wed, 21 Nov 2007 15:03:55 -0800
Message-ID: <200711212303.lALN3uMR013716@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	hidave.darkstar@gmail.com
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56235 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753550AbXKUXET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:04:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Young <hidave.darkstar@gmail.com>

According to the bluetooth HID spec v1.0 chapter 7.4.2

"This code requests a major state change in a BT-HID device.  A HID_CONTROL
request does not generate a HANDSHAKE response."

"A HID_CONTROL packet with a parameter of VIRTUAL_CABLE_UNPLUG is the only
HID_CONTROL packet a device can send to a host.  A host will ignore all other
packets."

So in the hidp_precess_hid_control function, we just need to deal with the
UNLUG packet.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/bluetooth/hidp/core.c |   19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff -puN net/bluetooth/hidp/core.c~bluetooth-hidp_process_hid_control-remove-unnecessary-parameter-dealing net/bluetooth/hidp/core.c
--- a/net/bluetooth/hidp/core.c~bluetooth-hidp_process_hid_control-remove-unnecessary-parameter-dealing
+++ a/net/bluetooth/hidp/core.c
@@ -369,30 +369,13 @@ static inline void hidp_process_hid_cont
 {
 	BT_DBG("session %p param 0x%02x", session, param);
 
-	switch (param) {
-	case HIDP_CTRL_NOP:
-		break;
-
-	case HIDP_CTRL_VIRTUAL_CABLE_UNPLUG:
+	if (param == HIDP_CTRL_VIRTUAL_CABLE_UNPLUG) {
 		/* Flush the transmit queues */
 		skb_queue_purge(&session->ctrl_transmit);
 		skb_queue_purge(&session->intr_transmit);
 
 		/* Kill session thread */
 		atomic_inc(&session->terminate);
-		break;
-
-	case HIDP_CTRL_HARD_RESET:
-	case HIDP_CTRL_SOFT_RESET:
-	case HIDP_CTRL_SUSPEND:
-	case HIDP_CTRL_EXIT_SUSPEND:
-		/* FIXME: We have to parse these and return no error */
-		break;
-
-	default:
-		__hidp_send_ctrl_message(session,
-			HIDP_TRANS_HANDSHAKE | HIDP_HSHK_ERR_INVALID_PARAMETER, NULL, 0);
-		break;
 	}
 }
 
_
