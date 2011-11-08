From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 1/2] net: make ipv6 bind honour freebind
Date: Mon,  7 Nov 2011 16:57:21 -0800
Message-ID: <1320713842-21152-1-git-send-email-zenczykowski@gmail.com>
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
	with ESMTP id S1753715Ab1KHA5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 19:57:38 -0500
Received: by qyk27 with SMTP id 27so3070970qyk.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 16:57:37 -0800 (PST)
In-Reply-To: <CAHo-Oow3LhhvMEO8ph7ZM2TO48KtTak+VZjY56ceWdhxeyUzgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

This makes native ipv6 bind follow the precedent set by:
  - native ipv4 bind behaviour
  - dual stack ipv4-mapped ipv6 bind behaviour.

This does allow an unpriviledged process to spoof its source IPv6
address, just like it currently can spoof its source IPv4 address
(for example when using UDP).

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv6/af_inet6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d27c797..1040424 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -347,7 +347,7 @@ int inet6_bind(struct socket *sock, struct sockaddr=
 *uaddr, int addr_len)
 			 */
 			v4addr =3D LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-				if (!inet->transparent &&
+				if (!(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
 					err =3D -EADDRNOTAVAIL;
--=20
1.7.3.1
