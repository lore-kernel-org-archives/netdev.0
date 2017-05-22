From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 16:29:36 -0500
Message-ID: <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36066 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933607AbdEVV3k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:29:40 -0400
In-Reply-To: <20170522210927.GR29447@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 04:09 PM, Andrew Lunn wrote:
> Are you using interrupts? Or polling?

adpt->phydev->irq = PHY_IGNORE_INTERRUPT;
ret = phy_connect_direct(netdev, adpt->phydev, emac_adjust_link,
			 PHY_INTERFACE_MODE_SGMII);

Technically it's polling, except that it's my NIC's hardware that is polling
the MDIO bus, and then generating an interrupt when there's a link state change.

When the link state changes, I call phy_mac_interrupt()

if (status & ISR_GPHY_LINK)
	phy_mac_interrupt(adpt->phydev, !!(status & GPHY_LINK_UP_INT));

> If polling, it should come back again 1 second later and see if
> auto-neg has completed. Hopefully the SGMII side comes up eventually.
> 
> If you are using interrupts, you need another interrupt when the SGMII
> side comes up, otherwise i think the state machine is stuck waiting.

I'll have to test this, but what do I do if I don't get another interrupt?
I have a suspicion that the link is actually okay, and that the error is bogus.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
