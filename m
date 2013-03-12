From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/core: move vlan_depth out of while loop
 in skb_network_protocol()
Date: Tue, 12 Mar 2013 11:47:55 -0400 (EDT)
Message-ID: <20130312.114755.1294836047203725026.davem@davemloft.net>
References: <1363069844-10624-1-git-send-email-roy.qing.li@gmail.com>
	<1363071386.13690.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org, pshelar@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755475Ab3CLPrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:47:45 -0400
In-Reply-To: <1363071386.13690.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Mar 2013 07:56:26 +0100

> On Tue, 2013-03-12 at 14:30 +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>> 
>> move vlan_depth out of while loop, or else vlan_depth always is ETH_HLEN,
>> can not be increased, and lead to infinite loop when frame has two vlan headers.
>> 
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  net/core/dev.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 90cee5b..35a6a6e 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2211,9 +2211,9 @@ EXPORT_SYMBOL(skb_checksum_help);
>>  __be16 skb_network_protocol(struct sk_buff *skb)
>>  {
>>  	__be16 type = skb->protocol;
>> +	int vlan_depth = ETH_HLEN;
>>  
>>  	while (type == htons(ETH_P_8021Q)) {
>> -		int vlan_depth = ETH_HLEN;
>>  		struct vlan_hdr *vh;
>>  
>>  		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
> 
> Nice catch, bug added in commit 05e8ef4ab2d8087d (net: factor out
> skb_mac_gso_segment() from skb_gso_segment() )
> 
> So this is a patch for net tree, not for net-next.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
