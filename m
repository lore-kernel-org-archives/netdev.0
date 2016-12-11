From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v4] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Sun, 11 Dec 2016 11:45:15 -0800
Message-ID: <042cef25-4dca-d266-c5eb-4d2ed573f81a@gmail.com>
References: <1481138451-28144-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        jon.mason@broadcom.com, nks.gnu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36306 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753620AbcLKTpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 14:45:18 -0500
Received: by mail-oi0-f67.google.com with SMTP id u15so8574036oie.3
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 11:45:18 -0800 (PST)
In-Reply-To: <1481138451-28144-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/07/16 à 11:20, Timur Tabi a écrit :
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

This is already applied but:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
