From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: iplink_ stuff cleanup
Date: Mon, 19 Mar 2012 15:53:27 -0700
Message-ID: <20120319155327.089d6495@nehalam.linuxnetplumber.net>
References: <CAGm1_kuHYCRuoUEfBeV6GbjypUJgr1_058f-e4AhojHP1fTJWg@mail.gmail.com>
	<20120315091857.2114cb48@nehalam.linuxnetplumber.net>
	<CAGm1_kvbqOtArw4dUpnzTRB1JtfBCaAAeyFYCPrcaGYUF10NSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48608 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab2CSWxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 18:53:30 -0400
In-Reply-To: <CAGm1_kvbqOtArw4dUpnzTRB1JtfBCaAAeyFYCPrcaGYUF10NSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Mar 2012 23:22:59 +0100
Yegor Yefremov <yegorslists@googlemail.com> wrote:

> >> I'm still struggling to get ip/iplink_* routines to show up in
> >> Android's ip binary
> >> (https://groups.google.com/d/topic/android-building/yjV4iYnT1Zc/di=
scussion).
> >> I've looked at the algorithm that is used to access those function=
s
> >> (like can_parse_opt, vlan_parse_opt etc.)
> >>
> >> =A0snprintf(buf, sizeof(buf), LIBDIR "/ip/link_%s.so", id);
> >> =A0 =A0 =A0 =A0 dlh =3D dlopen(buf, RTLD_LAZY);
> >> =A0 =A0 =A0 =A0 if (dlh =3D=3D NULL) {
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* look in current binary, only op=
en once */
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dlh =3D BODY;
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dlh =3D=3D NULL) {
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dlh =3D BODY =3D d=
lopen(NULL, RTLD_LAZY);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dlh =3D=3D NUL=
L)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 re=
turn NULL;
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> >> =A0 =A0 =A0 =A0 }
> >>
> >> =A0 =A0 =A0 =A0 snprintf(buf, sizeof(buf), "%s_link_util", id);
> >> =A0 =A0 =A0 =A0 l =3D dlsym(dlh, buf);
> >> =A0 =A0 =A0 =A0 if (l =3D=3D NULL)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> >>
> >> as far as I can see from the ip/Makefile there are no dynamic libs
> >> like /ip/link_%s.so. Wouldn't it be simpler to let all iplink_*
> >> objects to export their interfaces via header files and just make =
a
> >> table in ip/iplink.c to hold protocol ID and pointer at link_utils
> >> struct.
> >>
> >> struct link_util can_link_util =3D {
> >> =A0 =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =3D "can",
> >> =A0 =A0 =A0 =A0 .maxattr =A0 =A0 =A0 =A0=3D IFLA_CAN_MAX,
> >> =A0 =A0 =A0 =A0 .parse_opt =A0 =A0 =A0=3D can_parse_opt,
> >> =A0 =A0 =A0 =A0 .print_opt =A0 =A0 =A0=3D can_print_opt,
> >> =A0 =A0 =A0 =A0 .print_xstats =A0 =3D can_print_xstats,
> >> };
> >>
> >> Am I missing something?
> >>
> >> Regards,
> >> Yegor
> >
> > Ip utilities have dynamic extensibility, it is possible for someone
> > to add shared libraries for new functionality. This is a cool featu=
re
> > but isn't used directly by the standard code. It does use it indire=
ctly
> > by using dlopen() to find functions locally.
> >
> > Think of it as introspection in C.
> >
> > I won't take it out of the standard version, but you may have to fi=
nd
> > another way to handle it on the Android universe.
>=20
> The solution turned out to be simple:
> https://android-review.googlesource.com/#/c/34240/.
> -Wl,--no-gc-sections did the job.
>=20
> Can you suggest some more pro arguments for dynamic method of
> exporting API routines?

You could make it optional on your platform, but for mainline Linux
it has been around long enough that someone surely depends on it.
