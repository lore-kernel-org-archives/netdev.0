From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] bpf: allow bpf programs to tail-call other
 bpf programs
Date: Thu, 21 May 2015 18:17:07 +0200
Message-ID: <555E0503.8010302@iogearbox.net>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com> <1432079946-9878-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zi Shen Lim <zlim.lnx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432079946-9878-2-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/20/2015 01:59 AM, Alexei Starovoitov wrote:
> introduce bpf_tail_call(ctx, &jmp_table, index) helper function
> which can be used from BPF programs like:
> int bpf_prog(struct pt_regs *ctx)
> {
>    ...
>    bpf_tail_call(ctx, &jmp_table, index);
>    ...
> }
> that is roughly equivalent to:
> int bpf_prog(struct pt_regs *ctx)
> {
>    ...
>    if (jmp_table[index])
>      return (*jmp_table[index])(ctx);
>    ...
> }
> The important detail that it's not a normal call, but a tail call.
> The kernel stack is precious, so this helper reuses the current
> stack frame and jumps into another BPF program without adding
> extra call frame.
> It's trivially done in interpreter and a bit trickier in JITs.
> In case of x64 JIT the bigger part of generated assembler prologue
> is common for all programs, so it is simply skipped while jumping.
> Other JITs can do similar prologue-skipping optimization or
> do stack unwind before jumping into the next program.
>
...
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>

LGTM, thanks!

Acked-by: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
