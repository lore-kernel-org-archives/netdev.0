From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC v2 net-next 10/16] bpf: add eBPF verifier
Date: Tue, 12 Aug 2014 12:32:31 -0700
Message-ID: <CALCETrUDb6kLH_Qp=YMm=m3P_hmEu3dfDTse=ptCsdpO9EEcAQ@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
 <1405657206-12060-11-git-send-email-ast@plumgrid.com> <CALCETrUt1yLXTt5pDZJd0s4s+4dhs0LB7tbJYd6p1+EbdNWw7w@mail.gmail.com>
 <CAMEtUuygJoH+PBNksTwRHyRObCZixoTDFzmnHroErZHZLaGNbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
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
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuygJoH+PBNksTwRHyRObCZixoTDFzmnHroErZHZLaGNbg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 24, 2014 at 12:25 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Thu, Jul 24, 2014 at 11:25 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> On Thu, Jul 17, 2014 at 9:20 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>> Safety of eBPF programs is statically determined by the verifier, which detects:
>>> - loops
>>> - out of range jumps
>>> - unreachable instructions
>>> - invalid instructions
>>> - uninitialized register access
>>> - uninitialized stack access
>>> - misaligned stack access
>>> - out of range stack access
>>> - invalid calling convention
>>
>> Is there something that documents exactly what conditions an eBPF
>> program must satisfy in order to be considered valid?
>
> I did a writeup in the past on things that verifiers checks and gave it
> to internal folks to review. Guys have said that now they understand very
> well how it works, but in reality it didn't help at all to write valid programs.
> What worked is 'verification trace' = the instruction by instruction dump
> of verifier state while it's analyzing the program.
> I gave few simple examples of it in
> 'Understanding eBPF verifier messages' section:
> https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/diff/Documentation/networking/filter.txt?id=b22459133b9f52d2176c8c0f8b5eb036478a40c9
> Every example there is what "program must satisfy to be valid"...
>
> Therefore I'm addressing two things:
> 1. how verifier works and what it checks for.
>   that is described in 'eBPF verifier' section of the doc and
>   in 200 lines of comments inside verifier.c

That doc is pretty good.  I'll try to read it carefully soon.  Sorry
for the huge delay here -- I've been on vacation.

--Andy

> 2. how to write valid programs
>  that's more important one, since it's a key to happy users.
>  'verification trace' is the first step. I'm planning to add debug info and
>  user space tool that points out to line in C instead of assembler trace.
>  In other words to bring errors to user as early as possible during
>  compilation process.
>  This is not a concern when programs are written in assembler,
>  since the programs will be much shorter and thought through by
>  the author. However I don't think there will be too many users
>  willing to understand ebpf assembler.
>
> I suspect you're more concerned about #1 at this point whereas
> I'm concerned about #2.



-- 
Andy Lutomirski
AMA Capital Management, LLC
