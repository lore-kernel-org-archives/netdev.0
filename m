From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v2] net: qcom/emac: add ethtool support
Date: Fri, 13 Jan 2017 00:20:37 -0600
Message-ID: <0b772f90-9f0b-fa3c-7b8e-08c253b256d6@codeaurora.org>
References: <1483738981-31019-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, Alok Chauhan <alokc@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49268 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdAMGUm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:20:42 -0500
In-Reply-To: <1483738981-31019-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
> +static void emac_get_pauseparam(struct net_device *netdev,
> +				struct ethtool_pauseparam *pause)
> +{
> +	struct phy_device *phydev = netdev->phydev;
> +
> +	if (phydev) {
> +		if (phydev->autoneg)
> +			pause->autoneg = 1;
> +		if (phydev->pause)
> +			pause->rx_pause = 1;
> +		if (phydev->pause != phydev->asym_pause)
> +			pause->tx_pause = 1;
> +	}
> +}

I finally figured out why this code was bothering me.

This function works, as long as I do NOT implement set_pauseparam. 
That's because the driver always matches the pause frame support in the 
MAC with whatever the PHY is doing.  Since the MAC and PHY are always in 
sync, I can use the PHY settings for get_pauseparam.

However, technically this is not correct.  get_pauseparam is supposed to 
return the setting of the MAC, not the PHY.  If I also implement 
set_pauseparam, which can force the MAC to ignore the PHY and 
enable/disable pause frames arbitrarily, then the above function is wrong.

Do I finally understand this correctly?

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
