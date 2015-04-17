From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] Bluetooth: hidp: Fix regression with older userspace and flags validation
Date: Fri, 17 Apr 2015 22:34:18 +0200
Message-ID: <1429302858-44595-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jrg.otte-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

While it is not used by newer userspace anymore, the older userspace wa=
s
utilizing HIDP_VIRTUAL_CABLE_UNPLUG and HIDP_BOOT_PROTOCOL_MODE flags
when adding a new HIDP connection.

The flags validation is important, but we can not break older userspace
and with that allow providing these flags even if newer userspace does
not use them anymore.

Reported-by: J=C3=B6rg Otte <jrg.otte-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
---
 net/bluetooth/hidp/core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index a05b9dbf14c9..9070dfd6b4ad 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -1313,7 +1313,8 @@ int hidp_connection_add(struct hidp_connadd_req *=
req,
 			struct socket *ctrl_sock,
 			struct socket *intr_sock)
 {
-	u32 valid_flags =3D 0;
+	u32 valid_flags =3D BIT(HIDP_VIRTUAL_CABLE_UNPLUG) |
+			  BIT(HIDP_BOOT_PROTOCOL_MODE);
 	struct hidp_session *session;
 	struct l2cap_conn *conn;
 	struct l2cap_chan *chan;
--=20
2.1.0
