From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net: ethernet: nixge: Add support for National
 Instruments XGE netdev
Date: Fri, 14 Jul 2017 03:34:35 +0200
Message-ID: <20170714013435.GA9065@lunn.ch>
References: <1499980909-11702-1-git-send-email-mdf@kernel.org>
 <1499980909-11702-2-git-send-email-mdf@kernel.org>
 <20170713223636.GF3120@lunn.ch>
 <20170714003111.GA13512@tyrael.ni.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Moritz Fischer <mdf@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, mark.rutland@arm.com, robh+dt@kernel.org
To: Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170714003111.GA13512@tyrael.ni.corp.natinst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > +	/* not sure if this is the correct way of dealing with this ... */
> > > +	ndev->phydev->supported &= ~(SUPPORTED_Autoneg);
> > > +	ndev->phydev->advertising = ndev->phydev->supported;
> > > +	ndev->phydev->autoneg = AUTONEG_DISABLE;
> > 
> > What are you trying to achieve?
> 
> Basically can't do Autoneg, I'll need to take a closer look.

Hi Moritz

What i actually think you mean, is it can only do 1Gbps. So you could
autoneg, but only advertise 1Gbps. Look at masking out
PHY_10BT_FEATURES and PHY_100BT_FEATURES.

Take a look at:

http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/renesas/ravb_main.c#L1045

It might actually make sense to add a phy_set_min_speed(), a mirror to
phy_set_max_speed().

	Andrew
