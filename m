From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 1/2] net: dsa: mv88e6xxx: Add helper for accessing port registers
Date: Mon, 19 Sep 2016 22:17:51 -0400
Message-ID: <87ponzqpps.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1474331590-7959-1-git-send-email-andrew@lunn.ch> <1474331590-7959-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40502 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbcITCR5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 22:17:57 -0400
In-Reply-To: <1474331590-7959-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

<snip>

> @@ -585,19 +601,19 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
>  				  struct phy_device *phydev)
>  {
>  	struct mv88e6xxx_chip *chip = ds->priv;
> -	u32 reg;
> -	int ret;
> +	u16 reg;
> +	int err;
>  
>  	if (!phy_is_pseudo_fixed_link(phydev))
>  		return;
>  
>  	mutex_lock(&chip->reg_lock);
>  
> -	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_PCS_CTRL);
> -	if (ret < 0)
> +	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
> +	if (err)
>  		goto out;
>  
> -	reg = ret & ~(PORT_PCS_CTRL_LINK_UP |
> +	reg = reg & ~(PORT_PCS_CTRL_LINK_UP |

        reg &= ~(PORT_PCS_CTRL_LINK_UP |

>  		      PORT_PCS_CTRL_FORCE_LINK |
>  		      PORT_PCS_CTRL_DUPLEX_FULL |
>  		      PORT_PCS_CTRL_FORCE_DUPLEX |

<snip>

>  	/* Wait up to one second for reset to complete. */
>  	timeout = jiffies + 1 * HZ;
>  	while (time_before(jiffies, timeout)) {
> -		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, 0x00);
> -		if (ret < 0)
> -			return ret;
> +		err = _mv88e6xxx_reg_read(chip, REG_GLOBAL, 0x00);
> +		if (err)
> +			return err;

Ouch! Wrong s/ret/err/ here.

>  
> -		if ((ret & is_reset) == is_reset)
> +		if ((err & is_reset) == is_reset)

Here as well. Keep ret or use mv88e6xxx_read().

>  			break;
>  		usleep_range(1000, 2000);
>  	}
>  	if (time_after(jiffies, timeout))
> -		ret = -ETIMEDOUT;
> +		err = -ETIMEDOUT;
>  	else
> -		ret = 0;
> +		err = 0;
>  
> -	return ret;
> +	return err;
>  }
>  
>  static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)

Thanks,

        Vivien
