From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-netx] net: lan78xx: add LAN7801 MAC-only support
Date: Tue, 29 Nov 2016 15:57:08 -0800
Message-ID: <b0dea0b1-11d1-3d58-c055-41824eaf1d1f@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D4096E268@CHN-SV-EXMX02.mchp-main.com>
 <007d0bc0-378c-da93-d730-28f7b5b5073a@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D4096FC85@CHN-SV-EXMX02.mchp-main.com>
 <dcabc07f-ab5f-ad25-5beb-09f717c06e4e@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D409700F2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33210 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbcK2X5L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:57:11 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so17780097pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 15:57:11 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D409700F2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 03:55 PM, Woojung.Huh@microchip.com wrote:
>> There are two ways to get these settings propagated to the PHY driver:
>>
>> - using a board fixup which is going to be invoked during
>> drv->config_init() time
>>
>> - specifying a phydev->dev_flags and reading it from the PHY driver to
>> act upon and configure the PHY based on that value, there are only
>> 32-bits available though, and you need to make sure they are not
>> conflicting with other potential users in tree
>>
>> My preference would go with 1, since you could just register it in your
>> PHY driver and re-use the code you are proposing to include here.
> 
> Florian,
> 
> It seems phy_unregister_fixup() will be needed for module network driver.
> phy_fixup_list keeps the list even after unloading module.
> Do you know any update is waiting for submission? If not, I'll make patch.

Oh, yes, that's a good point, we need such a thing, so far fixups have
been exclusively used by code that is built-in, but there really is not
a reason for that. Please go ahead and cook a patch for this, thanks!
-- 
Florian
