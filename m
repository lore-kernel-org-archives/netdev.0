From: Dave Martin <dave.martin@linaro.org>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 15:52:52 +0000
Message-ID: <20111219155252.GG2031@linaro.org>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
 <20111219151958.GU24496@pengutronix.de>
 <20111219152418.GF2031@linaro.org>
 <20111219153338.GV24496@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mircea Gherzan <mgherzan@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62468 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab1LSPw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 10:52:57 -0500
Received: by werm1 with SMTP id m1so1360558wer.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 07:52:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111219153338.GV24496@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 04:33:38PM +0100, Uwe Kleine-K?nig wrote:
> Hello,
> 
> On Mon, Dec 19, 2011 at 03:24:18PM +0000, Dave Martin wrote:
> > On Mon, Dec 19, 2011 at 04:19:58PM +0100, Uwe Kleine-K?nig wrote:
> > > On Mon, Dec 19, 2011 at 12:50:21PM +0000, Dave Martin wrote:
> > > > On Mon, Dec 19, 2011 at 09:40:30AM +0100, Mircea Gherzan wrote:
> > > > > Based of Matt Evans's PPC64 implementation.
> > > > Note that it's fine to have the JIT generating ARM code, even if the rest
> > > > if the kernel is Thumb-2.  This would only start to cause problems if we
> > > > want to do things like set kprobes in the JITted code, or unwind out of
> > > > the JITted code.
> > > or use a CPU that doesn't speak ARM (e.g. v7M)
> > 
> > Indeed... I was assuming though that that would be out of scope for the
> > first iteration of this code.
> Right, depending on !THUMB2 is fine. Only generating ARM code with
> THUMB2=y is not.

The kernel doesn't support v7-M upstream though.  CONFIG_THUMB2_KERNEL=y
doesn't mean that there is no ARM code present -- there _is_ ARM code in
the kernel image even with this option (though not very much).

IMHO, CONFIG_THUMB2_KERNEL should be viewed as similiar to an optimisation
option or other code gen options -- it's a hint to use the Thumb-2
instruction set in preference to ARM, but doesn't make a 100% guarantee.
Some parts of the kernel do contain ARM code even in this configuration.


The real problem we have here is that we do not distinguish between v7-A
and v7-M in Kconfig (this is not the same thing as CONFIG_MMU, since
there's no special reason why it should be impossible to build a ucLinux
kernel for v7-A -- in which case the ARM instruction is available)

In the meantime, we could temporarily make the JIT dependent on
MMU || !THUMB2_KERNEL, but that doesn't seem strictly correct.


If we had dedicated Kconfig variables describing the (non-) availability
of the two instruction sets, that might enable us to get this right.

Cheers
---Dave
