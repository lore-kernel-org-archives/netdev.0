From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v3 1/3] net: filter: simplify label names from jump-table
Date: Thu, 1 May 2014 12:47:02 -0700
Message-ID: <CAMEtUuwb+7NBT+PYFD5_Tw+NAdWwJ4ztiZbCpdx=gJ8nM9hJPg@mail.gmail.com>
References: <1398960996-10469-1-git-send-email-dborkman@redhat.com>
	<1398960996-10469-2-git-send-email-dborkman@redhat.com>
	<1398964810.29914.200.camel@edumazet-glaptop2.roam.corp.google.com>
	<536286E5.1080309@redhat.com>
	<1398970213.29914.211.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:57124 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbaEATrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 15:47:04 -0400
Received: by mail-wi0-f169.google.com with SMTP id hi5so1259511wib.4
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 12:47:02 -0700 (PDT)
In-Reply-To: <1398970213.29914.211.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 1, 2014 at 11:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-05-01 at 19:39 +0200, Daniel Borkmann wrote:
>
>> Well, if you review the code itself in filter.c it makes it hard
>> to read and review, with this patch, you'll immediately get the
>> label name and what it actually does, so I think it's quite convenient
>> and way more readable by itself. For grepping, you can always add
>> subdirectories you're searching for, besides that I don't think
>> that everything in the kernel needs to have unique names only so
>> that one can grep for it among the whole tree.
>
>
>
> Considering that Alexei claimed :
>
> +Internal BPF is a general purpose RISC instruction set. Not every register and
> +every instruction are used during translation from original BPF to new format.
> +For example, socket filters are not using 'exclusive add' instruction, but
> +tracing filters may do to maintain counters of events, for example. Register R9
> +is not used by socket filters either, but more complex filters may be running
> +out of registers and would have to resort to spill/fill to stack.
>
> I tried to verify this claim and I could not.

I'm not sure what part are you referring to.
That xadd is not used right now? It's not. I think we agreed on it
last week.
What else do you mean?

> After your patch, it will be really this :
>
> "We, Daniel and Alexei, hereby certify that this code is 100% safe.

I don't see where we say this.
Few paragraphs below the doc clearly says that it's a RISC instruction set
and safety on instruction set comes from verifier which is TBD.
Instruction set by itself is just an instruction set. Just like original BPF.

>  If you Eric, or anyone else, want to check, you'll have to grep in
> appropriate places, and use your brain as we did."
>
> I find very worrying all this stuff. This looks like you guys make
> everything possible to make it absolutely unmaintainable.

imo that's a harsh and unfair statement.
Calling it 'unmaintainable' just because you don't see how xadd
can be used?
I'm working on tracing filters that will demonstrate that in a bit.

This particular Daniel's patch I think is a nice cleanup.
It indeed makes interpreter code shorter, less verbose and easier to read.

I suspect you think of this internal BPF format as it's solving only
socket filters use case and all filters will be coming from user space.
That's very narrow view. In case of tracing filters there is no BPF
to send to kernel. User to kernel interface is a character string
like "a==1 || b == 2". That is the filter. I'm parsing the string
and converting it inside the kernel to internal bpf format,
so I would like to use full power of underlying cpu.
Think of internal BPF as 'uasm' that mips guys are using to construct tlb
handler on the fly.
But this 'uasm' is generic for all architectures.
Eventually we may want to expose internal bpf to user space, only then
verifier will be must have and we'll be discussing '100% safety'.
Right now everything is internal and I'm pretty sure you understood
very well how original bpf was translated to internal bpf, so I don't follow
your concern about 'unmaintainable'.

At the same time it's impossible for me to follow what you guys are
doing with tcp stack, but I'm not calling it unmaintainable just because
I don't understand it.
If you feel more documentation is needed, sure. Please let us know
what pieces are not explained well.
When I look at the doc by myself, it's hard to see what else is missing
or what pieces are difficult to grasp.

Regards,
Alexei
