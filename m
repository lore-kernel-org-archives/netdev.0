From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 16:51:10 +0200
Message-ID: <4832E55E.2030009@trash.net>
References: <4832E223.7020206@trash.net> <20080520144822.GR28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Warasin <peter@endian.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763921AbYETOvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 10:51:12 -0400
In-Reply-To: <20080520144822.GR28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Patrick McHardy wrote:
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index b11e6e1..3be4559 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -514,10 +514,11 @@ struct net_device
>>  #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
>>  #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
>>  #define NETIF_F_LRO		32768	/* large receive offload */
>> +#define NETIF_F_VLAN_TSO	65536	/* Supports TSO for VLANs */
>>
>>  	/* Segmentation offload features */
>> -#define NETIF_F_GSO_SHIFT	16
>> -#define NETIF_F_GSO_MASK	0xffff0000
>> +#define NETIF_F_GSO_SHIFT	20
>> +#define NETIF_F_GSO_MASK	0xfff00000
> 
> I really don't think it's a good idea to move around existing flags.  How
> about stealing some of the unused high-order bits of NETIF_F_GSO_MASK
> instead?


Mhh it doesn't really belong there. Whats the problem with
moving these bits? They are only used internally (and use
up too much space anyway).

