From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet
 Bridging: Enable Hardware Checksumming)
Date: Fri, 20 May 2005 09:07:46 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505200858480.12681@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
 <20050519214015.GA19961@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <20050519214015.GA19961@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>> +static inline void br_features_change(struct net_bridge *br, struct net_device *dev)
>> +{
>> +	br->dev->features &= dev->features | ~BR_FEAT_MASK;
>
> ~BR_FEAT_MASK isn't necessary. Either you wanted to do an '&' just
> before it, so that BR_FEAT_MASK features are the only ones that you want
> or you are enabling features that aren't necessarily supported by the
> adapter/driver (like LLTX and HW_VLAN stuff).

So, I invert BR_FEAT_MASK so I can, by default clear special features.
Then I ored with dev->features, so I can enable special features if the 
slave device supports it. Then, I do & so I can clear stuff that is not 
supported by device, but the rest of br->dev features remains untouched.

Let's test: if dev hash SG the code is like this:
BR_FEAT_MASK = 1001 (only test SG and HW_CSUM)
# br is inited
br |= 1001
br &= 0001 | ~1001
br &= 0001 | 0110
br &= 0111
br = 1001 & 0111 = 0001 - so bit SG is set also in br. But not HW_CSUM 
because it's not in device.

I can't see the code is wrong. Can you give me an example when it fails, 
please?

>> +}
>> +
>> +/*
>> + * Recomputes features using slave's features
>> + */
>> +static void br_features_recompute(struct net_bridge *br)
>> +{
>> +	struct net_bridge_port *p;
>> +
>> +	br->dev->features |= BR_FEAT_MASK;
>
> The OR is not needed.  Just re-initialize features to BR_FEAT_MASK and
> everything will take case of itself.

Nope. Not correct. Because we might enable LLTX on the bridge, but not in 
BR_FEAT_MASK.
I will post a patch in few hours with all stuff updated.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
