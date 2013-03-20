From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dynticks: avoid flow_cache_flush() interrupting every
 core
Date: Wed, 20 Mar 2013 13:29:01 -0400 (EDT)
Message-ID: <20130320.132901.1638904507644521607.davem@davemloft.net>
References: <201303192143.r2JLhZIX020469@farm-0021.internal.tilera.com>
	<20130320.121704.1797978839297064162.davem@davemloft.net>
	<CAFTL4hwUuRdxUNF0rA9DVNREyBign6FRnAXFp_W+-YfYUfzU9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gilad@benyossef.com,
	sasha.levin@oracle.com, akpm@linux-foundation.org,
	paulmck@linux.vnet.ibm.com, yoshfuji@linux-ipv6.org
To: fweisbec@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFTL4hwUuRdxUNF0rA9DVNREyBign6FRnAXFp_W+-YfYUfzU9Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frederic Weisbecker <fweisbec@gmail.com>
Date: Wed, 20 Mar 2013 17:37:04 +0100

> 2013/3/20 David Miller <davem@davemloft.net>:
>> From: Chris Metcalf <cmetcalf@tilera.com>
>> Date: Tue, 19 Mar 2013 17:35:58 -0400
>>
>>> Previously, if you did an "ifconfig down" or similar on one core, and
>>> the kernel had CONFIG_XFRM enabled, every core would be interrupted to
>>> check its percpu flow list for items that could be garbage collected.
>>>
>>> With this change, we generate a mask of cores that actually have any
>>> percpu items, and only interrupt those cores.  When we are trying to
>>> isolate a set of cpus from interrupts, this is important to do.
>>>
>>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
>>> ---
>>> This change stands alone so could be taken into the net tree if
>>> desired, but it is most useful in the context of Frederic Weisbecker's
>>> linux-dynticks work.  So it could be taken up through either tree,
>>> but it certainly needs sign-off from someone familiar with net/core/flow.c.
>>
>> I'm find with this going into the dynticks changes:
>>
>> Acked-by: David S. Miller <davem@davemloft.net>
> 
> At it looks pretty self-contained, can that perhaps go through the
> networking tree?

Fair enough, applied to net-next, thanks.
