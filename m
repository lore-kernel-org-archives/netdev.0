From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v3 3/5] net: use ndo_fix_features for
	ethtool_ops->set_flags
Date: Thu, 3 Feb 2011 14:45:09 +0100
Message-ID: <20110203134509.GB28042@rere.qmqm.pl>
References: <cover.1296325509.git.mirq-linux@rere.qmqm.pl> <3ebf175d86bad22033e680e0cde198598ffcedc6.1296325509.git.mirq-linux@rere.qmqm.pl> <1296341043.3477.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49479 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756397Ab1BCNpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 08:45:10 -0500
Content-Disposition: inline
In-Reply-To: <1296341043.3477.64.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 30, 2011 at 08:44:03AM +1000, Ben Hutchings wrote:
> On Sat, 2011-01-29 at 19:39 +0100, Micha=B3 Miros=B3aw wrote:
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  net/core/ethtool.c |   22 ++++++++++++++++++++--
> >  1 files changed, 20 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 409aebb..17a689f4 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -240,6 +240,25 @@ static int ethtool_set_features(struct net_dev=
ice *dev, void __user *useraddr)
> >  	return ret;
> >  }
> > =20
> > +static int __ethtool_set_flags(struct net_device *dev, u32 data)
> > +{
> > +	if (data & ~flags_dup_features)
> > +		return -EINVAL;
> > +
> > +	if (!(dev->hw_features & flags_dup_features)) {
> > +		if (!dev->ethtool_ops->set_flags)
> > +			return -EOPNOTSUPP;
> > +		return dev->ethtool_ops->set_flags(dev, data);
> > +	}
> > +
> > +	dev->wanted_features =3D
> > +		(dev->wanted_features & ~flags_dup_features) | data;
> > +
> > +	netdev_update_features(dev);
> > +
> > +	return 0;
> [...]
>=20
> I think it would be clearer to write this as:
[cut]

I changed it to check for more invalid states and to reject changing
of bits not in hw_features but present in flags_dup_features.

Best Regards,
Micha=B3 Miros=B3aw
