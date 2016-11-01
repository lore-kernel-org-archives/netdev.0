From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Tue, 1 Nov 2016 12:03:57 -0700
Message-ID: <be1c80d3-654a-65c8-3c5b-9a7bfbf8817d@gmail.com>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
 <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
 <5818E2B0.80902@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33775 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbcKATEA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 15:04:00 -0400
Received: by mail-pf0-f173.google.com with SMTP id d2so24672152pfd.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 12:03:59 -0700 (PDT)
In-Reply-To: <5818E2B0.80902@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 11:45 AM, Timur Tabi wrote:
> Florian Fainelli wrote:
>> So in premise, this is good, and is exactly what I have in mind for the
>> series that I am cooking, but if we apply this alone, without a change
>> in drivers/net/phy/phy.c which adds SUPPORTED_Pause |
>> SUPPORTED_AsymPause to phydev->features, we are basically breaking the
>> Ethernet MAC drivers that don't explicitly override phydev->features and
>> yet rely on that to get flow control to work.
> 
> That's what I figured, but I wasn't sure how to handle that.  However,
> isn't the ability to pass pause frames a feature that some PHYs do not
> have?  That is, does every PHY support bits 10 and 11 in register 4?
> 

The standard (IEEE Std 802.3-2008) describes this as the
Auto-negotiation advertisement register and these bits are part of the
Technology ability field register. These two bits A5 (PAUSE operation
for full duplex links) and A6 (Asymetric PAUSE operation for full duplex
links) have no cabling requirement, and earlier the paragraph mentions
this is to be resolved by the "management" entity, so I don't think the
PHY has any business in that other than reflecting what the MAC is
capable of doing towards the link partner, but I could be reading the
specification incorrectly.
