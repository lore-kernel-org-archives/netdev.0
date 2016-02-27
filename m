From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 26 Feb 2016 21:25:33 -0800
Message-ID: <CA+55aFxDYr6Abs+czfJK0z=wSiznS1=bHw4AVb0VN+NrB6pK7g@mail.gmail.com>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
	<CAKgT0UfjM6jpGwJpXb=w6VX5P0SqzKe41HGCzp=Rz6stpO6Ucg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33782 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbcB0FZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 00:25:34 -0500
Received: by mail-io0-f195.google.com with SMTP id g203so9911156iof.0
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 21:25:34 -0800 (PST)
In-Reply-To: <CAKgT0UfjM6jpGwJpXb=w6VX5P0SqzKe41HGCzp=Rz6stpO6Ucg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 2:52 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> I'm still not a fan of the unaligned reads.  They may be okay but it
> just seems like we are going run into corner cases all over the place
> where this ends up biting us.

No.

Unaligned reads are not just "ok".

The fact is, not doing unaligned reads is just stupid.

Guys, the RISC people tried the whole "only do aligned crap". It was a
mistake. It's stupid. It's wrong.

Every single successful remaining RISC architecture learnt from their
mistakes. That should tell you something.

It should tell you that the people who tried to teach you that
unaligned reads were bad were charlatans.

It's *much* better to do unaligned reads in software and let hardware
sort it out than to try to actively avoid them.

On x86, unaligned reads have never even been expensive (except back in
the dark days when people started doing vector extensions and got them
wrong - those people learnt their lesson too).

And on other architectures, that historically got this wrong (ARM got
it *really* wrong originally), sanity eventually prevailed. So there
isn't a single relevant architecture left where it would make sense to
do extra work in order to only do aligned reads.

The whole "unaligned reads are bad" ship sailed long ago, and it sank.
Let is be.

                    Linus
