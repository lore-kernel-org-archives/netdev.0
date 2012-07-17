From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: refine early skb orphaning
Date: Mon, 16 Jul 2012 23:08:55 -0700 (PDT)
Message-ID: <20120716.230855.968922272409923316.davem@davemloft.net>
References: <1342271787.3265.9632.camel@edumazet-glaptop>
	<20120714145333.2c441166@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hagen@jauu.net,
	msg@google.com, aterzis@google.com, ycheng@google.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab2GQGI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:08:56 -0400
In-Reply-To: <20120714145333.2c441166@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 14 Jul 2012 14:53:33 -0700

> On Sat, 14 Jul 2012 15:16:27 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> netem does an early orphaning of skbs. Doing so breaks TCP Small Queue
>> or any mechanism relying on socket sk_wmem_alloc feedback.
>> 
>> Ideally, we should perform this orphaning after the rate module and
>> before the delay module, to mimic what happens on a real link :
>> 
>> skb orphaning is indeed normally done at TX completion, before the
>> transit on the link.
>> 
>> +-------+   +--------+  +---------------+  +-----------------+
>> + Qdisc +---> Device +--> TX completion +--> links / hops    +->
>> +       +   +  xmit  +  + skb orphaning +  + propagation     +
>> +-------+   +--------+  +---------------+  +-----------------+
>>       < rate limiting >                  < delay, drops, reorders >
>> 
>> If netem is used without delay feature (drops, reorders, rate
>> limiting), then we should avoid early skb orphaning, to keep pressure
>> on sockets as long as packets are still in qdisc queue.
>> 
>> Ideally, netem should be refactored to implement delay module
>> as the last stage. Current algorithm merges the two phases
>> (rate limiting + delay) so its not correct.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
