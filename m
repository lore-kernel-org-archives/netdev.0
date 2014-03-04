From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v4 net-next 1/3] Extended BPF interpreter and converter
Date: Tue, 04 Mar 2014 19:23:16 +0100
Message-ID: <53161A14.3060405@redhat.com>
References: <1393910304-4004-1-git-send-email-ast@plumgrid.com> <1393910304-4004-2-git-send-email-ast@plumgrid.com> <5315A40E.6010209@redhat.com> <CAMEtUuwzo9JdcHdUvSOecmK5QD=5vcRLEE3DsLth=mxXnPOocw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuwzo9JdcHdUvSOecmK5QD=5vcRLEE3DsLth=mxXnPOocw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2014 06:09 PM, Alexei Starovoitov wrote:
> On Tue, Mar 4, 2014 at 1:59 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
...
>> Hmm, so the case statement is about BPF_RET | BPF_A and BPF_RET | BPF_K
>> but BPF_RET | BPF_X is not mentioned. However, in BPF_SRC(fp->code)
>> selection you fall back to BPF_X if it doesn't equal BPF_K? Is that
>> correct? And, you probably also need to handle BPF_RET | BPF_X ?
>
> :) that design choice of original BPF always puzzled me.
> BPF_A macro only used in one insn: BPF_RET + BPF_A
> and all other insns use BPF_K and BPF_X
> and though comment in uapi/filter.h says "ret - BPF_K and BPF_X also apply"
> this is not true, since sk_chk_filter() only allows ret+a and ret+k
> libpcap is equally confused. It never generates ret+x, but has few
> places in the code
> that can recognize it. I guess that's an artifact of distant past.

Good point, ret+a and ret+k are main users anyway, though we could fix
that limitation actually. ;)

> epbf has only one RET insn that takes register R0 and returns it.
> That is similar to real CPU 'ret' insn and done to make epbf easier
> to generate from gcc/llvm point of view.
> ebpf jit converts 'ret' into 'leave; ret' on x86_64.
>
> so original bpf+k and bpf+a are converted into 'mov r0, [a or k]; ret r0'
>
> btw, if there is interest I can put ebpf testsuite into tools/net/

Yes, please. Would be great if you can place the test suite under:

   tools/testing/selftests/net/bpf/

I believe some stuff there could get its own folder e.g. "packet"
for PF_PACKET test cases etc, so that we can easily arrange them.
