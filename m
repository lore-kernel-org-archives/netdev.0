From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 2/2] iproute2: misc/ss.c - fix run_ssfilter af_packet when protocol == 0
Date: Thu, 25 Jun 2015 02:03:03 -0700
Message-ID: <1435222983-14661-2-git-send-email-zenczykowski@gmail.com>
References: <1435222983-14661-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Stephen Hemminger <shemming@brocade.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36592 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbbFYJDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 05:03:16 -0400
Received: by iecvh10 with SMTP id vh10so50337386iec.3
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 02:03:15 -0700 (PDT)
In-Reply-To: <1435222983-14661-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

s->local.data is a pointer to a field of a non-NULL struct, and hence
cannot be NULL, thus comparing it to 0 is always false, and thus the
return is always false.

Presumably this was meant to be a check whether s->local.data[0] (which
I believe stores af_packet protocol) is 0, ie. ANY.

Change-Id: Ia232f5b06ce081e3b2fb6338f1a709cd94e03ae5
=46ixes:
  ss.c:1018:37: error: comparison of array 's->local.data' equal to a n=
ull pointer is always false [-Werror,-Wtautological-pointer-compare]
    return s->lport =3D=3D 0 && s->local.data =3D=3D 0;
                            ~~~~~~~~~^~~~    ~
  1 error generated.
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index dba0901791c7..36b0efdfd32f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1090,7 +1090,7 @@ static int run_ssfilter(struct ssfilter *f, struc=
t sockstat *s)
 					     strspn(p+1, "0123456789abcdef") =3D=3D 5);
 		}
 		if (s->local.family =3D=3D AF_PACKET)
-			return s->lport =3D=3D 0 && s->local.data =3D=3D 0;
+			return s->lport =3D=3D 0 && s->local.data[0] =3D=3D 0;
 		if (s->local.family =3D=3D AF_NETLINK)
 			return s->lport < 0;
=20
--=20
2.4.3.573.g4eafbef
