From: Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Thu, 29 Jan 2015 21:35:44 +0900
Message-ID: <CAM9d7chgjWh6CyTiNHJX+kWbk29ANEHWSPgY4ga3BpkFbPwgiQ@mail.gmail.com>
References: <CAMEtUuzSDYYWneoTy9=AmMa9=x4owWbWsXod=Do54+yj4Je3=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzSDYYWneoTy9=AmMa9=x4owWbWsXod=Do54+yj4Je3=Q@mail.gmail.com>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 29, 2015 at 4:04 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Wed, Jan 28, 2015 at 10:41 PM, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>
>> I think it's not a problem of bpf.  An user process can be killed
>> anytime while it enabed events without bpf.  The only thing it should
>> care is the auto-unload IMHO.
>
> ok. I think it does indeed make sense to decouple the logic.
> We can add 'auto_enable' file to achieve desired Ctrl-C behavior.
> While the 'auto_enable' file is open the event will be enabled
> and writes to 'enable' file will be ignored.
> As soon as file closes, the event is auto-disabled.
> Then user space will use 'bpf' file to attach/auto-unload
> and 'auto_enable' file together.
> Seem there would be a use for such 'auto_enable'
> without bpf as well.

Why do you want such an 'auto_enable' feature?  I guess it's enough
just to keep an event in the soft-disabled state and run a bpf program
before the check.


>
>> I'm okay for not calling bpf program in NMI but not for disabling events.
>>
>> Suppose an user was collecting an event (including in NMI) and then
>> [s]he also wanted to run a bpf program.  So [s]he wrote a program
>> always return 1.  But after attaching the program, it didn't record
>> the event in NMI..  Isn't that a problem?
>
> ok, I think 'if (in_nmi()) return 1;' will work then, right?
> Or you're thinking something else ?

Nope, returning 1 would be okay..


>
>> Right.  I think bpf programs belong to a user process but events are
>> global resource.  Maybe you also need to consider attaching bpf
>> program via perf (ioctl?) interface..
>
> yes. I did. Please see my reply to Masami.
> ioctl only works for tracepoints.

What was the problem of kprobes then? :)

Thanks,
Namhyung
