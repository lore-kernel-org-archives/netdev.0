From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 1/5] net: dsa: Add infrastructure to support LAG
Date: Mon, 2 Oct 2017 10:05:36 +0300
Message-ID: <20171002070536.GA12726@shredder.mtl.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
 <20171001194639.8647-2-f.fainelli@gmail.com>
 <20171002020327.GA21593@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        idosch@mellanox.com, Woojung.Huh@microchip.com, john@phrozen.org,
        sean.wang@mediatek.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:54431 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750891AbdJBHFi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 03:05:38 -0400
Content-Disposition: inline
In-Reply-To: <20171002020327.GA21593@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 04:03:27AM +0200, Andrew Lunn wrote:
> On Sun, Oct 01, 2017 at 12:46:35PM -0700, Florian Fainelli wrote:
> > +static bool dsa_slave_lag_check(struct net_device *dev, struct net_device *lag_dev,
> > +				struct netdev_lag_upper_info *lag_upper_info)
> > +{
> > +	struct dsa_slave_priv *p = netdev_priv(dev);
> > +	u8 lag_id;
> > +
> > +	/* No more lag identifiers available or already in use */
> > +	if (dsa_switch_lag_get_index(p->dp->ds, lag_dev, &lag_id) != 0)
> > +		return false;
> > +
> > +	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH)
> > +		return false;
> 
> I wounder if the driver needs to decide this? Can different hardware
> support different tx_types?

FWIW, the same check exists in mlxsw, but maybe other devices support
more methods, so I think it makes sense to have the driver decide this.
