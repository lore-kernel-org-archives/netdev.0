From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 11/12] net: dsa: mv88e6xxx: add G1 helper for
 ageing time
Date: Tue, 19 Jul 2016 16:45:18 +0200
Message-ID: <20160719144518.GC31103@lunn.ch>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
 <20160719004540.1066-12-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160719004540.1066-12-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
> +				     unsigned int msecs)
> +{
> +	const unsigned int coeff = chip->info->age_time_coeff;
> +	const unsigned int min = 0x01 * coeff;
> +	const unsigned int max = 0xff * coeff;
> +	u8 age_time;
> +	u16 val;
> +	int err;
> +
> +	if (msecs < min || msecs > max)
> +		return -ERANGE;
> +
> +	/* Round to nearest multiple of coeff */
> +	age_time = (msecs + coeff / 2) / coeff;
> +
> +	err = mv88e6xxx_read(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, &val);
> +	if (err)
> +		return err;
> +
> +	/* AgeTime is 11:4 bits */
> +	val &= ~0xff0;
> +	val |= age_time << 4;
> +
> +	return mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, val);
> +}

Hi Vivien

This is doing a read/modify/write, so should really hold the mutex.

> +	err = mv88e6xxx_g1_set_age_time(chip, 300000);

Maybe use (5 * 60 * 1000) to make it more readable?

      Andrew
