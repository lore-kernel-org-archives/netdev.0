From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 01 Feb 2017 13:59:38 -0500 (EST)
Message-ID: <20170201.135938.186383946169055237.davem@davemloft.net>
References: <20170201102208.GM27312@n2100.armlinux.org.uk>
        <20170201105121.GA8191@n2100.armlinux.org.uk>
        <264c73a7-8294-23f0-88e9-1f27d558cbf8@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@armlinux.org.uk, netdev@vger.kernel.org, andrew@lunn.ch,
        maowenan@huawei.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44474 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdBAS7p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 13:59:45 -0500
In-Reply-To: <264c73a7-8294-23f0-88e9-1f27d558cbf8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 1 Feb 2017 10:55:46 -0800

> You are right, but there is still a fundamental problem IMHO in that you
> should not be able to rmmod a PHY driver as long as a network device is
> attached to the PHY, and if the PHY driver is attached from several
> different network devices, they should all have a way to prevent a PHY
> driver rmmod, each of them incrementing the driver refcount, which is
> what the patche from Maowan does here.

It briefly occurred to me that we might want to be able to disconnect
PHYs to allow an unload using notifiers, the same way that when you
take a netdevice down we emit notifiers so that all of the references
to the netdevice can release themselves.

I have no idea how well that would work, or whether it is valuable or
not.  But it is another way to handle this.

But that is a longer-term thing even if we want to go that way, and
thus grabbing the proper refs is the right things to do for now.
