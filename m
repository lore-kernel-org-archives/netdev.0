From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH 7/9] ethtool: prepare for larger netdev_features_t
 type
Date: Thu, 23 Jun 2011 19:03:48 +0100
Message-ID: <1308852228.2712.5.camel@bwh-desktop>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	 <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
	 <1308604618.2701.189.camel@bwh-desktop>
	 <BANLkTi=RB1MSR=c6GhXr4bsrPtFJVZnaZ8ZLCN=o339S_BE7iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8446 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933510Ab1FWSDw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 14:03:52 -0400
In-Reply-To: <BANLkTi=RB1MSR=c6GhXr4bsrPtFJVZnaZ8ZLCN=o339S_BE7iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-23 at 10:50 -0700, Mahesh Bandewar wrote:
> On Mon, Jun 20, 2011 at 2:16 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > [...]
> > > @@ -125,19 +131,26 @@ static int ethtool_set_features(struct net_=
device *dev, void __user *useraddr)
> > >       if (copy_from_user(features, useraddr, sizeof(features)))
> > >               return -EFAULT;
> > >
> > > -     if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
> > > +     /* I wonder if the compiler will be smart enough to loop-un=
roll
> > > +      * and optimize this... (no worries if not) --mq */
> > > +     for (i =3D ETHTOOL_DEV_FEATURE_WORDS; i-- > 0; ) {
> > > +             valid =3D (valid << 32)|features[i].valid;
> > > +             wanted =3D (wanted << 32)|features[i].requested;
> > > +     }
> > [...]
> >
> > I don't know (or care) about optimisation of this, but I would expe=
ct
> > gcc to complain about shifting a 32-bit value by 32 bits.  I sugges=
t you
> > write this as:
> >
> >        for (i =3D 0; i < ETHTOOL_DEV_FEATURE_WORDS; ++i) {
> >                valid |=3D (netdev_features_t)features[i].valid << 3=
2 *i;
> >                wanted |=3D (netdev_features_t)features[i].requested=
 << 32 *i;
>=20
> It's a valid point but this type of typecast or similar usage would
> imply that netdev_feature_t is an int of XXX bits. That's not opaque
> and would hinder the way you can abstract the feature type.

Yes, ethtool_{get,set}_features() will have to be changed if and when
the representation of netdev_features_t is changed significantly.  I
don't think there's any way of avoiding that and I don't think it reall=
y
matters.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

