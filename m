From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Mon, 14 Jun 2010 21:12:52 +0200
Message-ID: <1276542772.2444.13.camel@edumazet-laptop>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <1276466190.14011.223.camel@localhost>
	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
	 <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
	 <4C1662C3.3070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Pedro Garcia <pedro.netdev@dondevamos.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35454 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486Ab0FNTM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 15:12:57 -0400
Received: by wyb40 with SMTP id 40so4180129wyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 12:12:55 -0700 (PDT)
In-Reply-To: <4C1662C3.3070708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 19:11 +0200, Patrick McHardy a =C3=A9crit =
:
> Ben Hutchings wrote:
> > On Mon, 2010-06-14 at 18:49 +0200, Pedro Garcia wrote:
> >  =20
> >> On Sun, 13 Jun 2010 22:56:30 +0100, Ben Hutchings
> >> <bhutchings@solarflare.com> wrote:
> >>    =20
> >>> I have no particular opinion on this change, but you need to read=
 and
> >>> follow Documentation/SubmittingPatches.
> >>>
> >>> Ben.
> >>>      =20
> >> Sorry, first kernel patch, and I did not know about it. I resubmit=
 with
> >> the correct style / format:
> >>    =20
> > [...]
> >
> > Sorry, no you haven't.
> >
> > - Networking changes go through David Miller's net-next-2.6 tree so=
 you
> > need to use that as the baseline, not 2.6.26
> > - Patches should be applicable with -p1, not -p0 (so if you use dif=
f,
> > you should run it from one directory level up)
> > - The patch was word-wrapped
>=20
> Additionally:
>=20
> - please use the proper comment style, meaning each line begins
>   with a '*'
>=20
> - the pr_debug statements may be useful for debugging, but are
>   a bit excessive for the final version
>=20
> - + /* 2010-06-13: Pedro Garcia
>=20
>    We have changelogs for this, simply explaining what the code
>    does is enough.
>=20
> - Please CC the maintainer (which is me)
> --

Pedro, we have two kind of vlan setups :

accelerated and non accelerated ones.

Your patch address non accelated ones only, since you only touch
vlan_skb_recv()

Accelerated vlan can follow these paths :

1) NAPI devices

vlan_gro_receive() -> vlan_gro_common()

2) non NAPI devices

__vlan_hwaccel_rx()=20

So you might also patch __vlan_hwaccel_rx() and vlan_gro_common()

Please merge following bits to your patch submission :

http://kerneltrap.org/mailarchive/linux-netdev/2010/5/23/6277868


Good luck for your first patch !


