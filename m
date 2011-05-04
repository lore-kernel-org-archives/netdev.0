From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCHv3 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Wed, 4 May 2011 18:05:21 +0200
Message-ID: <20110504160521.GA2035@rere.qmqm.pl>
References: <1304471935-402-1-git-send-email-maheshb@google.com>
 <1304471935-402-2-git-send-email-maheshb@google.com>
 <1304471935-402-3-git-send-email-maheshb@google.com>
 <20110504111112.GA15486@rere.qmqm.pl>
 <20110504080408.0142f701@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52506 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912Ab1EDQFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 12:05:22 -0400
Content-Disposition: inline
In-Reply-To: <20110504080408.0142f701@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 04, 2011 at 08:04:08AM -0700, Stephen Hemminger wrote:
> On Wed, 4 May 2011 13:11:12 +0200
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > On Tue, May 03, 2011 at 06:18:55PM -0700, Mahesh Bandewar wrote:
> > > This patch adds tg3_set_features() to handle loopback mode. Curre=
ntly the
> > > capability is added for the devices which support internal MAC lo=
opback mode.
> > > So when enabled, it enables internal-MAC loopback.
> > [...]
> > > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > > index 7c7c9a8..46de633 100644
> > > --- a/drivers/net/tg3.c
> > > +++ b/drivers/net/tg3.c
> > > @@ -6319,6 +6319,51 @@ static u32 tg3_fix_features(struct net_dev=
ice *dev, u32 features)
> > >  	return features;
> > >  }
> > > =20
> > > +static int tg3_set_features(struct net_device *dev, u32 features=
)
> > > +{
> > > +	struct tg3 *tp =3D netdev_priv(dev);
> > > +	u32 cur_mode =3D 0;
> > > +	int err =3D 0;
> > > +
> > > +	if (!netif_running(dev)) {
> > > +		err =3D -EAGAIN;
> > > +		goto sfeatures_out;
> > > +	}
> > netdev_update_features() is not designed to handle -EAGAIN from
> > ndo_set_features callback. It might be useful to implement this
> > handling, but in this case you should just return 0 and check
> > dev->features in ndo_open callback.
>=20
> EAGAIN is a bad choice of error code anyway. It implies that the
> application should retry, which in this case is not true.
>=20
> This error code is used for things like flow controlled sockets where
> the application should do a select/poll and the condition will clear
> when other side has read.
>=20
> Why not use ENETDOWN instead?

The "application" here is netdev_update_features() here. Whatever the
error code, it would need to be handled there.

Best Regards,
Micha=B3 Miros=B3aw
