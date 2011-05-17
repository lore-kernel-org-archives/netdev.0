From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Tue, 17 May 2011 17:00:29 +0200
Message-ID: <20110517150029.GA23179@rere.qmqm.pl>
References: <20110516104309.GA3534@gondor.apana.org.au>
 <20110516112133.GA11274@redhat.com>
 <20110516121857.GA4495@gondor.apana.org.au>
 <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
 <20110516224658.GA11157@gondor.apana.org.au>
 <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
 <20110517081954.A227013A6A@rere.qmqm.pl>
 <20110517142943.GA926@redhat.com>
 <20110517144635.GA22878@rere.qmqm.pl>
 <20110517145428.GA1472@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50496 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755161Ab1EQPAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 11:00:31 -0400
Content-Disposition: inline
In-Reply-To: <20110517145428.GA1472@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 05:54:28PM +0300, Michael S. Tsirkin wrote:
> On Tue, May 17, 2011 at 04:46:35PM +0200, Micha=B3 Miros=B3aw wrote:
> > On Tue, May 17, 2011 at 05:29:43PM +0300, Michael S. Tsirkin wrote:
> > > On Tue, May 17, 2011 at 10:19:54AM +0200, Micha=B3 Miros=B3aw wro=
te:
> > > > tun->set_features are meant to limit not force the features.
[...]
> > > One thing that this will do though: previously, if
> > > ethtool disables offloads, then an application enables
> > > them, the application will have the last say.
> > > With this patch, the most conservative approach wins.
> > > Right?
> >=20
> > Exactly.
> >=20
> > On device creation, wanted_features default to all offloads
> > enabled, so unless an admin changes the flags, the application cont=
rols
> > what is enabled. This matters only when using persistent tun/tap an=
d
> > admin and user are two different people. If the admin is using queu=
es
> > and doesn't want to handle e.g. TSO packets (I'm not sure if they a=
re
> > properly accounted in all queuing disciplines), then the feature sh=
ould
> > not be enabled by user.
[...]
> Yes, with virtualization admin and the app are two different people
> usually.  The device doesn't have to be persistent though I think -
> what limits this to persistent devices?

Hmm. Nothing really. I just forgot about the virtualization case. You
usually will change the offloads just after device creation unless you'=
re
testing or debugging something.

> I agree this behaviour seems more consistent, I just hope this change
> does not break any setups.

The only effect would be some performance drop on cases, where admin tu=
rned
off the offloads and they stay like that regardless of what user part d=
oes.

Best Regards,
Micha=B3 Miros=B3aw
