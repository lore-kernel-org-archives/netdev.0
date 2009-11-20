From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 2/7 RFC] TCPCT part 1b: generate
 Responder Cookie secret
Date: Fri, 20 Nov 2009 12:51:26 -0800 (PST)
Message-ID: <20091120.125126.169046646.davem@davemloft.net>
References: <4B06A659.3020109@gmail.com>
	<20091120.092228.216274668.davem@davemloft.net>
	<87eins53fu.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: william.allen.simpson@gmail.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754565AbZKTUvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:51:09 -0500
In-Reply-To: <87eins53fu.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 20 Nov 2009 21:47:17 +0100

> David Miller <davem@davemloft.net> writes:
> 
>> From: William Allen Simpson <william.allen.simpson@gmail.com>
>> Date: Fri, 20 Nov 2009 09:23:21 -0500
>>
>>> +static DEFINE_SPINLOCK(tcp_secret_locker);
>>
>> So connection creation scalability will be limited now because
>> we'll always have to go through this centralized spinlock even
>> for independent listening sockets, right?
> 
> I was about to complain about the same thing in a earlier version
> of this patch kit, but then I noticed the spin lock aquiring 
> is guarded by
> 
> if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
> 
> which presumably makes it rare enough?

Works for me.
