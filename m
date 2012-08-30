From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: remove pointless conditional before kfree_skb()
Date: Thu, 30 Aug 2012 13:39:28 -0400 (EDT)
Message-ID: <20120830.133928.1850319389901233806.davem@davemloft.net>
References: <1346184598.3571.16.camel@edumazet-glaptop>
	<20120828173929.7b371079@obelix.rh>
	<1346211528.3571.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, weiyj.lk@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab2H3Rjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:39:31 -0400
In-Reply-To: <1346211528.3571.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Aug 2012 20:38:48 -0700

> On Tue, 2012-08-28 at 17:39 -0300, Flavio Leitner wrote:
> 
>> Ok, and what if kfree_skb() becomes a macro that first checks
>> if the skb is NULL and if not, call the _kfree_skb() to
>> continue as before?
>> 
>> #define kfree_skb(skb)		\
>>         if (skb)		\
>> 		_kfree_skb(skb)	\
> 
> Then its adding a conditional test on each call site and increase
> kernel code size.
> 
> So if you plan submitting such patch, please keep the whole thing out of
> line.

I'm tossing this entire series.

Each and every case must be investigated individually and:

1) If the check is kept, a big comment explaining why is added
   to the code.

2) If the check is removed, a big piece of explanatory text is
   added to the commit log message explaining everything in
   full detail.
