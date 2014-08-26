From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v6 net-next 1/6] net: filter: add "load 64-bit immediate"
 eBPF instruction
Date: Mon, 25 Aug 2014 19:02:52 -0700
Message-ID: <CAMEtUuxq1t_G1bvrzJQLDj0+E9g3U4ASqzijpG+EL409+i6+7g@mail.gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
	<1409014858-1410-2-git-send-email-ast@plumgrid.com>
	<20140825.180621.1003932711320755950.davem@davemloft.net>
	<CAMEtUuxdQpkX8t1_szde=Q1ALcp5t7rRyK+zEDafj27_J2LzVg@mail.gmail.com>
	<CALCETrVgSXuRG_ZPXQt55ze7pHOCezU4Ev1KFUww6Yqk4JACgg@mail.gmail.com>
	<CAMEtUuwz9MEei+tjWx4Fv8cK_zc9TKVbWxQEAE+yWvxRMa793g@mail.gmail.com>
	<CALCETrWLvjt_D2B2sYoQtXeU1_9-005BfPcuYDKp75GbPk68dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrWLvjt_D2B2sYoQtXeU1_9-005BfPcuYDKp75GbPk68dQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 25, 2014 at 6:54 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Mon, Aug 25, 2014 at 6:53 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> On Mon, Aug 25, 2014 at 6:38 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>> On Mon, Aug 25, 2014 at 6:35 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>> On Mon, Aug 25, 2014 at 6:06 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>>>>> From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>>>>> Date: Mon, 25 Aug 2014 18:00:53 -0700
>>>>>
>>>>>> add BPF_LD_IMM64 instruction to load 64-bit immediate value into a register.
>>>>>
>>>>> I think you need to rethink this.
>>>>>
>>>>> I understand that you want to be able to compile arbitrary C code into
>>>>> eBPF, but you have to restrict strongly what data the eBPF code can get
>>>>> to.
>>>>
>>>> I believe verifier already does restrict it. I don't see any holes in
>>>> the architecture. I'm probably not explaining it clearly though :(
>>>>
>>>>> Arbitrary pointer loads is asking for trouble.
>>>>
>>>> Of course.
>>>> There is no arbitrary pointer from user space.
>>>> Verifier checks all pointers.
>>>> I guess this commit log description is confusing.
>>>> It says:
>>>> BPF_LD_IMM64(R1, const_imm_map_ptr)
>>>> that's what appears in the program _after_ it goes through verifier.
>>>> User space cannot pass a pointer into the kernel.
>>>
>>> If you don't intend for userspace to load a program that contains this
>>> instruction, then why does it need to be an instruction that the
>>> verifier rewrites?  Why not have an instruction "load immediate
>>
>> user space use _pseudo_ bpf_ld_imm64 instruction.
>> _pseudo_ stands for using 'map_fd' as imm instead of pointer.
>>
>>> relocated pointer" that contains a reference to a relocation table and
>>
>> Andy, I guess you missed explanation in:
>> https://lkml.org/lkml/2014/8/13/111
>> "
>> Obviously user space doesn't know what kernel map pointer is associated
>> with process-local map-FD.
>> So it's using pseudo BPF_LD_IMM64 instruction.
>> BPF_LD_IMM64 with src_reg == 0 -> generic move 64-bit immediate into dst_reg
>> BPF_LD_IMM64 with src_reg == BPF_PSEUDO_MAP_FD -> mov map_fd into dst_reg
>> Other values are reserved for now. (They will be used to implement
>> global variables, strings and other constants and per-cpu areas in the future)
>> So the programs look like:
>>   BPF_LD_MAP_FD(BPF_REG_1, process_local_map_fd),
>>   BPF_CALL(BPF_FUNC_map_lookup_elem),
>> eBPF verifier scans the program for such pseudo instructions, converts
>> process_local_map_fd -> in-kernel map pointer
>> and drops 'pseudo' flag of BPF_LD_IMM64 instruction.
>> "
>
> Will a program that uses BPF_LD_IMM64 w/o the FPG_REG_1 thing be accepted?

If you mean the program like:
BPF_LD_IMM64(BPF_REG_1, 0xdead),
BPF_CALL(BPF_FUNC_map_lookup_elem),
yes, it will be rejected, because type of R1 will not match
map_lookup() argument
constraints.
See check_ld_imm() in verifier.c where it assigns the type during verification.
There are 5 tests in verifier testsuite that test things around bpf_ld_imm64
and 2 tests around _pseudo_ bpf_ld_imm64.
