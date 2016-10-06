From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver
 for Microsemi PHYs.
Date: Thu, 6 Oct 2016 04:09:56 -0700
Message-ID: <f10c1be8-bfce-a2e5-9a5c-d612a3e2cd4f@gmail.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928202451.GC30728@lunn.ch> <20161004143122.GC29274@microsemi.com>
 <20161005071834.GD5575@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Allan.Nielsen@microsemi.com
To: Andrew Lunn <andrew@lunn.ch>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34918 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752880AbcJFLKE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 07:10:04 -0400
Received: by mail-qt0-f195.google.com with SMTP id g49so414910qtc.2
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 04:10:04 -0700 (PDT)
In-Reply-To: <20161005071834.GD5575@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/05/2016 12:18 AM, Andrew Lunn wrote:
>>>> +     phydev->mdix = ETH_TP_MDI_AUTO;
>>>
>>> Humm, interesting. The only other driver supporting mdix is the
>>> Marvell one. It does not do this, it leaves it to its default value of
>>> ETH_TP_MDI_INVALID. It does however interpret ETH_TP_MDI_INVALID as
>>> meaning as ETH_TP_MDI_AUTO.
>>>
>>> There needs to be consistency here. You either need to do the same as
>>> the Marvell driver, or you need to modify the Marvell driver to also
>>> set phydev->mdix to ETH_TP_MDI_AUTO.
>>>
>> In Ethtool two variable i.e. eth_tp_mdix_ctrl, eth_tp_mdix use to update
>> the status. But, driver header is having one variable i.e. mdix.
>> Driver header should also have another variabl like mdix_ctrl.
>> Then, Ethtool can get/set the Auto MDIX/MDI.
>> In case, mdix is not configure with ETH_TP_MDI_AUTO, Ethtool shows error as
>> "setting MDI not supported"

Agreed, we currently report eth_tp_mdi and eth_tp_mdi_ctrl using
phydev->mdix, but this is too limiting.

>>
>> Please suggest me if you have any better method to fix this issue.
> 
> Maybe we should add a new flag for the .flags member of the
> phy_driver. If PHY_HAS_MDIX is set, the phy core will set phydev->mdix
> to ETH_TP_MDI_AUTO?

I agree with Raju here, like most other Ethernet drivers, we should
allow PHY drivers to have an eth_tp_mdix_ctrl to indicate what is the
configured MDI setting, and read eth_tp_mdi to indicate what is the
current status, then ethtool can properly differentiate what is going on.

Raju, Andrew, does that work for you?
-- 
Florian
