From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH net-next] net: ipv4: Add ability to have GRE ignore DF bit
 in IPv4 payloads
Date: Tue, 7 Jun 2016 14:42:16 -0600
Message-ID: <575731A8.1040303@redfish-solutions.com>
References: <20160607194846.11494-1-philipp@redfish-solutions.com>
 <1465331022.134529.630880921.787BED73@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:54896 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756598AbcFGUmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 16:42:25 -0400
In-Reply-To: <1465331022.134529.630880921.787BED73@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2016 02:23 PM, Hannes Frederic Sowa wrote:
>
> On Tue, Jun 7, 2016, at 21:48, Philip Prindeville wrote:
>>   static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>> index d8f5e0a..95649eb 100644
>> --- a/net/ipv4/ip_tunnel.c
>> +++ b/net/ipv4/ip_tunnel.c
>> @@ -682,7 +682,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct
>> net_device *dev,
>>   	}
>>   
>>   	df = tnl_params->frag_off;
>> -       if (skb->protocol == htons(ETH_P_IP))
>> +       if (skb->protocol == htons(ETH_P_IP) && !tunnel->ignore_df)
>>   		df |= (inner_iph->frag_off&htons(IP_DF));
>>   
>>   	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
> Is still enforce that we inherit the ttl from the inner header to the
> outer header if we don't set df bit?
>
> Thanks,
> Hannes

That's correct.  That happens a few lines above and we don't change that 
behavior with this patch.

-Philip
