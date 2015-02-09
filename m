From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: Remove redundant phy_attach()
Date: Mon, 09 Feb 2015 11:21:26 -0800
Message-ID: <54D908B6.9020101@gmail.com>
References: <1423445395-412-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:42573 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933468AbbBITVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 14:21:31 -0500
Received: by pdbfp1 with SMTP id fp1so2593570pdb.9
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 11:21:30 -0800 (PST)
In-Reply-To: <1423445395-412-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/15 17:29, Andrew Lunn wrote:
> dsa_slave_phy_setup() finds the phy for the port via device tree and
> using of_phy_connect(), or it uses the fall back of taking a phy from
> the switch internal mdio bus and calling phy_connect_direct(). Either
> way, if a phy is found, phy_attach_direct() is called to attach the
> phy to the slave device.
> 
> In dsa_slave_create(), a second call to phy_attach() is made. This
> results in the warning "PHY already attached". Remove this second,
> redundant attaching of the phy.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  net/dsa/slave.c | 13 -------------
>  1 file changed, 13 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 589aafd01fc5..d104ae15836f 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -676,18 +676,5 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  
>  	netif_carrier_off(slave_dev);
>  
> -	if (p->phy != NULL) {
> -		if (ds->drv->get_phy_flags)
> -			p->phy->dev_flags |= ds->drv->get_phy_flags(ds, port);
> -
> -		phy_attach(slave_dev, dev_name(&p->phy->dev),
> -			   PHY_INTERFACE_MODE_GMII);
> -
> -		p->phy->autoneg = AUTONEG_ENABLE;
> -		p->phy->speed = 0;
> -		p->phy->duplex = 0;
> -		p->phy->advertising = p->phy->supported | ADVERTISED_Autoneg;
> -	}
> -
>  	return slave_dev;
>  }
> 


-- 
Florian
