From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH v6 net-next 1/6] net: filter: add "load 64-bit immediate"
 eBPF instruction
Date: Mon, 25 Aug 2014 18:38:28 -0700
Message-ID: <CALCETrVgSXuRG_ZPXQt55ze7pHOCezU4Ev1KFUww6Yqk4JACgg@mail.gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
 <1409014858-1410-2-git-send-email-ast@plumgrid.com> <20140825.180621.1003932711320755950.davem@davemloft.net>
 <CAMEtUuxdQpkX8t1_szde=Q1ALcp5t7rRyK+zEDafj27_J2LzVg@mail.gmail.com>
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
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuxdQpkX8t1_szde=Q1ALcp5t7rRyK+zEDafj27_J2LzVg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 25, 2014 at 6:35 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Mon, Aug 25, 2014 at 6:06 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>> Date: Mon, 25 Aug 2014 18:00:53 -0700
>>
>>> add BPF_LD_IMM64 instruction to load 64-bit immediate value into a register.
>>
>> I think you need to rethink this.
>>
>> I understand that you want to be able to compile arbitrary C code into
>> eBPF, but you have to restrict strongly what data the eBPF code can get
>> to.
>
> I believe verifier already does restrict it. I don't see any holes in
> the architecture. I'm probably not explaining it clearly though :(
>
>> Arbitrary pointer loads is asking for trouble.
>
> Of course.
> There is no arbitrary pointer from user space.
> Verifier checks all pointers.
> I guess this commit log description is confusing.
> It says:
> BPF_LD_IMM64(R1, const_imm_map_ptr)
> that's what appears in the program _after_ it goes through verifier.
> User space cannot pass a pointer into the kernel.

If you don't intend for userspace to load a program that contains this
instruction, then why does it need to be an instruction that the
verifier rewrites?  Why not have an instruction "load immediate
relocated pointer" that contains a reference to a relocation table and
have the JIT do it?  That might be easier to understand than having
the verifier do it, and it'll avoid committing to ABIs before we need
them.

--Andy
