From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Wed, 9 Nov 2016 09:06:09 -0800
Message-ID: <26a8fde2-6403-b14e-a163-c3a1b6afeb4d@gmail.com>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
 <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
 <5820AC1D.4040408@codeaurora.org> <582238F3.30906@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36472 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752429AbcKIRGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 12:06:11 -0500
Received: by mail-pf0-f195.google.com with SMTP id n85so910038pfi.3
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 09:06:11 -0800 (PST)
In-Reply-To: <582238F3.30906@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2016 12:43 PM, Timur Tabi wrote:
> On 11/07/2016 10:30 AM, Timur Tabi wrote:
>>
>> I'm still don't understand 100% how these flags really work, because I
>> just can't shake the feeling that they should not be set for every phy.
>>   If these flags are supposed to be turned on universally, then why are
>> they even an option?
> 
> So I've been giving this more thought.  Can you tell me if the following
> is correct:
> 
> 1) PHY drivers and/or phylib sets the SUPPORTED_Pause |
> SUPPORTED_AsymPause bits in phydev->supported.  This indicates that the
> PHY supports pause frames.

Agreed.

> 
> 2) The MAC driver checks phydev->supported before it calls phy_start().
>  If (SUPPORTED_Pause | SUPPORTED_AsymPause) is set, then it sets those
> bits in phydev->advertising if it wants to enable pause frame support.

Also correct.

> 
> 3) When the link state changes, the MAC driver checks
> phydev->advertising, and if the bits are set, then it enables those
> features in the MAC.

Almost, we need to see what the link partner advertised, by looking at
phydev->pause / phydev->asym_pause and checking the local knobs whether
flow control can be enabled, but other than that, this looks correct to me.
-- 
Florian
