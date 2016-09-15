From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Wed, 14 Sep 2016 21:00:56 -0700
Message-ID: <20160915040054.GA65308@ast-mbp.thefacebook.com>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
 <57D9CB25.1010103@digikod.net>
 <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
 <20160915021940.GA65119@ast-mbp.thefacebook.com>
 <CALCETrWXjJZZRj5XvDQ+-Grue+b4MW2TFKsfgYYFYoFBFVH71g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWXjJZZRj5XvDQ+-Grue+b4MW2TFKsfgYYFYoFBFVH71g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 07:27:08PM -0700, Andy Lutomirski wrote:
> >> >
> >> > This RFC handle both cgroup and seccomp approaches in a similar way. I
> >> > don't see why building on top of cgroup v2 is a problem. Is there
> >> > security issues with delegation?
> >>
> >> What I mean is: cgroup v2 delegation has a functionality problem.
> >> Tejun says [1]:
> >>
> >> We haven't had to face this decision because cgroup has never properly
> >> supported delegating to applications and the in-use setups where this
> >> happens are custom configurations where there is no boundary between
> >> system and applications and adhoc trial-and-error is good enough a way
> >> to find a working solution.  That wiggle room goes away once we
> >> officially open this up to individual applications.
> >>
> >> Unless and until that changes, I think that landlock should stay away
> >> from cgroups.  Others could reasonably disagree with me.
> >
> > Ours and Sargun's use cases for cgroup+lsm+bpf is not for security
> > and not for sandboxing. So the above doesn't matter in such contexts.
> > lsm hooks + cgroups provide convenient scope and existing entry points.
> > Please see checmate examples how it's used.
> >
> 
> To be clear: I'm not arguing at all that there shouldn't be
> bpf+lsm+cgroup integration.  I'm arguing that the unprivileged
> landlock interface shouldn't expose any cgroup integration, at least
> until the cgroup situation settles down a lot.

ahh. yes. we're perfectly in agreement here.
I'm suggesting that the next RFC shouldn't include unpriv
and seccomp at all. Once bpf+lsm+cgroup is merged, we can
argue about unpriv with cgroups and even unpriv as a whole,
since it's not a given. Seccomp integration is also questionable.
I'd rather not have seccomp as a gate keeper for this lsm.
lsm and seccomp are orthogonal hook points. Syscalls and lsm hooks
don't have one to one relationship, so mixing them up is only
asking for trouble further down the road.
If we really need to carry some information from seccomp to lsm+bpf,
it's easier to add eBPF support to seccomp and let bpf side deal
with passing whatever information. 
