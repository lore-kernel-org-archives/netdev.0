From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Wed, 14 Sep 2016 21:08:57 -0700
Message-ID: <CALCETrXTS8R1E2b9mmWzpOO6QOW5nWYW_RQRJYU1CGRsbNy+Yw@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
 <57D9CB25.1010103@digikod.net> <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
 <20160915021940.GA65119@ast-mbp.thefacebook.com> <CALCETrWXjJZZRj5XvDQ+-Grue+b4MW2TFKsfgYYFYoFBFVH71g@mail.gmail.com>
 <20160915040054.GA65308@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160915040054.GA65308-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 9:00 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Sep 14, 2016 at 07:27:08PM -0700, Andy Lutomirski wrote:
>> >> >
>> >> > This RFC handle both cgroup and seccomp approaches in a similar way. I
>> >> > don't see why building on top of cgroup v2 is a problem. Is there
>> >> > security issues with delegation?
>> >>
>> >> What I mean is: cgroup v2 delegation has a functionality problem.
>> >> Tejun says [1]:
>> >>
>> >> We haven't had to face this decision because cgroup has never properly
>> >> supported delegating to applications and the in-use setups where this
>> >> happens are custom configurations where there is no boundary between
>> >> system and applications and adhoc trial-and-error is good enough a way
>> >> to find a working solution.  That wiggle room goes away once we
>> >> officially open this up to individual applications.
>> >>
>> >> Unless and until that changes, I think that landlock should stay away
>> >> from cgroups.  Others could reasonably disagree with me.
>> >
>> > Ours and Sargun's use cases for cgroup+lsm+bpf is not for security
>> > and not for sandboxing. So the above doesn't matter in such contexts.
>> > lsm hooks + cgroups provide convenient scope and existing entry points.
>> > Please see checmate examples how it's used.
>> >
>>
>> To be clear: I'm not arguing at all that there shouldn't be
>> bpf+lsm+cgroup integration.  I'm arguing that the unprivileged
>> landlock interface shouldn't expose any cgroup integration, at least
>> until the cgroup situation settles down a lot.
>
> ahh. yes. we're perfectly in agreement here.
> I'm suggesting that the next RFC shouldn't include unpriv
> and seccomp at all. Once bpf+lsm+cgroup is merged, we can
> argue about unpriv with cgroups and even unpriv as a whole,
> since it's not a given. Seccomp integration is also questionable.
> I'd rather not have seccomp as a gate keeper for this lsm.
> lsm and seccomp are orthogonal hook points. Syscalls and lsm hooks
> don't have one to one relationship, so mixing them up is only
> asking for trouble further down the road.
> If we really need to carry some information from seccomp to lsm+bpf,
> it's easier to add eBPF support to seccomp and let bpf side deal
> with passing whatever information.
>

As an argument for keeping seccomp (or an extended seccomp) as the
interface for an unprivileged bpf+lsm: seccomp already checks off most
of the boxes for safely letting unprivileged programs sandbox
themselves.  Furthermore, to the extent that there are use cases for
unprivileged bpf+lsm that *aren't* expressible within the seccomp
hierarchy, I suspect that syscall filters have exactly the same
problem and that we should fix seccomp to cover it.

If I ever add a "seccomp monitor", which is something I want to do
eventually, I think it should work for lsm+bpf as well, which is
another argument for keeping it in seccomp.

--Andy
