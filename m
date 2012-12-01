From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next v1 3/3] net/mlx4_en: Set number of rx/tx channels
 using ethtool
Date: Sat, 1 Dec 2012 17:50:09 +0200
Message-ID: <CAJZOPZK98UOsK2HFSC3V6fdzvJfWVKg6pZzxptE97MTgOAk7-w@mail.gmail.com>
References: <1354216903-830-1-git-send-email-amirv@mellanox.com>
	<1354216903-830-4-git-send-email-amirv@mellanox.com>
	<1354319925.2640.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:42787 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133Ab2LAPuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 10:50:09 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so1322930iay.5
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 07:50:09 -0800 (PST)
In-Reply-To: <1354319925.2640.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 1, 2012 at 1:58 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>
> On Thu, 2012-11-29 at 21:21 +0200, Amir Vadai wrote:
> > Add support to changing number of rx/tx channels using
> > ethtool ('ethtool -[lL]'). Where the number of tx channels specified in
> > ethtool
> > is the number of rings per user priority - not total number of tx rings.
> >
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   69
> > +++++++++++++++++++++++
> >  drivers/net/ethernet/mellanox/mlx4/en_main.c    |    2 +-
> >  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   26 +++++----
> >  drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    2 +-
> >  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    8 ++-
> >  5 files changed, 93 insertions(+), 14 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > index dc8ccb4..681bc1b 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > @@ -999,6 +999,73 @@ static int mlx4_en_set_rxnfc(struct net_device
> > *dev, struct ethtool_rxnfc *cmd)
> [...]
> > +static int mlx4_en_set_channels(struct net_device *dev,
> > +             struct ethtool_channels *channel)
> > +{
> > +     struct mlx4_en_priv *priv = netdev_priv(dev);
> > +     struct mlx4_en_dev *mdev = priv->mdev;
> > +     int port_up;
> > +     int err = 0;
> > +
> > +     if (channel->other_count || channel->combined_count ||
> > +         channel->tx_count > channel->max_tx ||
> > +         channel->rx_count > channel->max_rx ||
>
> The values of max_tx and max_rx are passed in from userland, so you
> can't trust them.

Is this a general statement re ethtool values passed from user space
or something specific here? can't one assume that the ethtool process
runs under the appropriate admin permission?

>> +         !channel->tx_count || !channel->rx_count)
>> +             return -EINVAL;
> [...]
