From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 2 Sep 2010 09:55:03 +0000
Message-ID: <20100902095502.GA8775@ff.dom.local>
References: <20100830.095012.233695092.davem@davemloft.net> <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local> <20100901.145151.93454549.davem@davemloft.net> <20100902083327.GA6246@ff.dom.local> <1283419909.2454.137.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41601 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab0IBJzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 05:55:11 -0400
Received: by bwz11 with SMTP id 11so414015bwz.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 02:55:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283419909.2454.137.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 11:31:49AM +0200, Eric Dumazet wrote:
> Le jeudi 02 septembre 2010 ?? 08:33 +0000, Jarek Poplawski a =E9crit =
:
> > On Wed, Sep 01, 2010 at 02:51:51PM -0700, David Miller wrote:
> > > The only scenerio you can guarentee that all packets for a given
> > > flow key will be treated the same is the one where the input devi=
ce
> > > is the same as well.
> > >=20
> > > When there is a single napi --> device mapping, it works, but wit=
hout
> > > that invariant it doesn't.
> >=20
> > Do you mean a single napi can't be used eg. for vlan_gro and napi_g=
ro?
> > (napi_gro handles flows for skb->dev different from napi->dev or I
> > miss something?)
> >=20
>=20
> Same napi can be used both for vlan tagged trafic and "non tagged
> trafic".
>=20
> vlan_gro_common() does the right thing, when initializing skb->dev to
> the vlan device, before doing the GRO loop.
>=20
> So if we receive two packets on same ethernet device, two different
> vlans, vlan_gro_common() automatically say they are not part of the s=
ame
> flow, even if upper layers would say "it's ok for these two packets t=
o
> merge". Of course, we wont ask upper layers what they think :)
>=20
> So we must keep the test against skb->dev, because of vlans,
>=20
> diffs =3D (unsigned long)p->dev ^ (unsigned long)skb->dev;
>=20
> (both in vlan_gro_common() and __napi_gro_receive())
>=20

Exactly, but there is no "a single napi --> device mapping". And sky2
uses the same model. So, there is only a question of cost of this test,
and a question of probability of gro errors on collisions without such
a test in normal use. (And if gro can never do such errors for other
reasons?)

Jarek P.
