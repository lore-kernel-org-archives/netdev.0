From: David Sterba <dsterba-AlSwsSmVLrQ@public.gmane.org>
Subject: [PATCH] Bluetooth: l2cap: fix misuse of logical operation in place of bitop
Date: Mon, 27 Dec 2010 19:00:10 +0100
Message-ID: <1293472810-30233-1-git-send-email-dsterba@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Sterba <dsterba-AlSwsSmVLrQ@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=
	<jprvita-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
To: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

CC: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
CC: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
CC: Jo=C3=A3o Paulo Rechi Vita <jprvita-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Signed-off-by: David Sterba <dsterba-AlSwsSmVLrQ@public.gmane.org>
---
 net/bluetooth/l2cap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index cd8f6ea..bdfdfdc 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1893,8 +1893,8 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb,=
 struct socket *sock, struct ms
 		if (pi->mode =3D=3D L2CAP_MODE_STREAMING) {
 			l2cap_streaming_send(sk);
 		} else {
-			if (pi->conn_state & L2CAP_CONN_REMOTE_BUSY &&
-					pi->conn_state && L2CAP_CONN_WAIT_F) {
+			if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY) &&
+					(pi->conn_state & L2CAP_CONN_WAIT_F)) {
 				err =3D len;
 				break;
 			}
--=20
1.7.3.4.626.g73e7b
