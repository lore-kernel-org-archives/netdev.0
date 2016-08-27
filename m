From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Sat, 27 Aug 2016 11:11:55 -0700
Message-ID: <20160827181153.GB38754@ast-mbp.thefacebook.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <CALCETrVK1yQw=8ckLn3dcB4LuKft0NOrvQFoyFRs98ON00WgBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Network Development <netdev@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Daniel Mack <daniel@zonque.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVK1yQw=8ckLn3dcB4LuKft0NOrvQFoyFRs98ON00WgBw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 27, 2016 at 12:30:36AM -0700, Andy Lutomirski wrote:
> > cgroup is the common way to group multiple tasks.
> > Without cgroup only parent<->child relationship will be possible,
> > which will limit usability of such lsm to a master task that controls
> > its children. Such api restriction would have been ok, if we could
> > extend it in the future, but unfortunately task-centric won't allow it
> > without creating a parallel lsm that is cgroup based.
> > Therefore I think we have to go with cgroup-centric api and your
> > application has to use cgroups from the start though only parent-child
> > would have been enough.
> > Also I don't think the kernel can afford two bpf based lsm. One task
> > based and another cgroup based, so we have to find common ground
> > that suits both use cases.
> > Having unprivliged access is a subset. There is no strong reason why
> > cgroup+lsm+bpf should be limited to root only always.
> > When we can guarantee no pointer leaks, we can allow unpriv.
> 
> I don't really understand what you mean.  In the context of landlock,
> which is a *sandbox*, can one of you explain a use case that
> materially benefits from this type of cgroup usage?  I haven't thought
> of one.

In case of seccomp-like sandbox where parent controls child processes
cgroup is not needed. It's needed when container management software
needs to control a set of applications. If we can have one bpf-based lsm
that works via cgroup and without, I'd be fine with it. Right now
I haven't seen a plausible proposal to do that. Therefore cgroup based
api is a common api that works for sandbox as well, though requiring
parent to create a cgroup just to control a single child is cumbersome.
