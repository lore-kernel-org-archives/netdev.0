From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: marvell: fix Marvell 88E1512 used in SGMII mode
Date: Tue, 10 Jan 2017 15:24:11 -0800
Message-ID: <61950d83-cbe1-6e1b-4afc-bc471b386ff3@gmail.com>
References: <E1cR5bt-0000O8-1T@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36775 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdAJXYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 18:24:14 -0500
Received: by mail-pf0-f194.google.com with SMTP id b22so14477096pfd.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 15:24:14 -0800 (PST)
In-Reply-To: <E1cR5bt-0000O8-1T@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2017 03:13 PM, Russell King wrote:
> When an Marvell 88E1512 PHY is connected to a nic in SGMII mode, the
> fiber page is used for the SGMII host-side connection.  The PHY driver
> notices that SUPPORTED_FIBRE is set, so it tries reading the fiber page
> for the link status, and ends up reading the MAC-side status instead of
> the outgoing (copper) link.  This leads to incorrect results reported
> via ethtool.
> 
> If the PHY is connected via SGMII to the host, ignore the fiber page.
> However, continue to allow the existing power management code to
> suspend and resume the fiber page.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Fixes: 6cfb3bcc0641 ("Marvell phy: check link status in case of fiber
link.")
-- 
Florian
