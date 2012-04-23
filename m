From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Mon, 23 Apr 2012 14:56:48 -0700
Message-ID: <4F95D020.9080500@hp.com>
References: <1335173934.3293.84.camel@edumazet-glaptop> <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop> <20120423.160149.1515408777176168288.davem@davemloft.net> <1335213446.5205.65.camel@edumazet-glaptop> <4F95C22D.3010908@hp.com> <1335216631.5205.71.camel@edumazet-glaptop> <4F95CECF.6030901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:31678 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828Ab2DWV4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 17:56:50 -0400
In-Reply-To: <4F95CECF.6030901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2012 02:51 PM, Rick Jones wrote:
> On 04/23/2012 02:30 PM, Eric Dumazet wrote:
>> On Mon, 2012-04-23 at 13:57 -0700, Rick Jones wrote:
>>> Probably better to call that something other than 16K buffers - the send
>>> size was probably 16K, which reflected SO_SNDBUF at the time the data
>>> socket was created, but clearly SO_SNDBUF grew in that timeframe.
>>>
>>
>>
>> Maybe I was not clear : Application does sendmsg() of 16KB buffers.
>
> I'd probably call that a 16K send test. The root of the issue being
> there being "send buffers" and "send socket buffers" (and their receive
> versions).
>
> My "canonical" test - at least one that appears in most of my
> contemporary scripts uses a 64K send size for the bulk transfer tests. I
> switch back-and-forth between tests which allow the socket buffer size
> to be determined automagically, and those where I set both sides' socket
> buffers to 1M via the test-specific -s and -S options. In "netperf
> speak" those would probably be "x64K" and "1Mx64k" respectively. More
> generally "<socket buffer size>x<send size>" (I rarely set/specify the
> receive size in those tests, leaving it at whatever SO_RCVBUF is at the
> start.
>
>> Yet, in the small time it takes to perform this operation, softirq can
>> queue up to 300 packets coming from the other side.
>
> There is more to it than just queue-up 16 KB right?

I should have added that 300 ACKs seems huge as a backlog.  At 
ack-every-other that is 300 * 1448 * 2 or 868800 bytes worth of ACKs. 
That sounds like a great deal more than just one 16KB send's worth of 
being held-off.  I mean at 10Gbe speeds (using your 54 usec for 64KB) 
that represents data which took something like three quarters of a 
millisecond to transmit on the wire.

rick
