From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Thu, 20 Nov 2008 14:52:35 +1030
Message-ID: <200811201452.35527.rusty@rustcorp.com.au>
References: <200811190208.11346.rusty@rustcorp.com.au> <200811200943.21410.rusty@rustcorp.com.au> <20081119.151754.44649102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59980 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418AbYKTEWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 23:22:42 -0500
In-Reply-To: <20081119.151754.44649102.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 20 November 2008 09:47:54 David Miller wrote:
> We make a big fuss (rightly) about a few hundred bytes and this sucker
> is FOUR KILOBYTES.

Sure, but this is just trading 4k runtime for 4k static, ie. it's just 
unhiding it.  That's very different from adding random bloat.

> Really for the time being I'd rather see this converted to a
> num_possible_cpus() sized normal kzalloc() and direct indexing.  I
> don't want the networking to bloat up the main kernel image by so
> much.

Nooooooo! :)

First, num_possible_cpus() is the wrong answer (if there are holes in 
cpu_possible_map).  Second, there's little point having percpu infrastructure 
which people avoid.  Third, that memory not going to be numa-aware.  Fourth, 
the dynamic percpu version is fewer instructions (with dynamic percpu 
patches).

I've spent an hour trying to implement DEFINE_PER_CPU_ZERO(), but AFAICT it 
can't be done (gas rejects "b" as a section attribute) :(

So I've dropped the patch, but I wonder if this 4k of stats should be here at 
all.

Thanks,
Rusty.
