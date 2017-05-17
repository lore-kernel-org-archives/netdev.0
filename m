From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/3] net: dsa: mv88e6xxx: mv88e6390X SERDES support
Date: Wed, 17 May 2017 16:49:32 -0400
Message-ID: <877f1f8azn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495051512-13554-1-git-send-email-andrew@lunn.ch> <1495051512-13554-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, nikita.yoush@cogentembedded.com,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50146 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752996AbdEQUv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 16:51:27 -0400
In-Reply-To: <1495051512-13554-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> -static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
> -			      int reg, u16 *val)
> +int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
> +		       int reg, u16 *val)
>  {
>  	int addr = phy; /* PHY devices addresses start at 0x0 */
>  	struct mii_bus *bus;
> @@ -265,8 +265,8 @@ static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
>  	return chip->info->ops->phy_read(chip, bus, addr, reg, val);
>  }
>  
> -static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
> -			       int reg, u16 val)
> +int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
> +			int reg, u16 val)

Please add a very first patch which expose the mv88e6xxx_phy_ (and page_
of patch 1/3) PHY related code in new phy.[ch] files. These are the
missing specific files for the PHY Registers sets ;-)

> +	if (chip->info->ops->serdes_power)
> +		return chip->info->ops->serdes_power(chip, port, true);
> +
> +	return 0;
>  }
>  
>  static int mv88e6xxx_setup_message_port(struct mv88e6xxx_chip *chip, int port)
> @@ -2068,15 +2071,6 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
>  	if (err)
>  		return err;
>  
> -	/* If this port is connected to a SerDes, make sure the SerDes is
> -	 * powered up.
> -	 */
> -	if (chip->info->ops->serdes_power) {
> -		err = chip->info->ops->serdes_power(chip, port, true);
> -		if (err)
> -			return err;
> -	}
> -

All 3 patches moves this call around. Can we place it right once, the
first time a mv88e6xxx_serdes_power() helper is added?


Thank you,

        Vivien
