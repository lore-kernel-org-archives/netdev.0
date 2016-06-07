From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: ipv4: Add ability to have GRE ignore DF bit
 in IPv4 payloads
Date: Wed, 8 Jun 2016 00:23:39 +0200
Message-ID: <11871c8f-3643-0b08-8187-5ed82e21aaa8@stressinduktion.org>
References: <20160607194846.11494-1-philipp@redfish-solutions.com>
 <1465331022.134529.630880921.787BED73@webmail.messagingengine.com>
 <575731A8.1040303@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: Philip Prindeville <philipp_subx@redfish-solutions.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33556 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932887AbcFGWXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:23:43 -0400
In-Reply-To: <575731A8.1040303@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.06.2016 22:42, Philip Prindeville wrote:
> On 06/07/2016 02:23 PM, Hannes Frederic Sowa wrote:
>>
>> On Tue, Jun 7, 2016, at 21:48, Philip Prindeville wrote:
>>>   static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
>>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>>> index d8f5e0a..95649eb 100644
>>> --- a/net/ipv4/ip_tunnel.c
>>> +++ b/net/ipv4/ip_tunnel.c
>>> @@ -682,7 +682,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct
>>> net_device *dev,
>>>       }
>>>         df = tnl_params->frag_off;
>>> -       if (skb->protocol == htons(ETH_P_IP))
>>> +       if (skb->protocol == htons(ETH_P_IP) && !tunnel->ignore_df)
>>>           df |= (inner_iph->frag_off&htons(IP_DF));
>>>         max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct
>>> iphdr)
>> Is still enforce that we inherit the ttl from the inner header to the
>> outer header if we don't set df bit?
>>
>> Thanks,
>> Hannes
> 
> That's correct.  That happens a few lines above and we don't change that
> behavior with this patch.

It should be discouraged to use this feature, but I have to admit that I
already used stripping of DF bit, too.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
