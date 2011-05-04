From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Wed, 04 May 2011 17:08:53 +0100
Message-ID: <1304525333.2926.2.camel@bwh-desktop>
References: <1304471935-402-1-git-send-email-maheshb@google.com>
	 <1304471935-402-2-git-send-email-maheshb@google.com>
	 <1304471935-402-3-git-send-email-maheshb@google.com>
	 <20110504111112.GA15486@rere.qmqm.pl> <20110504080408.0142f701@nehalam>
	 <20110504160521.GA2035@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58302 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab1EDQI6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 12:08:58 -0400
In-Reply-To: <20110504160521.GA2035@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 18:05 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Wed, May 04, 2011 at 08:04:08AM -0700, Stephen Hemminger wrote:
> > On Wed, 4 May 2011 13:11:12 +0200
> > Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:
> > > On Tue, May 03, 2011 at 06:18:55PM -0700, Mahesh Bandewar wrote:
> > > > This patch adds tg3_set_features() to handle loopback mode. Cur=
rently the
> > > > capability is added for the devices which support internal MAC =
loopback mode.
> > > > So when enabled, it enables internal-MAC loopback.
> > > [...]
> > > > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > > > index 7c7c9a8..46de633 100644
> > > > --- a/drivers/net/tg3.c
> > > > +++ b/drivers/net/tg3.c
> > > > @@ -6319,6 +6319,51 @@ static u32 tg3_fix_features(struct net_d=
evice *dev, u32 features)
> > > >  	return features;
> > > >  }
> > > > =20
> > > > +static int tg3_set_features(struct net_device *dev, u32 featur=
es)
> > > > +{
> > > > +	struct tg3 *tp =3D netdev_priv(dev);
> > > > +	u32 cur_mode =3D 0;
> > > > +	int err =3D 0;
> > > > +
> > > > +	if (!netif_running(dev)) {
> > > > +		err =3D -EAGAIN;
> > > > +		goto sfeatures_out;
> > > > +	}
> > > netdev_update_features() is not designed to handle -EAGAIN from
> > > ndo_set_features callback. It might be useful to implement this
> > > handling, but in this case you should just return 0 and check
> > > dev->features in ndo_open callback.
> >=20
> > EAGAIN is a bad choice of error code anyway. It implies that the
> > application should retry, which in this case is not true.
> >=20
> > This error code is used for things like flow controlled sockets whe=
re
> > the application should do a select/poll and the condition will clea=
r
> > when other side has read.
> >=20
> > Why not use ENETDOWN instead?
>=20
> The "application" here is netdev_update_features() here. Whatever the
> error code, it would need to be handled there.

The important point - which I think you already stated - is that when
the device is down this function is not expected to apply changes to th=
e
hardware and therefore it should return 0.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

