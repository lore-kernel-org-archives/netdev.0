From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Wed, 14 Sep 2016 19:19:41 -0700
Message-ID: <20160915021940.GA65119@ast-mbp.thefacebook.com>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
 <57D9CB25.1010103@digikod.net>
 <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Mack <daniel@zonque.org>,
	David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
	Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Linux API <linux-api@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4647-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 06:25:07PM -0700, Andy Lutomirski wrote:
> On Wed, Sep 14, 2016 at 3:11 PM, Mickaël Salaün <mic@digikod.net> wrote:
> >
> > On 14/09/2016 20:27, Andy Lutomirski wrote:
> >> On Wed, Sep 14, 2016 at 12:24 AM, Mickaël Salaün <mic@digikod.net> wrote:
> >>> Add a new flag CGRP_NO_NEW_PRIVS for each cgroup. This flag is initially
> >>> set for all cgroup except the root. The flag is clear when a new process
> >>> without the no_new_privs flags is attached to the cgroup.
> >>>
> >>> If a cgroup is landlocked, then any new attempt, from an unprivileged
> >>> process, to attach a process without no_new_privs to this cgroup will
> >>> be denied.
> >>
> >> Until and unless everyone can agree on a way to properly namespace,
> >> delegate, etc cgroups, I think that trying to add unprivileged
> >> semantics to cgroups is nuts.  Given the big thread about cgroup v2,
> >> no-internal-tasks, etc, I just don't see how this approach can be
> >> viable.
> >
> > As far as I can tell, the no_new_privs flag of at task is not related to
> > namespaces. The CGRP_NO_NEW_PRIVS flag is only a cache to quickly access
> > the no_new_privs property of *tasks* in a cgroup. The semantic is unchanged.
> >
> > Using cgroup is optional, any task could use the seccomp-based
> > landlocking instead. However, for those that want/need to manage a
> > security policy in a more dynamic way, using cgroups may make sense.
> >
> > I though cgroup delegation was OK in the v2, isn't it the case? Do you
> > have some links?
> >
> >>
> >> Can we try to make landlock work completely independently of cgroups
> >> so that it doesn't get stuck and so that programs can use it without
> >> worrying about cgroup v1 vs v2, interactions with cgroup managers,
> >> cgroup managers that (supposedly?) will start migrating processes
> >> around piecemeal and almost certainly blowing up landlock in the
> >> process, etc?
> >
> > This RFC handle both cgroup and seccomp approaches in a similar way. I
> > don't see why building on top of cgroup v2 is a problem. Is there
> > security issues with delegation?
> 
> What I mean is: cgroup v2 delegation has a functionality problem.
> Tejun says [1]:
> 
> We haven't had to face this decision because cgroup has never properly
> supported delegating to applications and the in-use setups where this
> happens are custom configurations where there is no boundary between
> system and applications and adhoc trial-and-error is good enough a way
> to find a working solution.  That wiggle room goes away once we
> officially open this up to individual applications.
> 
> Unless and until that changes, I think that landlock should stay away
> from cgroups.  Others could reasonably disagree with me.

Ours and Sargun's use cases for cgroup+lsm+bpf is not for security
and not for sandboxing. So the above doesn't matter in such contexts.
lsm hooks + cgroups provide convenient scope and existing entry points.
Please see checmate examples how it's used.
