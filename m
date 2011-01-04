From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 04 Jan 2011 09:38:35 +0100
Message-ID: <1294130315.2711.48.camel@edumazet-laptop>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
	 <1294125880.2711.34.camel@edumazet-laptop>
	 <1294126407.2711.39.camel@edumazet-laptop>
	 <AANLkTimDms0FTmXWf9WSpcxwZXVVSXQj44jZ2Ag8Osuk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, Joel Sing <jsing@google.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48244 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab1ADIik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 03:38:40 -0500
Received: by wyb28 with SMTP id 28so14095599wyb.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 00:38:39 -0800 (PST)
In-Reply-To: <AANLkTimDms0FTmXWf9WSpcxwZXVVSXQj44jZ2Ag8Osuk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 16:07 +0800, Changli Gao a =C3=A9crit :
> On Tue, Jan 4, 2011 at 3:33 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le mardi 04 janvier 2011 =C3=A0 08:24 +0100, Eric Dumazet a =C3=A9c=
rit :
> >
> >> Please use FIB_RES_PREFSRC(res)
> >>
> >
> > Hmm no, this is not applicable, but this could be shorter :
> >
> > fl.fl4_src =3D res.fi->fib_prefsrc ? : fl.fl4_dst;
> >
> >
>=20
> I think Joe may object the use of "? :"
>=20

Ternary operator is standard C idiom, used in networking stuff, for
example in FIB_RES_PREFSRC() ;)

This could be properly done using another macro in include/net/ip_fib.h
to centralize this ternary op in one point :

#define __FIB_RES_PREFSRC(res, default) ((res).fi->fib_prefsrc ? : defa=
ult)
#define FIB_RES_PREFSRC(res) __FIB_RES_PREFSRC(res, default, __fib_res_=
prefsrc(&res))



