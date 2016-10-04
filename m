From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next 1/2] net: phy: Add Wake-on-LAN driver for
 Microsemi PHYs.
Date: Tue, 4 Oct 2016 19:42:51 +0530
Message-ID: <20161004141250.GA29274@microsemi.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-2-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928162705.GB25553@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0055.outbound.protection.outlook.com ([104.47.41.55]:3040
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750781AbcJDONj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 10:13:39 -0400
Content-Disposition: inline
In-Reply-To: <20160928162705.GB25553@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for code review and valuable comments.

On Wed, Sep 28, 2016 at 06:27:05PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > +#define MSCC_PHY_WOL_MAC_CONTROL       27
> > +#define EDGE_RATE_CNTL_POS             5
> > +#define EDGE_RATE_CNTL_MASK            0x00E0
> 
> This patch does not require these two #defines.
> 
> Please indicate in the cover note if the patches depends on other
> patches in order to cleanly apply. Or if these patches are going to
> conflict with some other patches.
> 

Accepted. I will remove those 2 defines.

> > +     reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
> > +     if (wol_conf->wolopts & WAKE_MAGICSECURE)
> > +             reg_val |= SECURE_ON_ENABLE;
> > +     else
> > +             reg_val &= ~SECURE_ON_ENABLE;
> > +     phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
> > +
> > +     if (wol_conf->wolopts & WAKE_MAGICSECURE) {
> > +             reg_val = wol_conf->sopass[4] << 8;
> > +             reg_val |= wol_conf->sopass[5];
> > +             phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, reg_val);
> > +             reg_val = wol_conf->sopass[2] << 8;
> > +             reg_val |= wol_conf->sopass[3];
> > +             phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, reg_val);
> > +             reg_val = wol_conf->sopass[0] << 8;
> > +             reg_val |= wol_conf->sopass[1];
> > +             phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, reg_val);
> > +     } else {
> > +             phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, 0);
> > +             phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, 0);
> > +             phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, 0);
> > +     }
> 
> Wouldn't it be better to set the password, and then enable the
> password feature?
> 

Accepted. I will change.

> I don't know much about WOL. Hopefully Florian will add further
> comments.
> 
>          Andrew

---
Thanks,
Raju.
