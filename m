From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 2.6.34-rc3 + CAN build problem
Date: Sat, 10 Apr 2010 11:47:31 +0200
Message-ID: <1270892851.2093.32.camel@edumazet-laptop>
References: <4BC03340.5020500@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	socketcan-core@lists.berlios.de,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:47328 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab0DJJrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Apr 2010 05:47:37 -0400
In-Reply-To: <4BC03340.5020500@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 avril 2010 =C3=A0 10:13 +0200, N=C3=A9meth M=C3=A1rton a =C3=
=A9crit :
> Hi,
>=20
> I have some problem building Liunux kernel 2.6.34-rc3 with the attach=
ed .config:
>=20
> $ make clean bzImage modules
> [...]
>   CC      net/socket.o
>   LD      net/802/built-in.o
>   LD      net/can/built-in.o
>   CC [M]  net/can/bcm.o
>   CC [M]  net/can/raw.o
> In file included from /mnt/store/nmarci/src/linux-2.6.34-rc3/arch/x86=
/include/asm/uaccess.h:571,
>                  from include/net/checksum.h:25,
>                  from include/linux/skbuff.h:28,
>                  from include/linux/if_ether.h:124,
>                  from include/linux/netdevice.h:29,
>                  from net/can/raw.c:48:
> In function =E2=80=98copy_from_user=E2=80=99,
>     inlined from =E2=80=98raw_setsockopt=E2=80=99 at net/can/raw.c:44=
7:
> /mnt/store/nmarci/src/linux-2.6.34-rc3/arch/x86/include/asm/uaccess_3=
2.h:212: error: call to =E2=80=98copy_from_user_overflow=E2=80=99 decla=
red with attribute error:
> copy_from_user() buffer size is not provably correct
> make[2]: *** [net/can/raw.o] Error 1
> make[1]: *** [net/can] Error 2
> make: *** [net] Error 2
>=20
>=20

Could you give us your compiler version ?

Code is fine, but compiler a bit dumb :(

[PATCH] can: avoids a false warning

At this point optlen =3D=3D sizeof(sfilter) but some compilers are dumb=
=2E

Reported-by: N=C3=A9meth M=C3=A1rton <nm127@freemail.h
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/can/raw.c b/net/can/raw.c
index 3a7dffb..da99cf1 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -445,7 +445,7 @@ static int raw_setsockopt(struct socket *sock, int =
level, int optname,
 				return -EFAULT;
 			}
 		} else if (count =3D=3D 1) {
-			if (copy_from_user(&sfilter, optval, optlen))
+			if (copy_from_user(&sfilter, optval, sizeof(sfilter)))
 				return -EFAULT;
 		}
=20


