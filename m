From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Wed, 10 Dec 2014 21:58:23 +0100
Message-ID: <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman> <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:42504 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933049AbaLJU6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 15:58:44 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so3524938pac.36
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 12:58:43 -0800 (PST)
In-Reply-To: <20141210171724.GI4602@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2014 at 6:17 PM, Felipe Balbi <balbi@ti.com> wrote:
> Hi,
>
> On Fri, Dec 05, 2014 at 11:03:44AM +0100, Yegor Yefremov wrote:
>> On Thu, Dec 4, 2014 at 5:56 PM, Felipe Balbi <balbi@ti.com> wrote:
>> > Hi,
>> >
>> > On Thu, Dec 04, 2014 at 05:41:38PM +0100, Yegor Yefremov wrote:
>> >> I have following problem. My systems reboots at high network load
>> >> after this commit (found via git bissect):
>> >>
>> >> commit 55601c9f24670ba926ebdd4d712ac3b177232330
>> >> Author: Felipe Balbi <balbi@ti.com>
>> >> Date:   Mon Sep 8 17:54:58 2014 -0700
>> >>
>> >>     arm: omap: intc: switch over to linear irq domain
>> >>
>> >>     now that we don't need to support legacy board-files,
>> >>     we can completely switch over to a linear irq domain
>> >>     and make use of irq_alloc_domain_generic_chips() to
>> >>     allocate all generic irq chips for us.
>> >>
>> >>     Signed-off-by: Felipe Balbi <balbi@ti.com>
>> >>     Signed-off-by: Tony Lindgren <tony@atomide.com>
>> >>
>> >> and I get following error messages:
>> >>
>> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>> >
>> > irq 0 ? Weird, that's not a valid IRQ.
>> >
>> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> >> ->action():   (null)
>> >>    IRQ_NOPROBE set
>> >>  IRQ_NOREQUEST set
>> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> >> ->action():   (null)
>> >>    IRQ_NOPROBE set
>> >>  IRQ_NOREQUEST set
>> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> >> ->action():   (null)
>> >>    IRQ_NOPROBE set
>> >>  IRQ_NOREQUEST set
>> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> >> ->action():   (null)
>> >>
>> >> My system: am335x with fast ethernet on the first slave and gigabit
>> >> Ethernet on second CPSW slave. This issue occurs, when I ran nuttcp
>> >> with default settings.
>> >>
>> >> With commit above I can at least see these messages, but 3.18-rc7 for
>> >> example reboots without any messages.
>> >>
>> >> Any idea?
>> >
>> > if you take v3.18-rc7 and just revert that commit, does the problem go
>> > away ?
>>
>> git revert failed as the driver has more changes meanwhile or I'm
>> missing some params. I've tried to force the driver to use legacy
>> routines, but then I don't get pass U-Boot's "Starting kernel ..." See
>> attached patch.
>>
>> Compiler used:
>>
>> Linux version 3.18.0-rc7 (...) (gcc version 4.8.3 20140320
>> (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #309 SMP Fri Dec 5
>> 10:59:38 CET 2014
>>
>> Btw, what am335x based hardware do you have? I can run tests on both
>> BBB and am335x-evmsk.
>
> coming back to this. I have BBB only. Can you provide some extra
> information on how I can trigger this problem here ?

I have basically two am335x based boards, where I can trigger this
problem via nuttcp (I think iperf would do the job too). The first
system stalls almost immediately, the second one was working for about
7 minutes. I have tried the same kernel on am335x-evmsk - and this
system didn't stall. I could provide dts files for both systems.

I've tried to reduce my dts as much as I could to match  am335x-evmsk
dts, I have even removed entries for the PMIC, but still the system
stalls. Btw PMIC's INT line is connected to a GPIO pin on processor.

I've used omap2plus_defconfig for all 3 devices. Any other info I can supply?

Yegor
