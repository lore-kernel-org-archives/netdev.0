From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Keep a reference count on ethernet_dev
Date: Tue, 24 Jan 2017 12:39:11 -0500 (EST)
Message-ID: <20170124.123911.330293119907498159.davem@davemloft.net>
References: <20170121174055.27560-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdAXRjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:39:15 -0500
In-Reply-To: <20170121174055.27560-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 21 Jan 2017 09:40:54 -0800

> of_find_net_device_by_node() just returns a reference to a net_device but does
> not increment its reference count, which means that the master network device
> can just vanish under our feet.
> 
> Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

This is fine, except now this netdev is completely locked into place with
no way to dynamically unload it.

If someone tries to modunload the driver for this ethernet device,
their screen will fill up with warning messages indicating that the
reference taken here in the DSA code is not going away.

You need to implement a netdev notifier that tears down this DSA
instance during an unregister event and releases the ethernet_dev.
Similar to how we handle protocol addresses bound to a netdev, etc.
