From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 02 Feb 2012 23:45:44 +0100
Message-ID: <1328222744.2480.38.camel@edumazet-laptop>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	 <1328219828.2480.32.camel@edumazet-laptop>
	 <CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:61666 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab2BBWps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 17:45:48 -0500
Received: by wics10 with SMTP id s10so2178594wic.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 14:45:47 -0800 (PST)
In-Reply-To: <CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 15:29 -0700, Erich E. Hoover a =C3=
=A9crit :
> On Thu, Feb 2, 2012 at 2:57 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 14:36 -0700, Erich E. Hoover a=
 =C3=A9crit :
> > > ...
> > > +             if (sk->sk_bound_dev_if && ifindex !=3D sk->sk_boun=
d_dev_if)
> > > +                     break;
> >
> > what happens if later sk_bound_dev_if is changed ? Should we redo t=
he
> > above tests ?
>=20
> Would it be better if ip_default_ifindex performed the same compariso=
n
> and prioritized the sk->sk_bound_dev_if value?
>=20

I guess you should mimic other OS behavior. Tests are probably needed.

> > > ...
> > > +     case IP_UNICAST_IF:
> > > +     {
> > > +             __be32 iface;
> > > +
> > > +             len =3D sizeof(__be32);
> > > +             iface =3D htonl(inet->outif_index);
> > > +             release_sock(sk);
> > > +
> > > +             if (put_user(len, optlen))
> > > +                     return -EFAULT;
> > > +             if (copy_to_user(optval, &iface, len))
> > > +                     return -EFAULT;
> > > +             return 0;
> >
> > wow.... thats not pretty...
> >
> >        what about :
> >
> >        case IP_UNICASE_IF:
> >                val =3D htonl(inet->outif_index);
> >                break;
> >
>=20
> The return value needs to be 4 bytes even if sizeof(int) !=3D 4.
>=20

On all arches supported by linux, sizeof(int) =3D=3D 4

Maybe avoid sparse warning since val is not __be32

	val =3D (__force int)htonl(inet->outif_index);
	break;

> > > ...
> > IPv6 not supported ?
>=20
> Nope, at least according to the documentation the option is only for
> IPv4 (IPPROTO_IP).

Probably because of the mix on interface index and IPv4 addr on "other
OS".

But if we implement interface index only, it could be used on IPv6
too... I dont know...
