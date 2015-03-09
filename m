From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 7/8] net/socket: sock_map_fd - use faster fd allocation api
Date: Mon,  9 Mar 2015 14:20:02 -0700
Message-ID: <1425936003-24544-7-git-send-email-zenczykowski@gmail.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
 <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:37691 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158AbbCIVU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:29 -0400
Received: by iebtr6 with SMTP id tr6so33983800ieb.4
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:29 -0700 (PDT)
In-Reply-To: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/socket.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 87fd36939778..10f5daf0e625 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -400,13 +400,12 @@ static int sock_map_fd(struct socket *sock, int f=
lags)
 		return PTR_ERR(newfile);
 	}
=20
-	fd =3D get_unused_fd_flags(flags);
+	fd =3D get_unused_fd_and_install_flags(flags, newfile);
 	if (unlikely(fd < 0)) {
 		fput(newfile);
 		return fd;
 	}
=20
-	fd_install(fd, newfile);
 	return fd;
 }
=20
--=20
2.2.0.rc0.207.ga3a616c
