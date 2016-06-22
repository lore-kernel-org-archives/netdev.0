From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce cpu usage when SO_SNDBUF is
 set
Date: Wed, 22 Jun 2016 14:18:14 -0400
Message-ID: <576AD666.7050809@akamai.com>
References: <cover.1466608332.git.jbaron@akamai.com>
 <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
 <1466616854.6850.69.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:12734 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751630AbcFVSSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 14:18:32 -0400
In-Reply-To: <1466616854.6850.69.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/22/2016 01:34 PM, Eric Dumazet wrote:
> On Wed, 2016-06-22 at 11:32 -0400, Jason Baron wrote:
>> From: Jason Baron <jbaron@akamai.com>
>>
>> When SO_SNDBUF is set and we are under tcp memory pressure, the effective
>> write buffer space can be much lower than what was set using SO_SNDBUF. For
>> example, we may have set the buffer to 100kb, but we may only be able to
>> write 10kb. In this scenario poll()/select()/epoll(), are going to
>> continuously return POLLOUT, followed by -EAGAIN from write(), and thus
>> result in a tight loop. Note that epoll in edge-triggered does not have
>> this issue since it only triggers once data has been ack'd. There is no
>> issue here when SO_SNDBUF is not set, since the tcp layer will auto tune
>> the sk->sndbuf.
>
> Still, generating one POLLOUT event per incoming ACK will not please
> epoll() users in edge-trigger mode.
>
> Host is under global memory pressure, so we probably want to drain
> socket queues _and_ reduce cpu pressure.
>
> Strategy to insure all sockets converge to small amounts ASAP is simply
> the best answer.
>
> Letting big SO_SNDBUF offenders hog memory while their queue is big
> is not going to help sockets who can not get ACK
> (elephants get more ACK than mice, so they have more chance to succeed
> their new allocations)
>
> Your patch adds lot of complexity logic in tcp_sendmsg() and
> tcp_sendpage().
>
>
> I would prefer a simpler patch like :
>
>

Ok, fair enough. I'm going to assume that you will submit this as
a formal patch.

For 1/2, the getting the correct memory barrier, should I re-submit
that as a separate patch?

Thanks,

-Jason
