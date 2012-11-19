From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unable to handle paging request, arm, at aio/tcp code, only 3.6
Date: Mon, 19 Nov 2012 13:34:18 -0800
Message-ID: <1353360858.10798.86.camel@edumazet-glaptop>
References: <20121119183222.GI2068@vicerveza.homeunix.net>
	 <1353354095.10798.76.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53173 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab2KSVeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 16:34:20 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so3757527pbc.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 13:34:20 -0800 (PST)
In-Reply-To: <1353354095.10798.76.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

> Thanks for the report.
>=20
> I believe this is a regression of commit
> 35ad9b9cf7d8a2e6259a0d24022e910adb6f3489
> (ipv6: Add helper inet6_csk_update_pmtu().)
>=20
> I'll prepare a patch to fix this.

Please try the following fix.

Thanks !

[PATCH] ipv6: fix inet6_csk_update_pmtu() return value

In case of error, inet6_csk_update_pmtu() should consistently
return NULL.

Bug added in commit 35ad9b9cf7d8a=20
(ipv6: Add helper inet6_csk_update_pmtu().)

Reported-by: Llu=C3=ADs Batlle i Rossell <viric@viric.name>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/inet6_connection_sock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index c4f9341..3064785 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -252,6 +252,7 @@ struct dst_entry *inet6_csk_update_pmtu(struct sock=
 *sk, u32 mtu)
 		return NULL;
 	dst->ops->update_pmtu(dst, sk, NULL, mtu);
=20
-	return inet6_csk_route_socket(sk, &fl6);
+	dst =3D inet6_csk_route_socket(sk, &fl6);
+	return IS_ERR(dst) ? NULL : dst;
 }
 EXPORT_SYMBOL_GPL(inet6_csk_update_pmtu);
