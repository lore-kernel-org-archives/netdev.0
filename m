From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] codel: use Newton method instead of sqrt()
 and divides
Date: Sat, 12 May 2012 17:52:17 -0400 (EDT)
Message-ID: <20120512.175217.1632102067268101115.davem@davemloft.net>
References: <1336855256.31653.1329.camel@edumazet-glaptop>
	<20120512.164513.1156706853054390966.davem@davemloft.net>
	<1336859324.31653.1385.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org,
	nichols@pollere.com, van@pollere.net, codel@lists.bufferbloat.net,
	ycheng@google.com, mattmathis@google.com, therbert@google.com,
	shemminger@vyatta.com, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab2ELVyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 17:54:23 -0400
In-Reply-To: <1336859324.31653.1385.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 12 May 2012 23:48:44 +0200

> On Sat, 2012-05-12 at 16:45 -0400, David Miller wrote:
>> Using a u16 would also work for me.
> 
> I tried it but it gives noticeable errors for count > 16000, and no
> speed gain.
 ...
> And if a flow is really agressive, count can grow above 10^6
> 
>> > By the way, gcc on x86 generates nice "and 0xfffffffe,%eax" instruction
>> > for (vars->rec_inv_sqrt << 1).
>> 
>> Yeah but what do stores of ->rec_inv_sqrt look like?
> 
> The load is "shr %edi" as in :
> and the store an "or %ecx,%esi"

Ok, fair enough.
