From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 23/26] samples: bpf: elf file loader
Date: Thu, 14 Aug 2014 22:56:07 -0700
Message-ID: <CAMEtUux1hK-fU6FHTU3==TW2c50Q-UHEpb=t_d3dG1A7pJM2bA@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-24-git-send-email-ast@plumgrid.com>
	<CAE40pddG1e3Q8OZ8t5QQimGhHzS5FbqK3YuvKnFywEEoSUbGzQ@mail.gmail.com>
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
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAE40pddG1e3Q8OZ8t5QQimGhHzS5FbqK3YuvKnFywEEoSUbGzQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2014 at 12:29 PM, Brendan Gregg
<brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> [...]
>> +static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
>> +{
>> +       int fd, event_fd, err;
>> +       char fmt[32];
>> +       char path[256] = DEBUGFS;
>> +
>> +       fd = bpf_prog_load(BPF_PROG_TYPE_TRACING_FILTER, prog, size, license);
>> +
>> +       if (fd < 0) {
>> +               printf("err %d errno %d\n", fd, errno);
>> +               return fd;
>> +       }
>
> Minor suggestion: since this is sample code, I'd always print the bpf
> log after this this printf() error message:
>
> printf("%s", bpf_log_buf);
>
> Which has helped me debug my eBPF programs, as will be the case for
> anyone hacking on the examples.

Good point. Will do in V5.

> Or have a function for logdie(), if
> the log buffer may be populated with useful messages from other error
> paths as well.

This log buffer is an optional buffer that eBPF verifier is using to
store its messages. Mainly for humans to understand why verifier
rejected the program. It's also used by verifier testsuite to check
that reject reason actually matches the test intent.
