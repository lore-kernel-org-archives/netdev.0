From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] ipv6: fix sparse warning
Date: Wed, 10 Dec 2014 13:54:39 +0800
Message-ID: <5487E01F.4020201@windriver.com>
References: <1418182101-7992-1-git-send-email-ying.xue@windriver.com> <1418190018.27198.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:55587 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaLJFyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 00:54:52 -0500
In-Reply-To: <1418190018.27198.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2014 01:40 PM, Eric Dumazet wrote:
> On Wed, 2014-12-10 at 11:28 +0800, Ying Xue wrote:
>> This fixes the following sparse warning when using
>>
>> make C=1 CF=-D__CHECK_ENDIAN__ net/ipv6/addrconf.o
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>>
>> To silence above spare complaint, an RCU annotation should be added
>> to next pointer of hlist_node structure through hlist_next_rcu() macro
>> when iterating over a hlist with hlist_for_each_entry_continue_rcu_bh().
>>
>> By the way, this commit also resolves the same error appearing in
>> hlist_for_each_entry_continue_rcu().
> 
> This probably should be sent to lkml and CC Paul E. McKenney
> 
> 
> 
> 

I prefer that the patch as well as another similar patch ("tipc: fix RCU
sparse error") are still based on net-next tree, but I will CC Paul E.
McKenney and lkml when resend them, is it ok?

Especially for the patch ("tipc: fix RCU sparse error"), it fixes the
sparse error introduced by the commit 97ede29e80ee ("tipc: convert name
table read-write lock to RCU") which was only merged into net-next tree.

Regards,
Ying
