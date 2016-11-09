From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Wed, 9 Nov 2016 09:55:06 -0800
Message-ID: <485d2b33-3f86-d41a-e01b-d6d434a386b6@gmail.com>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
 <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
 <5820AC1D.4040408@codeaurora.org> <582238F3.30906@codeaurora.org>
 <26a8fde2-6403-b14e-a163-c3a1b6afeb4d@gmail.com>
 <58235E0A.2030305@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34602 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754305AbcKIRzJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 12:55:09 -0500
Received: by mail-pf0-f178.google.com with SMTP id n85so130283169pfi.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 09:55:08 -0800 (PST)
In-Reply-To: <58235E0A.2030305@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2016 09:34 AM, Timur Tabi wrote:
> On 11/09/2016 11:06 AM, Florian Fainelli wrote:
> 
>>> 1) PHY drivers and/or phylib sets the SUPPORTED_Pause |
>>> SUPPORTED_AsymPause bits in phydev->supported.  This indicates that the
>>> PHY supports pause frames.
>>
>> Agreed.
> 
> So I'm still not sure *where* phylib should set the bits in
> phydev->supported.  I previously thought that phy_sanitize_settings()
> would be a candidate, but that function is called only when
> autonegotiation is disabled.
> 
> So the only thing I can think of is to do this:
> 
> /* A mapping of all SUPPORTED settings to speed/duplex */
> static const struct phy_setting settings[] = {
>     {
>         .speed = SPEED_10000,
>         .duplex = DUPLEX_FULL,
> -        .setting = SUPPORTED_10000baseKR_Full,
> +        .setting = SUPPORTED_10000baseKR_Full |
> +            SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> 
> ... for all of the entries in settings[]
> 
> But this seems excessive, and I don't know if all of these SPEED_xxx
> standards actually support pause frames.

You could set these bits in phy_probe() and later let the
phy_sanitize_settings() make sure that these bits do not get advertised
unless we have a full duplex link.

> 
>>> >3) When the link state changes, the MAC driver checks
>>> >phydev->advertising, and if the bits are set, then it enables those
>>> >features in the MAC.
> 
>> Almost, we need to see what the link partner advertised, by looking at
>> phydev->pause / phydev->asym_pause and checking the local knobs whether
>> flow control can be enabled, but other than that, this looks correct
>> to me.
> 
> Yes, that's what I meant to write.  Fortunately, my EMAC driver already
> does this.

OK, just making sure ;)
-- 
Florian
