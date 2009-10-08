From: Thomas Chou <thomas@wytron.com.tw>
Subject: Re: [PATCH 3/4] ethoc: align received packet to make IP header at
  word boundary
Date: Thu, 08 Oct 2009 10:42:22 +0800
Message-ID: <4ACD518E.7040707@wytron.com.tw>
References: <1254735200-2718-2-git-send-email-thomas@wytron.com.tw>	<1254735200-2718-3-git-send-email-thomas@wytron.com.tw>	<20091007091337.532d9ed1@nehalam> <20091007.135217.73491149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr9.hinet.net ([168.95.4.109]:33328 "EHLO msr9.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254AbZJHCmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 22:42:08 -0400
In-Reply-To: <20091007.135217.73491149.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2009 04:52 AM, David Miller wrote:
> From: Stephen Hemminger<shemminger@vyatta.com>
> Date: Wed, 7 Oct 2009 09:13:37 -0700
>
>> On Mon,  5 Oct 2009 17:33:19 +0800
>> Thomas Chou<thomas@wytron.com.tw>  wrote:
>>
>>> diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
>>> index f92747f..0c6c7f4 100644
>>> --- a/drivers/net/ethoc.c
>>> +++ b/drivers/net/ethoc.c
>>> @@ -399,6 +399,10 @@ static int ethoc_rx(struct net_device *dev, int limit)
>>>   		if (ethoc_update_rx_stats(priv,&bd) == 0) {
>>>   			int size = bd.stat>>  16;
>>>   			struct sk_buff *skb = netdev_alloc_skb(dev, size);
>>> +
>>> +			size -= 4; /* strip the CRC */
>>> +			skb_reserve(skb, 2); /* align TCP/IP header */
>>
>> Please use NET_IP_ALIGN rather than hard coding 2 so that the value
>> can be changed on a per-cpu architecture basis if desired.
>
> Indeed.
>
> Thomas please send a patch to fix this up, thanks.
>
>
Submitted. Thanks.

- Thomas
