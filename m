From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Sat, 15 Feb 2014 17:13:42 +0100
Message-ID: <52FF9236.1040205@redhat.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com> <52F3670D.5090608@redhat.com> <CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com> <52FD2908.8000009@redhat.com> <52FD458D.6020107@redhat.com> <CAMEtUuwfSYr=7+_8jKryUMUTL1NE-wRV_h=PX7uKdkUebgGiPg@mail.gmail.com> <52FE4C0C.1090008@redhat.com> <CAMEtUuyZtE1hSBP5xXOjTy1sed2iV1JK8pEGQATiwmxsj+GUFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753396AbaBOQOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Feb 2014 11:14:42 -0500
In-Reply-To: <CAMEtUuyZtE1hSBP5xXOjTy1sed2iV1JK8pEGQATiwmxsj+GUFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2014 06:55 PM, Alexei Starovoitov wrote:
> On Fri, Feb 14, 2014 at 9:02 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 02/14/2014 01:59 AM, Alexei Starovoitov wrote:
>> ...
>>>>
>>>> I'm very curious, do you also have any performance numbers, e.g. for
>>>>
>>>> networking by taking JIT'ed/non-JIT'ed BPF filters and compare them
>>>> against
>>>> JIT'ed/non-JIT'ed eBPF filters to see how many pps we gain or loose e.g.
>>>> for a scenario with a middle box running cls_bpf .. or some other macro/
>>>> micro benchmark just to get a picture where both stand in terms of
>>>> performance? Who knows, maybe it would outperform nftables engine as
>>>> well? ;-) How would that look on a 32bit arch with eBPF that is 64bit?
>>>
>>> I don't have jited/non-jited numbers, but I suspect for micro-benchmarks
>>> the gap should be big. I was shooting for near native performance after
>>> JIT.
>>
>> Ohh, I meant it would be interesting to see a comparison of e.g. common
>> libpcap
>> high-level filters that are in 32bit BPF + JIT (current code) vs 64bit BPF +
>> JIT
>> (new code). I'm wondering how 32bit-only archs should be handled to not
>> regress
>> in evaluation performance to the current code.
>
> Agreed. If we want to rip off old bpf interpreter and replace it with old->new
> converter + new bpf interpreter, the performance of it should be very close.
> In grand scheme some differences are ok, since libpcap bpf filters are not hot.
> So much is happening before and after that tcpdump won't notice whether
> filter was jited or not. cls_bpf is a different story, though I don't know what
> specific use case you have there.
> Could you define a bpf micro benchmark ? cls_bpf with pktgen?

Well, that's just one example, it's not necessarily about cls_bpf, e.g. just
a modified pktgen where skb goes through new/old BPF filters on local output
path and the remote machine queries nic counters (e.g. ifpps, an ixia box or
something else suitable). There's probably even something more simple and
suitable for comparing both, so it doesn't necessarily has to be this scenario.
It's just to have a basic comparison to see where we would stand e.g. in case
of 32/64bit architectures. Otherwise, regarding your other email, sounds like
convergence at least to _me_. Details can then still be discussed at particular
steps, but integrating this step by step into the existing architecture would
be a good start, imho.
