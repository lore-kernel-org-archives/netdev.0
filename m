From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Mon, 30 Aug 2010 13:25:02 -0700 (PDT)
Message-ID: <20100830.132502.68138403.davem@davemloft.net>
References: <AANLkTimW_7a9=yK4po9FshH0i0LT-MZF+fysGRvgT3jG@mail.gmail.com>
	<20100829.211954.232753860.davem@davemloft.net>
	<AANLkTinrPcJwMs+frY7J_QKuNv1MDGRQAgPgwofuFydw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	hagen@jauu.net, lars.eggert@nokia.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53203
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753536Ab0H3UYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:24:46 -0400
In-Reply-To: <AANLkTinrPcJwMs+frY7J_QKuNv1MDGRQAgPgwofuFydw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Sun, 29 Aug 2010 23:54:48 -0700

> On Sun, Aug 29, 2010 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
>> From: Jerry Chu <hkchu@google.com>
>> Date: Sun, 29 Aug 2010 17:23:05 -0700
>>
>>> Personally I think as an API, it's easier for an application to
>>> grasp the concept of a time quantity than # of
>>> retransmissions. (E.g., how will an app determine it needs 10
>>> retries vs 20 retries?)
>>
>> Conversely how can the user grasp how many actual attempts will
>> be made if backoff is employed?
>>
>> It's very easy to under-cap the number of actual packet send
>> attempts that will be made specifying just a timeout, in the
>> presence of backoff.
> 
> My previous statement presumes applications care less about exactly
> how many times retransmission attempts have been made because
> that's more of "implementation detail" for a reliable transport. But I can
> see one can argue either way effectively so I'm ok with both. If people
> prefer timeout in # of retries then it just needs to be converted to time
> units when used in conjunction with the USER TIMEOUT option (and
> one can readily use the existing "retransmits_timed_out()" function,
> although the latter presents only an approximation).

I was just saying that it can result in unexpected situations.  The
user can increase and increase the timeout they use, but to no effect
because due to backoff the increase isn't adding any more probes at
all.

In any event, I've applied your patch, let's see how this goes.

Thanks!
