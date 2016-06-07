From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/5] net: dsa: Initialize
 ds->enabled_port_mask and ds->phys_mii_mask
Date: Tue, 7 Jun 2016 02:22:12 +0200
Message-ID: <20160607002212.GO12165@lunn.ch>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
 <1465254895-11152-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemlof.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60944 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316AbcFGAWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 20:22:16 -0400
Content-Disposition: inline
In-Reply-To: <1465254895-11152-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -304,6 +312,18 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
>  	if (err < 0)
>  		return err;
>  
> +	if (!ds->slave_mii_bus && ds->drv->phy_read) {
> +		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
> +		if (!ds->slave_mii_bus)
> +			return err;
> +
> +		dsa_slave_mii_bus_init(ds);
> +
> +		err = mdiobus_register(ds->slave_mii_bus);
> +		if (err < 0)
> +			return err;
> +	}
> +
>  	for (index = 0; index < DSA_MAX_PORTS; index++) {
>  		port = ds->ports[index].dn;
>  		if (!port)

Hi Florian

This hunk does not seem to fit in this patch.

It is also missing the unregister in dsa_ds_unapply().

   Andrew
