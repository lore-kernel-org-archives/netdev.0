From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver
 for Microsemi PHYs.
Date: Mon, 17 Oct 2016 17:36:31 +0530
Message-ID: <20161017120630.GB25339@microsemi.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928202451.GC30728@lunn.ch>
 <20161004143122.GC29274@microsemi.com>
 <20161005071834.GD5575@lunn.ch>
 <f10c1be8-bfce-a2e5-9a5c-d612a3e2cd4f@gmail.com>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Lunn <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <Allan.Nielsen@microsemi.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0086.outbound.protection.outlook.com ([104.47.37.86]:38277
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934005AbcJQMkU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 08:40:20 -0400
Content-Disposition: inline
In-Reply-To: <f10c1be8-bfce-a2e5-9a5c-d612a3e2cd4f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian/Andrew,

Thank you for review comments.

On Thu, Oct 06, 2016 at 04:09:56AM -0700, Florian Fainelli wrote:
> EXTERNAL EMAIL
> 
> 
> On 10/05/2016 12:18 AM, Andrew Lunn wrote:
> >>>> +     phydev->mdix = ETH_TP_MDI_AUTO;
> >>>
> >>> Humm, interesting. The only other driver supporting mdix is the
> >>> Marvell one. It does not do this, it leaves it to its default value of
> >>> ETH_TP_MDI_INVALID. It does however interpret ETH_TP_MDI_INVALID as
> >>> meaning as ETH_TP_MDI_AUTO.
> >>>
> >>> There needs to be consistency here. You either need to do the same as
> >>> the Marvell driver, or you need to modify the Marvell driver to also
> >>> set phydev->mdix to ETH_TP_MDI_AUTO.
> >>>
> >> In Ethtool two variable i.e. eth_tp_mdix_ctrl, eth_tp_mdix use to update
> >> the status. But, driver header is having one variable i.e. mdix.
> >> Driver header should also have another variabl like mdix_ctrl.
> >> Then, Ethtool can get/set the Auto MDIX/MDI.
> >> In case, mdix is not configure with ETH_TP_MDI_AUTO, Ethtool shows error as
> >> "setting MDI not supported"
> 
> Agreed, we currently report eth_tp_mdi and eth_tp_mdi_ctrl using
> phydev->mdix, but this is too limiting.
> 
> >>
> >> Please suggest me if you have any better method to fix this issue.
> >
> > Maybe we should add a new flag for the .flags member of the
> > phy_driver. If PHY_HAS_MDIX is set, the phy core will set phydev->mdix
> > to ETH_TP_MDI_AUTO?
> 
> I agree with Raju here, like most other Ethernet drivers, we should
> allow PHY drivers to have an eth_tp_mdix_ctrl to indicate what is the
> configured MDI setting, and read eth_tp_mdi to indicate what is the
> current status, then ethtool can properly differentiate what is going on.
> 

Andrew, Do you want me to add new flag (mdix_ctrl) or keep it as it is?
These changes are more relevant for mdix get status function.
Do you want to me implement along with mdix get status function? 

> Raju, Andrew, does that work for you?
> --
> Florian

---
Thanks,
Raju.
