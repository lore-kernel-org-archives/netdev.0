From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 1/3] net: phy: avoid setting unsupported EEE
 advertisments
Date: Mon, 27 Mar 2017 11:04:28 -0700
Message-ID: <af448c35-218d-a6c9-3c3a-802350285d88@gmail.com>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQJ-0004qu-M0@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew lunn <andrew@lunn.ch>
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35889 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbdC0SFH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:05:07 -0400
Received: by mail-wr0-f195.google.com with SMTP id u1so15598862wra.3
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:05:01 -0700 (PDT)
In-Reply-To: <E1csRQJ-0004qu-M0@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2017 02:58 AM, Russell King wrote:
> We currently allow userspace to set any EEE advertisments it desires,
> whether or not the PHY supports them.  For example:
> 
>  # ethtool --set-eee eth1 advertise 0xffffffff
>  # ethtool --show-eee eth1
>  EEE Settings for eth1:
>         EEE status: disabled
>         Tx LPI: disabled
>         Supported EEE link modes:  100baseT/Full
>                                    1000baseT/Full
>                                    10000baseT/Full
>         Advertised EEE link modes:  100baseT/Full
>                                     1000baseT/Full
>                                     1000baseKX/Full
>                                     10000baseT/Full
>                                     10000baseKX4/Full
>                                     10000baseKR/Full
> 
> Clearly, this is not sane, we should only allow link modes that are
> supported to be advertised (as we do elsewhere.)  Ensure that we mask
> the MDIO_AN_EEE_ADV value with the capabilities retrieved from the
> MDIO_PCS_EEE_ABLE register.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
