From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: ip route flush bugfix
Date: Mon, 09 Nov 2009 21:24:44 +0100
Message-ID: <4AF87A8C.9090302@gmail.com>
References: <4AF86FE3.4090005@anduras.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Sven Anders <sven@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60194 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbZKIUYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 15:24:40 -0500
In-Reply-To: <4AF86FE3.4090005@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sven Anders a =E9crit :
> Hello!
>=20
> I experienced an error, if I try to perform a
>=20
>   ip route flush proto 4
>=20
> with many routes in a complex environment, it
> gave me the following error:
>=20
>   Failed to send flush request: Success
>   Flush terminated
>=20
> I'm using version 2.6.29.
> I check GIT, but there was only the "MSG_PEEK" fix.
>=20
> I tracked it down to the rtnl_send_check() function
> in lib/libnetlink.c.
>=20
> In this function there is the following for loop:
>=20
>         for (h =3D (struct nlmsghdr *)resp; NLMSG_OK(h, status);
>              h =3D NLMSG_NEXT(h, status)) {
>                 if (h->nlmsg_type =3D=3D NLMSG_ERROR) {
>                         struct nlmsgerr *err =3D (struct nlmsgerr*)NL=
MSG_DATA(h);
>                         if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct=
 nlmsgerr)))
>                                 fprintf(stderr, "ERROR truncated\n");
>                         else
>                                 errno =3D -err->error;
> 		}
>                 return -1;
>         }
>=20
> I think the "return -1;" should be inside the if statement.
>=20
> I attached a patch for this. The first part of the patch is taken fro=
m
> one of the late git commits.
>=20
> Please note me, if the fix is wrong...
>=20
>=20
> Regards
>  Sven
>=20
> PS: This is a repost, because I neither received a confirmation nor a=
 remark, that
>     the fix is wrong. Moreover the fix didn't make it in the GIT repo=
sitory yet...
>=20


Yes, I posted a similar patch yesterday :)

http://article.gmane.org/gmane.linux.network/142908

Still waiting an ACK from Stephen

