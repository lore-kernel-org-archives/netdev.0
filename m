From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 17:39:51 +0000
Message-ID: <CAHkRjk5ABYmwfxbvFgh2yWP_D69Sap6Pud+yMG7fBCTzRwmNzg@mail.gmail.com>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org> <20111219151958.GU24496@pengutronix.de>
 <20111219152418.GF2031@linaro.org> <20111219153338.GV24496@pengutronix.de> <20111219155252.GG2031@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Uwe Kleine-K?nig" <u.kleine-koenig@pengutronix.de>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Dave Martin <dave.martin@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:46646 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab1LSRkP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 12:40:15 -0500
Received: by qadb15 with SMTP id b15so3456323qad.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 09:40:14 -0800 (PST)
In-Reply-To: <20111219155252.GG2031@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 December 2011 15:52, Dave Martin <dave.martin@linaro.org> wrote:
> On Mon, Dec 19, 2011 at 04:33:38PM +0100, Uwe Kleine-K?nig wrote:
>> On Mon, Dec 19, 2011 at 03:24:18PM +0000, Dave Martin wrote:
>> > On Mon, Dec 19, 2011 at 04:19:58PM +0100, Uwe Kleine-K?nig wrote:
>> > > On Mon, Dec 19, 2011 at 12:50:21PM +0000, Dave Martin wrote:
>> > > > On Mon, Dec 19, 2011 at 09:40:30AM +0100, Mircea Gherzan wrote=
:
>> > > > > Based of Matt Evans's PPC64 implementation.
>> > > > Note that it's fine to have the JIT generating ARM code, even =
if the rest
>> > > > if the kernel is Thumb-2. =A0This would only start to cause pr=
oblems if we
>> > > > want to do things like set kprobes in the JITted code, or unwi=
nd out of
>> > > > the JITted code.
>> > > or use a CPU that doesn't speak ARM (e.g. v7M)
>> >
>> > Indeed... I was assuming though that that would be out of scope fo=
r the
>> > first iteration of this code.
>> Right, depending on !THUMB2 is fine. Only generating ARM code with
>> THUMB2=3Dy is not.
>
> The kernel doesn't support v7-M upstream though. =A0CONFIG_THUMB2_KER=
NEL=3Dy
> doesn't mean that there is no ARM code present -- there _is_ ARM code=
 in
> the kernel image even with this option (though not very much).
>
> IMHO, CONFIG_THUMB2_KERNEL should be viewed as similiar to an optimis=
ation
> option or other code gen options -- it's a hint to use the Thumb-2
> instruction set in preference to ARM, but doesn't make a 100% guarant=
ee.
> Some parts of the kernel do contain ARM code even in this configurati=
on.
>
>
> The real problem we have here is that we do not distinguish between v=
7-A
> and v7-M in Kconfig (this is not the same thing as CONFIG_MMU, since
> there's no special reason why it should be impossible to build a ucLi=
nux
> kernel for v7-A -- in which case the ARM instruction is available)

If we ever take the time to push ARMv7-M into mainline, my patches
actually introduce CONFIG_CPU_V7M:

http://www.linux-arm.org/git?p=3Dlinux-2.6-stable.git;a=3Dcommitdiff;h=3D=
53a9ca6eccb3e14c7d9045870464cbfb37b0bb3b

--=20
Catalin
