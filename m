From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] tcp: ensure epoll edge trigger wakeup when out of memory
Date: Tue, 19 May 2015 10:10:33 -0400
Message-ID: <555B4459.806@akamai.com>
References: <20150515211707.D9FC480066@prod-mail-relay07.akamai.com>	<20150519.000945.697478668443801629.davem@davemloft.net> <20150519.001045.1156234709900758412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:22173 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755413AbbESOKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 10:10:34 -0400
In-Reply-To: <20150519.001045.1156234709900758412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/19/2015 12:10 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 19 May 2015 00:09:45 -0400 (EDT)
>
>> From: Jason Baron <jbaron@akamai.com>
>> Date: Fri, 15 May 2015 21:17:07 +0000 (GMT)
>>
>>> From: Jason Baron <jbaron@akamai.com>
>>>
>>> If we really can't get an skb allocated, make sure that we let
>>> userspace know. This at least gives us a chance to re-try or abort.
>>>
>>> Signed-off-by: Jason Baron <jbaron@akamai.com>
>> Applied to net-next, thanks Jason.
> Nevermind, reverted, you didn't compile let alone test this:
>

Hi David,

This was meant as: "do you think this is a good idea? If so, I will
go off and test it. I mentioned it was *not* tested in the separate
thread where we were discussing it:

http://marc.info/?l=linux-netdev&m=143172482802074&w=2

However, I didn't make that at all clear in *this* thread. And I'm
sorry for the inconvenience.

I meant to do:

+       if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 && err ==
-EAGAIN))
+               sk->sk_write_space(sk);

not:

+       if (unlikely(sk->sk_write_queue == 0 && err == -EAGAIN))
+               sk->sk_write_space(sk);

Sounds like you are ok with doing the wakeup here- so I will go
off and test that approach, and report back my findings.

Thanks,

-Jason
