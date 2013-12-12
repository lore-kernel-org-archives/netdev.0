From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: fix gso_prefix check
Date: Thu, 12 Dec 2013 15:48:15 -0500 (EST)
Message-ID: <20131212.154815.2086817276719433173.davem@davemloft.net>
References: <1386858013-20544-1-git-send-email-paul.durrant@citrix.com>
	<1386859342.18946.18.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.durrant@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, wei.liu2@citrix.com,
	david.vrabel@citrix.com
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957Ab3LLUsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 15:48:18 -0500
In-Reply-To: <1386859342.18946.18.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 12 Dec 2013 14:42:22 +0000

> On Thu, 2013-12-12 at 14:20 +0000, Paul Durrant wrote:
>> There is a mistake in checking the gso_prefix mask when passing large
>> packets to a guest. The wrong shift is applied to the bit - the raw skb
>> gso type is used rather then the translated one. This leads to large packets
>> being handed to the guest without the GSO metadata. This patch fixes the
>> check.
>> 
>> The mistake manifested as errors whilst running Microsoft HCK large packet
>> offload tests between a pair of Windows 8 VMs. I have verified this patch
>> fixes those errors.
>> 
>> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
>> Cc: Wei Liu <wei.liu2@citrix.com>
>> Cc: Ian Campbell <ian.campbell@citrix.com>
>> Cc: David Vrabel <david.vrabel@citrix.com>
>> ---
>>  drivers/net/xen-netback/netback.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index 56c3e5a..999e290 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -452,7 +452,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>>  	}
>>  
>>  	/* Set up a GSO prefix descriptor, if necessary */
>> -	if ((1 << skb_shinfo(skb)->gso_type) & vif->gso_prefix_mask) {
>> +	if ((1 << gso_type) & vif->gso_prefix_mask) {
> 
> gso_type here is XEN_NETIF_GSO_TYPE_TCPV4, vif->gso_prefix_mask is
> initialised with GSO_BIT(TCPV4) et al. Where
>         #define GSO_BIT(type) \
>                 (1 << XEN_NETIF_GSO_TYPE_ ## type)
>         
> So, 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied and queued up for -stable, thanks.
