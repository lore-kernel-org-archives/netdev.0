From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Fri, 3 Feb 2017 13:07:39 -0800
Message-ID: <CALCETrVQyzoCDV5u_mui7KKCwLZ4+gJQFpjvz3XuNtvVTOqRcQ@mail.gmail.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org> <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
 <20170119005925.GA18554@mtj.duckdns.org> <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg@mail.gmail.com>
 <20170120023907.GA3294@ast-mbp.thefacebook.com> <CALCETrV6NArtFa89iW+QO3udxpJYpMXLbOEk6ZYyWsw7oZDS2Q@mail.gmail.com>
 <20170123043154.GA93519@ast-mbp.thefacebook.com> <CALCETrXK65itdDqYTdhB-Td8d-Hzj00dcDScUOUh9psCZN_cLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXK65itdDqYTdhB-Td8d-Hzj00dcDScUOUh9psCZN_cLA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 23, 2017 at 12:20 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Sun, Jan 22, 2017 at 8:31 PM, Alexei Starovoitov
> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Thu, Jan 19, 2017 at 08:04:59PM -0800, Andy Lutomirski wrote:
>>> restricting the types of sockets that can be created, then you do want
>>> the filter to work across namespaces, but seccomp can do that too and
>>> the current code doesn't handle netns correctly.
>>
>> are you saying that seccomp supports netns filtering? please show the proof.
>
> It can trivially restruct the types of sockets that are created by
> filtering on socket(2) syscall parameters, at least on sane
> architectures that don't use socketcall().

I think this is actually wrong -- the socket creation filter appears
to be called only on inet sockets.  Is there a good reason for that?

>
>> To summarize, I think the 'prog override is not allowed' flag would be
>> ok feature to have and I wouldn't mind making it the default when no 'flag'
>> field is passed to bpf syscall, but it's not acceptable to remove current
>> 'prog override is allowed' behavior.
>> So if you insist on changing the default, please implement the flag asap.
>> Though from security point of view and ABI point of view there is absolutely
>> no difference whether this flag is added today or a year later while
>> the default is kept as-is.
>
> It's too late and I have too little time.  I'll try to write a patch
> to change the default to just deny attempts to override.  Better
> behavior can be added later.
>
> IMO your suggestions about priorities are overcomplicated.  For your
> instrumentation needs, I can imagine that a simple "make this hook not
> run if a descendent has a hook" would do it.  For everything else, run
> them all in tree order (depending on filter type) and let the eBPF
> code do whatever it wants to do.

Is there any plan to address this?  If not, I'll try to write that
patch this weekend.
