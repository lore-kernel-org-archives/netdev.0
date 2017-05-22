From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 16:19:26 -0500
Message-ID: <c57adeeb-b51c-5ac8-776e-1ead474f7b48@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210215.GQ29447@lunn.ch>
 <0528e1fa-2924-1286-578d-060419bfee49@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33702 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933776AbdEVVT2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:19:28 -0400
In-Reply-To: <0528e1fa-2924-1286-578d-060419bfee49@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 04:10 PM, Florian Fainelli wrote:
> Even a module argument would be rejected. If you need platform/SoC
> specific behavior propagated down to the PHY driver, several options exist:
> 
> - pass an agreed upon value for phy_flags to of_phy_connect() see
> drivers/net/ethernet/broadcom/tg3.c and
> drivers/net/ethernet/broadcom/genet/bcmgenet.c for instance and update
> the driver to act on that "flags" see drivers/net/phy/broadcom.c and
> drivers/net/phy/bcm7xxx.c

Will this work on ACPI systems as well?  I call phy_connect_direct() instead
of of_phy_connect().  I see some drivers set phydev->dev_flags before
calling phy_connect_direct().

My concern is that this problem occurs only on an at8031 chip, so having my
network driver passing an at8031-specific flag seems out of place.  What
happens if, on some other board, a different PHY is used, and that flag
means something else?

> - register a PHY fixup which is specific to the board/SoC, and have the
> PHY fixup do whatever is necessary for your platform (like setting
> specific registers)

Do you have an example of that?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
