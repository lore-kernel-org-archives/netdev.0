From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 RFC 6/7] Add MIB counter reading support
Date: Sat, 14 Oct 2017 22:07:06 +0200
Message-ID: <20171014200706.GA24477@lunn.ch>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-7-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507321985-15097-7-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static void ksz9477_phy_setup(struct ksz_device *dev, int port,
> +			      struct phy_device *phy)
> +{
> +	if (port < dev->phy_port_cnt) {
> +		/* SUPPORTED_Asym_Pause and SUPPORTED_Pause can be removed to
> +		 * disable flow control when rate limiting is used.
> +		 */
> +		phy->advertising = phy->supported;
> +	}
> +}
> +

This has nothing to do with MIBs. It does not belong in this patch.

>  static void ksz9477_port_setup(struct ksz_device *dev, int port, bool cpu_port)
>  {
>  	u8 data8;
> @@ -1159,6 +1198,8 @@ static int ksz9477_setup(struct dsa_switch *ds)
>  	/* start switch */
>  	ksz_cfg(dev, REG_SW_OPERATION, SW_START, true);
>  
> +	ksz_init_mib_timer(dev);
> +
>  	return 0;
>  }
>  
> @@ -1168,6 +1209,7 @@ static int ksz9477_setup(struct dsa_switch *ds)
>  	.set_addr		= ksz9477_set_addr,
>  	.phy_read		= ksz9477_phy_read16,
>  	.phy_write		= ksz9477_phy_write16,
> +	.adjust_link		= ksz_adjust_link,

Please move the adjust_link changes into a separate patch.

I need to come back at look at the mutex's and the freeze code. It is
not obviously correct, and i don't have the time at the moment.

       Andrew
