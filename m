From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 20:49:20 -0700
Message-ID: <503456C0.9000203@zytor.com>
References: <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com> <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com> <20120821.202945.2278895156403194101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, tglx@linutronix.de, mingo@redhat.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	x86@kernel.org, torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37895 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955Ab2HVDtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 23:49:39 -0400
In-Reply-To: <20120821.202945.2278895156403194101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 08:29 PM, David Miller wrote:
> 
> What we do is we have a FPU stack that grows up from the end of the
> thread_info struct, towards the bottom of the kernel stack.
> 

We have 8K of kernel stack, and an xstate which is pushing a kilobyte
already.  This seems like a nightmare.  Even if we allocate a larger
stack for this sole purpose, we'd have to put a pretty hard cap on how
far it could grow.

> Slot 0 is always the user FPU state.
> 
> Slot 1 and further are kernel FPU state save areas.
> 
> We hold a counter which keep track of how far deeply saved we are
> in the stack.
> 
> Not for the purpose of space saving, but for overhead reduction we
> sometimes can get away with only saving away half of the FPU
> registers.  The chip provides a pair of dirty bits, one for the lower
> half of the FPU register file and one for the upper half.  We only
> save the bits that are actually dirty.
> 
> Furthermore, when we have FPU using code in the kernel that only uses
> the lower half of the registers, we only save away that part of the
> state around the routine.

This is messy on x86; it is somewhat doable but it gets really hairy
because of the monolithic [f]xsave/[f]xrstor instruction.

	-hpa
