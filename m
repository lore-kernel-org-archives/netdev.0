From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Tue, 17 May 2011 18:11:56 +0300
Message-ID: <20110517151155.GA2062@redhat.com>
References: <20110516112133.GA11274@redhat.com>
 <20110516121857.GA4495@gondor.apana.org.au>
 <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
 <20110516224658.GA11157@gondor.apana.org.au>
 <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
 <20110517081954.A227013A6A@rere.qmqm.pl>
 <20110517142943.GA926@redhat.com>
 <20110517144635.GA22878@rere.qmqm.pl>
 <20110517145428.GA1472@redhat.com>
 <20110517150029.GA23179@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120Ab1EQPLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 11:11:55 -0400
Content-Disposition: inline
In-Reply-To: <20110517150029.GA23179@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 05:00:29PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> On Tue, May 17, 2011 at 05:54:28PM +0300, Michael S. Tsirkin wrote:
> > On Tue, May 17, 2011 at 04:46:35PM +0200, Micha=C5=82 Miros=C5=82aw=
 wrote:
> > > On Tue, May 17, 2011 at 05:29:43PM +0300, Michael S. Tsirkin wrot=
e:
> > > > On Tue, May 17, 2011 at 10:19:54AM +0200, Micha=C5=82 Miros=C5=82=
aw wrote:
> > > > > tun->set_features are meant to limit not force the features.
> [...]
> > > > One thing that this will do though: previously, if
> > > > ethtool disables offloads, then an application enables
> > > > them, the application will have the last say.
> > > > With this patch, the most conservative approach wins.
> > > > Right?
> > >=20
> > > Exactly.
> > >=20
> > > On device creation, wanted_features default to all offloads
> > > enabled, so unless an admin changes the flags, the application co=
ntrols
> > > what is enabled. This matters only when using persistent tun/tap =
and
> > > admin and user are two different people. If the admin is using qu=
eues
> > > and doesn't want to handle e.g. TSO packets (I'm not sure if they=
 are
> > > properly accounted in all queuing disciplines), then the feature =
should
> > > not be enabled by user.
> [...]
> > Yes, with virtualization admin and the app are two different people
> > usually.  The device doesn't have to be persistent though I think -
> > what limits this to persistent devices?
>=20
> Hmm. Nothing really. I just forgot about the virtualization case. You
> usually will change the offloads just after device creation unless yo=
u're
> testing or debugging something.

That's true. kvm invokes a user script after creating device
but just before configuring it, if there might be a problem
it's likely only because of something such a script might do
(which used to be harmless). My gut feeling is this
is unlikely.

> > I agree this behaviour seems more consistent, I just hope this chan=
ge
> > does not break any setups.
>=20
> The only effect would be some performance drop on cases, where admin =
turned
> off the offloads and they stay like that regardless of what user part=
 does.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

The performance drop is actually quite drastic :), but yes it
will keep going, which is a good thing.

--=20
MST
