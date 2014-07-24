From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v2 net-next 13/16] tracing: allow eBPF programs to be
 attached to events
Date: Wed, 23 Jul 2014 17:06:15 -0700
Message-ID: <CAMEtUuy__c2Av1AtWNa5ksH5if3FmhYZ2AnzTYcaAVXrpc4J1A@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-14-git-send-email-ast@plumgrid.com>
	<CAGXu5jJyw19h0+AwZEWSJt7hGnkRHAsf8fYim=XLzA-LH=svjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
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
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGXu5jJyw19h0+AwZEWSJt7hGnkRHAsf8fYim=XLzA-LH=svjw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 4:46 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>>
>> eBPF programs can call in-kernel helper functions to:
>> - lookup/update/delete elements in maps
>> - memcmp
>> - trace_printk
>> - load_pointer
>> - dump_stack
>
> Ah, this must be the pointer leaking you mentioned. :)
>
>
> Can the existing tracing mechanisms already expose kernel addresses? I
> suspect "yes". So I guess existing limitations on tracing exposure
> should already cover access control here? (I'm trying to figure out if
> a separate CONFIG is needed -- I don't think so: nothing "new" is
> exposed via eBPF, is that right?)

correct. through debugfs/tracing the whole kernel is already exposed.
Idea of eBPF for tracing is to give kernel developers and performance
engineers a tool to analyze what kernel is doing by writing programs
in C and attaching them to kprobe/tracepoint events, so it's definitely
for root only.
