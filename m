From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 13:46:50 -0700 (PDT)
Message-ID: <20140827.134650.1202884223919773168.davem@davemloft.net>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<1409142672.26515.24.camel@localhost>
	<1409145838.3173.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964892AbaH0Uqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:46:51 -0400
In-Reply-To: <1409145838.3173.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Aug 2014 06:23:58 -0700

> On Wed, 2014-08-27 at 14:31 +0200, Hannes Frederic Sowa wrote:
> 
>> One thing one should keep in mind is, that there must be a skb available
>> to trigger the flush, maybe this will hurt us one day.
>> 
>> Thinking more about it should we go with a coccinelle script and
>> replace/extend ndo_start_xmit with an additional argument?
> 
> This will be a pain for backports and things like that.

Agreed.

> skb->xmit_more is a bit annoying, because it consumes one bit in all
> skbs, while it could be one byte per cpu as ndo_start_xmit() is called
> while BH are disabled.
> 
> It also forces a cache line dirtying, that will hurt qdisc like HTB
> where skbs can be cooked/enqueued by remote cpus.

The xmit_more value sits in the same cache line as the queue number,
which also gets dirtied in the TX fast path.
