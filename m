From: Davidlohr Bueso <dave@gnu.org>
Subject: [PATCH] net: replace min with min_t in pktgen_if_write
Date: Tue, 09 Nov 2010 13:37:13 -0300
Message-ID: <1289320633.2260.12.camel@cowboy>
Reply-To: dave@gnu.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Davidlohr Bueso <dave@gnu.org>

This addresses the following compiler (gcc 4.4.5) warning:

  CC [M]  net/core/pktgen.o
net/core/pktgen.c: In function =E2=80=98pktgen_if_write=E2=80=99:
net/core/pktgen.c:890: warning: comparison of distinct pointer types la=
cks a cast

Signed-off-by: Davidlohr Bueso <dave@gnu.org>
---
 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fbce4b0..1992cd0 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -887,7 +887,7 @@ static ssize_t pktgen_if_write(struct file *file,
 	i +=3D len;
=20
 	if (debug) {
-		size_t copy =3D min(count, 1023);
+		size_t copy =3D min_t(size_t, count, 1023);
 		char tb[copy + 1];
 		if (copy_from_user(tb, user_buffer, copy))
 			return -EFAULT;
--=20
1.7.1
