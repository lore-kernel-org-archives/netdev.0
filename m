From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 20:24:18 -0700
Message-ID: <503450E2.2040504@zytor.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com> <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com> <20120821.193446.1534561579811962053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, tglx@linutronix.de, mingo@redhat.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37750 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753586Ab2HVDYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 23:24:40 -0400
In-Reply-To: <20120821.193446.1534561579811962053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 07:34 PM, David Miller wrote:
> 
> I really hope we eventually get rid of this rediculous restriction the
> x86 code has.
> 
> It really needs a proper stack of FPU state saves like sparc64 has.
> 
> Half of the code and complexity in arch/x86/crypto/ would just
> disappear, because most of it has to do with handling this obtuse
> FPU usage restriction which shouldn't even be an issue in the first
> place.
> 
> I continually see more and more code that has to check this
> irq_fpu_usable() thing, and have ugly fallback code, and therefore is
> a sign that this really needs to be fixed properly.
> 

[Cc: Linus, since he has had very strong opinions on this in the past.]

I'm all ears... tell me how sparc64 deals with this, maybe we can
implement something similar.  At the same time, do keep in mind that on
x86 this is not just a matter of the FPU state, but the entire "extended
state" which can be very large.

Given the cost of state save/enable, however, nothing is going to change
the need for kernel_fpu_begin/end, nor the fact that those things will
want to bracket large regions.

	-hpa
