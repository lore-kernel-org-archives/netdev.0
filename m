From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 14:46:13 -0700
Message-ID: <CAMEtUuw3rmQR5v7zrhUR=jYKrhCTp+GpndHDa-9djT3nBnhsaA@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
	<CALCETrXFb=etdrabEjbKdxKg51ViPXptOC=6CkKwcGS7Jau8nA@mail.gmail.com>
	<CAMEtUuzAuX=PVDtfQiRKgO7h5wx3gsTJUajr8VKsF4FR-d=JDw@mail.gmail.com>
	<CALCETrVAQ7oRm8zDHDiUurjrMw=+ABucLWjed_P__4j8deNE7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrVAQ7oRm8zDHDiUurjrMw=+ABucLWjed_P__4j8deNE7A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 1:42 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Sep 26, 2014 at 1:09 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Fri, Sep 26, 2014 at 12:51 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> On Fri, Sep 26, 2014 at 12:34 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>
>>> To add one more point:
>>>
>>> With the current verifier design, it's impossible to write a userspace
>>> tool that can take an eBPF program and check it.  The verification is
>>> far too context-dependent for that to be possible.  I won't go so far
>>> as to say that a userspace tool needs to *exist*, but I strongly
>>> object to exposing a verification algorithm that *precludes* writing
>>> such a tool.
>>
>> that's just not true.
>> why is it not possible?
>
> Because the types of referenced objects aren't encoded in the blob
> that a user program loads, unless I'm missing something.

patch #8 'handle pseudo BPF_LD_IMM64 insn' of this set
handles first type == map. Other types will be added in the future.
The same verification can be done in user space.
It's pretty much copy paste for everything from the kernel.
I don't understand yet why you really must do it in in userspace
in addition to doing it in kernel. It's definitely doable.
Instead of asking kernel to create a map, user space
can just remember map attributes (key_size, value_size)
and continues verification in userspace.

> But the eBPF binary doesn't encode this information. In fact, the
> caller of an ebpf syscall may not even have access to this
> information.

I don't follow. What info are you talking about?
are you saying that program only that references maps via fds
is not verifiable unless one knows what this fds refer to?
yeah, but we're talking user space verification here.
user knows what maps it creates with what attributes.
Also we can add a command to this syscall to fetch map
attributes. That would be trivial _incremental_ addition, right?

> I think this is addressable as a smallish change on top of your code.
> Rather than looking up a map when you need to learn its key and value
> size, I think that all you need to do is to look in a program section
> for the key and value size (and the fact that it's a map) and confirm
> that the referenced map *matches* the stored values.

we can add extra info to the program that will encode
program assumptions about maps. Sure. Though I think
it's extra info that kernel doesn't really need, since it can
only check that program assumptions match to what
kernel already knows. Kernel cannot rely on them.
So I'm not sure what this extra check really buys.

Anyway, if you think it's a smallish change, we can do it
incrementally on top of existing stuff, right?
Why this arguing then?
Sounds like you want to help with the development?
This is great! I'm all for it :)
