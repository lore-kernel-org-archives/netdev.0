From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: recv(2), MSG_TRUNK and kernels older than 2.6.22
Date: Tue, 20 Jul 2010 10:54:59 +0200
Message-ID: <1279616099.2498.9.camel@edumazet-laptop>
References: <4C455DC3.1050304@marples.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roy Marples <roy@marples.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53619 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067Ab0GTIzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 04:55:04 -0400
Received: by wwj40 with SMTP id 40so529737wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 01:55:02 -0700 (PDT)
In-Reply-To: <4C455DC3.1050304@marples.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 juillet 2010 =C3=A0 09:26 +0100, Roy Marples a =C3=A9crit :
> Hi
>=20
> I would like to support all possible kernels I can and previously use=
d a=20
> fixed buffer of size 256 to read from netlink sockets. This is now=20
> proving too small for some 64-bit kernels so I would like to use recv=
(2)=20
> with MSG_TRUNK to wor out the size. However, the man page says that t=
his=20
> only works for 2.6.22 kernels or newer.
>=20
> My question is, what is the behaviour of recv on older kernels where=20
> MSG_TRUNC is not supported? I would rather not use some arbitary size=
 if=20
> at all possible.
>=20

Is it for the dhcpcd problem we talk about few week ago, disturbed by
new 64bit stats ?

Why do you want to have a fixed size of 256 bytes ?

Using 8192 bytes on stack would avoid MSG_TRUNK mess.

static int
get_netlink(int fd, int flags,
    int (*callback)(struct nlmsghdr *))
{
        char buffer[8192];
        ssize_t bytes;
        struct nlmsghdr *nlm;
        int r =3D -1;

        for (;;) {
                bytes =3D recv(fd, buffer, sizeof(buffer), flags);
                if (bytes =3D=3D -1) {
                        if (errno =3D=3D EAGAIN) {
                                r =3D 0;
                                goto eexit;
                        }
                        if (errno =3D=3D EINTR)
                                continue;
                        goto eexit;
                }




