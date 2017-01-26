From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Thu, 26 Jan 2017 13:06:57 +0100
Message-ID: <87tw8myqhq.fsf@free-electrons.com>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
        <1485309314-23942-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:51906 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbdAZMHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 07:07:00 -0500
In-Reply-To: <1485309314-23942-2-git-send-email-andrew@lunn.ch> (Andrew Lunn's
        message of "Wed, 25 Jan 2017 02:55:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> -	return mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
> +	err = mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
> +	if (err)
> +		return err;
> +
> +	if (reg == MII_PHYSID2) {
> +		/* The mv88e6390 internal PHYS don't have a model number.
> +		 * Use the switch family model number instead.
> +		 */
> +		if (!(*val & 0x3ff)) {
> +			if (chip->info->family == MV88E6XXX_FAMILY_6390)

I needed to test the MV88E6XXX_FAMILY_6341 flag too. But this one have
to be done in my series because before it the flag is not introduced.

As pointed in the other patch, we still need to decide to use the sale
PHY ID or to use a new one.

Thanks,

Gregory


> +				*val |= PORT_SWITCH_ID_PROD_NUM_6390;
> +		}
> +	}
> +
> +	return 0;
>  }
>  
>  int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
> -- 
> 2.11.0
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
