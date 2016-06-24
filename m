From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Decrement phy_fixed_addr during unregister
Date: Fri, 24 Jun 2016 15:58:39 -0700
Message-ID: <576DBB1F.1030208@gmail.com>
References: <1466808251-19588-1-git-send-email-f.fainelli@gmail.com>
 <20160624225527.GA1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35177 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFXW6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 18:58:41 -0400
Received: by mail-pf0-f195.google.com with SMTP id t190so10342678pfb.2
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:58:41 -0700 (PDT)
In-Reply-To: <20160624225527.GA1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2016 03:55 PM, Russell King - ARM Linux wrote:
> On Fri, Jun 24, 2016 at 03:44:11PM -0700, Florian Fainelli wrote:
>> If we have a system which uses fixed PHY devices and calls
>> fixed_phy_register() then fixed_phy_unregister() we can exhaust the
>> number of fixed PHYs available after a while, since we keep incrementing
>> the variable phy_fixed_addr, but we never decrement it.
>>
>> This patch fixes that by decrementing phy_fixed_addr during
>> fixed_phy_del(), and in order to do that, we need to move the
>> phy_fixed_addr integer and its spinlock above that function.
> 
> Is this really a good idea?

In the sense that it is symetrical to the register code, probably.

> 
> What if we have two fixed phys register, and the first one is
> unregistered and a new one subsequently registered?
> 
> First phy registered, gets address 0, phy_fixed_addr becomes 1.
> Second phy registered, gets address 1, phy_fixed_addr becomes 2.
> First phy is unregistered, phy_fixed_addr becomes 1.
> Third phy registered, gets address 1, conflicts with the second phy.
> 
> Obviously not a good outcome.
>

What would you suggest we do instead? Would switching to IDA/IDR give us
better results for instance (I have not looked too closely yet)?
-- 
Florian
