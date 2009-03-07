From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/2] gigaset: return -ENOSYS for unimplemented functions
Date: Sat,  7 Mar 2009 23:10:57 +0100 (CET)
Message-ID: <20090307-patch-01.tilman@imap.cc>
References: <20090307-patch-00.tilman@imap.cc>
Cc: Paul Bolle <pebolle@tiscali.nl>, Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756761AbZCGWLe@vger.kernel.org>
In-Reply-To: <20090307-patch-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>

A number of functions in the usb_gigaset module will return -EINVAL if
CONFIG_GIGASET_UNDOCREQ is not set. Make these return -ENOSYS as it's
more specific and it might make it easier to see (from userspace) why
these functions actually fail.

Impact: some error return codes changed

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/usb-gigaset.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index fba61f6..2bd6d9d 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -278,17 +278,17 @@ static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
 				  unsigned new_state)
 {
-	return -EINVAL;
+	return -ENOSYS;
 }
 
 static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 {
-	return -EINVAL;
+	return -ENOSYS;
 }
 
 static int gigaset_baud_rate(struct cardstate *cs, unsigned cflag)
 {
-	return -EINVAL;
+	return -ENOSYS;
 }
 #endif
 
@@ -577,7 +577,7 @@ static int gigaset_brkchars(struct cardstate *cs, const unsigned char buf[6])
 	return usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x19, 0x41,
 			       0, 0, &buf, 6, 2000);
 #else
-	return -EINVAL;
+	return -ENOSYS;
 #endif
 }
 
-- 
1.5.4.7.gd8534-dirty
