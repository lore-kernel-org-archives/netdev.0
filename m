From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: bnx2x: convert to hw_features
Date: Sun, 10 Apr 2011 17:23:36 +0200
Message-ID: <20110410152336.GA14182@rere.qmqm.pl>
References: <20110410144746.679DD13A65@rere.qmqm.pl> <1302448214.2242.6.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58091 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882Ab1DJPXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 11:23:38 -0400
Content-Disposition: inline
In-Reply-To: <1302448214.2242.6.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 10, 2011 at 06:10:14PM +0300, Vladislav Zolotarov wrote:
> > +int bnx2x_set_features(struct net_device *dev, u32 features)
> > +{
> > +	struct bnx2x *bp =3D netdev_priv(dev);
> > +	u32 flags =3D bp->flags;
> > +
> > +	if (features & NETIF_F_LRO)
> > +		flags |=3D TPA_ENABLE_FLAG;
> > +	else
> > +		flags &=3D ~TPA_ENABLE_FLAG;
> > +
> > +	if (flags ^ bp->flags) {
> > +		bp->flags =3D flags;
> > +
> > +		return bnx2x_reload_if_running(dev);
> >  	}
> > =20
> > -	return rc;
> > +	return 0;
> >  }
>=20
> Thanks a lot, Michal. Looks ok but one remark below.
>=20
> Every time  bnx2x_reload_if_running(dev) is called one has to check i=
f
> there is still a recovery process in progress like u did in the
> bnx2x_fix_features(). So this check is missing in the function above.

bnx2x_set_features() might be called only if bnx2x_fix_features() retur=
ns
different feature set than what's already set in dev->features. So this
case is implicitly covered. I'll add a comment for this.

Best Regards,
Micha=B3 Miros=B3aw
