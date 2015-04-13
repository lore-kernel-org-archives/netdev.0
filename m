From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: do not block bh too long in
 inet_twdr_twkill_work()
Date: Sun, 12 Apr 2015 23:01:29 -0400 (EDT)
Message-ID: <20150412.230129.1277998183742216856.davem@davemloft.net>
References: <1428664747.25985.298.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150412.210456.227234180754411318.davem@davemloft.net>
	<1428889957.25985.377.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbbDMDBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 23:01:33 -0400
In-Reply-To: <1428889957.25985.377.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 12 Apr 2015 18:52:37 -0700

> On Sun, 2015-04-12 at 21:04 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 10 Apr 2015 04:19:07 -0700
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > I have seen inet_twdr_twkill_work() blocking softirq for
>> > periods up to 1.5 seconds, depending on number of timewait sockets.
>> > 
>> > This is an unacceptable source of latency.
>> > 
>> > Note that inet_twdr_do_twkill_work() releases death_lock spinlock
>> > for every tw handled, but does not take care of bh enabling.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> I think it makes sense to use local_softirq_pending() here rather
>> than flip the lock unconditionally.
> 
> I thought about that, but this meant having to test 2 conditions.
> 
> Not sure we need this patch anyway, if we merge the 'tcp/dccp: get rid
> of central timewait timer' in 4.1 
> 
> Its not like it is a new bug ...

Yeah, since 4.0 is out already, probably just pass on this patch.
