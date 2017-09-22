From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/4] net: dsa: move up phy enabling in core
Date: Fri, 22 Sep 2017 18:32:58 +0200
Message-ID: <20170922163258.GA3470@lunn.ch>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
 <20170922161753.19563-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170922161753.19563-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2017 at 12:17:50PM -0400, Vivien Didelot wrote:
> bcm_sf2 is currently the only driver using the phy argument passed to
> .port_enable. It resets the state machine if the phy has been hard
> reset. This check is generic and can be moved to DSA core.
>  
>  	dsa_port_set_state_now(p->dp, stp_state);
>  
> -	if (p->phy)
> -		phy_start(p->phy);
> +	if (phy) {
> +		/* If phy_stop() has been called before, phy will be in
> +		 * halted state, and phy_start() will call resume.
> +		 *
> +		 * The resume path does not configure back autoneg
> +		 * settings, and since the internal phy may have been
> +		 * hard reset, we need to reset the state machine also.
> +		 */
> +		phy->state = PHY_READY;
> +		phy_init_hw(phy);
> +		phy_start(phy);
> +	}

Hi Vivien

If this is generic, why is it needed at all here? Shouldn't this
actually by in phylib?

Florian ?

   Andrew
