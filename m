From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 21:14:27 -0700 (PDT)
Message-ID: <20120821.211427.1832042852041589162.davem@davemloft.net>
References: <503450E2.2040504@zytor.com>
	<CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	<5034591E.3040908@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, bhutchings@solarflare.com,
	tglx@linutronix.de, mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445Ab2HVEOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 00:14:31 -0400
In-Reply-To: <5034591E.3040908@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 21 Aug 2012 20:59:26 -0700

> kernel_fpu_end() would still have to re-enable preemption (and
> preemption would have to check the work flag), but that should be cheap.
> 
> We could allow the FPU in the kernel to have preemption, if we allocated
> space for two xstates per thread instead of one.  That is, however, a
> fair hunk of memory.

Once you have done the first FPU save for the sake of the kernel, you
can minimize what you save for any deeper nesting because the kernel
only cares about a very limited part of that FPU state not the whole
1K thing.

Those bits you can save by hand with a bunch of explicit stores of the
XMM registers, or something like that.
