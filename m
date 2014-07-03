From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Wed, 2 Jul 2014 17:01:24 -0700
Message-ID: <CAMEtUuw0y+r4v8vFBy=-idhe_tDDga34siF7+SCgRD+H-qamtg@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<CA+ZOOTODDPN=6SECq1uPPD7AGP1zgBJ+bfYaX9o3YhnaCTiHYQ@mail.gmail.com>
	<CAMEtUuxfrAUDDQVGNsNV2PeDii-6LAwQCbB2XGEHTJDwkkvyWg@mail.gmail.com>
	<CA+ZOOTM9KkOYJ5Nf25_x1fT+f76xMsdJRkqjYaABiNK9y3FNXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+ZOOTM9KkOYJ5Nf25_x1fT+f76xMsdJRkqjYaABiNK9y3FNXA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 2, 2014 at 4:35 PM, Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Jul 2, 2014 at 4:04 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>> +       reg = regs + BPF_REG_1; /* 1st arg to a function */
>>>> +       reg->ptr = PTR_TO_CTX;
>>> Wait, doesn't this depend on doing "BPF_MOV64_REG(BPF_REG_CTX,
>>> BPF_REG_ARG1)" (the bpf-to-ebpf prologue), which is only enforced on
>>> filters converted from bpf? In fact, shouldn't this set
>>> regs[BPF_REG_CTX] instead of regs[BPF_REG_1] ?
>>
>> nope. it's REG_1.
>> as you said r6=r1 is only emitted by converted classic filters.
>> Verifier will see this 'r6=r1' assignment and will copy the r1 type into r6.
> You're right. I read BPF_MOV64_REG() AT&T-syntax-style.
>
> BTW, check_stack_write() in kernel/bpf/verifier.c has a couple of
> assignments of a slot->ptr to 0 (instead of INVALID_PTR). I assume
> this is unintended.

yes. good catch. Will fix it.
Too bad C compiler silently casts integers to enums
