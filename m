From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP timewait recycle/reuse for IPv6?
Date: Mon, 17 Mar 2008 11:15:27 -0700
Message-ID: <47DEB53F.9030108@hp.com>
References: <200803171818.17494.opurdila@ixiacom.com> <47DEADC1.1040908@hp.com> <200803172004.33246.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:6076 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbYCQSP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 14:15:29 -0400
In-Reply-To: <200803172004.33246.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> On Monday 17 March 2008, Rick Jones wrote:
> 
>>Octavian Purdila wrote:
>>
>>>Hi,
>>>
>>>Is there a way to prevent getting bind(in6addr_any) failures when we
>>>have lots of TIMEWAIT sockets hanging around? It looks like timewait
>>>reuse/recyle is not supported in the IPv6 stack.
>>
>>What is the definition/value of "lots" here?
>>
> 
> 
> At least 26000, maybe even more. I suspect that when I get the bind
> failures most of the ports in the ip_local_port_range pool are in
> TIMEWATstate.
> This happens because of the particular traffic I am using, which
> generates a few 1000s of connections per second. The connection
> lifetime is very short.

Does it _have_ to be from a single IP address?

> While running the same traffic with IPv4, the timewait recyle/reuse
> features kicks in and keeps the number of TIMEWAIT sockets to under a
> 1000.

ISTR some discussion on the list about that recyling/reuse feature 
perhaps going away.  While TCP theory suggests that one can transition 
from TIME_WAIT to ESTABLISHED, if tings like the ISN are selected "just 
so" it seems the desire to randomize things like ISN's makes the chances 
of success rather remote.

Anyhow, if we presume a 60 second TIME_WAIT, and explicit selection of 
port numbers from the range of 5000 to 65535, it should be possible to 
sustain a connection "churn" rate of ~1000 connections per second 
without attempting to re-use an endpoint still in TIME_WAIT.  Each 
additional "simulated client" IP address you can add to that mix will 
increase the rate by another 1000 connections per second.

Anything trying for such a churn-rate from a single IP address in that 
wonderfully vague "real life" is arguably broken :)

rick jones
