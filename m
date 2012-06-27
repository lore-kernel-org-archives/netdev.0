From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 16:01:23 -0700
Message-ID: <4FEB90C3.9050607@hp.com>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com> <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com> <1340829541.26242.90.camel@edumazet-glaptop> <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net> <4FEB73EF.9090702@candelatech.com> <1340832022.26242.131.camel@edumazet-glaptop> <4FEB7BB9.1080905@candelatech.com> <1340832947.26242.169.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:38431 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462Ab2F0XBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 19:01:25 -0400
In-Reply-To: <1340832947.26242.169.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2012 02:35 PM, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 14:31 -0700, Ben Greear wrote:
>
>> For an example, see the VLAN code. rx-errors and tx-dropped are only 32-bit
>> counters.  Now, in the real world, we wouldn't expect those counters to
>> increase at high rates, but they are still 32-bit counters masquerading
>> as 64, and they could wrap after a while, so any code that expected a wrap
>> to mean a 64-bit wrap would be wrong.
>>
>> At the time I was last complaining, there were lots more cases
>> of this that I was fighting with, but I don't recall exactly what they
>> were.  Once my user-space code got paranoid enough, it was able to
>> at least mostly deal with 32 and 64 wraps.
>
> Good, you now know how to deal correctly with these things.
>
> Using 64bit fields for tx_dropped is what I call kernel bloat.

Today, sure, generalizing to packet counters in general, that bloat is 
likely on its way.  At 100 Gbit/s Ethernet, that is upwards of 147 
million packets per second each way.  At 1 GbE it is 125 million octets 
per second.  So, if 32 bit octet counters were insufficient for 1 GbE, 
32 bit packet counters likely will be insufficient for 100GbE.

Or, I suppose, 3 or more bonded 40 GbEs or 10 or more bonded 10 GbEs 
(unlikely though that last one may be) assuming there is stats 
aggregation in the bond interface.

rick jones
