From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 16:48:29 +0200
Message-ID: <1283006909.2277.22.camel@edumazet-laptop>
References: <20100827205042.GA13844@del.dom.local>
	 <20100828001337.GA1955@gondor.apana.org.au>
	 <20100828094433.GA3110@del.dom.local>
	 <1282992846.2277.15.camel@edumazet-laptop>
	 <20100828143132.GA3211@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36967 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab0H1Osf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 10:48:35 -0400
Received: by wyb35 with SMTP id 35so4867770wyb.19
        for <netdev@vger.kernel.org>; Sat, 28 Aug 2010 07:48:34 -0700 (PDT)
In-Reply-To: <20100828143132.GA3211@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 28 ao=C3=BBt 2010 =C3=A0 16:31 +0200, Jarek Poplawski a =C3=A9=
crit :
> On Sat, Aug 28, 2010 at 12:54:06PM +0200, Eric Dumazet wrote:
> > In commit f2bde7328633269ee935d9ed96535ade15cc348f
> > Author: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> >     net: allow multiple dev per napi with GRO
> >    =20
> >     GRO assumes that there is a one-to-one relationship between NAP=
I
> >     structure and network device. Some devices like sky2 share mult=
iple
> >     devices on a single interrupt so only have one NAPI handler. Ra=
ther than
> >     split GRO from NAPI, just have GRO assume if device changes tha=
t
> >     it is a different flow.
> >   =20
> >=20
> > It was assumed a napi could be shared by several devs, but I dont r=
eally
> > understand, since we have an unique ->dev pointer inside "napi_stru=
ct",
> > this one is set once, and never change.
> >=20
> > This pointer is currently used from napi_get_frags() [but that coul=
d be
> > avoided], and from netpoll_poll_lock().
> >=20
> > The netpoll_poll_lock() case is problematic.
> >=20
> > static inline void *netpoll_poll_lock(struct napi_struct *napi)
> > {
> >         struct net_device *dev =3D napi->_dev;
> >=20
> >         if (dev && dev->npinfo) {
> >                 spin_lock(&napi->poll_lock);
> >=20
> > Maybe we should remove 'dev' field from napi_struct and replace it =
by a
> > npinfo pointer ?
>=20
> Sky2 seems to work like a single netdev (with an internal sub-netdev)=
,
> so I can't see your concern: what is the main aim of this replacement=
?

I am trying to understand why this commit was needed then.

It adds an extra test in the main loop, testing skb->dev against p->dev=
,
it must me for something...

I am trying to say that the one to one relationship between NAPI
structure and a device is not only a GRO thing, but also a netpoll one.

So either we completely remove this one to one relationship, either
Stephen commit was not needed.

Some clarification is needed.


