From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH] NET: pktgen - fix compile warning
Date: Sat, 6 Nov 2010 23:11:38 -0700
Message-ID: <20101107061138.GA6601@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Nelson Elhage <nelhage@ksplice.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48131 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288Ab0KGGLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 01:11:45 -0500
Received: by iwn41 with SMTP id 41so2621591iwn.19
        for <netdev@vger.kernel.org>; Sat, 06 Nov 2010 23:11:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should fix the following warning:

net/core/pktgen.c: In function =E2=80=98pktgen_if_write=E2=80=99:
net/core/pktgen.c:890: warning: comparison of distinct pointer types la=
cks a cast

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---

Unless somebody already beat me to it...

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
Dmitry
