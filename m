From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v1 3/3] net/mlx4_en: Set number of rx/tx
 channels using ethtool
Date: Sat, 1 Dec 2012 16:18:38 +0000
Message-ID: <1354378718.7995.32.camel@deadeye.wl.decadent.org.uk>
References: <1354216903-830-1-git-send-email-amirv@mellanox.com>
	 <1354216903-830-4-git-send-email-amirv@mellanox.com>
	 <1354319925.2640.3.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAJZOPZK98UOsK2HFSC3V6fdzvJfWVKg6pZzxptE97MTgOAk7-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:12025 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315Ab2LAQSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 11:18:48 -0500
In-Reply-To: <CAJZOPZK98UOsK2HFSC3V6fdzvJfWVKg6pZzxptE97MTgOAk7-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-01 at 17:50 +0200, Or Gerlitz wrote:
> On Sat, Dec 1, 2012 at 1:58 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> >
> > On Thu, 2012-11-29 at 21:21 +0200, Amir Vadai wrote:
> > > Add support to changing number of rx/tx channels using
> > > ethtool ('ethtool -[lL]'). Where the number of tx channels specified in
> > > ethtool
> > > is the number of rings per user priority - not total number of tx rings.
> > >
> > > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > > ---
> > >  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   69
> > > +++++++++++++++++++++++
> > >  drivers/net/ethernet/mellanox/mlx4/en_main.c    |    2 +-
> > >  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   26 +++++----
> > >  drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    2 +-
> > >  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    8 ++-
> > >  5 files changed, 93 insertions(+), 14 deletions(-)
> > >
> > > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > > b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > > index dc8ccb4..681bc1b 100644
> > > --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > > +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > > @@ -999,6 +999,73 @@ static int mlx4_en_set_rxnfc(struct net_device
> > > *dev, struct ethtool_rxnfc *cmd)
> > [...]
> > > +static int mlx4_en_set_channels(struct net_device *dev,
> > > +             struct ethtool_channels *channel)
> > > +{
> > > +     struct mlx4_en_priv *priv = netdev_priv(dev);
> > > +     struct mlx4_en_dev *mdev = priv->mdev;
> > > +     int port_up;
> > > +     int err = 0;
> > > +
> > > +     if (channel->other_count || channel->combined_count ||
> > > +         channel->tx_count > channel->max_tx ||
> > > +         channel->rx_count > channel->max_rx ||
> >
> > The values of max_tx and max_rx are passed in from userland, so you
> > can't trust them.
> 
> Is this a general statement re ethtool values passed from user space
> or something specific here?

General statement.

> can't one assume that the ethtool process
> runs under the appropriate admin permission?

It has CAP_NET_ADMIN, which  is not the same thing as CAP_SYS_ADMIN (and
even that doesn't necessarily mean ultimate trust).

Ben.

> >> +         !channel->tx_count || !channel->rx_count)
> >> +             return -EINVAL;
> > [...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
