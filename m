From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] rds: Fix min() warning in rds_message_inc_copy_to_user()
Date: Mon, 15 Dec 2014 13:21:42 +0100
Message-ID: <1418646102-32415-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Al Viro <viro@zeniv.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/rds/message.c: In function =E2=80=98rds_message_inc_copy_to_user=E2=
=80=99:
net/rds/message.c:328: warning: comparison of distinct pointer types la=
cks a cast

Use min_t(unsigned long, ...) like is done in
rds_message_copy_from_user().

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/rds/message.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rds/message.c b/net/rds/message.c
index ff22022181875303..5a21e6f5986f1b82 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -325,7 +325,8 @@ int rds_message_inc_copy_to_user(struct rds_incomin=
g *inc, struct iov_iter *to)
 	copied =3D 0;
=20
 	while (iov_iter_count(to) && copied < len) {
-		to_copy =3D min(iov_iter_count(to), sg->length - vec_off);
+		to_copy =3D min_t(unsigned long, iov_iter_count(to),
+				sg->length - vec_off);
 		to_copy =3D min_t(unsigned long, to_copy, len - copied);
=20
 		rds_stats_add(s_copy_to_user, to_copy);
--=20
1.9.1
