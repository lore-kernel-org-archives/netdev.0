From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver
 for Microsemi PHYs.
Date: Thu, 6 Oct 2016 03:57:32 -0700
Message-ID: <965514c2-8219-435a-e32f-114c361ff55b@gmail.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928202451.GC30728@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Allan.Nielsen@microsemi.com
To: Andrew Lunn <andrew@lunn.ch>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36438 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbcJFK5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 06:57:40 -0400
Received: by mail-pf0-f193.google.com with SMTP id n24so992582pfb.3
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 03:57:39 -0700 (PDT)
In-Reply-To: <20160928202451.GC30728@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2016 01:24 PM, Andrew Lunn wrote:
>>  static int vsc85xx_wol_set(struct phy_device *phydev,
>>  			   struct ethtool_wolinfo *wol)
>>  {
>> @@ -227,6 +281,7 @@ static int vsc85xx_default_config(struct phy_device *phydev)
>>  	int rc;
>>  	u16 reg_val;
>>  
>> +	phydev->mdix = ETH_TP_MDI_AUTO;
> 
> Humm, interesting. The only other driver supporting mdix is the
> Marvell one. It does not do this, it leaves it to its default value of
> ETH_TP_MDI_INVALID. It does however interpret ETH_TP_MDI_INVALID as
> meaning as ETH_TP_MDI_AUTO.
> 
> There needs to be consistency here. You either need to do the same as
> the Marvell driver, or you need to modify the Marvell driver to also
> set phydev->mdix to ETH_TP_MDI_AUTO.
> 
> I don't yet know which of these two is the right thing to do.
> 
> Florian?

It's really hard to tell because the other drivers I looked at do not
necessarily seem to be consistent either. Here, if the MDI status is
really auto, then this is the correct value to return, if it is unknown,
it should be ETH_TP_MDI_INVALID.

For the Marvell PHY, it sounds like we should be able to determine what
was configured and return the correct MDI status value
-- 
Florian
