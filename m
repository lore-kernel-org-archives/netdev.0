From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Fri, 17 Apr 2015 15:55:32 -0400 (EDT)
Message-ID: <20150417.155532.328134690699313472.davem@davemloft.net>
References: <552F9986.30207@redhat.com>
	<1429187895.7346.195.camel@edumazet-glaptop2.roam.corp.google.com>
	<55313D4D.4050402@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ebiederm@xmission.com, jengelh@medozas.de,
	jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55313D4D.4050402@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Fri, 17 Apr 2015 19:05:17 +0200

> On 04/16/2015 02:38 PM, Eric Dumazet wrote:
>> On Thu, 2015-04-16 at 13:14 +0200, Denys Vlasenko wrote:
>> 
>>> However, without BUG_ONs, function is still a bit big
>>> on PREEMPT configs.
>> 
>> Only on allyesconfig builds, that nobody use but to prove some points
>> about code size.
> 
> How do you expect one to find excessively large inlines,
> if not on allyesconfig build?
> 
> Only by using allyesconfig, I can measure how many calls
> are there in the kernel. (grepping source is utterly unreliable
> due to nested inlines and macros).

It is not indicative for it's overhead in what people actually make
use of, which is what is actually important.

Uninlining a static inline that basically does no more than index into
an array is nothing more than pure folly.  So please don't try to
weasel your way out of accepting this basic fact.

That's exactly the situation where the implementation of an abstraction
via a static inline is exactly the thing to do.
