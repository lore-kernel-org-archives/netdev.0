From: Dave Martin <dave.martin@linaro.org>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 15:24:18 +0000
Message-ID: <20111219152418.GF2031@linaro.org>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
 <20111219151958.GU24496@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mircea Gherzan <mgherzan@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58918 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858Ab1LSPYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 10:24:22 -0500
Received: by faar15 with SMTP id r15so3292308faa.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 07:24:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111219151958.GU24496@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 04:19:58PM +0100, Uwe Kleine-K?nig wrote:
> On Mon, Dec 19, 2011 at 12:50:21PM +0000, Dave Martin wrote:
> > On Mon, Dec 19, 2011 at 09:40:30AM +0100, Mircea Gherzan wrote:
> > > Based of Matt Evans's PPC64 implementation.
> > > 
> > > Supports only ARM mode with EABI.
> > > 
> > > Supports both little and big endian. Depends on the support for
> > > unaligned loads on ARMv7. Does not support all the BPF opcodes
> > > that deal with ancillary data. The scratch memory of the filter
> > > lives on the stack.
> > > 
> > > Enabled in the same way as for x86-64 and PPC64:
> > > 
> > > 	echo 1 > /proc/sys/net/core/bpf_jit_enable
> > > 
> > > A value greater than 1 enables opcode output.
> > > 
> > > Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
> > > ---
> > 
> > Interesting patch... I haven't reviewed in detail, but I have a few
> > quick comments.
> > 
> > > 
> > > Changes in v2:
> > >  * enable the compiler ony for ARMv5+ because of the BLX instruction
> > >  * use the same comparison for the ARM version checks
> > >  * use misaligned accesses on ARMv6
> > 
> > You probably want to change the commit message now to reflect this.
> > 
> > >  * fix the SEEN_MEM
> > >  * fix the mem_words_used()
> > > 
> > >  arch/arm/Kconfig          |    1 +
> > >  arch/arm/Makefile         |    1 +
> > >  arch/arm/net/Makefile     |    3 +
> > >  arch/arm/net/bpf_jit_32.c |  838 +++++++++++++++++++++++++++++++++++++++++++++
> > >  arch/arm/net/bpf_jit_32.h |  174 ++++++++++
> > >  5 files changed, 1017 insertions(+), 0 deletions(-)
> > >  create mode 100644 arch/arm/net/Makefile
> > >  create mode 100644 arch/arm/net/bpf_jit_32.c
> > >  create mode 100644 arch/arm/net/bpf_jit_32.h
> > > 
> > > diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> > > index abba5b8..ea65c41 100644
> > > --- a/arch/arm/Kconfig
> > > +++ b/arch/arm/Kconfig
> > > @@ -30,6 +30,7 @@ config ARM
> > >  	select HAVE_SPARSE_IRQ
> > >  	select GENERIC_IRQ_SHOW
> > >  	select CPU_PM if (SUSPEND || CPU_IDLE)
> > > +	select HAVE_BPF_JIT if (!THUMB2_KERNEL && AEABI)
> > 
> > Have to tried your code with a Thumb-2 kernel?
> > 
> > Quickly skimming though your patch, I don't see an obvious reason why we
> > can't have that working, though I haven't tried it yet.
> > 
> > Note that it's fine to have the JIT generating ARM code, even if the rest
> > if the kernel is Thumb-2.  This would only start to cause problems if we
> > want to do things like set kprobes in the JITted code, or unwind out of
> > the JITted code.
> or use a CPU that doesn't speak ARM (e.g. v7M)

Indeed... I was assuming though that that would be out of scope for the
first iteration of this code.

Cheers
---Dave
