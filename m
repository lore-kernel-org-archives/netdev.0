From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 17/26] tracing: allow eBPF programs to be
 attached to events
Date: Fri, 15 Aug 2014 10:51:27 -0700
Message-ID: <CAMEtUuzCyxdOo+yYYZfDPRAu2yeQOw8TbUABwU-HD0+78PnV7A@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-18-git-send-email-ast@plumgrid.com>
	<CALCETrV7vO6r--G2ns+A6qmDQYSzNXeemT=x41EF+XWmayM95g@mail.gmail.com>
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
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrV7vO6r--G2ns+A6qmDQYSzNXeemT=x41EF+XWmayM95g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2014 at 10:25 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> User interface:
>> fd = open("/sys/kernel/debug/tracing/__event__/filter")
>>
>> write(fd, "bpf_123")
>
> I didn't follow all the code flow leading to parsing the "bpf_123"
> string, but if it works the way I imagine it does, it's a security
> problem.  In general, write(2) should never do anything that involves
> any security-relevant context of the caller.
>
> Ideally, you would look up fd 123 in the file table of whomever called
> open.  If that's difficult to implement efficiently, then it would be
> nice to have some check that the callers of write(2) and open(2) are
> the same task and that exec wasn't called in between.
>
> This isn't a very severe security issue because you need privilege to
> open the thing in the first place, but it would still be nice to
> address.

hmm. you need to be root to open the events anyway.
pretty much the whole tracing for root only, since any kernel data
structures can be printed, stored into maps and so on.
So I don't quite follow your security concern here.

Even say root opens a tracepoint and does exec() of another
app that uploads ebpf program, gets program_fd and does
write into tracepoint fd. The root app that did this open() is
doing exec() on purpose. It's not like it's exec-ing something
it doesn't know about.

Remember, FDs was your idea in the first place ;)
I had global ids and everything root initially.
