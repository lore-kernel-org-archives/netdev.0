From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Thu, 20 Nov 2008 09:43:21 +1030
Message-ID: <200811200943.21410.rusty@rustcorp.com.au>
References: <200811172050.31308.rusty@rustcorp.com.au> <200811190208.11346.rusty@rustcorp.com.au> <20081119.142023.117741600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46968 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929AbYKSXNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 18:13:32 -0500
In-Reply-To: <20081119.142023.117741600.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 20 November 2008 08:50:23 David Miller wrote:
> Do you really need this to forward some work you are doing?  If not
> can we just let sleeping dogs lie on this one? :)

Yes, I have patches to convert the dynamic percpu data to use the same 
mechanism as static percpu data.  Unfortunately we don't have a mechanism for 
enlarging the percpu region (which is why this wasn't done earlier), so we use 
a heuristic to figure out how much extra percpu region to allocate at boot.

And 4k makes this one of the Big Pigs in dynamic per-cpu allocations.

(SNMP mibs are even worse, but that's a separate debate...)

I can try to implement a bss-like DEFINE_PER_CPU_ZERO(), but it seems silly to 
talk about tight boot loader size restrictions for SMP kernels.

Cheers,
Rusty.
