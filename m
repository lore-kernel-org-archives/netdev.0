From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Wed, 19 Nov 2008 15:17:54 -0800 (PST)
Message-ID: <20081119.151754.44649102.davem@davemloft.net>
References: <200811190208.11346.rusty@rustcorp.com.au>
	<20081119.142023.117741600.davem@davemloft.net>
	<200811200943.21410.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46896
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751021AbYKSXRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:17:54 -0500
In-Reply-To: <200811200943.21410.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 20 Nov 2008 09:43:21 +1030

> On Thursday 20 November 2008 08:50:23 David Miller wrote:
> > Do you really need this to forward some work you are doing?  If not
> > can we just let sleeping dogs lie on this one? :)
> 
> Yes, I have patches to convert the dynamic percpu data to use the same 
> mechanism as static percpu data.  Unfortunately we don't have a mechanism for 
> enlarging the percpu region (which is why this wasn't done earlier), so we use 
> a heuristic to figure out how much extra percpu region to allocate at boot.
> 
> And 4k makes this one of the Big Pigs in dynamic per-cpu allocations.
> 
> (SNMP mibs are even worse, but that's a separate debate...)

We make a big fuss (rightly) about a few hundred bytes and this sucker
is FOUR KILOBYTES.

Really for the time being I'd rather see this converted to a
num_possible_cpus() sized normal kzalloc() and direct indexing.  I
don't want the networking to bloat up the main kernel image by so
much.

> I can try to implement a bss-like DEFINE_PER_CPU_ZERO(), but it seems silly to 
> talk about tight boot loader size restrictions for SMP kernels.

SMP these days is candy.  And sparc is what has the bootloader restrictions
btw :)
