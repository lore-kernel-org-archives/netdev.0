From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Fri, 13 Mar 2009 17:24:10 -0700
Message-ID: <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
References: <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com>
	 <20090313.140217.143696945.davem@davemloft.net>
	 <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com>
	 <20090313.151913.21135937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:1925 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757858AbZCNAYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 20:24:16 -0400
In-Reply-To: <20090313.151913.21135937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I appreciate this philosophy, but unfortunately I don't have the
>> luxury of working with a NIC that solves these problems.  The reality
>> may be that we're trying to squeeze performance out of crappy hardware
>> to scale on multi-core.  Left alone we couldn't get the stack to
>> scale, but with these "destable hacks" we've gotten 3X or so
>                         ^^^^^^^^
>
> Spelling.
>
>> improvement in packets per second across both our dumb 1G and 10G
>> NICs
>
> Do these NICs at least support multiqueue?
>

Yes, we are using a 10G NIC that supports multi-queue.  The number of
RX queues supported is half the number of cores on our platform, so
that is going to limit the parallelism.  With multi-queue turned on we
do see about 4X improvement in pps over just using a single queue;
this is about the same improvement we see using a single queue with
our software steering techniques (this particular device provides the
Toeplitz hash).  Enabling HW multi-queue has somewhat higher CPU
utilization though, the extra device interrupt load is not coming for
free.  We actually use the HW multi-queue in conjunction with our
software steering to get maximum pps (about 20% more).
