From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sun, 24 Aug 2014 12:11:28 -0700 (PDT)
Message-ID: <20140824.121128.714017644535675858.davem@davemloft.net>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<20140823.213839.1953243016141233125.davem@davemloft.net>
	<1408901868.5604.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbaHXTL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 15:11:29 -0400
In-Reply-To: <1408901868.5604.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 24 Aug 2014 10:37:48 -0700

> On Sat, 2014-08-23 at 21:38 -0700, David Miller wrote:
> 
>> Like Tom Herbert has mentioned we have all the infrastructure (sort
>> of) already to handle a list of SKBs going down into
>> dev_hard_start_xmit() via the GSO handling.
>> 
>> But that code is funny, because it keeps the original GSO head SKB
>> around as a placeholder to maintain the list of segmented SKBs.
> 
> This is because dev_hard_start_xmit() do not return an skb, but a rc
> code.
> 
> int ret = dev_hard_start_xmit(skb, dev, txq);
> 
> That can be changed so that we do not have to keep the original skb as
> the GSO head :
> 
> sch_direct_xmit() would 'requeue' the new skb (might be in the middle of
> the skb segmented chain), not the original one.
> 
> This would get rid of DEV_GSO_CB() presumably.

I considered this, but then there is the ugly issue of how to return
the netdev_tx_t code back into the call chain.

I hate passing things back by reference, it's always a symptom of bad
interface design :-/
