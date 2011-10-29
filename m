From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] bonding: Doesn't support IPv6
Date: Sat, 29 Oct 2011 11:00:12 +0200
Message-ID: <1319878812.2586.10.camel@edumazet-laptop>
References: <4EAB5455.5080004@8192.net>
	 <CAHXqBF+CcX=FQNSSsdsEAc9jAqi0G3RNLPjRCcc7wJ+QYnzzSA@mail.gmail.com>
	 <1319878162.2586.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John <linux@8192.net>, netdev@vger.kernel.org, andy@greyhouse.net
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:35089 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab1J2JAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 05:00:21 -0400
Received: by pzk36 with SMTP id 36so12755284pzk.1
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2011 02:00:21 -0700 (PDT)
In-Reply-To: <1319878162.2586.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 29 octobre 2011 =C3=A0 10:49 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le samedi 29 octobre 2011 =C3=A0 09:55 +0200, Micha=C5=82 Miros=C5=82=
aw a =C3=A9crit :
> > 2011/10/29 John <linux@8192.net>:
> > > --- a/drivers/net/bonding/bond_main.c   2011-04-19 11:18:48.00000=
0000 -0700
> > > +++ b/drivers/net/bonding/bond_main.c   2011-10-27 11:26:20.00000=
0000 -0700
> > [...]
> > > +               v6hash =3D (v6hash >> 16) ^ (v6hash >> 8) ^ v6has=
h;
> >=20
> > This XORs in only 3 of 4 bytes, and assuming count > 256 (its unlik=
ely
> > you have more than 256 slaves in bond) the most significant byte is
> > wasted. It should be:
> >=20
> > v6hash ^=3D v6hash >> 16;
> > v6hash ^=3D v6hash >> 8;
> >=20
> > Same for IPv4 part.
> >=20
> > OTOH, if that was your intention, then the description in your mail=
 was wrong.
> >=20
>=20
> Same end result :)
>=20

Oh well, not exactly, there was a reason for using two different C
instructions ;)

ALso the modulo is expensive...
