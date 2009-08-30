From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 04/47] Bluetooth: Disconnect HIDRAW devices on disconnect
Date: Sun, 30 Aug 2009 01:50:18 -0700
Message-ID: <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53263 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbZH3Ivx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:53 -0400
In-Reply-To: <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the HID subsystem will create HIDRAW devices for the transport
driver, but it will not disconnect them. Until the HID subsytem gets
fixed, ensure that HIDRAW and HIDDEV devices are disconnected when the
Bluetooth HID device gets removed.

Based on a patch from Brian Rogers <brian@xyzw.org>

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hidp/core.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index a9f7afb..f912d65 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -40,6 +40,7 @@
 
 #include <linux/input.h>
 #include <linux/hid.h>
+#include <linux/hidraw.h>
 
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
@@ -574,6 +575,8 @@ static int hidp_session(void *arg)
 	if (session->hid) {
 		if (session->hid->claimed & HID_CLAIMED_INPUT)
 			hidinput_disconnect(session->hid);
+		if (session->hid->claimed & HID_CLAIMED_HIDRAW)
+			hidraw_disconnect(session->hid);
 		hid_destroy_device(session->hid);
 	}
 
-- 
1.6.2.5

