From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v4] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Sat, 10 Dec 2016 23:31:41 -0500 (EST)
Message-ID: <20161210.233141.830947206162497097.davem@davemloft.net>
References: <1481138451-28144-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        jon.mason@broadcom.com, nks.gnu@gmail.com
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752257AbcLKEbn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 23:31:43 -0500
In-Reply-To: <1481138451-28144-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed,  7 Dec 2016 13:20:51 -0600

> Instead of having individual PHY drivers set the SUPPORTED_Pause and
> SUPPORTED_Asym_Pause flags, phylib itself should set those flags,
> unless there is a hardware erratum or other special case.  During
> autonegotiation, the PHYs will determine whether to enable pause
> frame support.
> 
> Pause frames are a feature that is supported by the MAC.  It is the MAC
> that generates the frames and that processes them.  The PHY can only be
> configured to allow them to pass through.
> 
> This commit also effectively reverts the recently applied c7a61319
> ("net: phy: dp83848: Support ethernet pause frames").
> 
> So the new process is:
> 
> 1) Unless the PHY driver overrides it, phylib sets the SUPPORTED_Pause
> and SUPPORTED_AsymPause bits in phydev->supported.  This indicates that
> the PHY supports pause frames.
> 
> 2) The MAC driver checks phydev->supported before it calls phy_start().
> If (SUPPORTED_Pause | SUPPORTED_AsymPause) is set, then the MAC driver
> sets those bits in phydev->advertising, if it wants to enable pause
> frame support.
> 
> 3) When the link state changes, the MAC driver checks phydev->pause and
> phydev->asym_pause,  If the bits are set, then it enables the corresponding
> features in the MAC.  The algorithm is:
> 
> 	if (phydev->pause)
> 		The MAC should be programmed to receive and honor
>                 pause frames it receives, i.e. enable receive flow control.
> 
> 	if (phydev->pause != phydev->asym_pause)
> 		The MAC should be programmed to transmit pause
> 		frames when needed, i.e. enable transmit flow control.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied.
