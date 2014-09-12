From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: nowait parameter.
Date: Fri, 12 Sep 2014 17:52:41 -0400 (EDT)
Message-ID: <20140912.175241.1635965281290152700.davem@davemloft.net>
References: <87oauxibda.fsf@rustcorp.com.au>
	<20140905.142618.2240630803375505977.davem@davemloft.net>
	<871trjjbd2.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, minipli@googlemail.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835AbaILVwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:52:43 -0400
In-Reply-To: <871trjjbd2.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 11 Sep 2014 09:07:29 +0930

> David Miller <davem@davemloft.net> writes:
>> From: Rusty Russell <rusty@rustcorp.com.au>
>> Date: Wed, 03 Sep 2014 13:50:01 +0930
>>
>> BTW, wrt. holding onto TX frames for unbounded amounts of time, I
>> think this is a bad idea even with skb_orphan().  There are resources
>> from the SKB you are hanging onto which can stall the removal of
>> modules indefinitely, such as netfilter references.
> 
> We could certainly have a once-a-second timer which did this, but should
> skb_orphan() do that work instead?

It would definitely improve the situation.

I've discussed a few times with Herbert Xu the idea of using hrtimers
since we have those, to do something more clever and timely.
