From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] fib_trie: Fix trie balancing issue if new node
 pushes down existing node
Date: Fri, 12 Dec 2014 11:00:51 -0500 (EST)
Message-ID: <20141212.110051.2301501157409036932.davem@davemloft.net>
References: <20141211054815.1357.36977.stgit@ahduyck-vm-fedora20>
	<20141211.213216.1630491264342423219.davem@davemloft.net>
	<548B0FD6.8040105@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030416AbaLLQAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:00:53 -0500
In-Reply-To: <548B0FD6.8040105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 12 Dec 2014 07:55:02 -0800

> On 12/11/2014 06:32 PM, David Miller wrote:
>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>> Date: Wed, 10 Dec 2014 21:49:22 -0800
>>
>>> This patch addresses an issue with the level compression of the fib_trie.
>>> Specifically in the case of adding a new leaf that triggers a new node to
>>> be added that takes the place of the old node.  The result is a trie where
>>> the 1 child tnode is on one side and one leaf is on the other which gives
>>> you a very deep trie.  Below is the script I used to generate a trie on
>>> dummy0 with a 10.X.X.X family of addresses.
>>  ...
>>> What this fix does is start the rebalance at the newly created tnode
>>> instead of at the parent tnode.  This way if there is a gap between the
>>> parent and the new node it doesn't prevent the new tnode from being
>>> coalesced with any pre-existing nodes that may have been pushed into one
>>> of the new nodes child branches.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> One has to be mindful with this code that what it's doing now might
>> be intentional.  For example, it might be doing things this way
>> on purpose in order to minimize rebalancing during route flaps.
>>
>> Barring anything like that, I think your change is fine.
> 
> I'm fairly certain that this isn't intentional.  If we replace a NULL
> pointer in an existing tnode then we rebalance starting at that tnode,
> it is only when there is no room in the trie and we have to add a new
> tnode that the issue occurs where we rebalance at the parent and not the
> tnode that the leaf was added to.

Ok, thanks for taking the time to explain this, I'm now convinced :)

Applied, thanks again.
