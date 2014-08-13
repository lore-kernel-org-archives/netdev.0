From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Wed, 13 Aug 2014 10:34:00 -0700
Message-ID: <CAMEtUuzo6xQkhg+y0h_WEArVZi9cxVoGAcTBDcwMXza+eQGBTw@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-2-git-send-email-ast@plumgrid.com>
	<53EB2D31.8090204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53EB2D31.8090204-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 2:17 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 08/13/2014 09:57 AM, Alexei Starovoitov wrote:
>>
>> add BPF_LD_IMM64 instruction to load 64-bit immediate value into register.
>> All previous instructions were 8-byte. This is first 16-byte instruction.
>> Two consecutive 'struct bpf_insn' blocks are interpreted as single
>> instruction:
>> insn[0/1].code = BPF_LD | BPF_DW | BPF_IMM
>> insn[0/1].dst_reg = destination register
>> insn[0].imm = lower 32-bit
>> insn[1].imm = upper 32-bit
>>
>> Classic BPF has similar instruction: BPF_LD | BPF_W | BPF_IMM
>> which loads 32-bit immediate value into a register.
>>
>> x64 JITs it as single 'movabsq %rax, imm64'
>> arm64 may JIT as sequence of four 'movk x0, #imm16, lsl #shift' insn
>>
>> Note that old eBPF programs are binary compatible with new interpreter.
>>
>> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>
>
> For follow-ups on this series, can you put the actual motivation
> for this change from the cover letter into this commit log as it
> otherwise doesn't say anything clearly why it is needed. Code and
> test case looks good to me.

ok. As you saw the full explanation is long, so I opted for 'it_does_this'
commit log. In the next rev will add more reasons to this log. Sure.
