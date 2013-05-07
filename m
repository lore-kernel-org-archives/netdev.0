From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] Bluetooth: hidp: using strlcpy or strcpy instead of strncpy
Date: Tue, 07 May 2013 21:50:32 +0800
Message-ID: <518906A8.7060708@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, andrei.emeltchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org,
	johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


For NUL terminated string, need always let it ended by zero.

Since have already called memcpy() to initialize 'ci', so need not
redundent initializations.

Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
---
 net/bluetooth/hidp/core.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 940f5ac..9a8ae63 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -76,25 +76,21 @@ static void hidp_copy_session(struct hidp_session *session, struct hidp_conninfo
 	ci->flags = session->flags;
 	ci->state = BT_CONNECTED;
 
-	ci->vendor  = 0x0000;
-	ci->product = 0x0000;
-	ci->version = 0x0000;
-
 	if (session->input) {
 		ci->vendor  = session->input->id.vendor;
 		ci->product = session->input->id.product;
 		ci->version = session->input->id.version;
 		if (session->input->name)
-			strncpy(ci->name, session->input->name, 128);
+			strlcpy(ci->name, session->input->name, 128);
 		else
-			strncpy(ci->name, "HID Boot Device", 128);
+			strcpy(ci->name, "HID Boot Device");
 	}
 
 	if (session->hid) {
 		ci->vendor  = session->hid->vendor;
 		ci->product = session->hid->product;
 		ci->version = session->hid->version;
-		strncpy(ci->name, session->hid->name, 128);
+		strlcpy(ci->name, session->hid->name, 128);
 	}
 }
 
-- 
1.7.7.6
