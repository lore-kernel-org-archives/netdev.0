From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY
 ID on mv88e6390
Date: Wed, 25 Jan 2017 19:00:14 +0100
Message-ID: <20170125180014.GC6611@lunn.ch>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
 <1485309314-23942-2-git-send-email-andrew@lunn.ch>
 <87sho7123x.fsf@free-electrons.com>
 <87o9yvyqwr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45899 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751442AbdAYSAS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 13:00:18 -0500
Content-Disposition: inline
In-Reply-To: <87o9yvyqwr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Since several chips have this issue, we can introduce a u16 physid2_mask
> member in the mv88e6xxx_info structure and move the check in
> mv88e6xxx_phy_read() so that the logic of device (as in Global2) helpers
> are not affected by such (necessary) hack. Something like:
> 
>     static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
>                                   int reg, u16 *val)
>     {
>         ...
> 
>         err = chip->info->ops->phy_read(chip, bus, addr, reg, val);
>         if (err)
>             return err;
> 
>         if (reg == MII_PHYSID2 && chip->info->physid2_mask) {
>             /* Some internal PHYs don't have a model number,
>              * so return the switch family model number directly.
>              */
>             if (!(*val & chip->info->physid2_mask))

Hi Vivien

I don't see the need to have per switch masks. Lets just hard code it
to ignore the lower 4 bits.

>                 *val |= chip->info->prod_num;

and this is not good. I deliberately picked the family num, not the
product num. Otherwise for the 6390 family, we have 6 different PHY
IDs. And two more for Gregorys two switches.

     Andrew
