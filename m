From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN negociation
Date: Fri, 04 May 2012 13:20:19 -0700
Message-ID: <4FA43A03.4090707@hp.com>
References: <1336144442.3752.348.camel@edumazet-glaptop> <4FA41B5B.5080103@hp.com> <1336155815.3752.365.camel@edumazet-glaptop> <4FA42491.2020104@hp.com> <1336158359.3752.382.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	=?UTF-8?B?RGF2ZSBUw6RodA==?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:3359 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab2EDUUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 16:20:22 -0400
In-Reply-To: <1336158359.3752.382.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 12:05 PM, Eric Dumazet wrote:
> On Fri, 2012-05-04 at 11:48 -0700, Rick Jones wrote:
>> I'll fire-up tcpdump on netperf.org:
>>
>> tcpdump -i eth0 -vvv '(tcp[tcpflags]&  tcp-syn != 0)&&  (ip[1] != 0x0)'
>>
>> and see what appears.
>>
>> rick
>
> of (ip[1]&  3 != 0)

True, I'm looking at more than the ECN bits, but in the 90 minutes the 
tcpdump has been running there have been no packets with the any of the 
8 bits at ip[1] being 1 anyway :)  Netperf.org doesn't get a massive 
quantity of traffic.  It may go the entire week-end or longer without 
seeing such a packet.

> Note that you could catch SYNACK with this filter (if your machine
> initiates some active TCP sessions), since SYNACK might have ECT bits,
> if some stacks implemented :
>
> http://tools.ietf.org/html/draft-kuzmanovic-ecn-syn-00  ( Adding
> Explicit Congestion Notification (ECN) Capability to TCP's SYN/ACK
> Packets )
>
> http://tools.ietf.org/id/draft-ietf-tcpm-ecnsyn-04.txt

True.  I suspect that 99 times out of 10, the outbound connections 
established by netperf.org are in response to traffic to netperf-talk, 
which is itself a rather quiet list, so I'm not too worried about the 
output being cluttered with false hits.

rick
