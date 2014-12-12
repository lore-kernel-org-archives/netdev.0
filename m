From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] fib_trie: Fix trie balancing issue if new node pushes
 down existing node
Date: Fri, 12 Dec 2014 08:09:15 -0800
Message-ID: <548B132B.5000606@gmail.com>
References: <20141211054815.1357.36977.stgit@ahduyck-vm-fedora20>	<20141211.213216.1630491264342423219.davem@davemloft.net> <20141212.105425.2023800747122061277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40651 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbaLLQJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:09:17 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so7528040pab.2
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 08:09:16 -0800 (PST)
In-Reply-To: <20141212.105425.2023800747122061277.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2014 07:54 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 11 Dec 2014 21:32:16 -0500 (EST)
>
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
> Alex, in case it isn't clear, I'm hoping that you might have some
> thoughts on this aspect of your changes. :)

Route flaps should at most trigger an inflate without a deflate due to
the way the resize logic works.  If this occurs often it would be useful
since then there would already be space in the tree for the next time
around.

- Alex
