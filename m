From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: allow CAP_NET_RAW to setsockopt SO_PRIORITY
Date: Mon, 24 Oct 2011 21:47:18 -0700
Message-ID: <1319518038-28679-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:43511 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab1JYErc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 00:47:32 -0400
Received: by ywm3 with SMTP id 3so121775ywm.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 21:47:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

It is my belief that CAP_NET_ADMIN is and should continue to be about
configuring the system as a whole, not about configuring per-socket
or per-packet parameters.

Sending and receiving raw packets is what CAP_NET_RAW is all about.
Hence it makes sense to allow a CAP_NET_RAW process to set the
priority of sockets and thus packets it sends.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/core/sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5a08762..3d163b6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -612,7 +612,8 @@ set_rcvbuf:
 		break;
=20
 	case SO_PRIORITY:
-		if ((val >=3D 0 && val <=3D 6) || capable(CAP_NET_ADMIN))
+		if ((val >=3D 0 && val <=3D 6)
+		    || capable(CAP_NET_ADMIN) || capable(CAP_NET_RAW))
 			sk->sk_priority =3D val;
 		else
 			ret =3D -EPERM;
--=20
1.7.3.1
