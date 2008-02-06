From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH 07/24 for-2.6.25] DM9000: Add initial ethtool support
Date: Wed, 6 Feb 2008 22:03:34 +0000
Message-ID: <20080206220334.GE15407@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk> <20080205000815.759244139@fluff.org.uk> <20080205225045.GA12258@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:55293 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752306AbYBFWD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 17:03:58 -0500
Content-Disposition: inline
In-Reply-To: <20080205225045.GA12258@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 11:50:45PM +0100, Francois Romieu wrote:
> Ben Dooks <ben-linux@fluff.org> :
> > Add support for ethtool operations for the DM9000.
> > 
> > Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> > 
> > Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
> > ===================================================================
> > --- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
> > +++ linux-2.6.24-quilt3/drivers/net/dm9000.c
> [...]
> > +static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> > +{
> > +	board_info_t *dm = to_dm9000_board(dev);
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&dm->lock, flags);
> > +	mii_ethtool_gset(&dm->mii, cmd);
> 
> drivers/net/mii.c::mii_ethtool_gset
> [...]
>         advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
> 
> drivers/net/dm9000.c::dm9000_probe
> [...]
>         db->mii.mdio_read    = dm9000_phy_read;
> 
> drivers/net/dm9000.c::dm9000_phy_read
> [...]
>         board_info_t *db = (board_info_t *) dev->priv;
>         unsigned long flags;
>         unsigned int reg_save;
>         int ret;
> 
>         spin_lock_irqsave(&db->lock,flags);
> 
> -> deadlock

The next patch in the series changes the locking.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
