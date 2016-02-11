From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/3] lan78xx: setting phy features in phy driver
Date: Wed, 10 Feb 2016 20:05:47 -0800
Message-ID: <56BC089B.6090309@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D404AB9F9@CHN-SV-EXMX02.mchp-main.com>
 <56BBC0BB.3010100@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D404ABB4D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:35272 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbcBKEFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 23:05:50 -0500
Received: by mail-ob0-f193.google.com with SMTP id il1so4256367obb.2
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 20:05:50 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404ABB4D@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/02/2016 15:18, Woojung.Huh@microchip.com wrote:
>>> +static int lan88xx_config_init(struct phy_device *phydev)
>>> +{
>>> +	phydev->supported &= phydev->drv->features;
>>> +	phydev->advertising &= phydev->drv->features;
>>
>> This looks suspicious, phy_probe() takes the driver supported features
>> and assigns it to phydev->supported, and phydev->advertising, is not
>> that working somehow?
>>
>> genphy_config_init() does look at the current MII_BMRS value to
>> determine what is supported by the PHY, and masks it in
>> phydev->supported, so that could indeed be an issue if we had not had a
>> change to mask with the supported modes before.
>>
>> I think we need more explanation here as to what kind of bug you may
>> have been observing, there could be one.
> 
> SUPPORTED_Pause & SUPPORTED_Asym_Pause set at phydev->features  are removed by genphy_config_init().
> As you pointed, it may be better to modify genphy_config_init() than each driver's config_init routine.

I see, that is definitively a bug, we should not clear these bits if the
Ethernet MAC driver asked for them.
