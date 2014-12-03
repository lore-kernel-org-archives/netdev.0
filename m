From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH v2 net] bpf: x86: fix epilogue generation for eBPF programs
Date: Tue, 2 Dec 2014 22:38:04 -0800
Message-ID: <CABg9mcso+YeS-sgAQmAu6MvsfNnzrKYuUG8m+WYJmxdaxbGmPA@mail.gmail.com>
References: <1417301173-23691-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417301173-23691-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Sat, Nov 29, 2014 at 2:46 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> classic BPF has a restriction that last insn is always BPF_RET.
> eBPF doesn't have BPF_RET instruction and this restriction.
> It has BPF_EXIT insn which can appear anywhere in the program
> one or more times and it doesn't have to be last insn.

Just to confirm, in valid eBPF, BPF_EXIT *must* be present at least
once, correct?
Does an eBPF JIT implementation need to check for it?

> Fix eBPF JIT to emit epilogue when first BPF_EXIT is seen
> and all other BPF_EXIT instructions will be emitted as jump.
>
> Since jump offset to epilogue is computed as:
> jmp_offset = ctx->cleanup_addr - addrs[i]
> we need to change type of cleanup_addr to signed to compute the offset as:
> (long long) ((int)20 - (int)30)
> instead of:
> (long long) ((unsigned int)20 - (int)30)
>
> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> Note, this bug is applicable only to native eBPF programs
> which first were introduced in 3.18, so no need for stable.
>
> arm64 JIT has the same problem, but the fix is not as trivial,
> so will be done as separate patch.

I'll cook up a patch for arm64 if you haven't already done so.
Any related test case I should run through?
