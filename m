From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 17:40:53 -0800
Message-ID: <CALCETrUc-iDUT8isKc43PPZ3xz31Sz+QTU+_SQQTAsWhH+zkLw@mail.gmail.com>
References: <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <20161219.203422.500916400463091702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161219.203422.500916400463091702.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 5:34 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon, 19 Dec 2016 16:02:56 -0800
>
>> huh? 'not right api' because it's using bpf syscall instead
>> of cgroup control-file? I think the opposite is the truth.
>
> I completely agree with Alexei on this.

So what happens when someone adds another type of filter?  Let's say
there's a simple, no-privilege-required list of allowed address
families that can hook up to the socket creation hook for a cgroup.
Does BPF_PROG_DETACH still detach it?  Or would both the bpf *and* the
list of allowed address families be in force?  If the latter, why
wouldn't two BPF programs on the same hook be allowed?

Concretely:

# mkdir /cgroup/a
# set_up_bpf_socket_rule /cgroup/a
# set_up_list_of_address_families /cgroup/a
# cat /cgroup/a/some_new_file [what gets displayed?]
# BPF_PROG_DETACH: what happens

By the way, even if Alexei is right, the BPF_PROG_DETACH API doesn't
even take a reference to a BPF program as an argument.  What is it
supposed to do if this mechanism ever gets extended?

--Andy
