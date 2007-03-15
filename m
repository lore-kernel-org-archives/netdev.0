From: Patrick McHardy <kaber@trash.net>
Subject: Re: fib_hash removal
Date: Thu, 15 Mar 2007 08:43:59 +0100
Message-ID: <45F8F93F.6010408@trash.net>
References: <20070315074046.GA1671@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, tgr@suug.ch
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56360 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbXCOHoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 03:44:10 -0400
In-Reply-To: <20070315074046.GA1671@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 14-03-2007 23:49, Patrick McHardy wrote:
> ...
> 
>>I noticed this a couple of times, but didn't manage to look
>>into it yet:
>>
>>BUG: sleeping function called from invalid context at mm/slab.c:3032
>>in_atomic():1, irqs_disabled():0
>>no locks held by ip/14309.
>>
>>Call Trace:
>> [<ffffffff810956e9>] debug_show_held_locks+0x9/0xb
>> [<ffffffff8100b0b0>] __might_sleep+0xd9/0xdb
>> [<ffffffff8100f745>] __kmalloc_track_caller+0x67/0x10f
>> [<ffffffff810aaff1>] __kzalloc+0x15/0x2f
>> [<ffffffff811fc5a5>] tnode_new+0x55/0x122
> 
> 
> tnode_alloc() uses GFP_KERNEL ...
> 
> 
>> [<ffffffff811fcc88>] resize+0x616/0x966
>> [<ffffffff811d2e08>] nlmsg_notify+0x43/0x6f
>> [<ffffffff811fd074>] trie_rebalance+0x9c/0xef
>> [<ffffffff811fd231>] trie_leaf_remove+0x16a/0x1c2
> 
> 
> ... but we have preempt_disable() here.

Yes, Robert already sent me a patch to remove the bogus preempt_disable,
but IIRC it was there to make sure changes to the tree don't interfere
with packet processing, so we might need to do something else. I'll try
to look into it later today.

