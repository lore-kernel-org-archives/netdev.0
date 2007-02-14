From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [patch 1/2] natsemi: Add support for using MII port with no PHY
Date: Wed, 14 Feb 2007 15:28:34 +0200
Message-ID: <20070214132834.GA4436@Ahmed>
References: <20070214100203.413293000@sirena.org.uk> <20070214100226.540001000@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.236]:17041 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273AbXBNN2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 08:28:45 -0500
Received: by nz-out-0506.google.com with SMTP id s1so182349nze
        for <netdev@vger.kernel.org>; Wed, 14 Feb 2007 05:28:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070214100226.540001000@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 14, 2007 at 10:02:04AM +0000, Mark Brown wrote:

> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>
> 
[...]
> -		if (np->phy_addr_external == PHY_ADDR_NONE) {
> +		/* If we're ignoring the PHY it doesn't matter if we can't
> +		 * find one. */
> +		if (!np->ignore_phy && np->phy_addr_external == PHY_ADDR_NONE) {
[...]
> +	if (!np->ignore_phy) {
> +		/* The link status field is latched: it remains low
> +		 * after a temporary link failure until it's read. We
> +		 * need the current link status, thus read twice.
> +		 */
> +		mdio_read(dev, MII_BMSR);
> +		bmsr = mdio_read(dev, MII_BMSR);
[...]
>  	/*
> +	 * If we're ignoring the PHY then autoneg and the internal
> +	 * transciever are really not going to work so don't let the
> +	 * user select them.
> +	 */
> +	if (np->ignore_phy && (ecmd->autoneg == AUTONEG_ENABLE ||

A trivial comment actually, Is there a point to write multi-line comments 
in two different formats ?

Thanks,

-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
