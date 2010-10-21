From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: synchronize bind() with RTM_NEWADDR
 notifications
Date: Thu, 21 Oct 2010 16:10:28 +0200
Message-ID: <1287670228.6871.99.camel@edumazet-laptop>
References: <4CC02ABF.8090008@iki.fi>
	 <1287666383-17615-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43820 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758479Ab0JUOKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 10:10:36 -0400
Received: by wyb28 with SMTP id 28so5163924wyb.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 07:10:35 -0700 (PDT)
In-Reply-To: <1287666383-17615-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 21 octobre 2010 =C3=A0 16:06 +0300, Timo Ter=C3=A4s a =C3=A9cr=
it :
> Otherwise we have race condition to user land:
>  1. process A: changes IP address
>  2. process A: kernel sends RTM_NEWADDR (and schedules out)
>  3. process B: gets notification
>  4. process B: tries to bind() to new IP, but fails with EADDRNOTAVAI=
L
>       because FIB is not yet updated and inet_addr_type() in inet_bin=
d()
>       does not recognize the IP as local
>  5. process A: calls inetaddr_chain notifiers which updates FIB
>=20
> Fix the error path to synchronize with configuration changes and retr=
y
> the address type check.
>=20
> IPv6 side seems to handle the notifications properly: bind() immediat=
ely
> after RTM_NEWADDR succeeds as expected.  This is because ipv6_chk_add=
r()
> uses inet6_addr_lst which is updated before address notification.
>=20
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> ---
> Since there was no reply to my question if this is ok, I interpreted =
it
> as "maybe". So here's the code for review. Hopefully this helps deter=
mining
> if this is an acceptable fix.
>=20

Just say : no

Really Timo, this problem must get another fix.

I understand you need an urgent fix, you can use your patch in the
meantime, of course ;)



