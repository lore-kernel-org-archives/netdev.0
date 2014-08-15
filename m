From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 17/26] tracing: allow eBPF programs to be
 attached to events
Date: Fri, 15 Aug 2014 12:32:41 -0700
Message-ID: <CALCETrUXeBSv6KbsPC+kHTAbAB2B8T3rk5N-OOZvCPU8fOr5Ew@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
 <1407916658-8731-18-git-send-email-ast@plumgrid.com> <CALCETrV7vO6r--G2ns+A6qmDQYSzNXeemT=x41EF+XWmayM95g@mail.gmail.com>
 <CAMEtUuzCyxdOo+yYYZfDPRAu2yeQOw8TbUABwU-HD0+78PnV7A@mail.gmail.com>
 <CALCETrUQN=vt3EUO=jNFC+sDHAiJdNyZWg4rwiEF7WKjPLi8Bg@mail.gmail.com>
 <CAMEtUuyDJeEJjzsZemFLT_y_QJ+vnJjze=KOxV+7g58Tsf4cTw@mail.gmail.com>
 <CALCETrW4Yscrte9=_ks_1BhSE9FTe-KZTv_a=g5wrwKhKkiuow@mail.gmail.com> <CAMEtUuzDxzPHsch24U_NjX23r6BvmK9b723HHJeNwQOJeA8r1A@mail.gmail.com>
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
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzDxzPHsch24U_NjX23r6BvmK9b723HHJeNwQOJeA8r1A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2014 at 12:29 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Fri, Aug 15, 2014 at 12:20 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>>
>>>> I don't think that fixing this should be a prerequisite for merging,
>>>> since the risk is so small.  Nonetheless, it would be nice.  (This
>>>> family of attacks has lead to several root vulnerabilities in the
>>>> past.)
>>>
>>> Ok. I think keeping a track of pid between open and write is kinda
>>> ugly.
>>
>> Agreed.
>>
>> TBH, I would just add a comment to the open implementation saying
>> that, if unprivileged or less privileged open is allowed, then this
>> needs to be fixed.
>
> ok. will do.
>
>>> Should we add some new CAP flag and check it for all file
>>> ops? Another option is to conditionally make open() of tracing
>>> files as cloexec...
>>
>> That won't help.  The same attack can be done with SCM_RIGHTS, and
>> cloexec can be cleared.
>
> ouch, can we then make ebpf FDs and may be debugfs FDs
> not passable at all? Otherwise it feels that generality and
> flexibility of FDs is becoming a burden.

I'm not sure there's much of a general problem.  The issue is when
there's an fd for which write(2) (or other
assumed-to-not-check-permissions calls like read, pread, pwrite, etc)
depend on context.  This is historically an issue for netlink and
various /proc files.

--Andy
