From: David Miller <davem@davemloft.net>
Subject: Re: route.c:645 suspicious rcu_dereference_check()
Date: Fri, 31 Aug 2012 16:54:38 -0400 (EDT)
Message-ID: <20120831.165438.225646535977371251.davem@davemloft.net>
References: <1346193187.3571.21.camel@edumazet-glaptop>
	<20120830.133433.566450758375930776.davem@davemloft.net>
	<1346413814.2591.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: proski@gnu.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab2HaUyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:54:40 -0400
In-Reply-To: <1346413814.2591.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 Aug 2012 04:50:14 -0700

> On Thu, 2012-08-30 at 13:34 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 28 Aug 2012 15:33:07 -0700
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > [PATCH] ipv4: must use rcu protection while calling fib_lookup
>> > 
>> > Following lockdep splat was reported by Pavel Roskin :
>>  ...
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> > Reported-by: Pavel Roskin <proski@gnu.org>
>> 
>> Applied, thanks.
>> 
>> It looks like the redirect handlers might have the same problem?
> 
> Hi David
> 
> Correct me if I am wrong, but redirect handlers should all run under
> rcu_read_lock() protection already.
> 
> rcu_read_lock() is done in ip_local_deliver_finish() or
> ip_rt_send_redirect() for the forward path.
> 
> And above of them, we also have rcu_read_lock() done in
> __netif_receive_skb()

Indeed, you're right, thanks.
