From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: auto corking
Date: Fri, 06 Dec 2013 10:02:54 -0800
Message-ID: <52A2114E.1070208@hp.com>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com> <52A1F603.2030208@hp.com> <1386351976.30495.266.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:18659 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab3LFSC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 13:02:58 -0500
In-Reply-To: <1386351976.30495.266.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 09:46 AM, Eric Dumazet wrote:
> On Fri, 2013-12-06 at 08:06 -0800, Rick Jones wrote:
>> On 12/06/2013 02:30 AM, David Laight wrote:
>>>> From: Eric Dumazet <edumazet@google.com>
>>>>
>>>> With the introduction of TCP Small Queues, TSO auto sizing, and TCP
>>>> pacing, we can implement Automatic Corking in the kernel, to help
>>>> applications doing small write()/sendmsg() to TCP sockets.
>>>
>>> Presumably this has the greatest effect on connections with Nagle
>>> disabled?
>>
>> I was wondering why Nagle didn't catch these things as well.  The
>> netperf command line Eric provided though didn't include the
>> test-specific -D option that would have disabled Nagle.  At least not
>> unless the "super_netperf" wrapper was adding it.
>>
>> So, why doesn't Nagle catch what is presumably a sub-MSS send while
>> there is data outstanding on the connection?
>
> super_netperf do not add any option.
>
> Note the netperf results do no really show the improvements of this
> patch. It's a side effect of the short cut.
>
> You kind of need a TCP_RR workload, but splitting the request into small
> chunks.

You mean write, write, read?

If all you need is multiple, small sends in flight at one time, you can 
light-up the burst mode option of netperf and ask it to put multiple 
"transactions" into flight at one time.  But that won't be the same as 
"write, write, read" (when an application presents logically associated 
data to the transport at the same time).  There will still be a 1-1 
correspondence between writes and reads with netperf's burst mode.

> Well written applications use TCP_CORK or MSG_MORE, but unfortunately
> many applications are not well written.

I still like the likes of writev() and other gathering sends better :)

rick jones
