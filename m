From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [PATCH RESEND] bluetooth: Remove bogus inline for l2cap_chan_connect()
Date: Sun, 26 Feb 2012 20:31:59 +0100
Message-ID: <1330284719-22348-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

commit 03a001948166d966d0d580cddb8ae3a23f8b795b ("Bluetooth: invert loc=
king
order in connect path") marked l2cap_chan_connect() inline for both the
prototype in include/net/bluetooth/l2cap.h and the implementation in
net/bluetooth/l2cap_core.c.

As the former doesn't contain an implementation, net/bluetooth/l2cap_so=
ck.c
now fails to build with gcc version 4.1.2 20061115 (prerelease) (Ubuntu
4.1.1-21), e.g. for m68k allmodconfig:

    net/bluetooth/l2cap_sock.c: In function =E2=80=98l2cap_sock_connect=
=E2=80=99:
    include/net/bluetooth/l2cap.h:838: sorry, unimplemented: inlining f=
ailed in call to =E2=80=98l2cap_chan_connect=E2=80=99: function body no=
t available
    net/bluetooth/l2cap_sock.c:126: sorry, unimplemented: called from h=
ere
    make[1]: *** [net/bluetooth/l2cap_sock.o] Error 1

As l2cap_chan_connect() is not that small and also called from
net/bluetooth/l2cap_sock.c, I removed both inline keywords.

Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
---
Linus, this has been breaking my builds for 6 weeks with no imminent ac=
tion
from the maintainer, so I'm sending it to you directly.

 include/net/bluetooth/l2cap.h |    2 +-
 net/bluetooth/l2cap_core.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2ca=
p.h
index 68f5891..124f7cf 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -834,7 +834,7 @@ int l2cap_add_scid(struct l2cap_chan *chan,  __u16 =
scid);
 struct l2cap_chan *l2cap_chan_create(struct sock *sk);
 void l2cap_chan_close(struct l2cap_chan *chan, int reason);
 void l2cap_chan_destroy(struct l2cap_chan *chan);
-inline int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16=
 cid,
+int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid,
 								bdaddr_t *dst);
 int l2cap_chan_send(struct l2cap_chan *chan, struct msghdr *msg, size_=
t len,
 								u32 priority);
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index faf0b11..980abdb 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1120,7 +1120,7 @@ static struct l2cap_chan *l2cap_global_chan_by_ps=
m(int state, __le16 psm, bdaddr
 	return c1;
 }
=20
-inline int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16=
 cid, bdaddr_t *dst)
+int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid, b=
daddr_t *dst)
 {
 	struct sock *sk =3D chan->sk;
 	bdaddr_t *src =3D &bt_sk(sk)->src;
--=20
1.7.0.4
