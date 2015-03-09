From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 1/8] net/socket: sock_map_fd - reverse error handling logic
Date: Mon,  9 Mar 2015 14:19:56 -0700
Message-ID: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:40691 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbCIVUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:19 -0400
Received: by igal13 with SMTP id l13so24937469iga.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:19 -0700 (PDT)
In-Reply-To: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

functional no-op, but easier to read

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/socket.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 95d3085cb477..323ebd530b88 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -397,13 +397,13 @@ static int sock_map_fd(struct socket *sock, int f=
lags)
 		return fd;
=20
 	newfile =3D sock_alloc_file(sock, flags, NULL);
-	if (likely(!IS_ERR(newfile))) {
-		fd_install(fd, newfile);
-		return fd;
+	if (unlikely(IS_ERR(newfile))) {
+		put_unused_fd(fd);
+		return PTR_ERR(newfile);
 	}
=20
-	put_unused_fd(fd);
-	return PTR_ERR(newfile);
+	fd_install(fd, newfile);
+	return fd;
 }
=20
 struct socket *sock_from_file(struct file *file, int *err)
--=20
2.2.0.rc0.207.ga3a616c
