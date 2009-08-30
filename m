From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 02/47] Bluetooth: Fix missing scheduling when VIRTUAL_CABLE_UNPLUG is received
Date: Sun, 30 Aug 2009 01:50:16 -0700
Message-ID: <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53263 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbZH3Ivv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:51 -0400
In-Reply-To: <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vikram Kandukuri <vkandukuri@atheros.com>

There is a test case in PTS tool; PTS will send the VIRTUAL_CABLE_UNPLUG
command to IUT. Then IUT should disconnect the channel and kill the HID
session when it receives the command. The VIRTUAL_CABLE_UNPLUG command
is parsed by HID transport, but it is not scheduled to do so. Add a
call to hidp_schedule() to kill the session.

Signed-off-by: Jothikumar Mothilal <jothikumar.mothilal@atheros.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hidp/core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index b186768..a9f7afb 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -374,6 +374,7 @@ static void hidp_process_hid_control(struct hidp_session *session,
 
 		/* Kill session thread */
 		atomic_inc(&session->terminate);
+		hidp_schedule(session);
 	}
 }
 
-- 
1.6.2.5

