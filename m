From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 17:16:46 +0200
Message-ID: <20100828151646.GB3211@del.dom.local>
References: <20100827205042.GA13844@del.dom.local>
 <20100828001337.GA1955@gondor.apana.org.au>
 <20100828094433.GA3110@del.dom.local>
 <1282992846.2277.15.camel@edumazet-laptop>
 <20100828143132.GA3211@del.dom.local>
 <1283006909.2277.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41719 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925Ab0H1PQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 11:16:53 -0400
Received: by fxm13 with SMTP id 13so2534887fxm.19
        for <netdev@vger.kernel.org>; Sat, 28 Aug 2010 08:16:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283006909.2277.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 28, 2010 at 04:48:29PM +0200, Eric Dumazet wrote:
> Le samedi 28 ao??t 2010 ?? 16:31 +0200, Jarek Poplawski a =E9crit :
> > On Sat, Aug 28, 2010 at 12:54:06PM +0200, Eric Dumazet wrote:
> > > In commit f2bde7328633269ee935d9ed96535ade15cc348f
> > > Author: Stephen Hemminger <shemminger@vyatta.com>
> > >=20
> > >     net: allow multiple dev per napi with GRO
> > >    =20
> > >     GRO assumes that there is a one-to-one relationship between N=
API
> > >     structure and network device. Some devices like sky2 share mu=
ltiple
> > >     devices on a single interrupt so only have one NAPI handler. =
Rather than
> > >     split GRO from NAPI, just have GRO assume if device changes t=
hat
> > >     it is a different flow.
> > >   =20
> > >=20
> > > It was assumed a napi could be shared by several devs, but I dont=
 really
> > > understand, since we have an unique ->dev pointer inside "napi_st=
ruct",
> > > this one is set once, and never change.
> > >=20
> > > This pointer is currently used from napi_get_frags() [but that co=
uld be
> > > avoided], and from netpoll_poll_lock().
> > >=20
> > > The netpoll_poll_lock() case is problematic.
> > >=20
> > > static inline void *netpoll_poll_lock(struct napi_struct *napi)
> > > {
> > >         struct net_device *dev =3D napi->_dev;
> > >=20
> > >         if (dev && dev->npinfo) {
> > >                 spin_lock(&napi->poll_lock);
> > >=20
> > > Maybe we should remove 'dev' field from napi_struct and replace i=
t by a
> > > npinfo pointer ?
> >=20
> > Sky2 seems to work like a single netdev (with an internal sub-netde=
v),
> > so I can't see your concern: what is the main aim of this replaceme=
nt?
>=20
> I am trying to understand why this commit was needed then.
>=20
> It adds an extra test in the main loop, testing skb->dev against p->d=
ev,
> it must me for something...
>=20
> I am trying to say that the one to one relationship between NAPI
> structure and a device is not only a GRO thing, but also a netpoll on=
e.

I guess it's not about the full one to one relationship, but kind of
overloading (pseudo vlan?). How much it's needed is another question,
but at least the order of these tests seems doubtful.

Jarek P.
