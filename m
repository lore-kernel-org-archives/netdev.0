From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Wed, 13 Aug 2014 09:08:24 -0700
Message-ID: <CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com> <1407916658-8731-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> add BPF_LD_IMM64 instruction to load 64-bit immediate value into register.
> All previous instructions were 8-byte. This is first 16-byte instruction.
> Two consecutive 'struct bpf_insn' blocks are interpreted as single instruction:
> insn[0/1].code = BPF_LD | BPF_DW | BPF_IMM
> insn[0/1].dst_reg = destination register
> insn[0].imm = lower 32-bit
> insn[1].imm = upper 32-bit

This might be unnecessarily difficult for fancy static analysis tools
to reason about.  Would it make sense to assign two different codes
for this?  For example, insn[0].code = code_for_load_low,
insns[1].code = code_for_load_high, along with a verifier check that
they come in matched pairs and that code_for_load_high isn't a jump
target?

(Something else that I find confusing about eBPF: the instruction
mnemonics are very strange.  Have you considered giving them real
names?  For example, load.imm.low instead of BPF_LD | BPF_DW | BPF_IMM
is easier to read and pronounce.)

--Andy
