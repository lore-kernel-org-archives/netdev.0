From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver
 for Microsemi PHYs.
Date: Mon, 17 Oct 2016 17:16:42 +0530
Message-ID: <20161017114601.GA25339@microsemi.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928202451.GC30728@lunn.ch>
 <965514c2-8219-435a-e32f-114c361ff55b@gmail.com>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Lunn <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <Allan.Nielsen@microsemi.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0044.outbound.protection.outlook.com ([104.47.41.44]:4696
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932764AbcJQLrC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 07:47:02 -0400
Content-Disposition: inline
In-Reply-To: <965514c2-8219-435a-e32f-114c361ff55b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian/Andrew,

Thank you for review comments.

On Thu, Oct 06, 2016 at 03:57:32AM -0700, Florian Fainelli wrote:
> EXTERNAL EMAIL
> 
> 
> On 09/28/2016 01:24 PM, Andrew Lunn wrote:
> >>  static int vsc85xx_wol_set(struct phy_device *phydev,
> >>                         struct ethtool_wolinfo *wol)
> >>  {
> >> @@ -227,6 +281,7 @@ static int vsc85xx_default_config(struct phy_device *phydev)
> >>      int rc;
> >>      u16 reg_val;
> >>
> >> +    phydev->mdix = ETH_TP_MDI_AUTO;
> >
> > Humm, interesting. The only other driver supporting mdix is the
> > Marvell one. It does not do this, it leaves it to its default value of
> > ETH_TP_MDI_INVALID. It does however interpret ETH_TP_MDI_INVALID as
> > meaning as ETH_TP_MDI_AUTO.
> >
> > There needs to be consistency here. You either need to do the same as
> > the Marvell driver, or you need to modify the Marvell driver to also
> > set phydev->mdix to ETH_TP_MDI_AUTO.
> >
> > I don't yet know which of these two is the right thing to do.
> >
> > Florian?
> 
> It's really hard to tell because the other drivers I looked at do not
> necessarily seem to be consistent either. Here, if the MDI status is
> really auto, then this is the correct value to return, if it is unknown,
> it should be ETH_TP_MDI_INVALID.
> 

In mdix get status function, This value will be update as per 
PHY mdix current status.

Shall i configure "phydev->mdix = ETH_TP_MDI_AUTO" as default ?

Andrew, do you have any comments?

> For the Marvell PHY, it sounds like we should be able to determine what
> was configured and return the correct MDI status value
> --
> Florian

---
Thanks,
Raju.
