From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next-2.6 PATCH v7 2/7 RFC] TCPCT part 1b: generate Responder Cookie secret
Date: Fri, 20 Nov 2009 21:47:17 +0100
Message-ID: <87eins53fu.fsf@basil.nowhere.org>
References: <4B06A1FF.8000202@gmail.com> <4B06A659.3020109@gmail.com>
	<20091120.092228.216274668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: william.allen.simpson@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41619 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443AbZKTUrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:47:17 -0500
In-Reply-To: <20091120.092228.216274668.davem@davemloft.net> (David Miller's message of "Fri, 20 Nov 2009 09:22:28 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Fri, 20 Nov 2009 09:23:21 -0500
>
>> +static DEFINE_SPINLOCK(tcp_secret_locker);
>
> So connection creation scalability will be limited now because
> we'll always have to go through this centralized spinlock even
> for independent listening sockets, right?

I was about to complain about the same thing in a earlier version
of this patch kit, but then I noticed the spin lock aquiring 
is guarded by

if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {

which presumably makes it rare enough?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
