From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/9] net: dsa: mv88e6xxx: use 4-bit port for
 PVT data
Date: Fri, 31 Mar 2017 18:33:33 +0200
Message-ID: <20170331163333.GG12814@lunn.ch>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
 <20170330213715.9666-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170330213715.9666-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/* Offset 0x1D: Misc Register */
> +
> +static int mv88e6xxx_g2_misc_5_bit_port(struct mv88e6xxx_chip *chip,
> +					bool port_5_bit)
> +{
> +	u16 val;
> +	int err;
> +
> +	err = mv88e6xxx_g2_read(chip, GLOBAL2_MISC, &val);
> +	if (err)
> +		return err;
> +
> +	if (port_5_bit)
> +		val |= GLOBAL2_MISC_5_BIT_PORT;
> +	else
> +		val &= ~GLOBAL2_MISC_5_BIT_PORT;
> +
> +	return mv88e6xxx_g2_write(chip, GLOBAL2_MISC, val);
> +}
> +
> +int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip)
> +{
> +	return mv88e6xxx_g2_misc_5_bit_port(chip, false);
> +}

Hi Vivien

Yes, i know, i'm nit-picking. The function naming is confusing here.
What would you call this function:

int mv88e6xxx_g2_misc_XXXXX(struct mv88e6xxx_chip *chip)
{
	return mv88e6xxx_g2_misc_5_bit_port(chip, true);
}

Thanks
	Andrew
