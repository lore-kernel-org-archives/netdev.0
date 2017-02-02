From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 1 Feb 2017 18:56:46 -0800
Message-ID: <608636cb-2281-0fa0-41a3-d4f882c57aad@gmail.com>
References: <20170201102208.GM27312@n2100.armlinux.org.uk>
 <20170201105121.GA8191@n2100.armlinux.org.uk>
 <264c73a7-8294-23f0-88e9-1f27d558cbf8@gmail.com>
 <20170201.135938.186383946169055237.davem@davemloft.net>
 <20170201191024.GQ27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, maowenan@huawei.com
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34604 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdBBC4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:56:49 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so400950pgj.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 18:56:49 -0800 (PST)
In-Reply-To: <20170201191024.GQ27312@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2017 11:10 AM, Russell King - ARM Linux wrote:
> On Wed, Feb 01, 2017 at 01:59:38PM -0500, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Wed, 1 Feb 2017 10:55:46 -0800
>>
>>> You are right, but there is still a fundamental problem IMHO in that you
>>> should not be able to rmmod a PHY driver as long as a network device is
>>> attached to the PHY, and if the PHY driver is attached from several
>>> different network devices, they should all have a way to prevent a PHY
>>> driver rmmod, each of them incrementing the driver refcount, which is
>>> what the patche from Maowan does here.
>>
>> It briefly occurred to me that we might want to be able to disconnect
>> PHYs to allow an unload using notifiers, the same way that when you
>> take a netdevice down we emit notifiers so that all of the references
>> to the netdevice can release themselves.
>>
>> I have no idea how well that would work, or whether it is valuable or
>> not.  But it is another way to handle this.
>>
>> But that is a longer-term thing even if we want to go that way, and
>> thus grabbing the proper refs is the right things to do for now.
> 
> It's something I'm effectively already doing as part of my phylink
> project for SFP support, since you can hot-unplug a copper SFP
> module, and the PHY on the copper SFP module will be gone.  phylink,
> however, sits between the network driver and phylib, which isn't
> ideal.

So, for the "net" tree what should we do? I don't really think that we
should be able to let the PHY state machine run without a PHY driver
bound to the device, at best nothing happens, at worse, we just crash
and burn without further chance of recovering.
-- 
Florian
