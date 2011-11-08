From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 2/2] net: make ipv6 PKTINFO honour freebind
Date: Mon,  7 Nov 2011 16:57:22 -0800
Message-ID: <1320713842-21152-2-git-send-email-zenczykowski@gmail.com>
References: <CAHo-Oow3LhhvMEO8ph7ZM2TO48KtTak+VZjY56ceWdhxeyUzgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61423 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab1KHA5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 19:57:39 -0500
Received: by mail-qy0-f174.google.com with SMTP id 27so3070970qyk.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 16:57:39 -0800 (PST)
In-Reply-To: <CAHo-Oow3LhhvMEO8ph7ZM2TO48KtTak+VZjY56ceWdhxeyUzgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

This just makes it possible to spoof source IPv6 address on a socket
without having to create and bind a new socket for every source IP
we wish to spoof.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv6/datagram.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e248069..83037af 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -654,7 +654,7 @@ int datagram_send_ctl(struct net *net, struct sock =
*sk,
=20
 			if (addr_type !=3D IPV6_ADDR_ANY) {
 				int strict =3D __ipv6_addr_src_scope(addr_type) <=3D IPV6_ADDR_SCO=
PE_LINKLOCAL;
-				if (!inet_sk(sk)->transparent &&
+				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
 				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
 						   strict ? dev : NULL, 0))
 					err =3D -EINVAL;
--=20
1.7.3.1
