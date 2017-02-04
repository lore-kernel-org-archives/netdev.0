From: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Sat, 4 Feb 2017 09:10:57 -0800
Message-ID: <CALCETrUWhus3givcEOLxEmKhOcYGpWnuADXTJTfbVP1HcUmQQA@mail.gmail.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org> <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
 <20170119005925.GA18554@mtj.duckdns.org> <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg@mail.gmail.com>
 <20170120023907.GA3294@ast-mbp.thefacebook.com> <CALCETrV6NArtFa89iW+QO3udxpJYpMXLbOEk6ZYyWsw7oZDS2Q@mail.gmail.com>
 <20170123043154.GA93519@ast-mbp.thefacebook.com> <CALCETrXK65itdDqYTdhB-Td8d-Hzj00dcDScUOUh9psCZN_cLA@mail.gmail.com>
 <CALCETrVQyzoCDV5u_mui7KKCwLZ4+gJQFpjvz3XuNtvVTOqRcQ@mail.gmail.com> <20170203232154.GA30114@ast-mbp.thefacebook.com>
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
In-Reply-To: <20170203232154.GA30114-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 3, 2017 at 3:21 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, Feb 03, 2017 at 01:07:39PM -0800, Andy Lutomirski wrote:
>>
>> Is there any plan to address this?  If not, I'll try to write that
>> patch this weekend.
>
> yes. I'm working on 'disallow program override' flag.
> It got stalled, because netns discussion got stalled.
> Later today will send a patch for dev_id+inode and
> will continue on the flag patch.
>

Would it make sense to try to document what your proposal does before
writing the code?  I don't yet see how to get semantics that are both
simple and sensible with a "disallow override" flag.

I *do* see how to get simple, sensible semantics with an approach
where all the programs in scope for the cgroup in question get called.
If needed, I can imagine a special "overridable" program that would
not be run if the socket in question is bound to a descendent cgroup
that also has an "overridable" program but would still let all the
normal hierarchical programs in scope get called.
