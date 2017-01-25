From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Wed, 25 Jan 2017 13:03:43 -0500
Message-ID: <87r33r3tkw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch> <1485309314-23942-2-git-send-email-andrew@lunn.ch> <87sho7123x.fsf@free-electrons.com> <87o9yvyqwr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46560 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750731AbdAYSEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:04:16 -0500
In-Reply-To: <87o9yvyqwr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

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
>                 *val |= chip->info->prod_num;

          if (reg == MII_PHYSID2 && (*val & 0xfff0) == 0)
              *val |= chip->info->prod_num << 4;

then. Do you agree?

>         }
>
>         return 0;
>     }

Thanks,

        Vivien
