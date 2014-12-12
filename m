From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] fib_trie: Fix trie balancing issue if new node
 pushes down existing node
Date: Fri, 12 Dec 2014 10:54:25 -0500 (EST)
Message-ID: <20141212.105425.2023800747122061277.davem@davemloft.net>
References: <20141211054815.1357.36977.stgit@ahduyck-vm-fedora20>
	<20141211.213216.1630491264342423219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934848AbaLLPy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 10:54:26 -0500
In-Reply-To: <20141211.213216.1630491264342423219.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Dec 2014 21:32:16 -0500 (EST)

> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 10 Dec 2014 21:49:22 -0800
> 
>> This patch addresses an issue with the level compression of the fib_trie.
>> Specifically in the case of adding a new leaf that triggers a new node to
>> be added that takes the place of the old node.  The result is a trie where
>> the 1 child tnode is on one side and one leaf is on the other which gives
>> you a very deep trie.  Below is the script I used to generate a trie on
>> dummy0 with a 10.X.X.X family of addresses.
>  ...
>> What this fix does is start the rebalance at the newly created tnode
>> instead of at the parent tnode.  This way if there is a gap between the
>> parent and the new node it doesn't prevent the new tnode from being
>> coalesced with any pre-existing nodes that may have been pushed into one
>> of the new nodes child branches.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> 
> One has to be mindful with this code that what it's doing now might
> be intentional.  For example, it might be doing things this way
> on purpose in order to minimize rebalancing during route flaps.
> 
> Barring anything like that, I think your change is fine.

Alex, in case it isn't clear, I'm hoping that you might have some
thoughts on this aspect of your changes. :)
