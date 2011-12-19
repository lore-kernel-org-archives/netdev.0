From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 16:19:58 +0100
Message-ID: <20111219151958.GU24496@pengutronix.de>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mircea Gherzan <mgherzan@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Dave Martin <dave.martin@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40225 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860Ab1LSPUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 10:20:09 -0500
Content-Disposition: inline
In-Reply-To: <20111219125021.GA2031@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 12:50:21PM +0000, Dave Martin wrote:
> On Mon, Dec 19, 2011 at 09:40:30AM +0100, Mircea Gherzan wrote:
> > Based of Matt Evans's PPC64 implementation.
> >=20
> > Supports only ARM mode with EABI.
> >=20
> > Supports both little and big endian. Depends on the support for
> > unaligned loads on ARMv7. Does not support all the BPF opcodes
> > that deal with ancillary data. The scratch memory of the filter
> > lives on the stack.
> >=20
> > Enabled in the same way as for x86-64 and PPC64:
> >=20
> > 	echo 1 > /proc/sys/net/core/bpf_jit_enable
> >=20
> > A value greater than 1 enables opcode output.
> >=20
> > Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
> > ---
>=20
> Interesting patch... I haven't reviewed in detail, but I have a few
> quick comments.
>=20
> >=20
> > Changes in v2:
> >  * enable the compiler ony for ARMv5+ because of the BLX instructio=
n
> >  * use the same comparison for the ARM version checks
> >  * use misaligned accesses on ARMv6
>=20
> You probably want to change the commit message now to reflect this.
>=20
> >  * fix the SEEN_MEM
> >  * fix the mem_words_used()
> >=20
> >  arch/arm/Kconfig          |    1 +
> >  arch/arm/Makefile         |    1 +
> >  arch/arm/net/Makefile     |    3 +
> >  arch/arm/net/bpf_jit_32.c |  838 +++++++++++++++++++++++++++++++++=
++++++++++++
> >  arch/arm/net/bpf_jit_32.h |  174 ++++++++++
> >  5 files changed, 1017 insertions(+), 0 deletions(-)
> >  create mode 100644 arch/arm/net/Makefile
> >  create mode 100644 arch/arm/net/bpf_jit_32.c
> >  create mode 100644 arch/arm/net/bpf_jit_32.h
> >=20
> > diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> > index abba5b8..ea65c41 100644
> > --- a/arch/arm/Kconfig
> > +++ b/arch/arm/Kconfig
> > @@ -30,6 +30,7 @@ config ARM
> >  	select HAVE_SPARSE_IRQ
> >  	select GENERIC_IRQ_SHOW
> >  	select CPU_PM if (SUSPEND || CPU_IDLE)
> > +	select HAVE_BPF_JIT if (!THUMB2_KERNEL && AEABI)
>=20
> Have to tried your code with a Thumb-2 kernel?
>=20
> Quickly skimming though your patch, I don't see an obvious reason why=
 we
> can't have that working, though I haven't tried it yet.
>=20
> Note that it's fine to have the JIT generating ARM code, even if the =
rest
> if the kernel is Thumb-2.  This would only start to cause problems if=
 we
> want to do things like set kprobes in the JITted code, or unwind out =
of
> the JITted code.
or use a CPU that doesn't speak ARM (e.g. v7M)

> It's just necessary to make sure that calls/returns into/out of the
> JITted code are handled correctly.  You don't seem to do any scary
> arithmetic or mov to or from pc or lr, and it doesn't look like you e=
ver
> call back into the kernel from JITted code, so the implementation is
> probably safe for ARM/Thumb interworking already (if I've understood
> correctly).
>=20
> It doesn't look hard to port the JIT to generate Thumb-2 code directl=
y
> either -- but I suggest not to worry about that initially.  So long a=
s
> the ARM-based JIT works in a Thumb-2 kernel, it will be useful.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
