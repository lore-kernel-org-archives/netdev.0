From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 07/24 for-2.6.25] DM9000: Add initial ethtool support
Date: Tue, 5 Feb 2008 23:50:45 +0100
Message-ID: <20080205225045.GA12258@electric-eye.fr.zoreil.com>
References: <20080205000159.432081941@fluff.org.uk> <20080205000815.759244139@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org,
	daniel@caiaq.de, laurentp@cse-semaphore.com
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46761 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753546AbYBEXJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 18:09:35 -0500
Content-Disposition: inline
In-Reply-To: <20080205000815.759244139@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks <ben-linux@fluff.org> :
> Add support for ethtool operations for the DM9000.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> 
> Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
> ===================================================================
> --- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
> +++ linux-2.6.24-quilt3/drivers/net/dm9000.c
[...]
> +static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +{
> +	board_info_t *dm = to_dm9000_board(dev);
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&dm->lock, flags);
> +	mii_ethtool_gset(&dm->mii, cmd);

drivers/net/mii.c::mii_ethtool_gset
[...]
        advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);

drivers/net/dm9000.c::dm9000_probe
[...]
        db->mii.mdio_read    = dm9000_phy_read;

drivers/net/dm9000.c::dm9000_phy_read
[...]
        board_info_t *db = (board_info_t *) dev->priv;
        unsigned long flags;
        unsigned int reg_save;
        int ret;

        spin_lock_irqsave(&db->lock,flags);

-> deadlock

-- 
Ueimor
