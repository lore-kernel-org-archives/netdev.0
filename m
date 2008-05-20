From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 08:46:40 -0700
Message-ID: <4832F260.5000104@candelatech.com>
References: <4832E223.7020206@trash.net> <20080520144822.GR28241@solarflare.com> <4832E55E.2030009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Peter Warasin <peter@endian.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:59401 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755718AbYETPqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 11:46:49 -0400
In-Reply-To: <4832E55E.2030009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Ben Hutchings wrote:
>> Patrick McHardy wrote:
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index b11e6e1..3be4559 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -514,10 +514,11 @@ struct net_device
>>>  #define NETIF_F_NETNS_LOCAL    8192    /* Does not change network 
>>> namespaces */
>>>  #define NETIF_F_MULTI_QUEUE    16384    /* Has multiple TX/RX 
>>> queues */
>>>  #define NETIF_F_LRO        32768    /* large receive offload */
>>> +#define NETIF_F_VLAN_TSO    65536    /* Supports TSO for VLANs */
>>>
>>>      /* Segmentation offload features */
>>> -#define NETIF_F_GSO_SHIFT    16
>>> -#define NETIF_F_GSO_MASK    0xffff0000
>>> +#define NETIF_F_GSO_SHIFT    20
>>> +#define NETIF_F_GSO_MASK    0xfff00000
>>
>> I really don't think it's a good idea to move around existing flags.  
>> How
>> about stealing some of the unused high-order bits of NETIF_F_GSO_MASK
>> instead?
>
>
> Mhh it doesn't really belong there. Whats the problem with
> moving these bits? They are only used internally (and use
> up too much space anyway).
I've been running with it shifted to 24 on 2.6.25 with no problems.   If 
no one else objects, I'd prefer it shifted all the way
to 24 to make room for more flags w/out additional changes in the 
shiftage later...

Thanks,
Ben

>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


