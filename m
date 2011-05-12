From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] l2tp: fix potential rcu race
Date: Thu, 12 May 2011 17:27:41 -0400 (EDT)
Message-ID: <20110512.172741.1724338998672360298.davem@davemloft.net>
References: <1305174156.3232.26.camel@edumazet-laptop>
	<20110512142641.GO2258@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	jchapman@katalix.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758749Ab1ELV2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 17:28:18 -0400
In-Reply-To: <20110512142641.GO2258@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 12 May 2011 07:26:41 -0700

> On Thu, May 12, 2011 at 06:22:36AM +0200, Eric Dumazet wrote:
>> While trying to remove useless synchronize_rcu() calls, I found l2tp is
>> indeed incorrectly using two of such calls, but also bumps tunnel
>> refcount after list insertion.
>> 
>> tunnel refcount must be incremented before being made publically visible
>> by rcu readers.
>> 
>> This fix can be applied to 2.6.35+ and might need a backport for older
>> kernels, since things were shuffled in commit fd558d186df2c
>> (l2tp: Split pppol2tp patch into separate l2tp and ppp parts)
> 
> Ouch!  Good catch, Eric!
> 
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Applied, thanks Eric.
