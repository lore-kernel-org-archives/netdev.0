From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 02/12] net: Introduce new feature setting ops
Date: Sun, 19 Dec 2010 21:22:39 +0000
Message-ID: <1292793759.2874.14.camel@localhost>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
	 <822f5776f99cab9889cd72d658d5fe50c56bb247.1292451559.git.mirq-linux@rere.qmqm.pl>
	 <1292541186.18294.16.camel@bwh-desktop>
	 <20101219004959.GA12005@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40388 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484Ab0LSVWm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 16:22:42 -0500
In-Reply-To: <20101219004959.GA12005@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-19 at 01:49 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> On Thu, Dec 16, 2010 at 11:13:06PM +0000, Ben Hutchings wrote:
> > On Wed, 2010-12-15 at 23:24 +0100, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> > > +static int ethtool_set_features(struct net_device *dev, void __u=
ser *useraddr)
> > > +{
> > > +	struct ethtool_features cmd;
> > > +	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_=
WORDS];
> > > +
> > > +	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> > > +		return -EFAULT;
> > > +	useraddr +=3D sizeof(cmd);
> > > +
> > > +	if (cmd.count > ETHTOOL_DEV_FEATURE_WORDS)
> > > +		cmd.count =3D ETHTOOL_DEV_FEATURE_WORDS;
> > So additional feature words will be silently ignored...
> > > +	if (copy_from_user(features, useraddr, sizeof(*features) * cmd.=
count))
> > > +		return -EFAULT;
> > > +	memset(features + cmd.count, 0,
> > > +		sizeof(features) - sizeof(*features) * cmd.count);
> > > +
> > > +	features[0].valid &=3D dev->hw_features | NETIF_F_SOFT_FEATURES=
;
> > [...]
> >=20
> > ...as will any other unsupported features.  This is not a good idea=
=2E
> > (However, remembering which features are wanted does seem like a go=
od
> > idea.)
>=20
> That's intentional. Unsupported features can't be enabled anyway.
> hw_features is supposed to contain all features that the device can s=
upport
> and is able to enable/disable. This set should be constant and anythi=
ng that
> is in the wanted_features set but is not supported because of other c=
onditions
> will be stripped by ndo_fix_features() call.
>=20
> Other way would be to return EINVAL when bits not changeable are pres=
ent in
> the valid mask. I don't want to do that, since then your example of c=
hanging
> a feature without GFEATURES first will not work.

That's right, it shouldn't work.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

