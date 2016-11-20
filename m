From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v2] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Sun, 20 Nov 2016 09:32:26 -0800
Message-ID: <7af71256-7c94-3847-f50f-482ff26f7e45@gmail.com>
References: <1478821561-26498-1-git-send-email-timur@codeaurora.org>
 <cf18464c-e225-af5d-9251-f2553b93b9ff@gmail.com>
 <CAOZdJXX5j9EVB8UtJK7u4-q4yFFtPBdWnWhL5aO_gGvL7fLTUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34412 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbcKTRc2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 12:32:28 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so16759141pfb.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 09:32:28 -0800 (PST)
In-Reply-To: <CAOZdJXX5j9EVB8UtJK7u4-q4yFFtPBdWnWhL5aO_gGvL7fLTUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/20/2016 08:08 AM, Timur Tabi wrote:
> On Mon, Nov 14, 2016 at 12:35 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> if (!(drv->features & (SUPPORTED_Pause | SUPPORTED_AsymPause))
>>         phydev->supported |= SUPPORTED_Pause | SUPPORTED_AsymPause;
> 
> How about, if either bit is set in drv->features, then assume the phy
> driver really knows what it's doing, and just copy those bits to
> phydev->supported?

Yes, that seems completely reasonable to me. Thanks!

> 
> if (drv->features & (SUPPORTED_Pause | SUPPORTED_AsymPause)) {
>     phydev->supported &= ~(SUPPORTED_Pause | SUPPORTED_AsymPause);
>     phydev->supported |= drv->features & (SUPPORTED_Pause |
> SUPPORTED_AsymPause);
> } else
>     phydev->supported |= SUPPORTED_Pause | SUPPORTED_AsymPause;
> 

-- 
Florian
