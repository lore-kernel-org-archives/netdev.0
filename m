From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net: dsa: mv88e6xxx: Refactor mv88e6352 SERDES code into an op
Date: Wed, 17 May 2017 17:01:28 -0400
Message-ID: <874lwj8afr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495051512-13554-1-git-send-email-andrew@lunn.ch> <1495051512-13554-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, nikita.yoush@cogentembedded.com,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50770 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752053AbdEQVDW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 17:03:22 -0400
In-Reply-To: <1495051512-13554-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>  static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
>  {
> -	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
> -		return -EOPNOTSUPP;
> -
>  	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
>  }
>  
> @@ -300,8 +298,8 @@ static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
>  	}
>  }
>  
> -static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
> -				   u8 page, int reg, u16 *val)
> +int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
> +			    u8 page, int reg, u16 *val)
>  {
>  	int err;
>  
> @@ -318,8 +316,8 @@ static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
>  	return err;
>  }
>  
> -static int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
> -				    u8 page, int reg, u16 val)
> +int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
> +			     u8 page, int reg, u16 val)

Hum, this patch does a bit too much... Please at least add a first one
providing phy.[ch] for the PHY Registers related functions, then add the
serdes_power operation.

> +#define MV88E6XXX_FLAG_G1_ATU_FID	BIT_ULL(MV88E6XXX_CAP_G1_ATU_FID)

This seems to be added back by mistake.

> @@ -889,6 +868,9 @@ struct mv88e6xxx_ops {
>  			   struct mv88e6xxx_vtu_entry *entry);
>  	int (*vtu_loadpurge)(struct mv88e6xxx_chip *chip,
>  			     struct mv88e6xxx_vtu_entry *entry);
> +
> +	/* Power on/off a SERDES interface */
> +	int (*serdes_power)(struct mv88e6xxx_chip *chip, int port, bool on);
>  };

While the get_* and set_* ops are an exception, we might want to sort
that at least before the vtu_* ops. But that is a minor comment.

> +#define MV88E6352_ADDR_SERDES		0x0f
> +#define MV88E6352_SERDES_PAGE_FIBER	0x01

Why not moving this in the serdes.h header with the others?


Thank you,

      Vivien
