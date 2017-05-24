From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 1/5] net: dsa: mv88e6xxx: Move phy functions into phy.[ch]
Date: Wed, 24 May 2017 11:31:43 -0400
Message-ID: <87lgpmfezk.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495573486-31827-1-git-send-email-andrew@lunn.ch> <1495573486-31827-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50702 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760072AbdEXPdo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 11:33:44 -0400
In-Reply-To: <1495573486-31827-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The upcoming SERDES support will need to make use of PHY functions. Move
> them out into a file of there own. No code changes.

                          their

[...]

> +int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page);
> +void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy);

I am not sure that you need to expose these functions. Can you confirm?

> +int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
> +			    u8 page, int reg, u16 *val);
> +int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
> +			     u8 page, int reg, u16 val);
> +int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip);
> +int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip);
> +void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip);
> +void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip);

If we want to move all PHY-related functions and wrappers into phy.[ch],
there are also mv88e6xxx_phy_init and mv88e6xxx_phy_destroy. This will
make most mv88e6xxx_ppu_* code static.

> +int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
> +			   int addr, int reg, u16 *val);
> +int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
> +			    int addr, int reg, u16 val);

Thanks,

        Vivien
