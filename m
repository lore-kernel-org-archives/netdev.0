From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: dsa: Keep a reference count on ethernet_dev
Date: Tue, 24 Jan 2017 09:56:39 -0800
Message-ID: <fa49f56d-db4b-dd18-7fe7-930526514dbf@gmail.com>
References: <20170121174055.27560-1-f.fainelli@gmail.com>
 <20170124.123911.330293119907498159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124.123911.330293119907498159.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/24/2017 09:39 AM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sat, 21 Jan 2017 09:40:54 -0800
> 
>> of_find_net_device_by_node() just returns a reference to a net_device but does
>> not increment its reference count, which means that the master network device
>> can just vanish under our feet.
>>
>> Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> This is fine, except now this netdev is completely locked into place with
> no way to dynamically unload it.
> 
> If someone tries to modunload the driver for this ethernet device,
> their screen will fill up with warning messages indicating that the
> reference taken here in the DSA code is not going away.
> 
> You need to implement a netdev notifier that tears down this DSA
> instance during an unregister event and releases the ethernet_dev.
> Similar to how we handle protocol addresses bound to a netdev, etc.

OK, that was actually my original approach, and then while detaching the
switch from the network device seemed easy enough, re-attaching it could
be a little challenging. Let's try again.

Thanks!
-- 
Florian
