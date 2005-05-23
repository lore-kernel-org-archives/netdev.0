From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet
 Bridging: Enable Hardware Checksumming)
Date: Mon, 23 May 2005 12:39:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505231235550.20838@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
 <20050519214015.GA19961@us.ibm.com> <Pine.LNX.4.62.0505200858480.12681@webhosting.rdsbv.ro>
 <200505201354.46824.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200505201354.46824.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>> +/*
>>>> + * Recomputes features using slave's features
>>>> + */
>>>> +static void br_features_recompute(struct net_bridge *br)
>>>> +{
>>>> +	struct net_bridge_port *p;
>>>> +
>>>> +	br->dev->features |= BR_FEAT_MASK;
>>>
>>> The OR is not needed.  Just re-initialize features to BR_FEAT_MASK and
>>> everything will take case of itself.
>>
>> Nope. Not correct. Because we might enable LLTX on the bridge, but not in
>> BR_FEAT_MASK.
>
> This is not the case.  This is the same as re-doing the entire feature list
> (as if it was being done initially).  All that needs to be done is for
> br->dev->features to have a initial value.
>
>> I will post a patch in few hours with all stuff updated.
>
> Great.  Thanks.
>
> Thanks,
> Jon

I will post a patch with the initial features as:

dev->features = BR_FEAT_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX

at Stephen's suggestion.

But, BR_FEAT_MASK will not have NETIF_F_NO_CSUM and NETIF_F_LLTX.

I think the code is correct as it is.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
