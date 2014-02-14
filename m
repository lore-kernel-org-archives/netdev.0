From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Fri, 14 Feb 2014 09:55:38 -0800
Message-ID: <CAMEtUuyZtE1hSBP5xXOjTy1sed2iV1JK8pEGQATiwmxsj+GUFw@mail.gmail.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
	<52F3670D.5090608@redhat.com>
	<CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com>
	<52FD2908.8000009@redhat.com>
	<52FD458D.6020107@redhat.com>
	<CAMEtUuwfSYr=7+_8jKryUMUTL1NE-wRV_h=PX7uKdkUebgGiPg@mail.gmail.com>
	<52FE4C0C.1090008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FE4C0C.1090008@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 14, 2014 at 9:02 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 02/14/2014 01:59 AM, Alexei Starovoitov wrote:
> ...
>>>
>>> I'm very curious, do you also have any performance numbers, e.g. for
>>>
>>> networking by taking JIT'ed/non-JIT'ed BPF filters and compare them
>>> against
>>> JIT'ed/non-JIT'ed eBPF filters to see how many pps we gain or loose e.g.
>>> for a scenario with a middle box running cls_bpf .. or some other macro/
>>> micro benchmark just to get a picture where both stand in terms of
>>> performance? Who knows, maybe it would outperform nftables engine as
>>> well? ;-) How would that look on a 32bit arch with eBPF that is 64bit?
>>
>>
>> I don't have jited/non-jited numbers, but I suspect for micro-benchmarks
>> the gap should be big. I was shooting for near native performance after
>> JIT.
>
>
> Ohh, I meant it would be interesting to see a comparison of e.g. common
> libpcap
> high-level filters that are in 32bit BPF + JIT (current code) vs 64bit BPF +
> JIT
> (new code). I'm wondering how 32bit-only archs should be handled to not
> regress
> in evaluation performance to the current code.

Agreed. If we want to rip off old bpf interpreter and replace it with old->new
converter + new bpf interpreter, the performance of it should be very close.
In grand scheme some differences are ok, since libpcap bpf filters are not hot.
So much is happening before and after that tcpdump won't notice whether
filter was jited or not. cls_bpf is a different story, though I don't know what
specific use case you have there.
Could you define a bpf micro benchmark ? cls_bpf with pktgen?

Thanks
Alexei
