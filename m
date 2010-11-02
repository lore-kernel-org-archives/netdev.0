From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 2/4] Ethtool: convert get_sg/set_sg calls to
	hw_features flag
Date: Tue, 2 Nov 2010 01:59:52 +0100
Message-ID: <20101102005952.GB15848@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl> <1288646150.2231.62.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37556 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab0KBA7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 20:59:54 -0400
Content-Disposition: inline
In-Reply-To: <1288646150.2231.62.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 09:15:50PM +0000, Ben Hutchings wrote:
> On Sat, 2010-10-30 at 06:28 +0200, Micha=B3 Miros=B3aw wrote:
> [...]
> > @@ -1088,7 +1076,19 @@ static int __ethtool_set_sg(struct net_devic=
e *dev, u32 data)
> >  		if (err)
> >  			return err;
> >  	}
> > -	return dev->ethtool_ops->set_sg(dev, data);
> > +
> > +	if (dev->ethtool_ops->hw_set_sg) {
> > +		err =3D dev->ethtool_ops->hw_set_sg(dev, data);
> > +		if (err)
> > +			return min(err, 0);
> > +	}
> > +
> > +	if (data)
> > +		dev->features |=3D NETIF_F_SG;
> > +	else
> > +		dev->features &=3D ~NETIF_F_SG;
> > +
> > +	return 0;
> >  }
> [...]
>=20
> The odd semantics of positive return values really need to be documen=
ted
> - both in the commit message and in the comment on struct ethtool_ops=
=2E

Will do.

Best Regards,
Micha=B3 Miros=B3aw=20
