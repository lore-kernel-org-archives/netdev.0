From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 14:00:05 -0700
Message-ID: <4FEB7455.6030107@hp.com>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com> <1340823810.26242.81.camel@edumazet-glaptop>  <4FEB6B64.5060708@hp.com> <1340829541.26242.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:20438 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761Ab2F0VAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:00:06 -0400
In-Reply-To: <1340829541.26242.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2012 01:39 PM, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 13:21 -0700, Rick Jones wrote:
>
>> It is a question of the speed of the communications more than the
>> bitness of the processor no?
>
> Why ?

The desire to have a greater than 32 bit counter stems from how quickly 
it will wrap, and how quickly it will wrap depends on the speed of 
communication.

> In 2012 or 2013, 64bits kernels are the norm, and 32bit the exception.

In servers and laptops I would be inclined to agree.  Elsewhere I am not 
so sure.   And while I don't know of its status, there is at least one 
hit on an RFC where, back in 2001, when a great many things were 32 bit, 
various 64-bit counters were added for L2TP Domain statistics:

http://tools.ietf.org/html/draft-ietf-l2tpext-l2tp-mib-03

(I think that became http://tools.ietf.org/html/rfc3371 in 2002)

So, it is possible people were simply painting a bikeshed, but 10 years 
ago, when the prevalence of 64 bit processors was not nearly so great, 
folks involved in L2TP MIB definitions found it worthwhile to make 
various counters 64-bit.

> Should we add complex code to l2tp just for being able to run it on
> 32bit kernels with 64bit stats ?
>
> Considering this code is buggy at the v1 & v2, I am really wondering.
>
> All sane SNMP applications are ready to cope with 32bits counters
> wrapping.

Once (maybe twice?) but no more than that.

> Machines that could wrap the 32bit counter several times per second are
> probably running on 64bit kernels.

I don't think it requires wrapping a 32 bit counter several times a 
second to warrant a > 32 bit counter.

> Also percpu stats are overkill unless a device is really meant to be
> used in // by many cpus.

I take it "//" is used as a shorthand for parallel?

rick
