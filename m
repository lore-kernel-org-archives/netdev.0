From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net/{mii,smsc}: Make mii_ethtool_get_link_ksettings and
 smc_netdev_get_ecmd return void
Date: Sun, 4 Jun 2017 21:01:33 +0200
Message-ID: <20170604190133.GB10273@lunn.ch>
References: <20170604172200.4177-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: klassert@mathematik.tu-chemnitz.de, pcnet32@frontier.com,
        hsweeten@visionengravers.com, jeffrey.t.kirsher@intel.com,
        cooldavid@cooldavid.org, mcuos.com@gmail.com, nic_swsd@realtek.com,
        ralf@linux-mips.org, romieu@fr.zoreil.com, nico@fluxnic.net,
        oneukum@suse.com, davem@davemloft.net, tremyfr@gmail.com,
        paul.gortmaker@windriver.com, jarod@redhat.com, green.hu@gmail.com,
        f.fainelli@gmail.com, edumazet@google.com, shchers@gmail.com,
        stephen.boyd@linaro.org, fgao@48lvckh6395k16k5.yundunddos.com,
        tklauser@distanz.ch, jay.vosburgh@canonical.com,
        robert.jarzmik@free.fr, jeremy.linton@arm.com,
        rmk+kernel@armlinux.org.uk, stephen@networkplumber.org,
        arnd@arndb.de, gerg@linux-m68k.org, allan@asix.com.tw,
        chris.roth@usask.ca, hayeswang@realtek.com,
        mario_limonciello@dell.com, netdev@vger.kern
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170604172200.4177-1-yuval.shaia@oracle.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
> index da02041..017f48c 100644
> --- a/drivers/net/cris/eth_v10.c
> +++ b/drivers/net/cris/eth_v10.c
> @@ -1417,10 +1417,9 @@ static int e100_get_link_ksettings(struct net_device *dev,
>  {
>  	struct net_local *np = netdev_priv(dev);
>  	u32 supported;
> -	int err;
>  
>  	spin_lock_irq(&np->lock);
> -	err = mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
> +	mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
>  	spin_unlock_irq(&np->lock);
>  
>  	/* The PHY may support 1000baseT, but the Etrax100 does not.  */
> @@ -1432,7 +1431,7 @@ static int e100_get_link_ksettings(struct net_device *dev,
>  	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
>  						supported);
>  
> -	return err;
> +	return 0;
>  }

How far are going planning on going? It seems like
*_get_link_ksettings() now all return a useless 0. Do you plan to
change ethtool_ops and make if void all the way up?

       Andrew
