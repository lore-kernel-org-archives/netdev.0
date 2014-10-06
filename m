From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: macvlan: optimizing the receive path?
Date: Mon, 06 Oct 2014 09:04:45 -0400
Message-ID: <5432936D.7010906@gmail.com>
References: <542DB55D.3090601@akamai.com> <20141004.204203.2211720828886085354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>, jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:45271 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaJFNEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 09:04:48 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so3367304qaq.24
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 06:04:47 -0700 (PDT)
In-Reply-To: <20141004.204203.2211720828886085354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2014 08:42 PM, David Miller wrote:
> From: Jason Baron <jbaron@akamai.com>
> Date: Thu, 02 Oct 2014 16:28:13 -0400
> 
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -321,8 +321,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>>         skb->dev = dev;
>>         skb->pkt_type = PACKET_HOST;
>>  
>> -       ret = netif_rx(skb);
>> -
>> +      macvlan_count_rx(vlan, len, true, 0);
>> +      return RX_HANDLER_ANOTHER;
>>  out:
>>         macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
>>         return RX_HANDLER_CONSUMED;
> 
> That last argument to macvlan_count_rx() is a bool and thus should be
> specified as "false".  Yes I know other areas of this file get it
> wrong too.
> 
> Also, what about GRO?  Won't we get GRO processing if we do this via
> netif_rx() but not via the RX_HANDLER_ANOTHER route?  Just curious...

Wouldn't GRO already happen at the lower level?  For macvlan-to-macvlan,
you'd typically have large packets so no need for GRO.

-vlad
