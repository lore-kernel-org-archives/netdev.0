From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/17] fib_trie: Reduce time spent in
 fib_table_lookup by 35 to 75%
Date: Thu, 01 Jan 2015 21:08:41 -0500 (EST)
Message-ID: <20150101.210841.1269406605009943743.davem@davemloft.net>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
	<20141231.184610.1802958694945952516.davem@davemloft.net>
	<54A4B1D4.1030506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbABCIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 21:08:43 -0500
In-Reply-To: <54A4B1D4.1030506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 31 Dec 2014 18:32:52 -0800

> On 12/31/2014 03:46 PM, David Miller wrote:
>> This knocks about 35 cpu cycles off of a lookup that ends up using the
>> default route on sparc64.  From about ~438 cycles to ~403.
> 
> Did that 438 value include both fib_table_lookup and check_leaf?  Just
> curious as the overall gain seems smaller than what I have been seeing
> on the x86 system I was testing with, but then again it could just be a
> sparc64 thing.

This is just a default run of my kbench_mod.ko from the net_test_tools
repo.  You can try it as well on x86-86 or similar.

> I've started work on a second round of patches.  With any luck they
> should be ready by the time the next net-next opens.  My hope is to cut
> the look-up time by another 30 to 50%, though it will take some time as
> I have to go though and drop the leaf_info structure, and look at
> splitting the tnode in half to break the key/pos/bits and child pointer
> dependency chain which will hopefully allow for a significant reduction
> in memory read stalls.

I'm very much looking forward to this.

> I am also planning to take a look at addressing the memory waste that
> occurs on nodes larger than 256 bytes due to the way kmalloc allocates
> memory as powers of 2.  I'm thinking I might try encouraging the growth
> of smaller nodes, and discouraging anything over 256 by implementing a
> "truesize" type logic that can be used in the inflate/halve functions so
> that the memory usage is more accurately reflected.

Wouldn't this result in a deeper tree?  The whole point is to keep the
tree as shallow as possible to minimize the memory refs on a lookup
right?
