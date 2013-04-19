From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v4 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Fri, 19 Apr 2013 16:55:07 +0100
Message-ID: <517168DB.4050705@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>  <1366384215-21441-1-git-send-email-jim_baxter@mentor.com> <1366385398.16391.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:39137 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756471Ab3DSPzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 11:55:12 -0400
In-Reply-To: <1366385398.16391.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/13 16:29, Eric Dumazet wrote:
> On Fri, 2013-04-19 at 16:10 +0100, Jim Baxter wrote:
>>  
>> +static int
>> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
>> +{
>> +	/* Only run for packets requiring a checksum. */
>> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
>> +		return 0;
>> +
>> +	if (unlikely(skb_cow_head(skb, 0)))
>> +		return -1;
>> +
>> +	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
>> +
>> +	return 0;
>> +}
> 
> 
>  
>> +	/* HW acceleration for ICMP TCP UDP checksum */
>> +	if (fec_enet_clear_csum(skb, ndev))
>> +		return NETDEV_TX_BUSY;
> 
> No : You must drop the packet and return NETDEV_TX_OK
> 
> 
> 

I have no issue with changing it, but I am curious, by returning OK will
the kernel not regard it a sent packet and it will be lost?

Thank you,
Jim
