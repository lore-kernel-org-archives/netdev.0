From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v7 2/7 RFC] TCPCT part 1b: generate Responder
 Cookie secret
Date: Sat, 21 Nov 2009 11:09:40 -0500
Message-ID: <4B0810C4.1060004@gmail.com>
References: <4B06A659.3020109@gmail.com>	<20091120.092228.216274668.davem@davemloft.net>	<87eins53fu.fsf@basil.nowhere.org> <20091120.125126.169046646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:40599 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203AbZKUQJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 11:09:38 -0500
Received: by yxe17 with SMTP id 17so3673467yxe.33
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 08:09:45 -0800 (PST)
In-Reply-To: <20091120.125126.169046646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Fri, 20 Nov 2009 21:47:17 +0100
> 
>> David Miller <davem@davemloft.net> writes:
>>
>>> From: William Allen Simpson <william.allen.simpson@gmail.com>
>>> Date: Fri, 20 Nov 2009 09:23:21 -0500
>>>
>>>> +static DEFINE_SPINLOCK(tcp_secret_locker);
>>> So connection creation scalability will be limited now because
>>> we'll always have to go through this centralized spinlock even
>>> for independent listening sockets, right?
>> I was about to complain about the same thing in a earlier version
>> of this patch kit, but then I noticed the spin lock aquiring 
>> is guarded by
>>
>> if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
>>
>> which presumably makes it rare enough?
> 
> Works for me.
> 
Roughly once every 10 minutes.  In the original code with rw_lock()
that would have been more frequent on the read side, but the RCU
technique speeds that up considerably?

Also, not every listening socket, just sockets after a cookie option
arrives.  That will probably be only a few selected sockets, at least
for the time being.


