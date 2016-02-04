From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 12:59:30 -0800
Message-ID: <CALx6S37fGc0-JBVCYT0zh1PMGWkkw--YaqRyUU8tFNMLEn7xFQ@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD63C9@AcuExch.aculab.com>
	<CAKgT0UcuJWmpwO4hu34qBWhrhqQ5GQMU_dWHF-Dd10+Y9aCH=g@mail.gmail.com>
	<CALx6S35X08W3ugsc0w_0RT6XdHOH_SF5g2u1z2yvhXL_uvDmNw@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD6923@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36914 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169AbcBDU7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 15:59:31 -0500
Received: by mail-ig0-f176.google.com with SMTP id 5so256102igt.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 12:59:31 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD6923@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 9:09 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Tom Herbert
> ...
>> > If nothing else reducing the size of this main loop may be desirable.
>> > I know the newer x86 is supposed to have a loop buffer so that it can
>> > basically loop on already decoded instructions.  Normally it is only
>> > something like 64 or 128 bytes in size though.  You might find that
>> > reducing this loop to that smaller size may improve the performance
>> > for larger payloads.
>>
>> I saw 128 to be better in my testing. For large packets this loop does
>> all the work. I see performance dependent on the amount of loop
>> overhead, i.e. we got it down to two non-adcq instructions but it is
>> still noticeable. Also, this helps a lot on sizes up to 128 bytes
>> since we only need to do single call in the jump table and no trip
>> through the loop.
>
> But one of your 'loop overhead' instructions is 'loop'.
> Look at http://www.agner.org/optimize/instruction_tables.pdf
> you don't want to be using 'loop' on intel cpus.
>
I'm not following. We can replace loop with decl %ecx and jg, but why
is that better?

Tom

> You might get some benefit from pipelining the loop (so you do
> a read to register in one iteration and a register-register adc
> the next).
>
>         David
>
