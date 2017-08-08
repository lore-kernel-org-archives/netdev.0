From: Joel Fernandes <joelaf@google.com>
Subject: Re: [PATCH RFC v2 3/5] samples/bpf: Fix inline asm issues building
 samples on arm64
Date: Mon, 7 Aug 2017 18:20:49 -0700
Message-ID: <CAJWu+orPBSozHo6PDnvg9+RzmYVO=rwwNZk45kHFsBJmy-3A-Q@mail.gmail.com>
References: <20170807130602.31785-1-joelaf@google.com> <20170807130602.31785-4-joelaf@google.com>
 <20170807.112840.395506747161262549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Chenbo Feng <fengc@google.com>,
        Alison Chaiken <alison@she-devel.com>,
        Juri Lelli <Juri.Lelli@arm.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "open list:BPF (Safe dynamic programs and tools)"
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807.112840.395506747161262549.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Mon, Aug 7, 2017 at 11:28 AM, David Miller <davem@davemloft.net> wrote:
>
> Please, no.

Sorry you dislike it, I had intentionally marked it as RFC as its an
idea I was just toying with the idea and posted it early to get
feedback.

>
> The amount of hellish hacks we are adding to deal with this is getting
> way out of control.

I agree with you that hellish hacks are being added which is why it
keeps breaking. I think one of the things my series does is to add
back inclusion of asm headers that were previously removed (that is
the worst hellish hack in my opinion that existing in mainline). So in
that respect my patch is an improvement and makes it possible to build
for arm64 platforms (which is currently broken in mainline).

>
> BPF programs MUST have their own set of asm headers, this is the
> only way to get around this issue in the long term.

Wouldn't that break scripts or bpf code that instruments/trace arch
specific code?

>
> I am also strongly against adding -static to the build.

I can drop -static if you prefer, that's not an issue.

As I understand it, there are no other cleaner alternatives and this
patchset makes the samples work. I would even argue that's its more
functional than previous attempts and fixes something broken in
mainline in a more generic way. If you can provide an example of where
my patchset may not work, I would love to hear it. My whole idea was
to do it in a way that makes future breakage not happen. I don't think
that leaving things broken in this state for extended periods of time
makes sense and IMHO will slow usage of bpf samples on other
platforms.

thanks,

-Joel
