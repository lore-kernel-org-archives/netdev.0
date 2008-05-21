From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Wed, 21 May 2008 18:28:26 +0200
Message-ID: <48344DAA.4060107@trash.net>
References: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45698 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759531AbYEUQ23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 12:28:29 -0400
In-Reply-To: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index b11e6e1..3be4559 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -514,10 +514,11 @@ struct net_device
>> #define NETIF_F_NETNS_LOCAL    8192    /* Does not change network namespaces */
>> #define NETIF_F_MULTI_QUEUE    16384   /* Has multiple TX/RX queues */
>> #define NETIF_F_LRO            32768   /* large receive offload */
>> +#define NETIF_F_VLAN_TSO       65536   /* Supports TSO for VLANs */
> 
> This has the potential to get pretty messy.  How about making a
> driver call back that the VLAN layer can invoke to get the supported
> feature bits for the VLAN device?
> 
> You have to modify the driver to set the bit anyway so could as well
> add a function instead of a bit.


I thought about this myself, my second idea was to add a
mask for feature bits to be propagated. Unless there is a
need for the driver to determine them at runtime, thats
slightly simpler. The driver would do:

dev->vlan_features = NETIF_F_CSUM_ALL | ...

What do you think about this?
