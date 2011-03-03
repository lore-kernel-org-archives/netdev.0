From: David Miller <davem@davemloft.net>
Subject: Re: inetpeer with create==0
Date: Wed, 02 Mar 2011 22:42:20 -0800 (PST)
Message-ID: <20110302.224220.179921025.davem@davemloft.net>
References: <AANLkTimwaUaC7Xu2djSNR9k98sYbSM0V88sCAc34R6Ac@mail.gmail.com>
	<20110302.213634.189680857.davem@davemloft.net>
	<AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab1CCGln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 01:41:43 -0500
In-Reply-To: <AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 3 Mar 2011 14:27:40 +0800

> On Thu, Mar 3, 2011 at 1:36 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Because trie eliminates all of the issues of having to size a hash
>> table, dynamically resize it, etc.
>>
>> Trie gives well bounded performance dependent solely upon size of
>> the table, rather than access patterns, distribution of keys, and
>> how perfect hash function is.
> 
> Thanks for your explaination. Routing cache has all of these issues. :)

Thats why I am working hard to remove it :-)

The %99 percentile performance of our routing cache is absolutely
terrible.  The routing cache does nothing except get in the way.

It is the reason why Linux is still completely unsuitable for use as a
router on the core internet.

> Radix tree may cost lots of memory than a rbtree, avl tree or hash
> table. Here is a case: turning to rbtree from radix tree.
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=8549164143a5431f9d9ea846acaa35a862410d9c

I would not be against the use of rbtree or similar if it could be
done with with fully RCU non-locked lookups even in the not-present
case.

> Hash table + jhash have been proven a safe and efficient data
> structure for large data sets(conntrack and ipvs), although the size
> of the hash table may have to be adjusted by an administrator.

If anything is proven, it is that hashing based collections of cached
information are nothing but trouble when the contents are controlled in
some way by external entities.

Actually, back to the original topic, I wonder how bad it is to simply
elide the recheck in the create==0 case anyways.  Except for the ipv4
fragmentation wraparound protection values, perfect inetpeer finding
is not necessary for correctness.  And IPv4 fragmentation always calls
inetpeer with create!=0.

Eric?
