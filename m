From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 09:21:59 -0700
Message-ID: <4FE1F8A7.9000306@hp.com>
References: <20120619.214657.1345825814176201681.davem@davemloft.net> <1340171359.4604.794.camel@edumazet-glaptop> <1340171489.4604.796.camel@edumazet-glaptop> <20120619.231401.2278176068934152926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:10837 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757149Ab2FTQWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 12:22:03 -0400
In-Reply-To: <20120619.231401.2278176068934152926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2012 11:14 PM, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Wed, 20 Jun 2012 07:51:29 +0200
>
>> On Wed, 2012-06-20 at 07:49 +0200, Eric Dumazet wrote:
>>
>>> 2) small lived tcp sessions
>>>
>>>     input dst is now dirtied because of the additional
>>> dst_clone()/dst_release()
>>
>> Not realy a concern because we dirty cache line anyway
>>
>> dst_use_noref()
>> {
>> 	dst->__use++;
>> 	dst->lastuse = time;
>> }
>
> Right, the costs probably even out for short TCP flows.
>
> But better to do real tests than to believe what any of
> us say. :-)

netperf -c -C  -t TCP_CC ...  #just connect/close

or

netperf -c -C -t TCP_CRR ...  # with a request/response pair in there

For some definition of "real" anyway :)

rick jones
