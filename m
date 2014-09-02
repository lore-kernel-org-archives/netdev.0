From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: Re-check for a VIO_DESC_READY data descriptor after short udelay()
Date: Tue, 2 Sep 2014 09:43:46 -0700
Message-ID: <665366D4-384B-45E1-B371-239EA87F5A15@oracle.com>
References: <20140829201809.GH14753@oracle.com> <20140901.204715.2121922580015092507.davem@davemloft.net> <54059BAA.1080307@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40818 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256AbaIBQnt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:43:49 -0400
In-Reply-To: <54059BAA.1080307@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 2, 2014, at 3:27 AM, Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:

> On 09/01/2014 11:47 PM, David Miller wrote:
> 
>> 
>> If there were no more packets coming, this is wasted useless polling
>> time in atomic context.
> 
> turns out that this gives a 20-30% perf improvement for tests like
> iperf.
> 
> when there are no more packets coming, the extra 12 microsecond
> delay is not that big of a deal anyway. The point was that the extra
> 12 micro-second tax in the quiescent network state is less expensive
> than exiting interrupt context, taking another interrupt and doing
> another ldc_read, when there is actually a burst of packets.
> 

We could optimize this a bit by not wait for normal traffic, I mean, non-burst traffic
and apply the retry  only  when we detect a stream of packets?
We could detect a stream based on how many packets are picked
up in this function, picking up 3 or more could be considered as a stream,
of course tune based on testing.

You probably tried it already, but checking to see if you tried with less number
of iterations, we could reduce the iterations if the numbers are equally good
with less iterations.

-Raghuram

> notice that there are many other such udelay() loops elsewhere in
> the code.
> 
> I can remove the retries and submit patch 1/1 again later today.
> 
>> 
>> Everything should be event based, and we should not be compensating
>> and making sacrifices for a producer slower than we are as a consumer.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
