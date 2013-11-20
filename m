From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: fix use after free race in send path when
 dev is released
Date: Wed, 20 Nov 2013 15:21:20 -0500 (EST)
Message-ID: <20131120.152120.518403007474992157.davem@davemloft.net>
References: <528C7319.5050309@redhat.com>
	<20131120.150711.1110320732127884184.davem@davemloft.net>
	<1384978559.10637.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	noureddine@aristanetworks.com, greearb@candelatech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754941Ab3KTUVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:21:22 -0500
In-Reply-To: <1384978559.10637.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Nov 2013 12:15:59 -0800

> On Wed, 2013-11-20 at 15:07 -0500, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
> 
>> > Yep, will try if this approach works, in other words doing the earlier
>> > exit via !po->running, plus deferring the dev_put() et al to RCU.
>> 
>> Thank you.  You might have to wrap the sendmsg path in an rcu lock
>> sequence.
> 
> Note that dev_put() / dev_hold() are blazingly fast ;)

Oh yes, per-cpu counters, almost forgot :-)))
