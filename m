From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: af_packet: Validate parameter size for PACKET_HDRLEN control message
Date: Wed, 27 Feb 2013 11:46:58 -0800
Message-ID: <1361994418-1403-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:54692 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab3B0Tq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 14:46:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building af_packet may fail with

In function =E2=80=98copy_from_user=E2=80=99,
    inlined from =E2=80=98packet_getsockopt=E2=80=99 at
    net/packet/af_packet.c:3215:21:
arch/x86/include/asm/uaccess_32.h:211:26: error: call to
    =E2=80=98copy_from_user_overflow=E2=80=99 declared with attribute e=
rror: copy_from_user()
    buffer size is not provably correct

if built with W=3D1 due to a missing parameter size validation.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/packet/af_packet.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c7bfeff..1976b23 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3210,6 +3210,8 @@ static int packet_getsockopt(struct socket *sock,=
 int level, int optname,
 		val =3D po->tp_version;
 		break;
 	case PACKET_HDRLEN:
+		if (len < sizeof(int))
+			return -EINVAL;
 		if (len > sizeof(int))
 			len =3D sizeof(int);
 		if (copy_from_user(&val, optval, len))
--=20
1.7.9.7
