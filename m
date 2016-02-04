From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 13:09:49 -0800
Message-ID: <CAKgT0Udgf3jySASPSRKfvjZY5dthnScd++GpHX1PkdUe4E=YPA@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD63C9@AcuExch.aculab.com>
	<CAKgT0UcuJWmpwO4hu34qBWhrhqQ5GQMU_dWHF-Dd10+Y9aCH=g@mail.gmail.com>
	<CALx6S35X08W3ugsc0w_0RT6XdHOH_SF5g2u1z2yvhXL_uvDmNw@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD6923@AcuExch.aculab.com>
	<CALx6S37fGc0-JBVCYT0zh1PMGWkkw--YaqRyUU8tFNMLEn7xFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33538 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080AbcBDVJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 16:09:49 -0500
Received: by mail-io0-f169.google.com with SMTP id f81so107217136iof.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 13:09:49 -0800 (PST)
In-Reply-To: <CALx6S37fGc0-JBVCYT0zh1PMGWkkw--YaqRyUU8tFNMLEn7xFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 12:59 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Feb 4, 2016 at 9:09 AM, David Laight <David.Laight@aculab.com> wrote:
>> From: Tom Herbert
>> ...
>>> > If nothing else reducing the size of this main loop may be desirable.
>>> > I know the newer x86 is supposed to have a loop buffer so that it can
>>> > basically loop on already decoded instructions.  Normally it is only
>>> > something like 64 or 128 bytes in size though.  You might find that
>>> > reducing this loop to that smaller size may improve the performance
>>> > for larger payloads.
>>>
>>> I saw 128 to be better in my testing. For large packets this loop does
>>> all the work. I see performance dependent on the amount of loop
>>> overhead, i.e. we got it down to two non-adcq instructions but it is
>>> still noticeable. Also, this helps a lot on sizes up to 128 bytes
>>> since we only need to do single call in the jump table and no trip
>>> through the loop.
>>
>> But one of your 'loop overhead' instructions is 'loop'.
>> Look at http://www.agner.org/optimize/instruction_tables.pdf
>> you don't want to be using 'loop' on intel cpus.
>>
> I'm not following. We can replace loop with decl %ecx and jg, but why
> is that better?

Because loop takes something like 7 cycles whereas the decl/jg
approach takes 2 or 3.  It is probably one of the reasons things look
so much better with the loop unrolled.

- Alex
