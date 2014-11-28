From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] bpf: x86: fix epilogue generation for eBPF programs
Date: Fri, 28 Nov 2014 10:39:14 +0100
Message-ID: <547842C2.4010306@redhat.com>
References: <1417064546-4129-1-git-send-email-ast@plumgrid.com> <5476F471.80500@redhat.com> <CAMEtUuyzDs2Nz8WHdEZXmY9JOZx=w2UwUF06Kq5qcgkaaRKs3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyzDs2Nz8WHdEZXmY9JOZx=w2UwUF06Kq5qcgkaaRKs3A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/28/2014 06:55 AM, Alexei Starovoitov wrote:
> On Thu, Nov 27, 2014 at 1:52 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 11/27/2014 06:02 AM, Alexei Starovoitov wrote:
>>>
>>> classic BPF has a restriction that last insn is always BPF_RET.
>>> eBPF doesn't have BPF_RET instruction and this restriction.
>>> It has BPF_EXIT insn which can appear anywhere in the program
>>> one or more times and it doesn't have to be last insn.
>>> Fix eBPF JIT to emit epilogue when first BPF_EXIT is seen
>>> and all other BPF_EXIT instructions will be emitted as jump.
>>>
>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>> ---
>>> Note, this bug is applicable only to native eBPF programs
>>> which first were introduced in 3.18, so no need to send it
>>> to stable and therefore no 'Fixes' tag.
>>
>> Btw, even if it's not sent to -stable, a 'Fixes:' tag is useful
>> information for backporting and regression tracking, preferably
>> always mentioned where it can clearly be identified.
>
> Well I didn't mention it, as I said, because I don't think it
> needs backporting. Otherwise with the tag the tools might
> pick it up automatically? Just a guess.

No, Dave selects -stable material on a case-by-case basis and bundles
it up eventually; after -net was merged, it's then pushed to -stable
by himself (see Documentation/networking/netdev-FAQ.txt +114). So the
comment below "---" is absolutely okay.

It can well be, that some people/companies cannot switch for various
reasons immediately to the next kernels, but nevertheless would like
to have a certain features included, so generally regression tracking
via 'Fixes:' tag is extremely useful/valuable. ;)

> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")

...
>> Why this type change here? This seems a bit out of context (I would
>> have expected a mention of this in the commit message, otherwise).
>
> The reason for signed is the following:
> jmp offset to epilogue is computed as:
> jmp_offset = ctx->cleanup_addr - addrs[i]
> when cleanup_addr was always last insn it wasn't a problem,
> since result of subtraction was positive.
> Now, since epilogue will be in the middle of JITed
> code the jmps to epilogue may be negative

Ok, thanks for the clarification, Alexei.
