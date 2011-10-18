From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 21:05:53 +0200
Message-ID: <1318964753.2407.7.camel@edumazet-laptop>
References: <4E9C8D8B.90606@mellanox.co.il>
	 <1318902525.2571.24.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
	 <1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <953B660C027164448AE903364AC447D2235EEC80@MTLDAG01.mtl.com>
	 <20111018083606.6367ff50@nehalam.linuxnetplumber.net>
	 <CAEuXFEwzoC-L7Agr3Ssq9M-QN2w+t=rxjVvt9oJwQ2pQw7To8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54083 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab1JRTF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 15:05:57 -0400
Received: by wyg36 with SMTP id 36so944329wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 12:05:56 -0700 (PDT)
In-Reply-To: <CAEuXFEwzoC-L7Agr3Ssq9M-QN2w+t=rxjVvt9oJwQ2pQw7To8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 11:49 -0700, Jesse Brandeburg a =C3=A9c=
rit :
> On Tue, Oct 18, 2011 at 8:36 AM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Tue, 18 Oct 2011 08:59:44 +0000
> > Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
> >> There is no gain in random values,
> >> I'll make the change to have static value for RSS function.
> >>
> >> We might consider how to ensure consistency across the different d=
rivers in this aspect.
> >
> > The key should be part of the network device core. Almost all hardw=
are just
> > implements the Microsoft standard, and if all drivers used same key=
 they should
> > come up with the same hash.
> >
> > Although using the same key all the time makes testing easier.
> > The risk of using the same key is that it makes it easier for an at=
tacker to
> > create a set of addresses that all map to the same CPU which would =
make a DoS
> > attack work better.  Therefore the key should be randomly generated=
 at boot time.
>=20
> Stephen, I respectfully disagree with your position here.  The risk o=
f
> using the same key is that a malicious user could target a particular
> queue with a DoS attack, but how is that different than any single
> queue device?  NAPI protects a single queue against (a network
> interrupt based) DoS.  I do not think we should be generating a rando=
m
> key at boot time, and because of the way NAPI mitigates load, we are
> okay.  The gain from from the far simpler setup (and reproducability)
> outweighs the risk until someone can show damage due to this
> theoretical DoS attack.

Note : This policy could be up to the admin :

1) We could let admin chose a known hash for reproducability

   ethtool .... rss_hash xxxxxxxx:yyyyyyyy:zzzzzzzz:....

2) We could have a 'rss_perturb N ' ethtool option, to randomly reshufl=
e
things every N seconds, for people really afraid ;)
