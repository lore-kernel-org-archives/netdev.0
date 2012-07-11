From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Wed, 11 Jul 2012 01:19:12 -0700 (PDT)
Message-ID: <20120711.011912.2063611962030549397.davem@davemloft.net>
References: <1341922569-4118-4-git-send-email-ogerlitz@mellanox.com>
	<1341923180.3265.5005.camel@edumazet-glaptop>
	<4FFD33B8.5010604@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com, erezsh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab2GKITP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:19:15 -0400
In-Reply-To: <4FFD33B8.5010604@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 11 Jul 2012 11:05:12 +0300

> On 7/10/2012 3:26 PM, Eric Dumazet wrote:
>> On Tue, 2012-07-10 at 15:16 +0300, Or Gerlitz wrote:
>>> The IPoIB code checks the VIF private flag on the RX path, and
>>> accoriding
>>> to the value of the flag prepares the skb CB data, etc.
>>>
>>
>> skb->cb[] can be destroyed in netif_receive_skb() /
>> __netif_receive_skb()
>>
>> #ifdef CONFIG_NET_CLS_ACT
>> 	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
>> 	...
>> #endif
> 
> Eric,
> 
> Can you elaborate a little further? we're not sure to see where
> skb->cb[] is touched on the flow
> you pointed to.

handle_ing() goes into the packet scheduler and qdisc layer,
the qdisc layer uses skb->cb[] via struct qdisc_skb_cb.
