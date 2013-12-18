From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 18 Dec 2013 11:32:21 +0100
Message-ID: <CAMuHMdXHiKe6fjEHu0GrSVMAmvKuX9wOUdC2MW3uSjRAU5tnWA@mail.gmail.com>
References: <20131218125643.8ff140371e1f8c306327d354@canb.auug.org.au>
	<20131217.212145.893665929052097867.davem@davemloft.net>
	<20131217.213033.1019416869378407851.davem@davemloft.net>
	<CAMuHMdUi4GQYR2p7enikEkTq1s-5YwirTzmo_tS0JwiE=dVmYw@mail.gmail.com>
	<20131218101523.GP13532@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ffusco@redhat.com, dborkman@redhat.com, tgraf@redhat.com,
	Joe Perches <joe@perches.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131218101523.GP13532@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 18, 2013 at 11:15 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Wed, Dec 18, 2013 at 09:33:47AM +0100, Geert Uytterhoeven wrote:
>> On Wed, Dec 18, 2013 at 3:30 AM, David Miller <davem@davemloft.net> wrote:
>> > diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
>> > index f01fb50..a73a8e2 100644
>> > --- a/arch/alpha/include/asm/Kbuild
>> > +++ b/arch/alpha/include/asm/Kbuild
>> > @@ -4,3 +4,4 @@ generic-y += clkdev.h
>> >  generic-y += exec.h
>> >  generic-y += trace_clock.h
>> >  generic-y += preempt.h
>> > +generic-y += hash.h
>>
>> Please keep them sorted.
>>
>> Yes, Peter violated that too, when adding preempt.h.
>
> So what I did was something like:
>
> for i in arch/*/include/asm/Kbuild
> do
>         echo "generic-y += preempt.h" >> $i
> done
>
> Whoever is going to hand edit all gazillion archs for changes like that?

So we need a script for that (adding Joe), that adds the "generic-y += ..."
line to all architectures that don't have it yet, and don't provide their
own version.

> And sort(1) is annoying in that it doesn't do in-place sort; you'll end
> up with empty files if you try the naive thing.
>
> Worse most of those Kbuild files include other random garbage, which
> makes automated sorting harder still.
>
> So unless there's a sane and easy way to keep it sorted; I'm going to
> ignore that rule.

Not keeping them sorted causes merge conflicts and duplicate/missing
entries.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
