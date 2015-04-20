From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: fix setup of port control 1
Date: Tue, 21 Apr 2015 01:05:07 +0200
Message-ID: <20150420230507.GC32294@lunn.ch>
References: <1429564763-10098-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429564763-10098-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 05:19:23PM -0400, Vivien Didelot wrote:
> mv88e6xxx_setup_port_common was writing to PORT_DEFAULT_VLAN (port
> offset 0x07) instead of PORT_CONTROL_1 (port offset 0x05).

Hi Vivien

Good catch.
 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Fixes: cca8b1337541 ("net: dsa: Use mnemonics rather than register numbers")
Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  drivers/net/dsa/mv88e6xxx.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 9f0c2b9..48712bd 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1251,8 +1251,7 @@ int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
>  	/* Port Control 1: disable trunking, disable sending
>  	 * learning messages to this port.
>  	 */
> -	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
> -				   0x0000);
> +	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_1, 0x0000);
>  	if (ret)
>  		goto abort;
>  
> -- 
> 2.3.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
