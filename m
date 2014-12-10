From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Wed, 10 Dec 2014 23:56:36 +0100
Message-ID: <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman> <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman> <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:39580 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbaLJW46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 17:56:58 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so3104064pab.19
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 14:56:57 -0800 (PST)
In-Reply-To: <20141210210234.GN4602@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2014 at 10:02 PM, Felipe Balbi <balbi@ti.com> wrote:
> Hi,
>
> On Wed, Dec 10, 2014 at 09:58:23PM +0100, Yegor Yefremov wrote:
>
> [snip]
>
>> >> git revert failed as the driver has more changes meanwhile or I'm
>> >> missing some params. I've tried to force the driver to use legacy
>> >> routines, but then I don't get pass U-Boot's "Starting kernel ..." See
>> >> attached patch.
>> >>
>> >> Compiler used:
>> >>
>> >> Linux version 3.18.0-rc7 (...) (gcc version 4.8.3 20140320
>> >> (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #309 SMP Fri Dec 5
>> >> 10:59:38 CET 2014
>> >>
>> >> Btw, what am335x based hardware do you have? I can run tests on both
>> >> BBB and am335x-evmsk.
>> >
>> > coming back to this. I have BBB only. Can you provide some extra
>> > information on how I can trigger this problem here ?
>>
>> I have basically two am335x based boards, where I can trigger this
>
> too bad, I have a single am335x board available here and that's my BBB.
>
> Do both boards stall or only the server or only the client ?
>
> If only one of them fail, then I try connecting my BBB to my AM437x SK
> and see if that'll die too.

I have following setup: all three devices (am335x-evmsk inclusively)
are connected to my development host via Gigabit switch. And on all of
them I run "nuttcp -S" and my dev host is client (nuttcp -t). Just
normal setup, when you try to measure am335x network performance. So
am335x devices communicate only with my host and not with each other.

If I use 3.18 I can only observe, that the system freezes, but when I
use the kernel with above mentioned commit I see interrupt errors,
like I described in my first e-mail.

>> problem via nuttcp (I think iperf would do the job too). The first
>> system stalls almost immediately, the second one was working for about
>> 7 minutes. I have tried the same kernel on am335x-evmsk - and this
>> system didn't stall. I could provide dts files for both systems.
>>
>> I've tried to reduce my dts as much as I could to match  am335x-evmsk
>> dts, I have even removed entries for the PMIC, but still the system
>> stalls. Btw PMIC's INT line is connected to a GPIO pin on processor.
>>
>> I've used omap2plus_defconfig for all 3 devices. Any other info I can
>> supply?
>
> just the extra bit of info above.
>
> --
> balbi
